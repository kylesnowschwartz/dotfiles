#!/bin/bash

# Script to install packages on a new system - Idempotent version
# Usage: ./install_packages.sh [--server] [--desktop] [--dev] [--all] [--dry-run]
# Without arguments, installs only core packages
# This version only installs packages and starts services if they don't already exist/running

set -e  # Exit on any error

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Function to print colored messages
print_msg() {
  local color=$1
  local message=$2
  echo -e "${color}${message}${NC}"
}

# Check if running as root
if [ "$EUID" -ne 0 ]; then
  print_msg "$RED" "Please run as root (use sudo)"
  exit 1
fi

# Check OS compatibility
if ! command -v apt >/dev/null || ! grep -qE 'Debian|Ubuntu' /etc/os-release; then
  print_msg "$RED" "This script is intended for Debian/Ubuntu systems only."
  exit 1
fi

# Parse arguments
INSTALL_SERVER=0
INSTALL_DESKTOP=0
INSTALL_DEV=0
DRY_RUN=0

for arg in "$@"; do
  case $arg in
    --server)
      INSTALL_SERVER=1
      ;;
    --desktop)
      INSTALL_DESKTOP=1
      ;;
    --dev)
      INSTALL_DEV=1
      ;;
    --all)
      INSTALL_SERVER=1
      INSTALL_DESKTOP=1
      INSTALL_DEV=1
      ;;
    --dry-run)
      DRY_RUN=1
      print_msg "$YELLOW" "DRY RUN MODE: No changes will be made to your system"
      ;;
    --help)
      echo "Usage: $0 [--server] [--desktop] [--dev] [--all] [--dry-run]"
      echo "  --server    Install server packages (jellyfin, samba, etc.)"
      echo "  --desktop   Install desktop packages (gnome-tweaks, etc.)"
      echo "  --dev       Install development packages (build-essential, etc.)"
      echo "  --all       Install all packages"
      echo "  --dry-run   Show what would be installed/configured without making changes"
      exit 0
      ;;
  esac
done

# Display what will be installed
print_msg "$BLUE" "Package Installation Script (Idempotent Version)"
if [ "$DRY_RUN" -eq 1 ]; then
  print_msg "$YELLOW" "DRY RUN MODE: This will only show what would be done without making changes"
fi
echo "The following package groups will be checked/installed:"
echo "- Core packages (always checked)"
if [ "$INSTALL_SERVER" -eq 1 ]; then echo "- Server packages"; fi
if [ "$INSTALL_DESKTOP" -eq 1 ]; then echo "- Desktop packages"; fi
if [ "$INSTALL_DEV" -eq 1 ]; then echo "- Development packages"; fi
echo ""

# Function to check if a package is already installed
is_package_installed() {
  dpkg -l "$1" 2>/dev/null | grep -q "^ii"
  return $?
}

# Function to check if a service is running
is_service_running() {
  systemctl is-active --quiet "$1"
  return $?
}

# Function to manage services
manage_service() {
  local service=$1
  
  if ! is_service_running "$service"; then
    if [ "$DRY_RUN" -eq 1 ]; then
      print_msg "$YELLOW" "[DRY RUN] Would enable and start $service service"
    else
      print_msg "$BLUE" "Starting $service service..."
      systemctl enable "$service"
      systemctl start "$service"
      print_msg "$GREEN" "$service service started"
    fi
  else
    print_msg "$GREEN" "$service service is already running"
  fi
}

# Function to run commands in a temporary directory
with_temp_dir() {
  local callback=$1
  
  # Skip actual directory creation in dry run mode
  if [ "$DRY_RUN" -eq 1 ]; then
    print_msg "$YELLOW" "[DRY RUN] Would create temporary directory and execute: $callback"
    return 0
  fi
  
  local current_dir=$(pwd)
  local temp_dir=$(mktemp -d)
  
  print_msg "$BLUE" "Using temporary directory: $temp_dir"
  cd "$temp_dir" || exit 1
  
  # Call the provided function
  $callback
  local result=$?
  
  # Clean up
  cd "$current_dir" || exit 1
  rm -rf "$temp_dir"
  
  return $result
}

# Function to install Jackett
install_jackett() {
  if [ "$DRY_RUN" -eq 1 ]; then
    print_msg "$YELLOW" "[DRY RUN] Would install Jackett from GitHub to /opt/Jackett"
    print_msg "$YELLOW" "[DRY RUN] Would download from: https://github.com/Jackett/Jackett/releases/latest"
    print_msg "$YELLOW" "[DRY RUN] Would create and enable jackett.service"
    return 0
  fi
  
  print_msg "$BLUE" "Installing Jackett from GitHub..."
  with_temp_dir jackett_install_steps
  
  if [ $? -eq 0 ]; then
    print_msg "$GREEN" "Jackett installed. You can access it at http://127.0.0.1:9117"
  else
    print_msg "$RED" "Jackett installation failed"
    return 1
  fi
}

# Jackett installation steps
jackett_install_steps() {
  local JACKETT_FILE="Jackett.Binaries.LinuxAMDx64.tar.gz"
  
  # Download Jackett
  print_msg "$BLUE" "Downloading Jackett..."
  if ! wget -Nc "https://github.com/Jackett/Jackett/releases/latest/download/$JACKETT_FILE"; then
    print_msg "$RED" "Failed to download Jackett"
    return 1
  fi
  
  # Extract to /opt and set up
  print_msg "$BLUE" "Extracting Jackett to /opt..."
  if ! tar -xzf "$JACKETT_FILE" -C /opt; then
    print_msg "$RED" "Failed to extract Jackett to /opt"
    return 1
  fi
  
  if ! cd /opt/Jackett* 2>/dev/null; then
    print_msg "$RED" "Failed to find Jackett directory in /opt"
    return 1
  fi
  
  # Set correct ownership
  print_msg "$BLUE" "Setting correct ownership..."
  local REAL_USER="${SUDO_USER:-$USER}"
  if [ -z "$REAL_USER" ]; then
    REAL_USER=$(who am i | awk '{print $1}')
  fi
  
  local REAL_GROUP="$(id -gn "$REAL_USER" 2>/dev/null || echo "$(id -g "$REAL_USER")")"
  if ! chown "$REAL_USER":"$REAL_GROUP" -R "/opt/Jackett"; then
    print_msg "$RED" "Failed to set ownership on /opt/Jackett"
    return 1
  fi
  
  # Install and start service
  print_msg "$BLUE" "Installing Jackett service..."
  if ! ./install_service_systemd.sh; then
    print_msg "$RED" "Failed to install Jackett service"
    return 1
  fi
  
  manage_service "jackett.service"
  return 0
}

# Function to install only missing packages
install_packages() {
  local packages=("$@")
  local missing_packages=()
  local installed_count=0
  local skipped_count=0
  
  # Check which packages need to be installed
  for package in "${packages[@]}"; do
    if is_package_installed "$package"; then
      print_msg "$GREEN" "Package $package is already installed, skipping..."
      ((skipped_count++))
    else
      missing_packages+=("$package")
    fi
  done
  
  # Install missing packages if any
  if [ ${#missing_packages[@]} -eq 0 ]; then
    print_msg "$GREEN" "All required packages are already installed!"
  else
    if [ "$DRY_RUN" -eq 1 ]; then
      print_msg "$YELLOW" "[DRY RUN] Would install ${#missing_packages[@]} packages: ${missing_packages[*]}"
      installed_count=${#missing_packages[@]}
    else
      print_msg "$BLUE" "Installing ${#missing_packages[@]} missing packages..."
      if ! apt update; then
        print_msg "$RED" "Failed to update package lists. Continuing anyway..."
      fi
      
      for package in "${missing_packages[@]}"; do
        print_msg "$BLUE" "Installing $package..."
        if apt install -y "$package"; then
          print_msg "$GREEN" "Installed $package successfully"
          ((installed_count++))
        else
          print_msg "$RED" "Failed to install $package"
        fi
      done
    fi
  fi
  
  print_msg "$GREEN" "Package installation summary: ${installed_count} installed, ${skipped_count} already installed"
}

# Core packages (always installed)
print_msg "$BLUE" "Checking core packages..."
CORE_PACKAGES=(
  "curl"
  "git"
  "neovim"
  "bash-completion"
  "ripgrep"
  "yazi"
)

install_packages "${CORE_PACKAGES[@]}"

# Server packages
if [ "$INSTALL_SERVER" -eq 1 ]; then
  print_msg "$BLUE" "Checking server packages..."
  SERVER_PACKAGES=(
    "smbclient"
    "samba"
    "openssh-server"
    "unattended-upgrades"
    "jellyfin"
    "qbittorrent-nox"
    "wget"  # Required for Jackett installation
  )

  install_packages "${SERVER_PACKAGES[@]}"
  
  # Check if Jackett is already installed
  if [ -d "/opt/Jackett" ] && systemctl is-enabled --quiet jackett.service 2>/dev/null; then
    print_msg "$GREEN" "Jackett is already installed, skipping installation..."
  else
    install_jackett
  fi

  # Enable and start services only if needed
  print_msg "$BLUE" "Checking service status..."
  
  # Manage services
  manage_service "ssh"
  manage_service "jellyfin"
  manage_service "qbittorrent-nox"

  # Configure unattended upgrades if not already configured
  if [ ! -f "/etc/apt/apt.conf.d/20auto-upgrades" ]; then
    if [ "$DRY_RUN" -eq 1 ]; then
      print_msg "$YELLOW" "[DRY RUN] Would configure unattended-upgrades"
    else
      print_msg "$BLUE" "Configuring unattended-upgrades..."
      if ! dpkg-reconfigure -plow unattended-upgrades; then
        print_msg "$RED" "Failed to configure unattended-upgrades"
      else
        print_msg "$GREEN" "Unattended upgrades configured successfully"
      fi
    fi
  else
    print_msg "$GREEN" "Unattended upgrades already configured"
  fi

  print_msg "$GREEN" "Server setup complete!"
fi

# Desktop packages
if [ "$INSTALL_DESKTOP" -eq 1 ]; then
  print_msg "$BLUE" "Checking desktop packages..."
  DESKTOP_PACKAGES=(
    "gnome-tweaks"
    "libfuse2"
    "xclip"
  )

  install_packages "${DESKTOP_PACKAGES[@]}"
  print_msg "$GREEN" "Desktop setup complete!"
fi

# Development packages
if [ "$INSTALL_DEV" -eq 1 ]; then
  print_msg "$BLUE" "Checking development packages..."
  DEV_PACKAGES=(
    "build-essential"
    "ruby"
  )

  install_packages "${DEV_PACKAGES[@]}"
  print_msg "$GREEN" "Development setup complete!"
fi

if [ "$DRY_RUN" -eq 1 ]; then
  print_msg "$YELLOW" "DRY RUN COMPLETE: No changes were made to your system"
  print_msg "$YELLOW" "Run without --dry-run to apply the changes shown above"
else
  print_msg "$GREEN" "All selected package groups have been checked and installed as needed!"
fi

echo "You can run this script again at any time - it will only install missing components."
echo "Usage: sudo ./install_packages.sh [--server] [--desktop] [--dev] [--all] [--dry-run]"

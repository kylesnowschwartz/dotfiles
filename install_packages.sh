#!/bin/bash

# Script to install packages on a new system - Idempotent version
# Usage: ./install_packages.sh [--server] [--desktop] [--dev] [--all] [--dry-run]

set -e  # Exit on any error

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Function to print colored messages
print_msg() {
  echo -e "${1}${2}${NC}"
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
      print_msg "$YELLOW" "→ Would enable and start $service service"
    else
      systemctl enable "$service" &>/dev/null
      systemctl start "$service" &>/dev/null
      print_msg "$GREEN" "✓ Started $service service"
    fi
  else
    print_msg "$GREEN" "✓ $service already running"
  fi
}

# Function to run commands in a temporary directory
with_temp_dir() {
  local callback=$1

  # Skip actual directory creation in dry run mode
  if [ "$DRY_RUN" -eq 1 ]; then
    print_msg "$YELLOW" "→ Would download and execute: $callback"
    return 0
  fi

  local current_dir=$(pwd)
  local temp_dir=$(mktemp -d)

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
    print_msg "$YELLOW" "→ Would install Jackett from GitHub"
    return 0
  fi

  with_temp_dir jackett_install_steps

  if [ $? -eq 0 ]; then
    print_msg "$GREEN" "✓ Jackett installed (access at http://127.0.0.1:9117)"
  else
    print_msg "$RED" "✗ Jackett installation failed"
    return 1
  fi
}

# Jackett installation steps
jackett_install_steps() {
  local JACKETT_FILE="Jackett.Binaries.LinuxAMDx64.tar.gz"

  # Download and install
  wget -q "https://github.com/Jackett/Jackett/releases/latest/download/$JACKETT_FILE" || return 1
  tar -xzf "$JACKETT_FILE" -C /opt || return 1
  cd /opt/Jackett* 2>/dev/null || return 1

  # Set ownership
  local REAL_USER="${SUDO_USER:-$USER}"
  [ -z "$REAL_USER" ] && REAL_USER=$(who am i | awk '{print $1}')
  local REAL_GROUP="$(id -gn "$REAL_USER" 2>/dev/null || id -g "$REAL_USER")"
  chown "$REAL_USER":"$REAL_GROUP" -R "/opt/Jackett" || return 1

  # Install service
  ./install_service_systemd.sh &>/dev/null || return 1
  manage_service "jackett.service"
  return 0
}

# Track package status
INSTALLED_PACKAGES=""
MISSING_PACKAGES=""

# Function to install only missing packages
install_packages() {
  local group="$1"
  shift

  # Track package counts
  local to_install=""

  # Check which packages need to be installed
  for package in "$@"; do
    if is_package_installed "$package"; then
      INSTALLED_PACKAGES="$INSTALLED_PACKAGES $package"
    else
      to_install="$to_install $package"
      MISSING_PACKAGES="$MISSING_PACKAGES $package"
    fi
  done

  # Install missing packages if needed
  if [ -z "$to_install" ]; then
    print_msg "$GREEN" "✓ All $group packages installed"
  else
    if [ "$DRY_RUN" -eq 1 ]; then
      print_msg "$YELLOW" "→ Would install:$to_install"
    else
      apt update -q &>/dev/null
      for package in $to_install; do
        if apt install -y "$package" &>/dev/null; then
          print_msg "$GREEN" "✓ Installed $package"
        else
          print_msg "$RED" "✗ Failed to install $package"
        fi
      done
    fi
  fi
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

install_packages "Core" "${CORE_PACKAGES[@]}"

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

  install_packages "Server" "${SERVER_PACKAGES[@]}"

    # Check if Jackett is already installed
  if [ -d "/opt/Jackett" ] && systemctl is-enabled --quiet jackett.service 2>/dev/null; then
    print_msg "$GREEN" "✓ Jackett already installed"
  else
    install_jackett
  fi

    # Manage services
  for service in ssh jellyfin qbittorrent-nox; do
    manage_service "$service"
  done

  # Configure unattended upgrades if not already configured
  if [ ! -f "/etc/apt/apt.conf.d/20auto-upgrades" ]; then
    if [ "$DRY_RUN" -eq 1 ]; then
      print_msg "$YELLOW" "→ Would configure unattended-upgrades"
    else
      dpkg-reconfigure -plow unattended-upgrades &>/dev/null
      print_msg "$GREEN" "✓ Configured unattended-upgrades"
    fi
  else
    print_msg "$GREEN" "✓ Unattended upgrades already configured"
  fi
fi

# Desktop packages
if [ "$INSTALL_DESKTOP" -eq 1 ]; then
  print_msg "$BLUE" "Checking desktop packages..."
  DESKTOP_PACKAGES=(
    "gnome-tweaks"
    "libfuse2"
    "xclip"
  )

  install_packages "Desktop" "${DESKTOP_PACKAGES[@]}"
  print_msg "$GREEN" "Desktop setup complete!"
fi

# Development packages
if [ "$INSTALL_DEV" -eq 1 ]; then
  print_msg "$BLUE" "Checking development packages..."
  DEV_PACKAGES=(
    "build-essential"
    "ruby"
  )

  install_packages "Development" "${DEV_PACKAGES[@]}"
  print_msg "$GREEN" "Development setup complete!"
fi

# Print final summary
print_summary() {
  echo "--------------------------------------------"
  if [ -z "$MISSING_PACKAGES" ]; then
    print_msg "$GREEN" "All packages already installed!"
  else
    print_msg "$YELLOW" "Packages to install: $MISSING_PACKAGES"
  fi
}

if [ "$DRY_RUN" -eq 1 ]; then
  print_summary
  print_msg "$YELLOW" "No changes made. Run without --dry-run to install."
fi

echo "You can run this script again at any time - it will only install missing components."
echo "Usage: sudo ./install_packages.sh [--server] [--desktop] [--dev] [--all] [--dry-run]"

#!/bin/bash

# Script to set up symlinks to dotfiles
# Run from your home directory (~)

# Determine dotfiles location dynamically
# Try to get script location, but fall back to default if needed
if [ -n "$0" ] && [ "$0" != "sh" ]; then
  # If run as a script and we can determine the path
  SCRIPT_PATH="$(cd "$(dirname "$0")" && pwd)/$(basename "$0")"
  DOTFILES_DIR="$(dirname "$SCRIPT_PATH")"
else
  # Default if sourced or run in other ways
  DOTFILES_DIR="${DOTFILES_DIR:-$HOME/Code/dotfiles}"
fi

# Setup variables
BACKUP_BASE_DIR="$HOME/backups"
BACKUP_DIR="$BACKUP_BASE_DIR/dotfiles_$(date +%Y%m%d-%H%M%S)"
VERBOSE=1

# Detect OS
OS="unknown"
if [ "$(uname)" = "Darwin" ]; then
  OS="macos"
elif [ "$(uname)" = "Linux" ]; then
  OS="linux"
elif [ "$(uname)" = "FreeBSD" ]; then
  OS="freebsd"
fi

# Parse command line arguments
NO_BACKUP=0
while getopts "qvhnf:" opt; do
  case $opt in
    q) VERBOSE=0 ;; # Quiet mode
    v) VERBOSE=2 ;; # Extra verbose
    n) NO_BACKUP=1 ;; # Skip backups
    f) DOTFILES_DIR="$OPTARG" ;; # Custom dotfiles directory path
    h)
      echo "Usage: $0 [-q] [-v] [-n] [-f path] [-h]"
      echo "  -q  Quiet mode (minimal output)"
      echo "  -v  Verbose mode (extra output)"
      echo "  -n  No backup (don't create backups of existing files)"
      echo "  -f  Specify custom dotfiles directory path"
      echo "  -h  Show this help message"
      exit 0
      ;;
    *)
      echo "Invalid option. Use -h for help."
      exit 1
      ;;
  esac
done

# Define the cleanup function for temporary files
cleanup() {
  if [ -n "$TEMP_LOG_FILE" ] && [ -f "$TEMP_LOG_FILE" ]; then
    rm -f "$TEMP_LOG_FILE"
  fi
}

# Set trap to catch script exit
trap cleanup EXIT

# Handle backup directory setup
if [ "$NO_BACKUP" -eq 1 ]; then
  echo "Skipping backup creation (running with -n flag)"
  # Use temporary log file since we won't have a backup directory
  # Create portable temporary file (mktemp might have different options on different systems)
  TEMP_LOG_FILE="${TMPDIR:-/tmp}/dotfiles_setup_$$.log"
  touch "$TEMP_LOG_FILE"
  LOG_FILE="$TEMP_LOG_FILE"
  echo "[$(date "+%Y-%m-%d %H:%M:%S")] [INFO] [$OS] Starting dotfiles setup (no backups)" > "$LOG_FILE"
else
  echo "Creating backup directory at $BACKUP_DIR"
  if ! mkdir -p "$BACKUP_BASE_DIR"; then
    echo "ERROR: Failed to create base backup directory at $BACKUP_BASE_DIR"
    exit 1
  fi

  if ! mkdir -p "$BACKUP_DIR"; then
    echo "ERROR: Failed to create backup directory at $BACKUP_DIR"
    exit 1
  fi

  # Now that backup directory exists, set up log file
  LOG_FILE="$BACKUP_DIR/setup.log"
  echo "[$(date "+%Y-%m-%d %H:%M:%S")] [INFO] [$OS] Starting dotfiles setup" > "$LOG_FILE"
fi

# Check for required commands
check_commands() {
  local missing=0
  for cmd in cp mkdir rm ln date dirname basename touch readlink; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
      echo "ERROR: Required command '$cmd' is not available"
      missing=$((missing + 1))
    fi
  done

  if [ $missing -gt 0 ]; then
    echo "ERROR: Missing $missing required command(s). Cannot continue."
    exit 1
  fi
}

# Run command check early (before any other operations)
check_commands

# Check if we can write to the temporary directory
if [ ! -w "${TMPDIR:-/tmp}" ]; then
  echo "ERROR: Cannot write to temporary directory ${TMPDIR:-/tmp}"
  exit 1
fi

# Set OS prefix for logs
log_prefix="[$OS]"

# Function to log messages
log() {
  local level="$1"
  local message="$2"
  local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
  echo "[$timestamp] [$level] $log_prefix $message" >> "$LOG_FILE"

  # Error messages are always displayed
  # INFO messages are displayed in normal and verbose mode
  # DEBUG messages are only displayed in verbose mode
  if [ "$level" = "ERROR" ] || \
     [ "$level" = "WARNING" ] || \
     ([ "$level" = "INFO" ] && [ "$VERBOSE" -ge 1 ]) || \
     ([ "$level" = "DEBUG" ] && [ "$VERBOSE" -ge 2 ]); then
    echo "[$level] $log_prefix $message"
  fi
}

# Check if dotfiles directory exists
if [ ! -d "$DOTFILES_DIR" ]; then
  log "ERROR" "Dotfiles directory not found at $DOTFILES_DIR"
  log "ERROR" "Please clone your dotfiles repository first."
  exit 1
fi

# Log backup status
if [ "$NO_BACKUP" -eq 1 ]; then
  log "INFO" "Running in no-backup mode"
else
  log "INFO" "Backup directory created at $BACKUP_DIR"
fi

# Function to remove a file or directory safely
safe_remove() {
  local path="$1"
  log "DEBUG" "Removing path $path"

  # Try standard rm first, which works on all platforms
  if ! rm -rf "$path" 2>/dev/null; then
    # If that fails on Linux, try with --preserve-root
    if [ "$OS" != "macos" ]; then
      if ! rm -rf --preserve-root "$path" 2>/dev/null; then
        log "ERROR" "Failed to remove path $path"
        return 1
      fi
    else
      log "ERROR" "Failed to remove path $path"
      return 1
    fi
  fi
  return 0
}

# Unified function to backup and symlink a file or directory
setup_symlink() {
  local source_rel="$1"
  local is_config="$2"
  local source_path=""
  local target_path=""

  # Set paths based on whether this is a config file or home file
  source_path="$DOTFILES_DIR/$source_rel"
  if [ "$is_config" = "config" ]; then
    target_path="$HOME/.config/$(basename "$source_rel")"
  else
    # This is a home directory file
    target_path="$HOME/$source_rel"
  fi

  local target_dir=$(dirname "$target_path")

  # Check if source path exists
  if [ ! -e "$source_path" ]; then
    log "WARNING" "Source path $source_path does not exist, skipping..."
    return
  fi

  # Make sure the target directory exists
  if [ ! -d "$target_dir" ]; then
    log "INFO" "Creating target directory $target_dir"
    if ! mkdir -p "$target_dir"; then
      log "ERROR" "Failed to create directory $target_dir"
      return
    fi
  fi

  # Check if symlink already exists and points to the correct location
  if [ -L "$target_path" ]; then
    local current_target=$(readlink "$target_path")
    if [ "$current_target" = "$source_path" ]; then
      log "DEBUG" "Symlink already exists and points to correct location: $target_path -> $source_path"
      return
    else
      log "INFO" "Updating existing symlink $target_path"
      if ! safe_remove "$target_path"; then
        return
      fi
    fi
  # Backup existing file/directory if it exists and is not a symlink
  elif [ -e "$target_path" ]; then
    if [ "$NO_BACKUP" -eq 1 ]; then
      log "INFO" "Removing existing path $target_path (no backup)"
    else
      log "INFO" "Backing up existing path $target_path to $BACKUP_DIR"
      if ! cp -a "$target_path" "$BACKUP_DIR/"; then
        log "ERROR" "Failed to backup $target_path"
        return
      fi
      log "DEBUG" "Backup complete"
    fi

    # Remove existing file/directory
    if ! safe_remove "$target_path"; then
      return
    fi
  fi

  # Create symlink
  log "INFO" "Creating symlink from $source_path to $target_path"
  if ! ln -sf "$source_path" "$target_path"; then
    log "ERROR" "Failed to create symlink for $target_path"
  else
    log "DEBUG" "Successfully linked $source_path -> $target_path"
  fi
}

# Define arrays for different types of dotfiles
HOME_FILES=(
  .bashrc
  .bash_aliases
  .bash_profile
  .gitconfig
  .inputrc
  .markdownlint.json
)

CONFIG_FILES=(
  .ripgreprc
  starship.toml
  yazi
  git
  tmux
  kitty
)

# Set up symlinks for home files
for file in "${HOME_FILES[@]}"; do
  setup_symlink "$file" "home"
done

# Set up symlinks for config files
for file in "${CONFIG_FILES[@]}"; do
  setup_symlink "$file" "config"
done

# Set up symlinks for any other configuration files
# Add more files here as needed

log "INFO" "Dotfiles setup complete!"

# Only show backup info if we're not in no-backup mode
if [ "$NO_BACKUP" -eq 0 ]; then
  log "INFO" "Backups of original files (if any) can be found in $BACKUP_DIR"

  # List backups if any exist and we're not in quiet mode
  if [ -d "$BACKUP_DIR" ] && [ -n "$(ls -A "$BACKUP_DIR" 2>/dev/null)" ] && [ "$VERBOSE" -ge 1 ]; then
    log "DEBUG" "Backup directory contents:"
    # More efficient way to list directory contents without pipe
    for entry in "$BACKUP_DIR"/*; do
      if [ -e "$entry" ]; then
        entry_info=$(ls -la "$entry")
        log "DEBUG" "$entry_info"
      fi
    done
  fi
fi

# Determine appropriate primary bash file by OS
case "$OS" in
  macos)
    primary_file=".bash_profile"
    ;;
  linux|freebsd|*)
    primary_file=".bashrc"
    ;;
esac

# Source the bash configuration to apply changes immediately
log "INFO" "Sourcing bash configuration files..."

# Only source files if running in interactive shell
if [ -n "$BASH_VERSION" ] && [ -n "$PS1" ]; then
  log "INFO" "Sourcing bash files for $OS"

  for file in .bashrc .bash_profile .bash_aliases; do
    if [ -f "$HOME/$file" ]; then
      log "INFO" "Sourcing $file"
      . "$HOME/$file" 2>/dev/null || log "WARNING" "Failed to source $file"
    fi
  done
  log "INFO" "Bash configurations applied"
else
  log "INFO" "To apply changes immediately, run: . ~/$primary_file"
fi

#!/bin/sh

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
  for cmd in cp mkdir rm ln date dirname basename touch; do
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

# Function to backup and symlink a file or directory
setup_symlink() {
  local source_path="$DOTFILES_DIR/$1"
  local target_path="$HOME/$1"
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

  # Backup existing file/directory if it exists and is not a symlink
  if [ -e "$target_path" ]; then
    if [ ! -L "$target_path" ]; then
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
      
      # Remove files in a safer way
      log "DEBUG" "Removing original file/directory $target_path"
      # Try standard rm first, which works on all platforms
      if ! rm -rf "$target_path" 2>/dev/null; then
        # If that fails on Linux, try with --preserve-root
        if [ "$OS" != "macos" ]; then
          if ! rm -rf --preserve-root "$target_path" 2>/dev/null; then
            log "ERROR" "Failed to remove original path $target_path"
            return
          fi
        else
          log "ERROR" "Failed to remove original path $target_path"
          return
        fi
      fi
    else
      log "INFO" "Removing existing symlink $target_path"
      if ! rm "$target_path"; then
        log "ERROR" "Failed to remove symlink $target_path"
        return
      fi
    fi
  fi

  # Create symlink
  log "INFO" "Creating symlink from $source_path to $target_path"
  if ! ln -sf "$source_path" "$target_path"; then
    log "ERROR" "Failed to create symlink for $target_path"
  fi
  
  # Log success
  log "DEBUG" "Successfully linked $source_path -> $target_path"
}

# Set up symlinks for bash files
setup_symlink .bashrc
setup_symlink .bash_aliases
setup_symlink .bash_profile
setup_symlink .gitconfig
setup_symlink .inputrc

# Function to symlink files specifically to ~/.config directory
setup_config_symlink() {
  local source_path="$DOTFILES_DIR/$1"
  local target_path="$HOME/.config/$(basename "$1")"
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

  # Backup existing file/directory if it exists and is not a symlink
  if [ -e "$target_path" ]; then
    if [ ! -L "$target_path" ]; then
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

      # Remove files in a safer way
      log "DEBUG" "Removing original file/directory $target_path"
      if ! rm -rf "$target_path" 2>/dev/null; then
        # If that fails on Linux, try with --preserve-root
        if [ "$OS" != "macos" ]; then
          if ! rm -rf --preserve-root "$target_path" 2>/dev/null; then
            log "ERROR" "Failed to remove original path $target_path"
            return
          fi
        else
          log "ERROR" "Failed to remove original path $target_path"
          return
        fi
      fi
    else
      log "INFO" "Removing existing symlink $target_path"
      if ! rm "$target_path"; then
        log "ERROR" "Failed to remove symlink $target_path"
        return
      fi
    fi
  fi

  # Create symlink
  log "INFO" "Creating symlink from $source_path to $target_path"
  if ! ln -sf "$source_path" "$target_path"; then
    log "ERROR" "Failed to create symlink for $target_path"
  fi

  # Log success
  log "DEBUG" "Successfully linked $source_path -> $target_path"
}

# Set up symlinks for config files
setup_config_symlink .ripgreprc
setup_config_symlink starship.toml
setup_config_symlink yazi
setup_config_symlink git

# Set up symlinks for tmux if needed
# For modern tmux configuration in ~/.config/tmux
if [ -d "$DOTFILES_DIR/tmux" ]; then
  setup_config_symlink tmux
  log "INFO" "Tmux configuration symlinked to ~/.config/tmux"
fi

# Set up symlinks for any other configuration files
# Add more files here as needed

log "INFO" "Dotfiles setup complete!"

# Only show backup info if we're not in no-backup mode
if [ "$NO_BACKUP" -eq 0 ]; then
  log "INFO" "Backups of original files (if any) can be found in $BACKUP_DIR"

  # List backups if any exist and we're not in quiet mode
  if [ -d "$BACKUP_DIR" ] && [ -n "$(ls -A "$BACKUP_DIR" 2>/dev/null)" ] && [ "$VERBOSE" -ge 1 ]; then
    log "DEBUG" "Backup directory contents:"
    ls -la "$BACKUP_DIR" | while read line; do
      log "DEBUG" "$line"
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

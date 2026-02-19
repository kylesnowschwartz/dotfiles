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
DRY_RUN=1 # Default to dry-run mode for safety

# Function to detect operating system
detect_os() {
  local os_name
  os_name="$(uname)"

  case "$os_name" in
  Darwin)
    echo "macos"
    ;;
  Linux)
    echo "linux"
    ;;
  FreeBSD)
    echo "freebsd"
    ;;
  *)
    echo "unknown"
    ;;
  esac
}

# Function to check if running on macOS
is_macos() {
  [ "$OS" = "macos" ]
}

# Function to check if running on Linux
is_linux() {
  [ "$OS" = "linux" ]
}

# Detect OS
OS=$(detect_os)

# Parse command line arguments
NO_BACKUP=0
while getopts "qvhnf:r" opt; do
  case $opt in
  q) VERBOSE=0 ;;              # Quiet mode
  v) VERBOSE=2 ;;              # Extra verbose
  n) NO_BACKUP=1 ;;            # Skip backups
  f) DOTFILES_DIR="$OPTARG" ;; # Custom dotfiles directory path
  r) DRY_RUN=0 ;;              # Actually run (disable dry-run)
  h)
    echo "Usage: $0 [-q] [-v] [-n] [-f path] [-r] [-h]"
    echo "  -q  Quiet mode (minimal output)"
    echo "  -v  Verbose mode (extra output)"
    echo "  -n  No backup (don't create backups of existing files)"
    echo "  -f  Specify custom dotfiles directory path"
    echo "  -r  Run for real (disable dry-run mode - default is dry-run)"
    echo "  -h  Show this help message"
    echo ""
    echo "NOTE: By default, this script runs in DRY-RUN mode (safe to test)."
    echo "      Use -r flag to actually create symlinks and make changes."
    exit 0
    ;;
  *)
    echo "Invalid option. Use -h for help."
    exit 1
    ;;
  esac
done

# Show dry-run status
if [ "$DRY_RUN" -eq 1 ]; then
  echo "=============================================="
  echo "  DRY-RUN MODE (no changes will be made)"
  echo "  Use -r flag to run for real"
  echo "=============================================="
  echo ""
fi

# Define the cleanup function for temporary files
cleanup() {
  if [ -n "$TEMP_LOG_FILE" ] && [ -f "$TEMP_LOG_FILE" ]; then
    rm -f "$TEMP_LOG_FILE"
  fi
}

# Set trap to catch script exit
trap cleanup EXIT

# Handle backup directory setup
if [ "$DRY_RUN" -eq 1 ]; then
  # In dry-run mode, always use temp log file
  echo "Using temporary log file (dry-run mode)"
  TEMP_LOG_FILE="${TMPDIR:-/tmp}/dotfiles_setup_$$.log"
  touch "$TEMP_LOG_FILE"
  LOG_FILE="$TEMP_LOG_FILE"
  echo "[$(date "+%Y-%m-%d %H:%M:%S")] [INFO] [$OS] Starting dotfiles setup (DRY-RUN)" >"$LOG_FILE"
elif [ "$NO_BACKUP" -eq 1 ]; then
  echo "Skipping backup creation (running with -n flag)"
  # Use temporary log file since we won't have a backup directory
  TEMP_LOG_FILE="${TMPDIR:-/tmp}/dotfiles_setup_$$.log"
  touch "$TEMP_LOG_FILE"
  LOG_FILE="$TEMP_LOG_FILE"
  echo "[$(date "+%Y-%m-%d %H:%M:%S")] [INFO] [$OS] Starting dotfiles setup (no backups)" >"$LOG_FILE"
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
  echo "[$(date "+%Y-%m-%d %H:%M:%S")] [INFO] [$OS] Starting dotfiles setup" >"$LOG_FILE"
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
  local dry_run_prefix=""

  if [ "$DRY_RUN" -eq 1 ]; then
    dry_run_prefix="[DRY-RUN] "
  fi

  echo "[$timestamp] [$level] $log_prefix $dry_run_prefix$message" >>"$LOG_FILE"

  # Error messages are always displayed
  # INFO messages are displayed in normal and verbose mode
  # DEBUG messages are only displayed in verbose mode
  if [ "$level" = "ERROR" ] ||
    [ "$level" = "WARNING" ] ||
    ([ "$level" = "INFO" ] && [ "$VERBOSE" -ge 1 ]) ||
    ([ "$level" = "DEBUG" ] && [ "$VERBOSE" -ge 2 ]); then
    echo "[$level] $log_prefix $dry_run_prefix$message"
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

  if [ "$DRY_RUN" -eq 1 ]; then
    log "DEBUG" "Would remove: $path"
    return 0
  fi

  # Try standard rm first, which works on all platforms
  if ! rm -rf "$path" 2>/dev/null; then
    # If that fails on Linux, try with --preserve-root
    if ! is_macos; then
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
    if [ "$DRY_RUN" -eq 0 ]; then
      if ! mkdir -p "$target_dir"; then
        log "ERROR" "Failed to create directory $target_dir"
        return
      fi
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
    if [ "$NO_BACKUP" -eq 1 ] || [ "$DRY_RUN" -eq 1 ]; then
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
  if [ "$DRY_RUN" -eq 1 ]; then
    log "DEBUG" "Would create symlink: $target_path -> $source_path"
  else
    if ! ln -sf "$source_path" "$target_path"; then
      log "ERROR" "Failed to create symlink for $target_path"
    else
      log "DEBUG" "Successfully linked $source_path -> $target_path"
    fi
  fi
}

# Define arrays for different types of dotfiles
# These are cross-platform configs that work on both macOS and Linux
# Home directory files are symlinked directly to ~/
# Config directory files are symlinked to ~/.config/

# Files to symlink to home directory (~/)
HOME_FILES=(
  .zshrc             # Zsh shell config (primary shell)
  .shell_aliases     # Cross-shell aliases and functions
  .gitconfig         # Git configuration
  .gitignore_global  # Global gitignore patterns
  .inputrc           # Readline configuration (vi mode)
  .markdownlint.json # Markdown linting rules
)

# Files/directories to symlink to ~/.config/
CONFIG_FILES=(
  .editorconfig # Cross-editor formatting rules
  .ripgreprc    # Ripgrep configuration
  yazi          # Terminal file manager config
  git           # Git templates and hooks
  ghostty       # Ghostty terminal config (experimental)
)

# NOTE: starship.toml is NOT in this list because it's managed by the
# starship-set function in .shell_aliases, which creates a symlink to
# one of the theme files in starship/ directory

# NOTE: tmux uses a custom setup below because Oh My Tmux requires
# three symlinks with non-standard paths (submodule + local overrides)

# Set up symlinks for home files
for file in "${HOME_FILES[@]}"; do
  setup_symlink "$file" "home"
done

# Set up symlinks for config files
for file in "${CONFIG_FILES[@]}"; do
  setup_symlink "$file" "config"
done

# Set up starship theme symlink if it doesn't exist
# The starship-set function in .shell_aliases manages theme switching
STARSHIP_CONFIG="$HOME/.config/starship.toml"
DEFAULT_STARSHIP_THEME="$DOTFILES_DIR/starship/chef-starship.toml"

if [ ! -e "$STARSHIP_CONFIG" ]; then
  log "INFO" "Creating default starship theme symlink to chef-starship.toml"
  if [ "$DRY_RUN" -eq 1 ]; then
    log "DEBUG" "Would create symlink: $STARSHIP_CONFIG -> $DEFAULT_STARSHIP_THEME"
  else
    if ! ln -sf "$DEFAULT_STARSHIP_THEME" "$STARSHIP_CONFIG"; then
      log "ERROR" "Failed to create starship theme symlink"
    else
      log "DEBUG" "Successfully linked starship theme"
    fi
  fi
  log "INFO" "Use 'starship-set <theme>' to switch themes"
else
  log "DEBUG" "Starship config already exists at $STARSHIP_CONFIG"
fi

# Set up Oh My Tmux symlinks
# Oh My Tmux requires: ~/.tmux (repo), ~/.tmux.conf (core), ~/.tmux.conf.local (overrides)
# These use custom target paths so we handle them inline rather than via setup_symlink
OH_MY_TMUX_DIR="$DOTFILES_DIR/tmux/oh-my-tmux"

if [ -d "$OH_MY_TMUX_DIR" ]; then
  log "INFO" "Setting up Oh My Tmux..."

  # Symlink pairs: source -> target
  declare -A TMUX_LINKS=(
    ["$OH_MY_TMUX_DIR"]="$HOME/.tmux"
    ["$OH_MY_TMUX_DIR/.tmux.conf"]="$HOME/.tmux.conf"
    ["$DOTFILES_DIR/tmux/.tmux.conf.local"]="$HOME/.tmux.conf.local"
  )

  for source_path in "${!TMUX_LINKS[@]}"; do
    target_path="${TMUX_LINKS[$source_path]}"

    if [ -L "$target_path" ]; then
      current_target=$(readlink "$target_path")
      if [ "$current_target" = "$source_path" ]; then
        log "DEBUG" "Tmux symlink already correct: $target_path"
        continue
      fi
      log "INFO" "Updating tmux symlink $target_path"
      safe_remove "$target_path"
    elif [ -e "$target_path" ]; then
      if [ "$NO_BACKUP" -eq 0 ] && [ "$DRY_RUN" -eq 0 ]; then
        log "INFO" "Backing up $target_path to $BACKUP_DIR"
        cp -a "$target_path" "$BACKUP_DIR/"
      fi
      safe_remove "$target_path"
    fi

    log "INFO" "Creating symlink: $target_path -> $source_path"
    if [ "$DRY_RUN" -eq 0 ]; then
      ln -sf "$source_path" "$target_path" || log "ERROR" "Failed to symlink $target_path"
    fi
  done
else
  log "WARNING" "Oh My Tmux submodule not found. Run: git submodule update --init"
fi

# Set up symlinks for any other configuration files
# Add more files here as needed

log "INFO" "Dotfiles setup complete!"

# ZSH Setup (if zsh is available)
# Check if zsh is installed and provide guidance
if command -v zsh >/dev/null 2>&1; then
  log "INFO" "Zsh detected, checking configuration..."

  # Check if zsh is already the default shell
  current_shell="$SHELL"
  zsh_path="$(command -v zsh)"

  if [ "$current_shell" != "$zsh_path" ]; then
    log "WARNING" "Current shell: $current_shell (not zsh)"
    log "INFO" "Zsh is recommended as the primary shell for this configuration"
    log "INFO" "To set zsh as default shell, run: chsh -s $zsh_path"
    log "INFO" "Then log out and log back in for the change to take effect"
  else
    log "INFO" "Zsh is already your default shell"
  fi
else
  log "WARNING" "Zsh not found. This configuration is optimized for zsh."
  log "INFO" "Consider installing zsh for the best experience."
  if is_macos; then
    log "INFO" "On macOS, zsh is included by default in recent versions"
  elif is_linux; then
    log "INFO" "Install with: sudo apt install zsh (Debian/Ubuntu) or sudo yum install zsh (RHEL/CentOS)"
  fi
fi

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

# Source the appropriate shell configuration to apply changes immediately
log "INFO" "Sourcing shell configuration files..."

# Detect which shell we're running in and source appropriately
if [ -n "$ZSH_VERSION" ]; then
  # Running in zsh
  if [ -f "$HOME/.zshrc" ]; then
    log "INFO" "Sourcing .zshrc for zsh..."
    # shellcheck disable=SC1091
    . "$HOME/.zshrc" 2>/dev/null || log "WARNING" "Failed to source .zshrc"
    log "INFO" "Zsh configuration applied"
  else
    log "WARNING" ".zshrc not found"
  fi
elif [ -n "$BASH_VERSION" ] && [ -n "$PS1" ]; then
  # Running in interactive bash
  log "INFO" "Sourcing bash files for $OS"

  for file in .shell_aliases; do
    if [ -f "$HOME/$file" ]; then
      log "INFO" "Sourcing $file"
      # shellcheck disable=SC1091
      . "$HOME/$file" 2>/dev/null || log "WARNING" "Failed to source $file"
    fi
  done
  log "INFO" "Bash configurations applied"
else
  # Not in an interactive shell, provide instructions
  if command -v zsh >/dev/null 2>&1; then
    log "INFO" "To apply changes in zsh, run: source ~/.zshrc"
  fi
  log "INFO" "To apply changes, run: source ~/.zshrc"
fi

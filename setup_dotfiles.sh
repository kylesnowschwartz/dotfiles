#!/bin/bash

# Script to set up symlinks to dotfiles
# Run from your home directory (~)

DOTFILES_DIR="$HOME/Code/dotfiles"
BACKUP_DIR="$HOME/dotfiles_backup_$(date +%Y%m%d-%H%M%S)"

# Check if dotfiles directory exists
if [ ! -d "$DOTFILES_DIR" ]; then
  echo "Error: Dotfiles directory not found at $DOTFILES_DIR"
  echo "Please clone your dotfiles repository first."
  exit 1
fi

# Create backup directory
echo "Creating backup directory at $BACKUP_DIR"
mkdir -p "$BACKUP_DIR"

# Function to backup and symlink a file
setup_symlink() {
  local source_file="$DOTFILES_DIR/$1"
  local target_file="$HOME/$1"

  # Check if source file exists
  if [ ! -f "$source_file" ]; then
    echo "Warning: Source file $source_file does not exist, skipping..."
    return
  fi

  # Backup existing file if it exists and is not a symlink
  if [ -f "$target_file" ] && [ ! -L "$target_file" ]; then
    echo "Backing up existing file $target_file to $BACKUP_DIR"
    mv "$target_file" "$BACKUP_DIR/"
  elif [ -L "$target_file" ]; then
    echo "Removing existing symlink $target_file"
    rm "$target_file"
  fi

  # Create symlink
  echo "Creating symlink from $source_file to $target_file"
  ln -sf "$source_file" "$target_file"
}

# Set up symlinks for bash files
setup_symlink .bashrc
setup_symlink .bash_aliases
setup_symlink .git-prompt.sh

# Set up symlinks for tmux if needed
# setup_symlink .tmux.conf
# Create ~/.config/tmux directory if it doesn't exist
# mkdir -p "$HOME/.config/tmux"
# ln -sf "$DOTFILES_DIR/tmux/tmux.conf" "$HOME/.config/tmux/tmux.conf"

# Set up symlinks for any other configuration files
# Add more files here as needed

echo "Dotfiles setup complete!"
echo "Backups of original files (if any) can be found in $BACKUP_DIR"
ls $BACKUP_DIR

# Source the bash configuration to apply changes immediately
echo "To apply changes immediately, run: source ~/.bashrc"

# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a personal dotfiles repository for cross-platform development environment configuration, supporting both macOS and Linux systems.

## Key Commands

### Setup and Installation

```bash
# Install dotfiles (creates symlinks)
./setup_dotfiles.sh

# Install dotfiles with options
./setup_dotfiles.sh -v      # verbose mode
./setup_dotfiles.sh -n      # no backup
./setup_dotfiles.sh -f path # custom dotfiles path

# Install packages (Linux/Debian/Ubuntu only)
sudo ./install_packages.sh --all       # install all packages
sudo ./install_packages.sh --dev       # development packages only
sudo ./install_packages.sh --server    # server packages only
sudo ./install_packages.sh --desktop   # desktop packages only
sudo ./install_packages.sh --dry-run   # preview what would be installed
```

### Daily Usage

```bash
# Reload tmux configuration
tmux source-file ~/.config/tmux/tmux.conf

# Reload bash configuration
source ~/.bashrc
```

## Architecture

### File Structure

- **Home directory files** (`.bashrc`, `.gitconfig`, etc.) → symlinked to `~/`
- **Config directory files** (`starship.toml`, `tmux/`, etc.) → symlinked to `~/.config/`
- **Setup scripts** handle cross-platform installation and package management

### Cross-Platform Design

- OS detection in both setup scripts and runtime configurations
- Platform-specific behaviors handled conditionally
- Separate package lists for different system types

### Key Components

#### Shell Environment (`.bashrc`)

- Cross-platform bash configuration with OS detection
- Vi-mode editing for command line
- Enhanced history management (1M entries, no duplicates)
- Dynamic PATH configuration for multiple language environments

#### Tmux Configuration (`tmux/tmux.conf`)

- Vi-style key bindings and navigation
- Spacemacs-inspired workflow patterns
- Plugin management via TPM (Tmux Plugin Manager)
- Catppuccin theme integration
- Enhanced copy-paste with system clipboard

#### Starship Prompt (`starship.toml`)

- Custom prompt format with Git integration
- OS-specific symbols and styling
- Directory and branch information display

#### Package Management (`install_packages.sh`)

- Modular installation with `--server`, `--desktop`, `--dev`, `--all` flags
- Idempotent operations (safe to run multiple times)
- Comprehensive logging with dry-run mode

### Safety Features

- **Backup system**: Original files backed up before symlink creation
- **Idempotent scripts**: All operations safe to repeat
- **Verbose logging**: Multiple verbosity levels for debugging
- **OS compatibility checks**: Scripts validate system requirements

## Development Notes

### Making Changes

- Test setup scripts on both macOS and Linux when possible
- Maintain cross-platform compatibility in all configurations
- Use the backup system when testing destructive changes
- Run setup scripts with `-v` flag for debugging

### Tmux Plugin Management

- Plugins managed via TPM (Tmux Plugin Manager)
- Plugin installation: `<prefix> + I` (capital i)
- Plugin updates: `<prefix> + U`
- Plugin cleanup: `<prefix> + alt + u`

### Shell Customization

- Aliases defined in `.bash_aliases`
- Platform-specific PATH modifications in `.bashrc`
- Starship prompt customization in `starship.toml`

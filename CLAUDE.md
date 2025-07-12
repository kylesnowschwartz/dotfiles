# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a personal dotfiles repository for cross-platform development environment configuration, supporting both macOS and Linux systems.

### File Structure

- **Home directory files** (`.bashrc`, `.gitconfig`, etc.) → symlinked to `~/`
- **Config directory files** (`starship.toml`, `yazi/`, etc.) → symlinked to `~/.config/`

### Key Components

#### Shell Environment (`.bashrc`)

- Vi-mode editing for command line
- Dynamic PATH configuration for multiple language environments

#### Starship Prompt (`starship.toml`)

- Custom prompt format with Git integration

### Shell Customization

- Aliases defined in `.bash_aliases`
- Platform-specific PATH modifications in `.bashrc`
- Starship prompt customization in `starship.toml`

#### Git Configuration (`.gitconfig`)

- **Delta integration**: Enhanced diff viewer with syntax highlighting and navigation
- **Automated workflows**: Custom aliases for PR management, commit amendments, and branch operations
- **Smart defaults**: Auto-rebase on pull, auto-squash for interactive rebases, auto-setup remote tracking
- **Developer productivity**: Automated commit generation via AI (`aic` alias), LFS support, and histogram diff algorithm
- **Global gitignore**: Excludes Claude Code local settings across all repositories

#### Tmux Configuration (`tmux/tmux.conf`)

- **Legacy configuration** preserved for potential future use
- Comprehensive setup with vi-style navigation, mouse support, and plugin ecosystem

#### Kitty Terminal Configuration (`kitty/kitty.conf`)

- **Experimental terminal emulator** - iTerm2 remains the primary terminal
- Nightfox theme with macOS integration and comprehensive key mappings for testing

#### Yazi File Manager (`yazi/yazi.toml`)

- **Terminal file manager** with minimal configuration
- Hidden files display enabled for comprehensive directory browsing

#### Ghostty Terminal (`ghostty/config`)

- **Another experimental terminal** alongside Kitty - iTerm2 remains primary
- MesloLGS Nerd Font with basic key mappings for tab navigation and clipboard integration
- Global quick terminal toggle with Cmd+` for overlay access

#### Claude Code Configuration (`claude/`)

- **AI pair-programming guidelines** with 24 principles for quality development workflow
- **Enhanced permissions** allowing comprehensive tool access including MCP servers (Context7, Playwright, Buildkite, Zen)
- **Optimized settings**: Extended timeouts, increased token limits, and project working directory maintenance
- **Utility scripts**: Setup for MCP servers, conversation analysis, and context management
- **GitHub integration**: SSH configuration, CLI authentication, and workflow documentation
- **macOS compatibility**: Solutions for Unicode filename issues in screenshots

#### EditorConfig (`.editorconfig`)

- **Cross-editor consistency** with standardized formatting rules
- **Language-specific settings**: Python (4 spaces), Go (tabs), Markdown (preserve trailing whitespace)
- **Universal defaults**: 2-space indentation, LF line endings, UTF-8 encoding, trailing whitespace removal

#### Installation & Setup Scripts

- **Package installer** (`install_packages.sh`) - Legacy Debian/Ubuntu script with server, desktop, and dev profiles
- **Symlink manager** (`setup_dotfiles.sh`) - Cross-platform dotfiles deployment with backup support and OS detection
- **Snippet storage** (`snippets/`) - Legacy private Yasnippets directory for Emacs text expansion

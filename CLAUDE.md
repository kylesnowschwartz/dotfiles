# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Quick Reference

### View Repository Structure
```bash
eza --tree --level 2
```

This reveals the key directories:
- `claude/` - Claude Code configuration with hooks (entrypoints/handlers)
- `ghostty/` - Ghostty terminal config with theme switching
- `yazi/` - Terminal file manager config
- `starship/` - Prompt theme configurations
- `git/` - Git configuration files
- `scripts/` - Utility scripts (smart-commit.sh, etc.)
- Home files (`.bashrc`, `.zshrc`, `.gitconfig`) → symlinked to `~/`
- Config dirs → symlinked to `~/.config/`

### Shell Environment
- **Primary shell**: zsh (`.zshrc`)
- **Alias file**: `.bash_aliases` (cross-compatible with both bash and zsh)
- **Input mode**: Vi-mode enabled for command line editing
- **Migration**: Recently migrated from bash to zsh, preserving all functionality

### Terminal Dependencies
See `terminal-dependencies.md` for comprehensive setup information:
- Package managers: Homebrew, Cargo, npm, pipx
- Modern CLI tools: eza, bat, ripgrep, fd, delta, duf, procs
- Language environments: Python, Ruby, Node, Rust, Go, Lua, R
- AWS/cloud tools and infrastructure dependencies
- Development tools: git, gh, direnv, fzf, tmux, neovim, starship

## Repository Overview

This is a personal dotfiles repository for cross-platform development environment configuration, supporting both macOS and Linux systems.

### File Structure

- **Home directory files** (`.bashrc`, `.zshrc`, `.gitconfig`, etc.) → symlinked to `~/`
- **Config directory files** (`starship.toml`, `yazi/`, etc.) → symlinked to `~/.config/`

## Key Components

### Shell Environment (`.zshrc` / `.bashrc`)

- **Primary configuration**: `.zshrc` for zsh (current shell)
- **Legacy compatibility**: `.bashrc` preserved for bash fallback
- Vi-mode editing for command line
- Dynamic PATH configuration for multiple language environments
- History management with deduplication and sharing between sessions
- FZF integration with bat/eza previews
- Zoxide for smart directory navigation

### Shell Customization (`.bash_aliases`)

- Cross-compatible aliases work with both bash and zsh
- Modern CLI replacements (eza, bat, ripgrep, procs, duf)
- Git workflow aliases and functions
- Starship theme switcher (`starship-set <theme>`)
- Delta color scheme switching (`delta-dark`, `delta-light`)
- Claude Code integration (`@@` quick CLI, sound controls)
- Custom functions: `new`, `newd`, `gif`, `irebase`

### Starship Prompt (`starship/`)

- Multiple theme configurations stored in `starship/` directory
- Custom prompt format with Git integration
- Theme switcher function in `.bash_aliases`
- Current config symlinked to `~/.config/starship.toml`

### Git Configuration (`git/.gitconfig`)

- **Delta integration**: Enhanced diff viewer with syntax highlighting and navigation
- **Automated workflows**: Custom aliases for PR management, commit amendments, and branch operations
- **Smart defaults**: Auto-rebase on pull, auto-squash for interactive rebases, auto-setup remote tracking
- **Developer productivity**: Automated commit generation via AI (`aic` alias), LFS support, and histogram diff algorithm
- **Global gitignore**: Excludes Claude Code local settings across all repositories
- **Smart commit script**: `scripts/smart-commit.sh` for conventional commits

### Yazi File Manager (`yazi/yazi.toml`)

- **Terminal file manager** with minimal configuration
- Hidden files display enabled for comprehensive directory browsing
- Shell function `y()` in `.bash_aliases` for cd-on-exit functionality

### Ghostty Terminal (`ghostty/config`)

- **Experimental terminal emulator** - iTerm2 remains the primary terminal
- MesloLGS Nerd Font with basic key mappings for tab navigation and clipboard integration
- Global quick terminal toggle with Cmd+` for overlay access
- **Theme switching**: Three-tier architecture for coordinated color schemes
  - **Orchestrated**: `ghostty/switch-theme.sh` - Atomic switching of Ghostty + Starship + Delta (keybindings: Cmd+Shift+, / Cmd+Shift+.)
  - **Flexible**: `starship-set <theme>` in `.bash_aliases` - Switch to any Starship theme, including downloadable presets
  - **Simple**: `delta-dark` / `delta-light` aliases in `.bash_aliases` - Quick git diff color changes

### Claude Code Configuration (`claude/`)

- **AI pair-programming guidelines** with 24 principles for quality development workflow (see `claude/CLAUDE.md`)
- **Enhanced permissions** allowing comprehensive tool access including MCP servers (Context7, Playwright, Buildkite, Zen)
- **Optimized settings**: Extended timeouts, increased token limits, and project working directory maintenance
- **Hook system**: Located in `claude/hooks/` with entrypoints and handlers for event-driven automation
- **Utility scripts**: Setup for MCP servers, conversation analysis, and context management
- **GitHub integration**: SSH configuration, CLI authentication, and workflow documentation
- **macOS compatibility**: Solutions for Unicode filename issues in screenshots

### EditorConfig (`.editorconfig`)

- **Cross-editor consistency** with standardized formatting rules
- **Language-specific settings**: Python (4 spaces), Go (tabs), Markdown (preserve trailing whitespace)
- **Universal defaults**: 2-space indentation, LF line endings, UTF-8 encoding, trailing whitespace removal

### Installation & Setup Scripts

- **Package installer** (`install_packages.sh`) - Legacy Debian/Ubuntu script with server, desktop, and dev profiles
- **Symlink manager** (`setup_dotfiles.sh`) - Cross-platform dotfiles deployment with backup support and OS detection
- **Terminal dependencies** (`terminal-dependencies.md`) - Comprehensive list of all installed tools and packages for future setup
- **Snippet storage** (`snippets/`) - Legacy private Yasnippets directory for Emacs text expansion

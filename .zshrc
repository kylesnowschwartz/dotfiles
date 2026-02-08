# shellcheck shell=bash
eval "$(/opt/homebrew/bin/brew shellenv)"
# ~/.zshrc: executed by zsh for interactive shells
# Cross-platform configuration for macOS and Linux - migrated from bash
#
# Migration notes:
# - Preserves all bash functionality while adding zsh improvements
# - Sources existing .bash_aliases for compatibility
# - Can be reverted by changing default shell back to bash
#
# CLAUDE CODE INSTRUCTIONS:
# When modifying this zsh configuration, always check the official zsh documentation
# for built-in, idiomatic features before implementing custom solutions. ZSH has many
# built-in parameters and options that replace common bash workarounds:
# - Use web search to find official zsh documentation and manual pages
# - Look for built-in zsh parameters rather than custom functions
# - Check the zsh manual: https://r.jina.ai/https://zsh.sourceforge.io/Doc/Release/zsh_toc.html
# - Prefer native zsh features over bash-style solutions when available

# Exit if not running interactively (zsh equivalent)
[[ $- != *i* ]] && return

#################################################
# PLATFORM DETECTION
#################################################

# Detect OS - used throughout the configuration
OS="unknown"
if [ "$(uname)" = "Darwin" ]; then
  OS="macos"
else
  OS="linux" # Default to Linux for other Unix-like systems
fi

#################################################
# ZSH-SPECIFIC CONFIGURATION
#################################################

# History management (zsh syntax)
# Note: HISTCONTROL is bash-specific, zsh uses setopt instead
# HISTSIZE=1000000
# HISTFILESIZE doesn't exist in zsh, use SAVEHIST instead
# SAVEHIST=1000000
HISTFILE=~/.zsh_history

# ZSH history options (improvements over bash)
setopt HIST_IGNORE_DUPS     # Don't record duplicate entries
setopt HIST_IGNORE_ALL_DUPS # Remove older duplicate entries from history
setopt HIST_REDUCE_BLANKS   # Remove superfluous blanks from history
setopt HIST_SAVE_NO_DUPS    # Don't save duplicate entries to history file
setopt HIST_VERIFY          # Show command with history expansion before running
setopt APPEND_HISTORY       # Append to history file (like bash's histappend)
setopt SHARE_HISTORY        # Share history between all sessions
setopt INC_APPEND_HISTORY   # Incrementally append to history file

# Terminal behavior (zsh equivalents of bash shopt)
setopt AUTO_CD # cd to directory by typing its name
# setopt CORRECT # Spell correction for commands (disabled - annoying)
# setopt CORRECT_ALL # Spell correction for arguments (can be annoying, remove if needed)

# Input mode - vi mode for zsh
set -o vi
bindkey -v

# Cursor shape configuration for vi mode (built-in ZSH parameter)
zle-keymap-select() {
  case $KEYMAP in
  vicmd) echo -ne '\e[1 q' ;;        # Block cursor for normal mode
  viins | main) echo -ne '\e[5 q' ;; # Line cursor for insert mode
  esac
}
zle -N zle-keymap-select

# Set initial cursor to line (insert mode)
echo -ne '\e[5 q'

# Additional vi-mode improvements
bindkey '^R' history-incremental-search-backward # Keep Ctrl+R for history search
bindkey '^P' history-search-backward             # Ctrl+P for previous command
bindkey '^N' history-search-forward              # Ctrl+N for next command

#################################################
# PATH CONFIGURATION
#################################################

# Common paths (cross-platform) - identical to bash version
[ -d "$HOME/.rbenv/bin" ] && export PATH="$HOME/.rbenv/bin:$PATH"
[ -d "$HOME/.npm/bin" ] && export PATH="$HOME/.npm/bin:$PATH"
[ -d "$HOME/.npm-global/bin" ] && export PATH="$HOME/.npm-global/bin:$PATH"
[ -d "$HOME/go/bin" ] && export PATH="$HOME/go/bin:$PATH"
[ -d "$HOME/.cargo/bin" ] && export PATH="$HOME/.cargo/bin:$PATH"
[ -d "/opt/homebrew/opt/rustup/bin" ] && export PATH="/opt/homebrew/opt/rustup/bin:$PATH"
[ -d "$HOME/.bun/bin" ] && export PATH="$HOME/.bun/bin:$PATH"
[ -d "$HOME/.local/bin" ] && export PATH="$PATH:$HOME/.local/bin"
# Platform-specific paths
if [ "$OS" = "macos" ]; then
  # macOS-specific paths
  [ -d "/Applications/RubyMine.app/Contents/MacOS" ] && export PATH="/Applications/RubyMine.app/Contents/MacOS:$PATH"
  [ -d "/Applications/Tailscale.app/Contents/MacOS" ] && export PATH="/Applications/Tailscale.app/Contents/MacOS:$PATH"
fi

#################################################
# ENVIRONMENT VARIABLES
#################################################

# Expose tmux state to subprocesses (Claude Code strips $TMUX but preserves this)
[ -n "$TMUX" ] && export TMUX_ATTACHED=1

# Editor and pager settings
export EDITOR=nvim
[ -x "$(command -v bat 2>/dev/null)" ] && export PAGER=bat

# Bun runtime
export BUN_INSTALL="$HOME/.bun"

# Java configuration
if [ "$OS" = "macos" ]; then
  # macOS Java
  if [ -x /usr/libexec/java_home ]; then
    JAVA_HOME=$(/usr/libexec/java_home)
    export JAVA_HOME
  fi

  # macOS Ruby with Homebrew openssl
  if command -v brew >/dev/null 2>&1; then
    openssl_dir=$(brew --prefix openssl 2>/dev/null)
    export RUBY_CONFIGURE_OPTS="--with-openssl-dir=$openssl_dir"
  fi
fi

# Ripgrep configuration
if [ -f "$HOME/config/.ripgreprc" ]; then
  export RIPGREP_CONFIG_PATH="$HOME/config/.ripgreprc"
elif [ -f "$HOME/.config/ripgrep/config" ]; then
  export RIPGREP_CONFIG_PATH="$HOME/.config/ripgrep/config"
elif [ -f "$HOME/Code/Dotfiles/.ripgreprc" ]; then
  export RIPGREP_CONFIG_PATH="$HOME/Code/Dotfiles/.ripgreprc"
fi

# Man pages with less but with some enhancements
export MANPAGER="less -R -s -M +Gg --use-color -Dd+r -Du+b"

#################################################
# ALIASES
#################################################

# Source additional aliases if available (your existing .bash_aliases)
[ -f ~/.bash_aliases ] && . ~/.bash_aliases

#################################################
# DEVELOPMENT TOOLS
#################################################

# Language version managers
# -----------------------

# rbenv (zsh support)
if command -v rbenv >/dev/null 2>&1; then
  eval "$(rbenv init - zsh)"
fi

# nodenv (zsh support)
[ -x "$(command -v nodenv 2>/dev/null)" ] && eval "$(nodenv init - zsh)"

# ASDF version manager
if [ -f "$HOME/.asdf/asdf.sh" ]; then
  . "$HOME/.asdf/asdf.sh"
elif [ -f "/opt/homebrew/opt/asdf/libexec/asdf.sh" ]; then
  . "/opt/homebrew/opt/asdf/libexec/asdf.sh"
elif [ -f "/opt/asdf-vm/asdf.sh" ]; then
  . "/opt/asdf-vm/asdf.sh"
fi

# Development tools
# -----------------------

# direnv (zsh support)
[ -x "$(command -v direnv 2>/dev/null)" ] && eval "$(direnv hook zsh)"

# ImageMagick
export DYLD_FALLBACK_LIBRARY_PATH="$(brew --prefix)/lib:$DYLD_FALLBACK_LIBRARY_PATH"

# FZF fuzzy finder with enhanced completion
if command -v fzf &>/dev/null; then
  # Initialize fzf for zsh
  eval "$(fzf --zsh)"

  # Base appearance settings
  export FZF_DEFAULT_OPTS="--height 50% --layout=default --border --color=hl:#2dd4bf"

  # Command configuration (uses fd if available, fallback to default find)
  if command -v fd &>/dev/null; then
    # Default command respects .gitignore (for tab completion)
    export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git --gitignore"

    # Ctrl+T searches everything, including gitignored files
    export FZF_CTRL_T_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git --no-ignore"

    # Alt+C for directories respects .gitignore
    export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git --gitignore"
  fi

  # Preview configuration
  preview_file="bat --color=always -n --line-range :500 {} 2>/dev/null"
  preview_dir="eza --tree --color=always {} 2>/dev/null"

  if command -v bat &>/dev/null; then
    # Tab completion previews (files and directories)
    export FZF_COMPLETION_OPTS="--preview '$preview_file || $preview_dir'"
    # Ctrl+T file browser previews
    export FZF_CTRL_T_OPTS="--preview '$preview_file'"
  fi

  if command -v eza &>/dev/null; then
    # Alt+C directory browser previews
    export FZF_ALT_C_OPTS="--preview '$preview_dir | head -200'"
  fi

  # Clean up variables
  unset preview_file preview_dir

  # Key binding configuration
  bindkey '^R' fzf-history-widget
else
  echo "fzf (fuzzy finder) not installed"
fi

# Autosuggestions (accept with → or End)
source "$(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh"

# AI-powered shell suggestions (Ctrl+Z to trigger)
export ZSH_AI_CMD_DEBUG=true # Log to /tmp/zsh-ai-cmd.log
export ZSH_AI_CMD_ANTHROPIC_MODEL='claude-opus-4-6'
[ -f ~/Code/my-projects/zsh-ai-cmd/zsh-ai-cmd.plugin.zsh ] && source ~/Code/my-projects/zsh-ai-cmd/zsh-ai-cmd.plugin.zsh

# Syntax highlighting (must be last)
source "$(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

# AWS CLI tools (zsh support) - will be initialized after compinit
AWS_VAULT_AVAILABLE=""
if command -v aws-vault >/dev/null 2>&1; then
  AWS_VAULT_AVAILABLE="yes"
fi

if [ "$OS" = "macos" ]; then
  # AWS completion setup - will be configured after compinit
  AWS_COMPLETER_PATH="/opt/homebrew/bin/aws_completer"
fi

# Yazi file manager (identical to bash version)
if command -v yazi >/dev/null 2>&1; then
  function y() {
    local tmp cwd
    tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
    yazi "$@" --cwd-file="$tmp"
    if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
      builtin cd -- "$cwd" || return
    fi
    rm -f -- "$tmp"
  }
fi

# https://github.com/max-sixty/worktrunk Git Worktrunk init
if command -v wt >/dev/null 2>&1; then eval "$(command wt config shell init zsh)"; fi

#################################################
# SHELL APPEARANCE
#################################################

# Starship prompt (zsh support)
[ -x "$(command -v starship 2>/dev/null)" ] && eval "$(starship init zsh)"

# ZSH completion system
# Add custom completions to fpath before compinit
# shellcheck disable=SC2206
fpath=(~/.zsh/completions $fpath)

autoload -Uz compinit

# Handle insecure directories by using -i flag to ignore them
# or use -u to allow insecure directories
compinit -i

# Additional zsh completion improvements
setopt AUTO_LIST        # Automatically list choices on ambiguous completion
setopt AUTO_MENU        # Show completion menu on successive tab press
setopt COMPLETE_IN_WORD # Complete from both ends of a word
setopt ALWAYS_TO_END    # Move cursor to the end of a completed word

# Case-insensitive tab completion
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# AWS completion (after compinit)
if [ -n "$AWS_COMPLETER_PATH" ] && [ -x "$AWS_COMPLETER_PATH" ]; then
  autoload -U +X bashcompinit && bashcompinit
  complete -C "$AWS_COMPLETER_PATH" aws
fi

# AWS vault completion (after compinit)
if [ "$AWS_VAULT_AVAILABLE" = "yes" ]; then
  eval "$(aws-vault --completion-script-zsh)"
fi

# PostgreSQL 16 (ARM Homebrew path)
[ -d "/opt/homebrew/opt/postgresql@16/bin" ] && export PATH="/opt/homebrew/opt/postgresql@16/bin:$PATH"

# Mysql 8.0 (ARM Homebrew path)
[ -d "/opt/homebrew/opt/mysql@8.0/bin" ] && export PATH="/opt/homebrew/opt/mysql@8.0/bin:$PATH"

# Zoxide better cd (zsh support)
eval "$(zoxide init zsh --cmd cd)"

#################################################
# ZSH-SPECIFIC ENHANCEMENTS
#################################################

# Enhanced globbing
setopt EXTENDED_GLOB # Enable extended globbing features
setopt NULL_GLOB     # If no match for glob, return empty list instead of error

# Directory stack
setopt AUTO_PUSHD        # Push the old directory onto the directory stack
setopt PUSHD_IGNORE_DUPS # Don't push the same directory twice
setopt PUSHD_MINUS       # Exchange the meanings of '+' and '-' for directory stack

# Job control
setopt NOTIFY # Report status of background jobs immediately
setopt NO_HUP # Don't kill jobs on shell exit

#################################################
# ADDITIONAL ZSH UTILITIES
#################################################

# Quick alias to reload zsh configuration
alias zreload="source ~/.zshrc && echo 'Zsh configuration reloaded'"

# Show zsh-specific features available
zsh-features() {
  echo "ZSH-specific features enabled:"
  echo "-----------------------------"
  echo "• Enhanced history with sharing between sessions"
  echo "• Spell correction for commands (and arguments)"
  echo "• Auto-cd: type directory name to cd into it"
  echo "• Extended globbing patterns"
  echo "• Automatic directory stack (use 'dirs -v' to see)"
  echo "• Enhanced tab completion"
  echo "• All your existing bash aliases and functions preserved"
  echo ""
  echo "Try these commands:"
  echo "  dirs -v    # Show directory stack"
  echo "  cd -<tab>  # Navigate directory stack"
  echo "  **/*.txt   # Recursive glob patterns"
}

# bun completions
[ -s "/Users/kyle/.bun/_bun" ] && source "/Users/kyle/.bun/_bun"

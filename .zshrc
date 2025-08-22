# shellcheck shell=bash
# ~/.zshrc: executed by zsh for interactive shells
# Cross-platform configuration for macOS and Linux - migrated from bash
#
# Migration notes:
# - Preserves all bash functionality while adding zsh improvements
# - Sources existing .bash_aliases for compatibility
# - Can be reverted by changing default shell back to bash

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
setopt CORRECT # Spell correction for commands
# setopt CORRECT_ALL # Spell correction for arguments (can be annoying, remove if needed)

# Input mode - vi mode for zsh
set -o vi
bindkey -v

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
[ -d "$HOME/.local/bin" ] && export PATH="$PATH:$HOME/.local/bin"

# Platform-specific paths
if [ "$OS" = "macos" ]; then
  # macOS-specific paths
  [ -d "/Applications/RubyMine.app/Contents/MacOS" ] && export PATH="/Applications/RubyMine.app/Contents/MacOS:$PATH"
fi

#################################################
# ENVIRONMENT VARIABLES
#################################################

# Editor and pager settings
export EDITOR=nvim
[ -x "$(command -v bat 2>/dev/null)" ] && export PAGER=bat

# Java configuration
if [ "$OS" = "macos" ]; then
  # macOS Java
  if [ -x /usr/libexec/java_home ]; then
    JAVA_HOME=$(/usr/libexec/java_home)
    export JAVA_HOME
  fi

  # macOS Ruby with Homebrew openssl
  if command -v brew >/dev/null 2>&1; then
    openssl_dir=$(brew --prefix openssl@1.1 2>/dev/null || echo '/usr/local')
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
elif [ -f "/usr/local/opt/asdf/libexec/asdf.sh" ]; then
  . "/usr/local/opt/asdf/libexec/asdf.sh"
elif [ -f "/opt/asdf-vm/asdf.sh" ]; then
  . "/opt/asdf-vm/asdf.sh"
fi

# Development tools
# -----------------------

# direnv (zsh support)
[ -x "$(command -v direnv 2>/dev/null)" ] && eval "$(direnv hook zsh)"

# ImageMagick
export DYLD_FALLBACK_LIBRARY_PATH="$(brew --prefix)/lib:$DYLD_FALLBACK_LIBRARY_PATH"

# FZF fuzzy finder (zsh version)
if [ -f ~/.fzf.zsh ]; then
  . ~/.fzf.zsh
elif [ -f /usr/local/opt/fzf/shell/key-bindings.zsh ]; then
  . /usr/local/opt/fzf/shell/key-bindings.zsh
elif [ -f /usr/share/doc/fzf/examples/key-bindings.zsh ]; then
  . /usr/share/doc/fzf/examples/key-bindings.zsh
elif [ -f /usr/share/fzf/shell/key-bindings.zsh ]; then
  . /usr/share/fzf/shell/key-bindings.zsh
fi

# FZF key bindings - set after sourcing fzf
bindkey '^R' fzf-history-widget

# AWS CLI tools (zsh support) - will be initialized after compinit
AWS_VAULT_AVAILABLE=""
if command -v aws-vault >/dev/null 2>&1; then
  AWS_VAULT_AVAILABLE="yes"
fi

if [ "$OS" = "macos" ]; then
  # AWS completion setup - will be configured after compinit
  AWS_COMPLETER_PATH="/usr/local/bin/aws_completer"
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

#################################################
# SHELL APPEARANCE
#################################################

# Starship prompt (zsh support)
[ -x "$(command -v starship 2>/dev/null)" ] && eval "$(starship init zsh)"

# ZSH completion system
autoload -Uz compinit

# Handle insecure directories by using -i flag to ignore them
# or use -u to allow insecure directories
compinit -i

# Additional zsh completion improvements
setopt AUTO_LIST        # Automatically list choices on ambiguous completion
setopt AUTO_MENU        # Show completion menu on successive tab press
setopt COMPLETE_IN_WORD # Complete from both ends of a word
setopt ALWAYS_TO_END    # Move cursor to the end of a completed word

# AWS completion (after compinit)
if [ -n "$AWS_COMPLETER_PATH" ] && [ -x "$AWS_COMPLETER_PATH" ]; then
  autoload -U +X bashcompinit && bashcompinit
  complete -C "$AWS_COMPLETER_PATH" aws
fi

# AWS vault completion (after compinit)
if [ "$AWS_VAULT_AVAILABLE" = "yes" ]; then
  eval "$(aws-vault --completion-script-zsh)"
fi

# Intel Homebrew (x86_64) only for consistency
if [[ -x "/usr/local/bin/brew" ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

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

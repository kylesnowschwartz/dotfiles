# shellcheck shell=bash
# ~/.bashrc: executed by bash(1) for non-login shells.
# Cross-platform configuration for macOS and Linux

# Exit if not running interactively
case $- in
*i*) ;;
*) return ;;
esac

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
# SHELL BEHAVIOR
#################################################

# History management
HISTCONTROL=ignoreboth # Don't store duplicates or commands starting with space
HISTSIZE=1000000
HISTFILESIZE=1000000
shopt -s histappend # Append to history file, don't overwrite

# Terminal behavior
shopt -s checkwinsize # Update window size after each command

# Input mode
set editing-mode vi # Use vi mode for readline
set -o vi           # Use vi mode for command line

#################################################
# PATH CONFIGURATION
#################################################

# Common paths (cross-platform)
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

# Man pages with neovim if available
# [ -x "$(command -v nvim 2>/dev/null)" ] && export MANPAGER="nvim +':setlocal nomodifiable' +Man!"
#
# Man pages with less but with some enhancements
export MANPAGER="less -R -s -M +Gg --use-color -Dd+r -Du+b"

#################################################
# ALIASES
#################################################

# Source additional aliases if available
[ -f ~/.bash_aliases ] && . ~/.bash_aliases

#################################################
# DEVELOPMENT TOOLS
#################################################

# Language version managers
# -----------------------

# rbenv
if command -v rbenv >/dev/null 2>&1; then
  eval "$(rbenv init - bash)"
  # [ -f "$HOME/set_rbenv_shell.sh" ] && "$HOME/set_rbenv_shell.sh"
fi

# nodenv
[ -x "$(command -v nodenv 2>/dev/null)" ] && eval "$(nodenv init - bash)"

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

# direnv
# export DIRENV_LOG_FORMAT=""
[ -x "$(command -v direnv 2>/dev/null)" ] && eval "$(direnv hook bash)"

# ImageMagick
# export MAGICK_HOME=/usr/local/opt/imagemagick@6j
# export DYLD_LIBRARY_PATH="$(brew --prefix)/lib:$$DYLD_LIBRARY_PATH"
export DYLD_FALLBACK_LIBRARY_PATH="$(brew --prefix)/lib:$DYLD_FALLBACK_LIBRARY_PATH"

# FZF fuzzy finder
if [ -f ~/.fzf.bash ]; then
  . ~/.fzf.bash
elif [ -f /usr/share/doc/fzf/examples/key-bindings.bash ]; then
  . /usr/share/doc/fzf/examples/key-bindings.bash
elif [ -f /usr/share/fzf/shell/key-bindings.bash ]; then
  . /usr/share/fzf/shell/key-bindings.bash
fi

# Git completion
if [ -f ~/git-completion.bash ]; then
  . ~/git-completion.bash
elif [ -f /usr/share/bash-completion/completions/git ]; then
  . /usr/share/bash-completion/completions/git
elif [ -f /etc/bash_completion.d/git ]; then
  . /etc/bash_completion.d/git
fi

# AWS CLI tools
if command -v aws-vault >/dev/null 2>&1; then
  eval "$(aws-vault --completion-script-bash)"
fi

if [ "$OS" = "macos" ]; then
  [ -x /usr/local/bin/aws_completer ] && complete -C '/usr/local/bin/aws_completer' aws
fi

# Yazi file manager
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

# Starship prompt
[ -x "$(command -v starship 2>/dev/null)" ] && eval "$(starship init bash)"

# Enable programmable completion features
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# Ghostty CLI action completions
# if [ -f "$HOME/.config/ghostty/ghostty-completion.bash" ]; then
#   . "$HOME/.config/ghostty/ghostty-completion.bash"
# fi

# For Warp Terminal integration (uncomment if needed)
# if [ "$TERM_PROGRAM" = "WarpTerminal" ]; then
#   printf '\eP$f{"hook": "SourcedRcFileForWarp", "value": { "shell": "bash"}}\x9c'
# fi
#
# Intel Homebrew (x86_64) only for consistency
if [[ -x "/usr/local/bin/brew" ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

# Zoxide better cd
#
eval "$(zoxide init bash --cmd cd)"

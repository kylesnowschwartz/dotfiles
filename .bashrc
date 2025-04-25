# ~/.bashrc: executed by bash(1) for non-login shells.
# Cross-platform configuration for macOS and Linux

# Exit if not running interactively
case $- in
    *i*) ;;
      *) return;;
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
HISTCONTROL=ignoreboth        # Don't store duplicates or commands starting with space
shopt -s histappend           # Append to history file, don't overwrite
HISTSIZE=1000                 # Command history length
HISTFILESIZE=2000             # History file size

# Terminal behavior
shopt -s checkwinsize         # Update window size after each command

# Input mode
set editing-mode vi           # Use vi mode for readline
set -o vi                     # Use vi mode for command line

#################################################
# PATH CONFIGURATION
#################################################

# Common paths (cross-platform)
[ -d "$HOME/.rbenv/bin" ] && export PATH="$HOME/.rbenv/bin:$PATH"
[ -d "$HOME/.npm/bin" ] && export PATH="$HOME/.npm/bin:$PATH"
[ -d "$HOME/.npm-global/bin" ] && export PATH="$HOME/.npm-global/bin:$PATH"
[ -d "$HOME/go/bin" ] && export PATH="$HOME/go/bin:$PATH"
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
  [ -x /usr/libexec/java_home ] && export JAVA_HOME=$(/usr/libexec/java_home)

  # macOS Ruby with Homebrew openssl
  if command -v brew >/dev/null 2>&1; then
    RUBY_CONFIGURE_OPTS="--with-openssl-dir=$(brew --prefix openssl@1.1 2>/dev/null || echo '/usr/local')"
  fi
fi

# Ripgrep configuration
if [ -f "$HOME/config/.ripgreprc" ]; then
  export RIPGREP_CONFIG_PATH="$HOME/config/.ripgreprc"
elif [ -f "$HOME/.config/ripgrep/config" ]; then
  export RIPGREP_CONFIG_PATH="$HOME/.config/ripgrep/config"
fi

# Man pages with neovim if available
[ -x "$(command -v nvim 2>/dev/null)" ] && export MANPAGER="nvim +':setlocal nomodifiable' +Man!"

#################################################
# ALIASES
#################################################

# Basic file operations (cross-platform)
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias mkdir='mkdir -v'
alias cp='cp -v'
alias ..="cd ../"
alias ...="cd ../../"
alias ....="cd ../../../"

# Notification alias
if [ "$OS" = "macos" ]; then
  # macOS notification
  alias alert='terminal-notifier -title "Terminal" -message "$([ $? = 0 ] && echo Command finished successfully || echo Command failed)"'
else
  # Linux notification
  alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'
fi

# Source additional aliases if available
[ -f ~/.bash_aliases ] && . ~/.bash_aliases

#################################################
# DEVELOPMENT TOOLS
#################################################

# Language version managers
# -----------------------

# rbenv
if command -v rbenv >/dev/null 2>&1; then
  eval "$(rbenv init -)"
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
[ -x "$(command -v direnv 2>/dev/null)" ] && eval "$(direnv hook bash)"

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
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
    yazi "$@" --cwd-file="$tmp"
    if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
      builtin cd -- "$cwd"
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

# Clipboard support (handled in bash_aliases)

# For Warp Terminal integration (uncomment if needed)
# if [ "$TERM_PROGRAM" = "WarpTerminal" ]; then
#   printf '\eP$f{"hook": "SourcedRcFileForWarp", "value": { "shell": "bash"}}\x9c'
# fi

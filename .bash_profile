# shellcheck shell=bash
# If the shell is interactive and .bashrc exists, get the aliases and functions
if [[ $- == *i* && -f ~/.bashrc ]]; then
  . ~/.bashrc
fi

# Not needed if loading automatically:
# https://iterm2.com/documentation-shell-integration.html
#
#
if [[ $TERM_PROGRAM != "WarpTerminal" ]]; then
  test -e "${HOME}/.iterm2_shell_integration.bash" && source "${HOME}/.iterm2_shell_integration.bash" || true
fi

# Created by `pipx` on 2024-07-10 01:34:14
# export PATH="$PATH:/Users/kyle/.local/bin"

# Silence macOS zsh default shell warning
export BASH_SILENCE_DEPRECATION_WARNING=1

# Added by `rbenv init` on Fri 20 Jun 2025 22:28:01 NZST
# eval "$(rbenv init - --no-rehash bash)"

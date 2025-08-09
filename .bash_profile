# shellcheck shell=bash
# If the shell is interactive and .bashrc exists, get the aliases and functions
if [[ $- == *i* && -f ~/.bashrc ]]; then
  . ~/.bashrc
  # else
  # echo 'Shell is not interactive'
fi

# Not needed if loading automatically:
# https://iterm2.com/documentation-shell-integration.html
#
if [[ $TERM_PROGRAM != "WarpTerminal" ]]; then
  test -e "${HOME}/.iterm2_shell_integration.bash" && source "${HOME}/.iterm2_shell_integration.bash" || true
fi

# Silence macOS zsh default shell warning
export BASH_SILENCE_DEPRECATION_WARNING=1

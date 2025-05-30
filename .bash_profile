# If the shell is interactive and .bashrc exists, get the aliases and functions
if [[ $- == *i* && -f ~/.bashrc ]]; then
    . ~/.bashrc
fi

test -e "${HOME}/.iterm2_shell_integration.bash" && source "${HOME}/.iterm2_shell_integration.bash" || true


# Created by `pipx` on 2024-07-10 01:34:14
export PATH="$PATH:/Users/kyle/.local/bin"

# Ripgrep configuration
export RIPGREP_CONFIG_PATH="$HOME/Code/dotfiles/.ripgreprc"

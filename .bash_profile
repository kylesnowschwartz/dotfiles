# If the shell is interactive and .bashrc exists, get the aliases and functions
if [[ $- == *i* && -f ~/.bashrc ]]; then
    . ~/.bashrc
fi

test -e "${HOME}/.iterm2_shell_integration.bash" && source "${HOME}/.iterm2_shell_integration.bash" || true


# Created by `pipx` on 2024-07-10 01:34:14
export PATH="$PATH:/Users/kyle/.local/bin"

# Ripgrep configuration
export RIPGREP_CONFIG_PATH="$HOME/Code/dotfiles/.ripgreprc"

# Silence macOS zsh default shell warning
export BASH_SILENCE_DEPRECATION_WARNING=1

# Added by `rbenv init` on Fri 20 Jun 2025 22:28:01 NZST
eval "$(rbenv init - --no-rehash bash)"

# Reload bash configuration - works with symlinks
# This sources .bashrc which in turn sources .bash_aliases
alias reload="source ~/.bashrc && echo 'Bash configuration reloaded'"

# Cross-platform notification for long-running commands
# Usage: sleep 10; alert
if [ "$(uname)" = "Darwin" ]; then
  # macOS notification
  if command -v terminal-notifier >/dev/null 2>&1; then
    alias alert='terminal-notifier -title "Terminal" -message "$([ $? = 0 ] && echo Command finished successfully || echo Command failed)"'
  else
    alias alert='echo "Command completed with status: $?"'
  fi
else
  # Linux notification
  if command -v notify-send >/dev/null 2>&1; then
    alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'
  else
    alias alert='echo "Command completed with status: $?"'
  fi
fi
alias be="bundle exec"
alias mkdir='mkdir -v'
# Cross-platform ls with colors
if [ "$(uname)" = "Darwin" ]; then
  # macOS
  alias ls='ls -AGghs'
else
  # Linux/Unix
  alias ls='ls -Aghs --color=auto'
fi
alias cp='cp -v'
alias ..="cd ../"
alias ...="cd ../../"
alias ....="cd ../../../"

rubymine() {
  open -a RubyMine "$@"
}

ss() {
  rfv "$@"
}

# Clipboard handling - cross-platform support
# On macOS, pbcopy and pbpaste are native commands
# On Linux, we need to create aliases that use xclip or xsel
if [ "$(uname)" != "Darwin" ]; then
  # Only define aliases on non-macOS systems
  if command -v xclip >/dev/null 2>&1; then
    alias pbcopy="xclip -selection clipboard"
    alias pbpaste="xclip -selection clipboard -o"
  elif command -v xsel >/dev/null 2>&1; then
    alias pbcopy="xsel --clipboard --input"
    alias pbpaste="xsel --clipboard --output"
  fi
fi

#review
#alias review='open "https://github.com/envato/marketplace/compare/$(git symbolic-ref --short HEAD)"'
alias review='open "https://github.com/$(git remote get-url origin | sed -E "s/.*:(.+)\/(.+).git/\\1\/\\2/")/compare/$(git symbolic-ref --short HEAD)"'

alias prep="rails db:migrate db:test:prepare"

#git aliases
alias gc="git commit -v"
alias ga="git add"
alias gs="git status"
alias gl="git log --graph --full-history --all --color --pretty=format:'%x1b[31m%h%x09%x1b[32m%d%x1b[0m%x20%s'"
alias gd="git diff"
alias gp="git push"
alias gco="git checkout"
alias pullff="git pull --ff"
alias fwl="git push --force-with-lease"
irebase() {
  local n=$1
  EDITOR=vim git rebase -i HEAD~$n
}

#rails_upgrade
alias dn="DEPENDENCIES_NEXT=1"

## Envato Aliases

alias marketplace_server="MARKET_SOCKET_DIR=/tmp bundle exec unicorn_rails -c config/unicorn.rb"
alias cdm="cd /Users/kyle/Code/market/"

# /aws accounts <account-id> # in slack

# aws-vault login Customer-Production.Developer
# aws-login Customer-Production.Developer
aws-login() {
  aws-vault login $1
}

# takes a role as $1 e.g. Customer-Production.Developer, and then all the rest of the arguments as your command to be
# executed
aws-exec() {
  aws-vault exec $1 -- ${@:2}
}

list-instances() {
  (
    echo -e "Instance ID\tPrivate IP\tAMI\tLaunch Time\tName\tRevision tag"
    aws ec2 describe-instances \
      --region $AWS_REGION \
      --filters Name=instance-state-name,Values=running \
      --query 'Reservations[*].Instances[*].[InstanceId,PrivateIpAddress,ImageId,LaunchTime,not_null(Tags[?Key==`Name`].Value | [0], `<noname>`),not_null(Tags[?Key==`deployment.revision`].Value | [0], `<none>`)]' \
      --output text | sort -k5,5
  ) | column -s $'\t' -t
}

list_instances() {
  list-instances
}

# Example stackmaster apply
# staging
# aws-exec cloudformation-user@envato-customer-staging bundle exec stack_master apply eu-west-1 shopfront_ext_alb_storefront_tg
# production
# aws exec cloudformation@envato-customer-production bundle exec stack_master apply us-east-1 shopfront_ext_alb_storefront_tg

# Opensearch
function opensearch() {
  JAVA_HOME="$(asdf where java zulu-17.46.19)" "$(asdf which opensearch)"
}

## End Envato Aliases
gshow() {
  git show ${1:null} --word-diff=color
}

gitlog() {
  git log main.. --format="%Cgreen[ $(git symbolic-ref --short HEAD) %C(bold blue)%h ] %C(green)%ar %C(bold blue)%an %Creset%s" --no-merges --reverse
}

# show next (newer) commit
git_next() {
  BRANCH=$(git show-ref | grep $(git show-ref -s -- HEAD) | sed 's|.*/\(.*\)|\1|' | grep -v HEAD | sort | uniq)
  HASH=$(git rev-parse $BRANCH)
  PREV=$(git rev-list --topo-order HEAD..$HASH | tail -1)
  git show $PREV
}

################
# TMUX #########
################

# Basic tmux shortcut
alias tm="tmux"

# Smart tmux session start/attach - uses directory name + hash if no name provided
# Usage: tmx [optional_session_name]
tmx() {
  if [ -n "$1" ]; then
    tmux new-session -A -s "$1"
  else
    tmux new-session -A -s $(basename $PWD | tr -d .)
  fi
}

# List all tmux sessions
alias tml="tmux list-sessions"

# Attach to last session or create one if none exists
alias tma="tmux attach || tmux new-session"

# Attach to a specific session by name
alias tmat="tmux attach-session -t"

# Kill a specific session (usage: tmk session_name)
alias tmk="tmux kill-session -t"

alias tmk!="tmux kill-server"

# Kill all sessions except the current one
alias tmka="tmux kill-session -a"

# Reload tmux configuration
alias tmr="tmux source-file ~/.config/tmux/tmux.conf"

# Create a new session with a specific name in a specific directory
# Usage: tmd session_name ~/path/to/directory
tmd() {
  tmux new-session -s "$1" -c "$2"
}

# Switch between tmux sessions using fzf if available
# Usage: tms
tms() {
  if command -v fzf >/dev/null 2>&1; then
    session=$(tmux list-sessions -F "#{session_name}" | fzf --height 40% --reverse)
    if [[ -n "$session" ]]; then
      tmux switch-client -t "$session"
    fi
  else
    echo "fzf not found. Install it for interactive session switching."
    tmux choose-session
  fi
}

# Display tmux aliases help
# Usage: tmh
tmh() {
  echo "TMUX Aliases Quick Reference:"
  echo "-----------------------------"
  echo "tmx [name] : Create/attach session (uses dir name+hash if no name provided)"
  echo "tm         : Basic tmux command"
  echo "tml        : List all tmux sessions"
  echo "tma        : Attach to last session or create one if none exists"
  echo "tmat NAME  : Attach to a specific session by name"
  echo "tmd NAME DIR : Create new session with NAME in directory DIR"
  echo "tmk NAME   : Kill session with NAME"
  echo "tmka       : Kill all sessions except current"
  echo "tmk!       : Kill all sessions"
  echo "tmr        : Reload tmux configuration"
  echo "tms        : Switch between sessions interactively (uses fzf if available)"
  echo "tmh        : Display this help message"
}

# CLAUDE
#
claude() {
  /Users/kyle/.claude-wrapper "$@"
}

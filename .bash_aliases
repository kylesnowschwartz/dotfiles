# shellcheck shell=bash
# Reload bash configuration - works with symlinks
# This sources .bashrc which in turn sources .bash_aliases
alias reload="source ~/.zshrc && echo 'Shell configuration reloaded'"

# Cross-platform notification for long-running commands
# Usage: sleep 10; alert
if [ "$(uname)" = "Darwin" ]; then
  # macOS notification
  if command -v terminal-notifier >/dev/null 2>&1; then
    alias alert='terminal-notifier -title "O Captain! My Captain!" -message "$([ $? = 0 ] && echo Command finished successfully || echo Command failed)"'
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

# Shortcut Aliases

alias cp='cp -v'
alias ..="cd ../"
alias ...="cd ../../"
alias ....="cd ../../../"
alias .....="cd ../../../../"

rubymine() {
  open -a RubyMine "$@"
}

finder() {
  local path="${1:-.}"
  if [[ ! -e "$path" ]]; then
    echo "finder: path not found: $path"
    return 1
  fi
  open -R "$path"
}

trae-cli() {
  local task_or_file="$1"
  local working_dir="${2:-$(pwd)}"

  if [[ -z "$task_or_file" ]]; then
    echo "Usage: trae-cli <task|file> [working-dir]"
    echo "Examples:"
    echo "  trae-cli 'analyze the code' /path/to/project"
    echo "  trae-cli ./task.md /path/to/project"
    return 1
  fi

  # If it's a file, read its contents; otherwise use as-is
  local task
  if [[ -f "$task_or_file" ]]; then
    task=$(cat "$task_or_file")
  else
    task="$task_or_file"
  fi

  uv run --directory ~/Code/trae-agent/ trae-cli run "$task" --working-dir "$working_dir"
}

# Modern CLI Alternatives
# ls - eza
# ps - procs
# df - duf
# grep - rg
# cat - bat
# find - fd
#
if command -v eza >/dev/null 2>&1; then
  # Use eza if available
  alias ls='eza -lA --no-user --no-permissions -o --time-style=relative --group-directories-first --icons=always --all'
elif [ "$(uname)" = "Darwin" ]; then
  # macOS fallback
  alias ls='ls -AGhs'
else
  # Linux/Unix fallback
  alias ls='ls -Ahs --color=auto'
fi

if command -v procs >/dev/null 2>&1; then
  alias ps='procs'
fi

if command -v duf >/dev/null 2>&1; then
  alias df='duf'
fi

# alias grep='rg'  # Disabled: breaks grep -E flag compatibility
# alias find='fd'

# bat wrapper - reads theme from file for instant switching across all shells
# No env var propagation needed - file is read fresh each invocation
bat() {
  local theme_file="$HOME/.config/bat-theme.txt"
  if [[ -f "$theme_file" ]]; then
    command bat --theme="$(< "$theme_file")" "$@"
  else
    command bat "$@"
  fi
}
alias cat='bat --paging=never'

# git wrapper - sets DELTA_FEATURES from file for instant theme switching
# Delta reads DELTA_FEATURES fresh each invocation, so this just works
git() {
  local theme_file="$HOME/.config/delta-theme.txt"
  if [[ -f "$theme_file" ]]; then
    DELTA_FEATURES="$(< "$theme_file")" command git "$@"
  else
    command git "$@"
  fi
}

# Make a new file
#
new() {
  local target="$1"
  [[ -z "$target" ]] && {
    echo "Usage: new <file>"
    return 1
  }

  # Always create parent directories
  /bin/mkdir -p "$(dirname "$target")"

  if [[ ! -f "$target" ]]; then
    /usr/bin/touch "$target"
    echo "Created file: $target"
  else
    echo "File already exists: $target"
  fi
}

# Make a new directory
#
newd() {
  local target="$1"
  [[ -z "$target" ]] && {
    echo "Usage: newd <directory>"
    return 1
  }

  if [[ ! -d "$target" ]]; then
    /bin/mkdir -p "$target"
    echo "Created directory: $target"
    cd "$target" || return
  else
    echo "Directory already exists: $target"
  fi
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

#git aliases
alias gc="~/Code/dotfiles/scripts/smart-commit.sh -v"
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
  EDITOR=vim git rebase -i HEAD~"$n"
}

## Envato Aliases

jira-log() {
  local project="${1:-}"
  local jql="assignee = currentUser() ORDER BY created DESC"
  [[ -n "$project" ]] && jql="assignee = currentUser() AND project = ${project} ORDER BY created DESC"

  local encoded_jql=$(printf '%s' "$jql" | jq -sRr '@uri')

  curl -s -u "${JIRA_EMAIL}:${JIRA_API_TOKEN}" \
    -H "Content-Type: application/json" \
    "https://envato.atlassian.net/rest/api/3/search/jql?jql=${encoded_jql}&fields=summary&fields=created&fields=status&maxResults=50" |
    jq -r '
      # Group issues by status
      .issues |
        group_by(.fields.status.name) |
        map({
          status: .[0].fields.status.name,
          issues: map("\(.key) \(.fields.created[:10]) \(.fields.summary)")
        }) | .[] | "\n\u001b[1;36m\(.status)\u001b[0m", (.issues[] | "  \(.)")
    '
}

alias dn="DEPENDENCIES_NEXT=1" #rails_upgrade
alias marketplace_server="MARKET_SOCKET_DIR=/tmp bundle exec unicorn_rails -c config/unicorn.rb"

# /aws accounts <account-id> # in slack

list-instances() {
  (
    echo -e "Instance ID\tPrivate IP\tAMI\tLaunch Time\tName\tRevision tag"
    aws ec2 describe-instances \
      --region "$AWS_REGION" \
      --filters Name=instance-state-name,Values=running \
      --query "Reservations[*].Instances[*].[InstanceId,PrivateIpAddress,ImageId,LaunchTime,not_null(Tags[?Key==\`Name\`].Value | [0], \`<noname>\`),not_null(Tags[?Key==\`deployment.revision\`].Value | [0], \`<none>\`)]" \
      --output text | sort -k5,5
  ) | column -s $'\t' -t
}

list_instances() {
  list-instances
}

# Opensearch
function opensearch() {
  JAVA_HOME="$(asdf where java zulu-17.46.19)" "$(asdf which opensearch)"
}

# Terraform aliases for Envato/Datadog monitoring
# Usage: tf-plan, tf-apply in infrastructure/terraform/datadog/monitors directory
#
# Required environment variables (add to your .bashrc or .bash_profile):
# export DATADOG_API_KEY="your_datadog_api_key"
# export DATADOG_APP_KEY="your_datadog_app_key"
#
# Get keys from: https://app.datadoghq.com/organization-settings/api-keys
#                https://app.datadoghq.com/organization-settings/application-keys

# Terraform plan with Envato credentials for Datadog monitors
alias tf-plan='export TF_VAR_DATADOG_API_KEY=$DATADOG_API_KEY && export TF_VAR_DATADOG_APP_KEY=$DATADOG_APP_KEY && aws-vault exec Market-Production.Developer -- terraform plan'

# Terraform apply with Envato credentials for Datadog monitors
alias tf-apply='export TF_VAR_DATADOG_API_KEY=$DATADOG_API_KEY && export TF_VAR_DATADOG_APP_KEY=$DATADOG_APP_KEY && aws-vault exec Market-Production.Developer -- terraform apply'

# Terraform apply with auto-approve for quick deployments (use with caution)
alias tf-apply-yes='export TF_VAR_DATADOG_API_KEY=$DATADOG_API_KEY && export TF_VAR_DATADOG_APP_KEY=$DATADOG_APP_KEY && aws-vault exec Market-Production.Developer -- terraform apply -auto-approve'

# Terraform init with proper AWS credentials
alias tf-init='aws-vault exec Market-Production.Developer -- terraform init'

# Terraform format check and fix
alias tf-fmt='terraform fmt -check=true -diff=true'
alias tf-fmt-fix='terraform fmt'

# Terraform validate
alias tf-validate='terraform validate'

# Combined Terraform workflow: init, format, validate, plan
alias tf-check='tf-init && tf-fmt && tf-validate && tf-plan'

## End Envato Aliases

gitlog() {
  git log main.. --format="%Cgreen[ $(git symbolic-ref --short HEAD) %C(bold blue)%h ] %C(green)%ar %C(bold blue)%an %Creset%s" --no-merges --reverse
}

# show next (newer) commit
git_next() {
  BRANCH=$(git show-ref | grep "$(git show-ref -s -- HEAD)" | sed 's|.*/\(.*\)|\1|' | grep -v HEAD | sort | uniq)
  HASH=$(git rev-parse "$BRANCH")
  PREV=$(git rev-list --topo-order HEAD.."$HASH" | tail -1)
  git show "$PREV"
}

# CLAUDE
#
# Wrap interactive claude with claude-chill for sane terminal rendering
# DISABLED: claude-chill has issues with Kitty keyboard protocol (see github.com/davidbeesley/claude-chill/issues/15)
# claude() {
#   for arg in "$@"; do
#     [[ "$arg" == "-p" ]] && { command claude "$@"; return; }
#   done
#   claude-chill -a 0 claude "$@"
# }

# Claude sound controls (uses ~/.config/claude/sounds.conf)
# off   - Silent notifications (visual only)
# glass - macOS notification sound (default)
# aoe   - Age of Empires themed sounds
alias claude-quiet='mkdir -p ~/.config/claude && echo "SOUND_MODE=off" > ~/.config/claude/sounds.conf && echo "Claude sounds disabled (SOUND_MODE=off)"'
alias claude-glass='mkdir -p ~/.config/claude && echo "SOUND_MODE=glass" > ~/.config/claude/sounds.conf && echo "Claude sounds: glass (macOS default)"'
alias claude-aoe='mkdir -p ~/.config/claude && echo "SOUND_MODE=aoe" > ~/.config/claude/sounds.conf && echo "Claude sounds: Age of Empires"'

# Quick Claude CLI with Haiku model - blazing fast text-only responses
# Disables all tools and MCP servers for maximum speed
# Usage:
#   @@ "quoted query"  - Direct query with arguments
#   @@                 - Interactive prompt (handles special chars automatically)
@@() {
  if [[ $# -eq 0 ]]; then
    # Interactive mode - bypasses shell parsing
    echo -n "Query: "
    read -r query
    [[ -z "$query" ]] && return 1
    claude -p --model haiku --tools "" --strict-mcp-config "$query"
  else
    # Argument mode - still useful for simple queries
    set -f
    trap 'set +f' EXIT
    claude -p --model haiku --tools "" --strict-mcp-config "$*"
  fi
}

# Turn .mov into gif
#
gif() { ffmpeg -i "$1" -vf "setpts=0.80*PTS" -r 15 -f gif "${1%.*}.gif"; }

# Unified theme switcher - file-based, instant effect in all shells
# Wrapper functions (bat, git) read theme files fresh each invocation
theme() {
  ~/.config/ghostty/switch-theme.sh "$@"
}

# Starship theme switcher
# NOTE: Prefer `theme <name>` for coordinated switching (Ghostty+Starship+Delta+bat+eza)
starship-set() {
  local theme="$1"
  local starship_dir="/Users/kyle/Code/dotfiles/starship"
  local config_path="$HOME/.config/starship.toml"

  [[ -z "$theme" ]] && {
    echo "Usage: starship-set <theme-name>"
    echo ""
    echo "Available themes:"
    ls "$starship_dir"/*-starship.toml 2>/dev/null | sed 's/.*\///;s/-starship\.toml//' | sort
    echo ""
    echo "Downloadable presets:"
    starship preset -l | while read -r preset; do
      [[ ! -f "$starship_dir/${preset}-starship.toml" ]] && echo "$preset"
    done
    return 1
  }

  # Check if it's a built-in preset first
  if starship preset -l | grep -q "^${theme}$"; then
    local preset_file="$starship_dir/${theme}-starship.toml"

    # Check if preset file already exists (might be customized)
    if [[ -f "$preset_file" ]]; then
      ln -sf "$preset_file" "$config_path"
      echo "Switched to existing preset '$theme': $preset_file"
    else
      # Download fresh preset
      {
        echo "# Starship preset: $theme"
        echo "# Downloaded: $(date '+%Y-%m-%d')"
        echo "# Customize as needed - remove these comments to make it 'custom'"
        echo ""
        starship preset "$theme"
      } >"$preset_file"
      ln -sf "$preset_file" "$config_path"
      echo "Downloaded and switched to preset '$theme': $preset_file"
    fi
    return 0
  fi

  # Check for custom themes
  local theme_file="$starship_dir/${theme}-starship.toml"

  if [[ ! -f "$theme_file" ]]; then
    echo "Theme '$theme' not found."
    echo ""
    echo "Available themes:"
    ls "$starship_dir"/*-starship.toml 2>/dev/null | sed 's/.*\///;s/-starship\.toml//' | sort
    echo ""
    echo "Downloadable presets:"
    starship preset -l | while read -r preset; do
      [[ ! -f "$starship_dir/${preset}-starship.toml" ]] && echo "$preset"
    done
    return 1
  fi

  ln -sf "$theme_file" "$config_path"
  echo "Switched to theme '$theme': $theme_file"
}

# Works with files, directories, and OpenInTerminal app
# $ defaults write /Users/kyle/Library/Group\ Containers/group.wang.jianing.app.OpenInTerminal/Library/Preferences/group.wang.jianing.app.OpenInTerminal.plist NeovimCommand "/usr/local/bin/iterm-nvim PATH"
#
alias iterm_nvim='iterm-nvim'

# Delta color scheme switching - uses delta's features system with proper cleanup
# DEPRECATED: Prefer `theme <name>` for coordinated switching across all tools
alias delta-light='git config --global --unset delta.dark 2>/dev/null; git config --global --unset delta.light 2>/dev/null; git config --unset delta.dark 2>/dev/null; git config --unset delta.light 2>/dev/null; git config delta.features light; echo "Delta switched to light mode"'
alias delta-dark='git config --global --unset delta.light 2>/dev/null; git config --global --unset delta.dark 2>/dev/null; git config --unset delta.light 2>/dev/null; git config --unset delta.dark 2>/dev/null; git config delta.features dark; echo "Delta switched to dark mode"'
alias delta-reset='git config --global --unset-all delta.light 2>/dev/null; git config --global --unset-all delta.dark 2>/dev/null; git config --unset delta.light 2>/dev/null; git config --unset delta.dark 2>/dev/null; git config --unset delta.features 2>/dev/null; echo "Delta reset to default"'

# Server aliases
alias media='ssh media'

# Git diff tree visualization
alias gdt='git-diff-tree'

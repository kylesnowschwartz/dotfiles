#!/usr/bin/env bash

# --- parse flags ---
show_branch=false
if [[ "$1" == "--show-branch" ]]; then
  show_branch=true
fi

# --- input ---
input=$(cat)
# Single jq call to extract all input fields
read -r session_id transcript raw_model_name < <(echo "$input" | jq -r '[.session_id // "unknown", .transcript_path // "", .model.display_name // "Claude"] | @tsv')

# Color session_id
session_id="\e[90m$(echo "$session_id" | cut -c1-8)\e[0m"

# Set context window based on model
if [[ "${raw_model_name,,}" == *sonnet* ]]; then
  context_window=800000
elif [[ "${raw_model_name,,}" == *opus* ]]; then
  context_window=160000
else
  context_window=160000 # default
fi

# Color model name
model_name="\e[0m\e[95m${raw_model_name}\e[0m"

# --- helpers ---
color() {
  local pct=$1
  if [[ $pct -ge 90 ]]; then
    printf "\e[31m" # red
  elif [[ $pct -ge 70 ]]; then
    printf "\e[33m" # yellow
  else
    printf "\e[32m" # green
  fi
}

comma() {
  printf "%'d" "$1" 2>/dev/null || echo "$1"
}

format_k_decimal() {
  local num=$1
  if [[ $num -ge 1000 ]]; then
    printf "%.1fk" "$(echo "scale=1; $num/1000" | bc)"
  else
    echo "$num"
  fi
}

get_git_branch() {
  # Fast git branch detection that works with symlinks and any directory
  # Use git rev-parse to find repo root and get branch name in one operation
  printf "\e[94m%s\e[0m" "$(git branch --show-current 2>/dev/null)"
}

get_git_changes() {
  # Fast git diff stats using single call - gets all changes (staged + unstaged)
  # Returns formatted string like "+55 -34" with colors, or empty string if no changes/errors
  local changes insertions=0 deletions=0
  changes=$(git diff HEAD --shortstat 2>/dev/null) || return

  [[ -z "$changes" ]] && return

  # Extract insertions and deletions in single operations
  [[ "$changes" =~ ([0-9]+)\ insertions? ]] && insertions=${BASH_REMATCH[1]}
  [[ "$changes" =~ ([0-9]+)\ deletions? ]] && deletions=${BASH_REMATCH[1]}

  # Only output if there are actual changes
  ((insertions > 0 || deletions > 0)) && printf "\e[32m+%d\e[0m \e[31m-%d\e[0m" "$insertions" "$deletions"
}

# --- main logic ---
# Get branch info if requested
branch_info=""
if [[ "$show_branch" == "true" ]]; then
  branch_part=$(get_git_branch)
  branch_changes=$(get_git_changes)
  if [[ -n "$branch_part" ]]; then
    branch_info="$branch_part"
    if [[ -n "$branch_changes" ]]; then
      branch_info+=" $branch_changes"
    fi
  fi
fi

if [[ ! -f "$transcript" ]]; then
  echo -e "$model_name | \e[36mwaiting for intial prompt.\e[0m | $branch_info | $session_id"
  exit 0
fi

# Find entry with latest timestamp among valid main usage entries
# Filters applied in sequence:
#   1. Keep main conversation entries (not sidechain)
#   2. Keep entries with usage data present
#   3. Exclude synthetic model entries
#   4. Exclude API error messages
#   5. Keep entries with either:
#      - No text content (thinking-only entries with valid usage)
#      - Text content that doesn't contain "no response requested"
#   6. Calculate total tokens (input + output + cache read + cache creation)
#   7. Keep only entries with positive token counts
#   8. Return total tokens from most recent valid entry
total=$(jq -s -r '
  [
    .[] |
    select(.isSidechain == false) |
    select(.usage // .message.usage) |
    select((.message.model // "" | ascii_downcase) | (. != "<synthetic>" and (contains("synthetic") | not))) |
    select(.isApiErrorMessage != true) |
    select(
      ([.message.content[]? | select(.type == "text")] | length == 0) or
      ([.message.content[]? | select(.type == "text" and (.text | test("no\\\\s+response\\\\s+requested"; "i")))] | length == 0)
    ) |
    {
      timestamp,
      total: ((.usage // .message.usage) // {} |
        (.input_tokens // 0) +
        (.output_tokens // 0) +
        (.cache_read_input_tokens // 0) +
        (.cache_creation_input_tokens // 0)
      )
    } |
    select(.total > 0)
  ] |
  if length > 0 then max_by(.timestamp).total else 0 end
' "$transcript" 2>/dev/null)

# Handle no usage found
if [[ $total -eq 0 ]]; then
  echo -e "$model_name | \e[36mwaiting for initial prompt.\e[0m | $branch_info | $session_id"
  exit 0
fi

# Calculate percentage and display
if [[ $context_window -gt 0 ]]; then
  pct=$((total * 100 / context_window))
else
  pct=0
fi

color_code=$(color "$pct")
usage_percent_label="\e[0m${color_code}${pct}%\e[0m"
usage_count_label="\e[33m($(format_k_decimal "$total")/$(format_k_decimal "$context_window"))\e[0m"

echo -e "$model_name | $branch_info\n $usage_percent_label $usage_count_label | $session_id"

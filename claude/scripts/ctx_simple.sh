#!/bin/bash
# Read JSON input once
input=$(cat)

# Helper functions for common extractions
# get_version() { echo "$input" | jq -r '.version'; }
# get_duration() { echo "$input" | jq -r '.cost.total_duration_ms'; }
# get_lines_added() { echo "$input" | jq -r '.cost.total_lines_added'; }
# get_lines_removed() { echo "$input" | jq -r '.cost.total_lines_removed'; }
# get_project_dir() { echo "$input" | jq -r '.workspace.project_dir'; }
get_model_name() { echo "$input" | jq -r '.model.display_name'; }
get_current_dir() { echo "$input" | jq -r '.workspace.current_dir'; }
get_cost() { echo "$input" | jq -r '.cost.total_cost_usd'; }
get_transcript_path() { echo "$input" | jq -r '.transcript_path // ""'; }

# Git helper functions
get_git_branch() {
  local branch=$(git branch --show-current 2>/dev/null)
  [[ -n "$branch" ]] && echo "$branch"
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
  # e.g. +5 -1
  ((insertions > 0 || deletions > 0)) && echo "+$insertions -$deletions"
}

# Usage extraction from transcript (simplified version of ctx_monitor.sh logic)
get_total_tokens() {
  local transcript=$(get_transcript_path)
  [[ ! -f "$transcript" ]] && echo "0" && return

  jq -s -r '
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
        if length > 0 then
          max_by(.timestamp).total
        else
          0
        end
        ' "$transcript" 2>/dev/null || echo "0"
}

# Use the helpers
MODEL=$(get_model_name)
DIR=$(get_current_dir)
TOKENS=$(get_total_tokens)
BRANCH=$(get_git_branch)
CHANGES=$(get_git_changes)
COST=$(get_cost)

# Build clean output string
output="[$MODEL] 📁 ${DIR##*/}"
[[ -n "$BRANCH" ]] && output+=" | $BRANCH"
[[ -n "$CHANGES" ]] && output+=" $CHANGES"
if [[ "$TOKENS" != "0" && -n "$TOKENS" ]]; then
  output+=" | $TOKENS"
else
  output+=" | ...waiting"
fi

if [[ "$COST" != "null" && -n "$COST" ]]; then
  rounded_cost=$(printf "%.2f" "$COST" 2>/dev/null || echo "0.00")
  output+=" | \$$rounded_cost"
else
  output+=" | \$0.00"
fi

# Output with explicit color reset to terminal default
printf "\e[0m%s\e[0m\n" "$output"

#!/usr/bin/env bash
# Context window monitor - OPTIMIZED jq version (fewer subprocess calls)

# --- input ---
input=$(cat)
# Single jq call to extract all input fields including current_dir
read -r session_id transcript model_name current_dir < <(echo "$input" | jq -r '[.session_id // "unknown", .transcript_path // "", .model.display_name // "Claude", .workspace.current_dir // ""] | @tsv')

# Format session_id (first 8 chars) and current directory (basename only)
session_id_short=$(echo "$session_id" | cut -c1-8)
current_dir_base=$(basename "$current_dir")

# Color formatting
formatted_session_id="\e[90m${session_id_short}\e[0m"
formatted_model="\e[95m${model_name}\e[0m"
context_window=200000

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

# --- main logic ---
if [[ ! -f "$transcript" ]]; then
  echo -e "$formatted_model | $current_dir_base | \e[36mwaiting for first question\e[0m | $formatted_session_id"
  exit 0
fi

# Find last valid main usage entry using reverse iteration
total=0

while IFS= read -r line; do
  [[ -z "$line" ]] && continue

  # Single jq call to extract all needed fields from the line
  read -r is_sidechain has_usage model is_error total < <(echo "$line" | jq -r '
        [
            (if has("isSidechain") then .isSidechain else true end),
            (if (.usage // .message.usage) then true else false end),
            ((.message.model // "") | ascii_downcase),
            (.isApiErrorMessage // false),
            ((.usage // .message.usage) // {} |
                ((.input_tokens // 0) +
                 (.output_tokens // 0) +
                 (.cache_read_input_tokens // 0) +
                 (.cache_creation_input_tokens // 0))
            )
        ] | @tsv' 2>/dev/null || echo "true false '' false 0")

  # Check conditions
  if [[ "$is_sidechain" == "false" ]] && [[ "$has_usage" == "true" ]]; then
    # Skip synthetic models
    if [[ "$model" == "<synthetic>" ]] || [[ "$model" == *"synthetic"* ]]; then
      continue
    fi

    # Skip API errors
    if [[ "$is_error" == "true" ]]; then
      continue
    fi

    # Check for "no response requested" - this still needs a separate check
    if echo "$line" | jq -e '.message.content[]? | select(.type == "text" and (.text | test("no\\s+response\\s+requested"; "i")))' >/dev/null 2>&1; then
      continue
    fi

    # If we have valid usage, use it
    if [[ $total -gt 0 ]]; then
      break
    fi
  fi
done < <(tac "$transcript" 2>/dev/null || tail -r "$transcript" 2>/dev/null)

# Handle no usage found
if [[ $total -eq 0 ]]; then
  echo -e "$formatted_model | $current_dir_base | \e[36mwaiting for first question\e[0m | $formatted_session_id"
  exit 0
fi

# Calculate percentage and display
if [[ $context_window -gt 0 ]]; then
  pct=$((total * 100 / context_window))
else
  pct=0
fi

color_code=$(color "$pct")
usage_percent_label="${color_code}${pct}%\e[0m"
usage_count_label="\e[33m$(comma "$total")/$(comma "$context_window")\e[0m"

echo -e "$formatted_model | $current_dir_base | $usage_percent_label ($usage_count_label) | $formatted_session_id"

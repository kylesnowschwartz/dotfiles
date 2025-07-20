#!/bin/bash
# Extract user messages from Claude conversation JSONL files

# Function to show usage
show_usage() {
  echo "Extract User Messages from Claude Conversations"
  echo "=============================================="
  echo
  echo "Usage:"
  echo "  $0 <session_id>                    - Extract from specific session"
  echo "  $0 <session_id> <output_file>      - Extract to specific file"
  echo "  $0 --all                          - Extract from all conversations"
  echo "  $0 --project <project_name>       - Extract from all sessions in project"
  echo
  echo "Examples:"
  echo "  $0 0f2edbcc-f513-46fe-9dae-468bd2a99eab"
  echo "  $0 0f2edbcc-f513-46fe-9dae-468bd2a99eab my_prompts.txt"
  echo "  $0 --all"
  echo "  $0 --project marketplace"
  echo
  echo "Output format:"
  echo "  Each user message is separated by '---' dividers"
  echo "  Timestamps and session info included as comments"
}

# Check dependencies
check_dependencies() {
  if ! command -v jq &>/dev/null; then
    echo "Error: jq is required but not installed."
    echo "Please install jq: brew install jq"
    exit 1
  fi
}

PROJECTS_DIR="$HOME/.claude/projects"

# Extract user messages from a specific JSONL file
extract_from_file() {
  local jsonl_file="$1"
  local output_file="$2"
  local session_id
  session_id=$(basename "$jsonl_file" .jsonl)
  local project_name
  project_name=$(basename "$(dirname "$jsonl_file")" | sed 's/-Users-kyle-/~\//' | sed 's/-/\//g')

  if [ ! -f "$jsonl_file" ]; then
    echo "Error: File '$jsonl_file' not found."
    return 1
  fi

  echo "# Extracted user messages from session: $session_id" >>"$output_file"
  echo "# Project: $project_name" >>"$output_file"
  echo "# Generated: $(date)" >>"$output_file"
  echo "" >>"$output_file"

  local message_count=0

  # Process each line of the JSONL file
  while IFS= read -r line; do
    if [ -n "$line" ]; then
      # Check if this is a user message
      msg_type=$(echo "$line" | jq -r '.type // empty' 2>/dev/null)

      if [ "$msg_type" = "user" ]; then
        timestamp=$(echo "$line" | jq -r '.timestamp // empty' 2>/dev/null)

        # Extract message content using jq to handle different formats
        content=$(echo "$line" | jq -r '
                    if .message.content then
                        if (.message.content | type) == "array" then
                            [.message.content[] |
                                if .type == "text" then .text
                                elif .type == "tool_result" then "# Tool Result: " + (.content // "")
                                else empty
                                end
                            ] | join("\n")
                        else
                            .message.content
                        end
                    else
                        empty
                    end
                ' 2>/dev/null)

        # Write the message if content exists
        if [ -n "$content" ] && [ "$content" != "null" ] && [ "$content" != "empty" ]; then
          echo "# Message from: $timestamp" >>"$output_file"
          echo "$content" >>"$output_file"
          echo "---" >>"$output_file"
          echo "" >>"$output_file"
          message_count=$((message_count + 1))
        fi
      fi
    fi
  done <"$jsonl_file"

  echo "# Total user messages extracted: $message_count" >>"$output_file"
  echo "" >>"$output_file"

  return $message_count
}

# Extract from specific session
extract_from_session() {
  local session_id="$1"
  local output_file="$2"

  if [ -z "$session_id" ]; then
    echo "Error: Please provide a session_id"
    exit 1
  fi

  if [ -z "$output_file" ]; then
    output_file="${session_id}_user_messages.txt"
  fi

  # Find the JSONL file with this session ID
  local found_file=""
  for project_dir in "$PROJECTS_DIR"/*; do
    if [ -d "$project_dir" ]; then
      local jsonl_file="$project_dir/$session_id.jsonl"
      if [ -f "$jsonl_file" ]; then
        found_file="$jsonl_file"
        break
      fi
    fi
  done

  if [ -z "$found_file" ]; then
    echo "Error: Session $session_id not found"
    exit 1
  fi

  echo "Extracting user messages from session $session_id..."

  # Clear output file
  true >"$output_file"

  extract_from_file "$found_file" "$output_file"
  local message_count=$?

  echo "Extraction complete. Found $message_count user messages."
  echo "Results saved to $output_file"
}

# Extract from all conversations
extract_from_all() {
  local output_file
  output_file="all_user_messages_$(date +%Y%m%d_%H%M%S).txt"
  local total_messages=0
  local total_sessions=0

  echo "Extracting user messages from all conversations..."

  # Clear output file
  true >"$output_file"

  echo "# All User Messages from Claude Conversations" >>"$output_file"
  echo "# Generated: $(date)" >>"$output_file"
  echo "# =============================================" >>"$output_file"
  echo "" >>"$output_file"

  for project_dir in "$PROJECTS_DIR"/*; do
    if [ -d "$project_dir" ]; then
      for jsonl_file in "$project_dir"/*.jsonl; do
        if [ -f "$jsonl_file" ]; then
          extract_from_file "$jsonl_file" "$output_file"
          local session_messages=$?
          total_messages=$((total_messages + session_messages))
          total_sessions=$((total_sessions + 1))
          echo "========================================" >>"$output_file"
          echo "" >>"$output_file"
        fi
      done
    fi
  done

  echo "# SUMMARY" >>"$output_file"
  echo "# Total sessions processed: $total_sessions" >>"$output_file"
  echo "# Total user messages extracted: $total_messages" >>"$output_file"

  echo "Extraction complete. Processed $total_sessions sessions."
  echo "Found $total_messages total user messages."
  echo "Results saved to $output_file"
}

# Extract from specific project
extract_from_project() {
  local project_name="$1"
  local output_file
  output_file="${project_name//\//_}_user_messages_$(date +%Y%m%d_%H%M%S).txt"
  local total_messages=0
  local total_sessions=0

  if [ -z "$project_name" ]; then
    echo "Error: Please provide a project name"
    exit 1
  fi

  echo "Extracting user messages from project: $project_name..."

  # Find project directory (convert project name to directory format)
  local search_pattern
  search_pattern=$(echo "$project_name" | sed 's/~/Users-kyle/' | sed 's/\//\-/g')
  local found_project=""

  for project_dir in "$PROJECTS_DIR"/*; do
    if [ -d "$project_dir" ]; then
      local dir_name
      dir_name=$(basename "$project_dir")
      if [[ "$dir_name" == *"$search_pattern"* ]]; then
        found_project="$project_dir"
        break
      fi
    fi
  done

  if [ -z "$found_project" ]; then
    echo "Error: Project '$project_name' not found"
    echo "Available projects:"
    for project_dir in "$PROJECTS_DIR"/*; do
      if [ -d "$project_dir" ]; then
        local display_name
        display_name=$(basename "$project_dir" | sed 's/-Users-kyle-/~\//' | sed 's/-/\//g')
        echo "  - $display_name"
      fi
    done
    exit 1
  fi

  # Clear output file
  true >"$output_file"

  echo "# User Messages from Project: $project_name" >>"$output_file"
  echo "# Generated: $(date)" >>"$output_file"
  echo "# =============================================" >>"$output_file"
  echo "" >>"$output_file"

  for jsonl_file in "$found_project"/*.jsonl; do
    if [ -f "$jsonl_file" ]; then
      extract_from_file "$jsonl_file" "$output_file"
      local session_messages=$?
      total_messages=$((total_messages + session_messages))
      total_sessions=$((total_sessions + 1))
      echo "========================================" >>"$output_file"
      echo "" >>"$output_file"
    fi
  done

  echo "# SUMMARY" >>"$output_file"
  echo "# Total sessions processed: $total_sessions" >>"$output_file"
  echo "# Total user messages extracted: $total_messages" >>"$output_file"

  echo "Extraction complete. Processed $total_sessions sessions from project '$project_name'."
  echo "Found $total_messages total user messages."
  echo "Results saved to $output_file"
}

# Main script logic
check_dependencies

case "$1" in
"--all")
  extract_from_all
  ;;
"--project")
  if [ -z "$2" ]; then
    echo "Error: Project name required"
    show_usage
    exit 1
  fi
  extract_from_project "$2"
  ;;
"--help" | "-h" | "help" | "")
  show_usage
  ;;
*)
  # Assume it's a session ID
  extract_from_session "$1" "$2"
  ;;
esac

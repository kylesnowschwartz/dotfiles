#!/bin/bash
# Script to query Claude conversations from JSONL files in projects directory

PROJECTS_DIR="$HOME/.claude/projects"

# List all conversations with basic info
list_conversations() {
  echo "Recent Claude conversations:"
  echo "=============================="
  echo

  # Find all JSONL files and get their info
  for project_dir in "$PROJECTS_DIR"/*; do
    if [ -d "$project_dir" ]; then
      project_name=$(basename "$project_dir" | sed 's/-Users-kyle-/~\//' | sed 's/-/\//g')
      echo "📁 Project: $project_name"

      for jsonl_file in "$project_dir"/*.jsonl; do
        if [ -f "$jsonl_file" ]; then
          session_id=$(basename "$jsonl_file" .jsonl)

          # Get first and last message timestamps
          first_msg=$(head -n 1 "$jsonl_file" 2>/dev/null | jq -r '.timestamp // empty' 2>/dev/null)
          last_msg=$(tail -n 1 "$jsonl_file" 2>/dev/null | jq -r '.timestamp // empty' 2>/dev/null)

          # Count total messages
          msg_count=$(wc -l <"$jsonl_file" 2>/dev/null || echo "0")

          # Get first user message as summary
          first_user_msg=$(grep '"type":"user"' "$jsonl_file" | head -n 1 | jq -r '.message.content // .message.content[0].text // empty' 2>/dev/null | cut -c1-100)

          if [ -n "$first_msg" ] && [ -n "$last_msg" ]; then
            echo "  🗨️  Session: $session_id"
            echo "      Started: $(date -d "$first_msg" 2>/dev/null || echo "$first_msg")"
            echo "      Last: $(date -d "$last_msg" 2>/dev/null || echo "$last_msg")"
            echo "      Messages: $msg_count"
            if [ -n "$first_user_msg" ]; then
              echo "      Preview: $first_user_msg..."
            fi
            echo
          fi
        fi
      done
    fi
  done
}

# Get a specific conversation by session ID
get_conversation() {
  local session_id="$1"
  if [ -z "$session_id" ]; then
    echo "Error: Please provide a session_id"
    exit 1
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

  echo "Conversation: $session_id"
  echo "=================================="
  echo

  # Process each line of the JSONL file
  while IFS= read -r line; do
    if [ -n "$line" ]; then
      # Extract message info using jq
      msg_type=$(echo "$line" | jq -r '.type // empty')
      timestamp=$(echo "$line" | jq -r '.timestamp // empty')

      if [ "$msg_type" = "user" ]; then
        content=$(echo "$line" | jq -r '.message.content // .message.content[0].text // empty' 2>/dev/null)
        if [ -n "$content" ] && [ "$content" != "null" ]; then
          echo "[$timestamp] USER:"
          echo "$content"
          echo
        fi
      elif [ "$msg_type" = "assistant" ]; then
        # Handle different content formats
        content=$(echo "$line" | jq -r '
                    if .message.content then
                        if (.message.content | type) == "array" then
                            [.message.content[] |
                                if .type == "text" then .text
                                elif .type == "tool_use" then "🔧 Tool: " + .name + " - " + (.input | tostring)
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

        if [ -n "$content" ] && [ "$content" != "null" ]; then
          echo "[$timestamp] CLAUDE:"
          echo "$content"
          echo
        fi
      fi
    fi
  done <"$found_file"
}

# Search conversations by content
search_conversations() {
  local search_term="$1"
  if [ -z "$search_term" ]; then
    echo "Error: Please provide a search term"
    exit 1
  fi

  echo "Searching for: '$search_term'"
  echo "=============================="
  echo

  for project_dir in "$PROJECTS_DIR"/*; do
    if [ -d "$project_dir" ]; then
      project_name=$(basename "$project_dir" | sed 's/-Users-kyle-/~\//' | sed 's/-/\//g')

      for jsonl_file in "$project_dir"/*.jsonl; do
        if [ -f "$jsonl_file" ]; then
          if grep -i -q "$search_term" "$jsonl_file"; then
            session_id=$(basename "$jsonl_file" .jsonl)
            echo "📁 Project: $project_name"
            echo "🗨️  Session: $session_id"

            # Show matching lines with context
            grep -i -n "$search_term" "$jsonl_file" | while IFS= read -r match; do
              line_num=$(echo "$match" | cut -d: -f1)
              content=$(echo "$match" | cut -d: -f2- | jq -r '.message.content // .message.content[0].text // empty' 2>/dev/null | cut -c1-200)
              if [ -n "$content" ] && [ "$content" != "null" ]; then
                echo "      Line $line_num: $content..."
              fi
            done
            echo
          fi
        fi
      done
    fi
  done
}

# Export a conversation to a readable text file
export_conversation() {
  local session_id="$1"
  local output_file="$2"

  if [ -z "$session_id" ]; then
    echo "Error: Please provide a session_id"
    exit 1
  fi

  if [ -z "$output_file" ]; then
    output_file="claude_conversation_${session_id}.txt"
  fi

  get_conversation "$session_id" >"$output_file"
  echo "Conversation exported to: $output_file"
}

# Display usage information
show_help() {
  echo "Claude Conversation Query Tool (JSONL Format)"
  echo "============================================="
  echo
  echo "Usage:"
  echo "  $0 list                                    - List all conversations"
  echo "  $0 get <session_id>                       - Display a specific conversation"
  echo "  $0 search <term>                          - Search conversations for a term"
  echo "  $0 export <session_id> [filename]         - Export conversation to a file"
  echo "  $0 help                                   - Show this help message"
  echo
  echo "Examples:"
  echo "  $0 list"
  echo "  $0 get 0f2edbcc-f513-46fe-9dae-468bd2a99eab"
  echo "  $0 search 'allowed-tools'"
  echo "  $0 export 0f2edbcc-f513-46fe-9dae-468bd2a99eab my_conversation.txt"
  echo
  echo "Note: Conversations are stored in $PROJECTS_DIR"
}

# Check if jq is available
check_dependencies() {
  if ! command -v jq &>/dev/null; then
    echo "Error: jq is required but not installed."
    echo "Please install jq: brew install jq"
    exit 1
  fi
}

# Main command processing
check_dependencies

case "$1" in
list)
  list_conversations
  ;;
get)
  get_conversation "$2"
  ;;
search)
  search_conversations "$2"
  ;;
export)
  export_conversation "$2" "$3"
  ;;
help | --help | -h | "")
  show_help
  ;;
*)
  echo "Error: Unknown command '$1'"
  echo
  show_help
  exit 1
  ;;
esac

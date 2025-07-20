#!/bin/bash
# Auto-stage new files created by Claude Code, respecting .gitignore
# Consensus implementation: Optimal for Claude Code hook environment
#
# CRITICAL REQUIREMENTS ADDRESSED:
# ✓ Respects .gitignore patterns using git check-ignore
# ✓ Fast execution for high-frequency hook operations
# ✓ Minimal dependencies (git, jq optional with python fallback)
# ✓ Robust error handling with appropriate exit codes
# ✓ Secure by default - won't stage unwanted files

set -euo pipefail

# Read JSON input from stdin (Claude Code hook requirement)
input=$(cat)

# DEBUG: Log what we received (remove after debugging)
echo "[DEBUG] Hook triggered at $(date)" >&2
echo "[DEBUG] Hook received input: $input" >&2

# Parse JSON using jq if available, fallback to python
if command -v jq >/dev/null 2>&1; then
  file_path=$(echo "$input" | jq -r '.tool_input.file_path // ""')
  # Claude Code uses different fields - check for successful file creation
  response_type=$(echo "$input" | jq -r '.tool_response.type // ""')
  response_file_path=$(echo "$input" | jq -r '.tool_response.filePath // ""')
else
  # Python fallback with specific error handling
  file_path=$(echo "$input" | python3 -c "
import json, sys
try:
    data = json.load(sys.stdin)
    print(data.get('tool_input', {}).get('file_path', ''))
except (json.JSONDecodeError, KeyError):
    print('')
")
  # Claude Code uses different fields - check for successful file creation
  response_type=$(echo "$input" | python3 -c "
import json, sys
try:
    data = json.load(sys.stdin)
    print(data.get('tool_response', {}).get('type', ''))
except (json.JSONDecodeError, KeyError):
    print('')
")
  response_file_path=$(echo "$input" | python3 -c "
import json, sys
try:
    data = json.load(sys.stdin)
    print(data.get('tool_response', {}).get('filePath', ''))
except (json.JSONDecodeError, KeyError):
    print('')
")
fi

# DEBUG: Show parsed values
echo "[DEBUG] Parsed file_path: '$file_path'" >&2
echo "[DEBUG] Parsed response_type: '$response_type'" >&2
echo "[DEBUG] Parsed response_file_path: '$response_file_path'" >&2

# Exit early if invalid input or failed operation
# Success means: we have a file path and either type="create" or response_file_path matches
if [[ -z "$file_path" || ("$response_type" != "create" && "$response_file_path" != "$file_path") ]]; then
  echo "[DEBUG] Exiting - invalid input or failed operation" >&2
  exit 0
fi

# Verify file exists (defensive programming)
[[ -f "$file_path" ]] || exit 0

# Determine git repository context
file_dir=$(dirname "$file_path")
[[ "$file_dir" == "." ]] && file_dir=$(pwd)

# Skip if not in a git repository
if ! git -C "$file_dir" rev-parse --git-dir >/dev/null 2>&1; then
  exit 0
fi

# Skip if file is already tracked by git
if git -C "$file_dir" ls-files --error-unmatch "$file_path" >/dev/null 2>&1; then
  exit 0
fi

# CRITICAL SECURITY CHECK: Respect .gitignore patterns
if git -C "$file_dir" check-ignore --quiet "$file_path" 2>/dev/null; then
  echo "Skipping ignored file: $file_path"
  exit 0
fi

# Stage the new file
if git -C "$file_dir" add "$file_path" 2>/dev/null; then
  echo "Auto-staged new file: $file_path"
else
  echo "Failed to stage file: $file_path" >&2
  exit 1
fi

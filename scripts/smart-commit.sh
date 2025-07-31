#!/bin/bash

# Smart Git Commit - Auto-restage and retry when pre-commit hooks fix files
# Usage: smart-commit [git commit options and arguments]

set -euo pipefail

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Function to check if files were modified by hooks
check_hook_modifications() {
  local modified_files
  modified_files=$(git diff --name-only)

  if [[ -n "$modified_files" ]]; then
    echo -e "${YELLOW}📝 Pre-commit hooks modified the following files:${NC}"
    echo "$modified_files" | sed 's/^/  /'

    return 0
  else
    return 1
  fi
}

# Function to stage modified files
stage_modified_files() {
  local modified_files
  modified_files=$(git diff --name-only)

  if [[ -n "$modified_files" ]]; then
    echo -e "${BLUE}🔄 Restaging modified files...${NC}"

    # Stage files one by one with proper error handling
    local failed_files=()
    while IFS= read -r file; do
      if [[ -n "$file" ]]; then
        if git add "$file" 2>/dev/null; then
          echo "  ✓ Staged: $file"
        else
          echo "  ✗ Failed to stage: $file"
          failed_files+=("$file")
        fi
      fi
    done <<<"$modified_files"

    # Report any failures
    if [[ ${#failed_files[@]} -gt 0 ]]; then
      echo -e "${YELLOW}⚠️  Failed to stage ${#failed_files[@]} file(s). Continuing with successful stages.${NC}"
      for file in "${failed_files[@]}"; do
        echo "    - $file"
      done
    fi

    return 0
  else
    return 1
  fi
}

# Main commit function
smart_commit() {
  local attempt=1
  local max_attempts=3

  echo -e "${BLUE}🚀 Attempting commit (attempt $attempt/$max_attempts)...${NC}"

  while [[ $attempt -le $max_attempts ]]; do
    # Try to commit
    if git commit "$@"; then
      echo -e "${GREEN}✅ Commit successful!${NC}"
      return 0
    else
      local exit_code=$?

      # Check if files were modified by pre-commit hooks
      if check_hook_modifications; then
        if [[ $attempt -lt $max_attempts ]]; then
          stage_modified_files
          ((attempt++))
          echo -e "${YELLOW}🔄 Retrying commit (attempt $attempt/$max_attempts)...${NC}"
        else
          echo -e "${RED}❌ Maximum retry attempts reached. Please review the changes manually.${NC}"
          return $exit_code
        fi
      else
        # No files were modified, so this is a genuine commit failure
        echo -e "${RED}❌ Commit failed without file modifications. Check the error above.${NC}"
        return $exit_code
      fi
    fi
  done
}

# Check if we're in a git repository
if ! git rev-parse --git-dir >/dev/null 2>&1; then
  echo -e "${RED}❌ Error: Not in a git repository${NC}" >&2
  exit 1
fi

# Run the smart commit function with all passed arguments
smart_commit "$@"

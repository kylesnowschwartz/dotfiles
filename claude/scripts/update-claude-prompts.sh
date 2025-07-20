#!/bin/bash

# Script to check and update claude-code-prompts.js from the GitHub gist
# Usage: ./update-claude-prompts.sh

set -e

GIST_URL="https://gist.githubusercontent.com/transitive-bullshit/487c9cb52c75a9701d312334ed53b20c/raw"
LOCAL_FILE="/Users/kyle/.claude/claude-code-prompts.js"
TEMP_FILE="/tmp/claude-code-prompts-latest.js"

echo "🔍 Checking for updates to Claude Code prompts..."

# Download the latest version
curl -s "$GIST_URL" -o "$TEMP_FILE"

if [ ! -f "$TEMP_FILE" ]; then
  echo "❌ Failed to download latest version"
  exit 1
fi

# Check if local file exists
if [ ! -f "$LOCAL_FILE" ]; then
  echo "📄 Local file doesn't exist, creating it..."
  mv "$TEMP_FILE" "$LOCAL_FILE"
  echo "✅ Created $LOCAL_FILE"
  exit 0
fi

# Compare files
if cmp -s "$LOCAL_FILE" "$TEMP_FILE"; then
  echo "✅ Your file is already up to date!"
  rm "$TEMP_FILE"
else
  echo "🔄 Updates found! Backing up current file..."
  cp "$LOCAL_FILE" "${LOCAL_FILE}.backup.$(date +%Y%m%d-%H%M%S)"

  echo "📥 Updating local file..."
  mv "$TEMP_FILE" "$LOCAL_FILE"

  echo "✅ Successfully updated claude-code-prompts.js"
  echo "💾 Backup saved as ${LOCAL_FILE}.backup.$(date +%Y%m%d-%H%M%S)"

  # Show a brief diff summary
  echo ""
  echo "📊 Summary of changes:"
  echo "Old file size: $(wc -c <"${LOCAL_FILE}.backup."*)"
  echo "New file size: $(wc -c <"$LOCAL_FILE")"
fi

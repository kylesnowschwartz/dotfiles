#!/usr/bin/env bash
# Theme switcher script for Ghostty and Starship
# Usage: switch-theme.sh [cobalt2|dayfox]

set -euo pipefail

set_claude_theme() {
  local theme="$1"
  local config="$CLAUDE_CONFIG"

  # Skip if jq not installed or config doesn't exist
  if ! command -v jq &>/dev/null || [[ ! -f "$config" ]]; then
    return 2
  fi

  # Get original permissions (macOS vs Linux compatible)
  local perms
  perms=$(stat -f "%OLp" "$config" 2>/dev/null || stat -c "%a" "$config" 2>/dev/null)

  # Generate unique temp file
  local tmpfile="${config}.tmp.$$.$RANDOM"

  # Update theme: dark = remove key, light = set value
  if [[ "$theme" == "dark" ]]; then
    jq 'del(.theme)' "$config" >"$tmpfile"
  else
    jq --arg t "$theme" '.theme = $t' "$config" >"$tmpfile"
  fi

  # Atomic rename with permission preservation
  if [[ $? -eq 0 && -s "$tmpfile" ]]; then
    chmod "$perms" "$tmpfile" && mv "$tmpfile" "$config"
    return 0
  else
    rm -f "$tmpfile"
    return 1
  fi
}

CONFIG_FILE="$HOME/.config/ghostty/config"
STARSHIP_CONFIG="$HOME/.config/starship.toml"
STARSHIP_DIR="$HOME/Code/dotfiles/starship"
CLAUDE_CONFIG="$HOME/.claude.json"
THEME_MARKER="# CURRENT_THEME:"

if [ $# -eq 0 ]; then
  echo "Usage: $0 [cobalt2|dayfox]"
  echo "Current theme:"
  grep "^$THEME_MARKER" "$CONFIG_FILE" 2>/dev/null || echo "  No theme set"
  exit 0
fi

THEME="$1"

# Validate theme name
if [[ ! "$THEME" =~ ^(cobalt2|dayfox)$ ]]; then
  echo "Error: Invalid theme '$THEME'. Valid options: cobalt2, dayfox"
  exit 1
fi

# Remove existing theme line
sed -i.bak "/^theme = /d" "$CONFIG_FILE"
sed -i.bak "/^$THEME_MARKER/d" "$CONFIG_FILE"

# Add new theme
echo "$THEME_MARKER $THEME" >>"$CONFIG_FILE"

# Map theme names to file names and starship configs
case "$THEME" in
cobalt2)
  echo "theme = cobalt2" >>"$CONFIG_FILE"
  STARSHIP_THEME="chef"
  DELTA_THEME="dark"
  CLAUDE_THEME="dark"
  ;;
dayfox)
  echo "theme = dayfox.ghostty" >>"$CONFIG_FILE"
  STARSHIP_THEME="chef-light"
  DELTA_THEME="light"
  CLAUDE_THEME="light"
  ;;
esac

# Switch Starship theme
STARSHIP_FILE="$STARSHIP_DIR/${STARSHIP_THEME}-starship.toml"
if [[ -f "$STARSHIP_FILE" ]]; then
  ln -sf "$STARSHIP_FILE" "$STARSHIP_CONFIG"
  STARSHIP_STATUS="✓"
else
  STARSHIP_STATUS="⚠"
fi

# Switch Delta theme (clean up old configs first)
git config --global --unset delta.dark 2>/dev/null || true
git config --global --unset delta.light 2>/dev/null || true
git config --unset delta.dark 2>/dev/null || true
git config --unset delta.light 2>/dev/null || true
git config --global delta.features "$DELTA_THEME"

# Switch gh-dash theme
GH_DASH_CONFIG="$HOME/.config/gh-dash/config.yml"
GH_DASH_THEME_DIR="$HOME/Code/dotfiles/gh-dash/themes"
GH_DASH_THEME_FILE="$GH_DASH_THEME_DIR/${THEME}.yml"

if [[ -f "$GH_DASH_THEME_FILE" ]]; then
  cp "$GH_DASH_THEME_FILE" "$GH_DASH_CONFIG"
  GH_DASH_STATUS="✓"
else
  GH_DASH_STATUS="⚠"
fi

# Switch Claude theme
set_claude_theme "$CLAUDE_THEME"
CLAUDE_STATUS=$?
if [[ $CLAUDE_STATUS -eq 0 ]]; then
  CLAUDE_DISPLAY="✓"
elif [[ $CLAUDE_STATUS -eq 2 ]]; then
  CLAUDE_DISPLAY="○" # Skipped (jq missing or config missing)
else
  CLAUDE_DISPLAY="⚠"
fi

echo "✓ Switched to $THEME theme"
echo "  - Ghostty: $THEME"
echo "  - Starship: $STARSHIP_THEME ${STARSHIP_STATUS}"
echo "  - Delta: $DELTA_THEME"
echo "  - gh-dash: $THEME ${GH_DASH_STATUS}"
echo "  - Claude: $CLAUDE_THEME ${CLAUDE_DISPLAY}"
echo "  Reload Ghostty with Cmd+Shift+R to see changes"

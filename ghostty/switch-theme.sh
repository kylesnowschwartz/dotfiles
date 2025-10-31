#!/usr/bin/env bash
# Theme switcher script for Ghostty and Starship
# Usage: switch-theme.sh [cobalt2|dayfox]

set -euo pipefail

CONFIG_FILE="$HOME/.config/ghostty/config"
STARSHIP_CONFIG="$HOME/.config/starship.toml"
STARSHIP_DIR="$HOME/Code/dotfiles/starship"
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
  ;;
dayfox)
  echo "theme = dayfox.ghostty" >>"$CONFIG_FILE"
  STARSHIP_THEME="chef-light"
  DELTA_THEME="light"
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
git config delta.features "$DELTA_THEME"

echo "✓ Switched to $THEME theme"
echo "  - Ghostty: $THEME"
echo "  - Starship: $STARSHIP_THEME ${STARSHIP_STATUS}"
echo "  - Delta: $DELTA_THEME"
echo "  Reload Ghostty with Cmd+Shift+R to see changes"

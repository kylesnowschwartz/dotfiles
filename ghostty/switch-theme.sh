#!/usr/bin/env bash
# Theme switcher script for Ghostty and Starship
# Usage: switch-theme.sh [list|next|prev|<theme-name>]

set -euo pipefail

# =============================================================================
# Constants
# =============================================================================

CONFIG_FILE="$HOME/.config/ghostty/config"
STARSHIP_CONFIG="$HOME/.config/starship.toml"
STARSHIP_DIR="$HOME/Code/dotfiles/starship"
CLAUDE_CONFIG="$HOME/.claude.json"
GH_DASH_CONFIG="$HOME/.config/gh-dash/config.yml"
GH_DASH_THEME_DIR="$HOME/Code/dotfiles/gh-dash/themes"
THEME_MARKER="# CURRENT_THEME:"

# Theme registry: name -> bucket (dark|light)
# Ghostty theme file is derived from name (name or name.ghostty in themes/)
declare -A THEME_BUCKETS=(
  ["cobalt2"]="dark"
  ["cobalt-next-neon"]="dark"
  ["dayfox"]="light"
  ["seoulbones-light"]="light"
)

# Ordered list for cycling
THEME_ORDER=(cobalt2 cobalt-next-neon dayfox seoulbones-light)

# Bucket configurations
declare -A DARK_CONFIG=(
  ["starship"]="chef"
  ["delta"]="dark"
  ["gh_dash"]="cobalt2"
  ["claude"]="dark"
)

declare -A LIGHT_CONFIG=(
  ["starship"]="chef-light"
  ["delta"]="light"
  ["gh_dash"]="dayfox"
  ["claude"]="light"
)

# =============================================================================
# Functions
# =============================================================================

get_current_theme() {
  grep "^$THEME_MARKER" "$CONFIG_FILE" 2>/dev/null | sed "s/^$THEME_MARKER //" || echo ""
}

get_theme_index() {
  local theme="$1"
  for i in "${!THEME_ORDER[@]}"; do
    if [[ "${THEME_ORDER[$i]}" == "$theme" ]]; then
      echo "$i"
      return
    fi
  done
  echo "-1"
}

get_ghostty_theme_value() {
  local theme="$1"
  local themes_dir="${CONFIG_FILE%/*}/themes"

  # Check for theme.ghostty first, then bare name
  if [[ -f "$themes_dir/${theme}.ghostty" ]]; then
    echo "${theme}.ghostty"
  elif [[ -f "$themes_dir/${theme}" ]]; then
    echo "$theme"
  else
    # Assume it's a built-in theme
    echo "$theme"
  fi
}

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

show_usage() {
  local current
  current=$(get_current_theme)
  echo "Usage: $0 [current|list|next|prev|<theme-name>]"
  echo ""
  echo "Commands:"
  echo "  current      Show current theme"
  echo "  list         Show available themes"
  echo "  next         Cycle to next theme"
  echo "  prev         Cycle to previous theme"
  echo "  <theme-name> Switch to specific theme"
  echo ""
  echo "Current theme: ${current:-No theme set}"
}

list_themes() {
  local current
  current=$(get_current_theme)
  echo "Available themes:"
  for theme in "${THEME_ORDER[@]}"; do
    local bucket="${THEME_BUCKETS[$theme]}"
    local marker=""
    [[ "$theme" == "$current" ]] && marker=" (current)"
    printf "  %-20s [%s]%s\n" "$theme" "$bucket" "$marker"
  done
}

update_ghostty_config() {
  local theme="$1"
  local theme_value="$2"

  # Remove existing theme lines
  sed -i.bak "/^theme = /d" "$CONFIG_FILE"
  sed -i.bak "/^$THEME_MARKER/d" "$CONFIG_FILE"

  # Add new theme
  echo "$THEME_MARKER $theme" >>"$CONFIG_FILE"
  echo "theme = $theme_value" >>"$CONFIG_FILE"
}

update_starship_config() {
  local starship_theme="$1"
  local starship_file="$STARSHIP_DIR/${starship_theme}-starship.toml"

  if [[ -f "$starship_file" ]]; then
    ln -sf "$starship_file" "$STARSHIP_CONFIG"
    echo "✓"
  else
    echo "⚠"
  fi
}

update_delta_config() {
  local delta_theme="$1"
  local delta_env_file="$HOME/.config/delta-theme.env"

  # Write DELTA_FEATURES to env file (sourced by shell)
  echo "export DELTA_FEATURES=$delta_theme" >"$delta_env_file"
}

update_gh_dash_config() {
  local theme="$1"
  local theme_file="$GH_DASH_THEME_DIR/${theme}.yml"

  if [[ -f "$theme_file" ]]; then
    cp "$theme_file" "$GH_DASH_CONFIG"
    echo "✓"
  else
    echo "⚠"
  fi
}

apply_theme() {
  local theme="$1"
  local bucket="${THEME_BUCKETS[$theme]}"

  # Get bucket-specific config
  local -n config_ref
  if [[ "$bucket" == "dark" ]]; then
    config_ref=DARK_CONFIG
  else
    config_ref=LIGHT_CONFIG
  fi

  local ghostty_value
  ghostty_value=$(get_ghostty_theme_value "$theme")

  # Apply all theme changes
  update_ghostty_config "$theme" "$ghostty_value"

  STARSHIP_STATUS=$(update_starship_config "${config_ref[starship]}")

  update_delta_config "${config_ref[delta]}"

  GH_DASH_STATUS=$(update_gh_dash_config "${config_ref[gh_dash]}")

  set_claude_theme "${config_ref[claude]}"
  CLAUDE_STATUS=$?
  if [[ $CLAUDE_STATUS -eq 0 ]]; then
    CLAUDE_DISPLAY="✓"
  elif [[ $CLAUDE_STATUS -eq 2 ]]; then
    CLAUDE_DISPLAY="○"
  else
    CLAUDE_DISPLAY="⚠"
  fi

  # Report results
  echo "✓ Switched to $theme [$bucket]"
  echo "  - Ghostty: $ghostty_value"
  echo "  - Starship: ${config_ref[starship]} ${STARSHIP_STATUS}"
  echo "  - Delta: ${config_ref[delta]}"
  echo "  - gh-dash: ${config_ref[gh_dash]} ${GH_DASH_STATUS}"
  echo "  - Claude: ${config_ref[claude]} ${CLAUDE_DISPLAY}"
}

# =============================================================================
# Main
# =============================================================================

if [[ $# -eq 0 ]]; then
  show_usage
  exit 0
fi

case "$1" in
current)
  current=$(get_current_theme)
  if [[ -n "$current" ]]; then
    echo "$current"
  else
    echo "No theme set"
    exit 1
  fi
  ;;
list)
  list_themes
  ;;
next | prev)
  current=$(get_current_theme)
  if [[ -z "$current" ]]; then
    # Default to first theme if none set
    apply_theme "${THEME_ORDER[0]}"
  else
    idx=$(get_theme_index "$current")
    if [[ "$idx" == "-1" ]]; then
      echo "Error: Current theme '$current' not in registry"
      exit 1
    fi

    count=${#THEME_ORDER[@]}
    if [[ "$1" == "next" ]]; then
      new_idx=$(((idx + 1) % count))
    else
      new_idx=$(((idx - 1 + count) % count))
    fi

    apply_theme "${THEME_ORDER[$new_idx]}"
  fi
  ;;
*)
  theme="$1"
  if [[ -z "${THEME_BUCKETS[$theme]+x}" ]]; then
    echo "Error: Unknown theme '$theme'"
    echo "Available themes: ${THEME_ORDER[*]}"
    exit 1
  fi
  apply_theme "$theme"
  ;;
esac

#!/usr/bin/env bash
# BUMPER_HANDS_OFF
# claude-statusline - Width-aware status line wrapper
#
# Runs bumper-lanes on wide terminals, blank on narrow (phone via Moshi).
# Used as Claude Code's statusLine command.
#
# Claude Code's execution environment hardcodes COLUMNS=80 regardless of actual
# terminal width, making tput/stty useless. When running inside tmux, we query
# the pane width directly from tmux which knows the real dimensions.

NARROW_THRESHOLD=80

if [ -n "$TMUX_ATTACHED" ]; then
  # Inside tmux: query real pane width (tput lies inside Claude Code, always 80)
  cols=$(tmux display-message -p '#{pane_width}' 2>/dev/null || echo 120)
  if [ "$cols" -lt "$NARROW_THRESHOLD" ]; then
    exit 0
  fi
fi

# Outside tmux: direct Mac terminal, always wide enough

exec /Users/kyle/.claude/plugins/cache/claude-bumper-lanes/claude-bumper-lanes/3.9.1/bin/bumper-lanes "$@"

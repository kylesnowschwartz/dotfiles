#!/usr/bin/env bash
# moshi-dev-session - Create a tmux session with the Moshi multi-agent layout
#
# Layout:
#   Window 1-3: Claude Code agent workspaces
#   Window 4:   Dev servers (web, expo, etc.)
#   Window 5:   Misc operations (git, deploy, etc.)
#
# Usage: moshi-dev-session [session-name]

set -euo pipefail

SESSION="${1:-dev}"

# Attach to existing session if it already exists
if tmux has-session -t "$SESSION" 2>/dev/null; then
  echo "Session '$SESSION' already exists, attaching..."
  exec tmux attach -t "$SESSION"
fi

# Create session with first agent window
# Short window names fit phone-width status bars (Moshi)
tmux new-session -d -s "$SESSION" -n "a1"

# Mark this session for Moshi push notifications
tmux set-environment -t "$SESSION" MOSHI_NOTIFY 1

# Agent windows 2-3
tmux new-window -t "$SESSION:2" -n "a2"
tmux new-window -t "$SESSION:3" -n "a3"

# Server window for dev servers
tmux new-window -t "$SESSION:4" -n "srv"

# Misc window for git, deploys, ad-hoc work
tmux new-window -t "$SESSION:5" -n "misc"

# Start on the first agent window
tmux select-window -t "$SESSION:1"

# Attach
exec tmux attach -t "$SESSION"

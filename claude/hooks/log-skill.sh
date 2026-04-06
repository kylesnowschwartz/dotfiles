#!/usr/bin/env bash
# Log skill invocations from Claude Code PreToolUse hook.
# Appends tab-delimited lines to ~/.claude/skill-usage.log
# Fields: timestamp, user, skill_name, arguments

set -euo pipefail

payload="$(cat)"
skill=$(echo "$payload" | jq -r '.tool_input.skill // "unknown"')
args=$(echo "$payload" | jq -r '.tool_input.args // ""')

printf '%s\t%s\t%s\t%s\n' \
  "$(date -u '+%Y-%m-%dT%H:%M:%SZ')" \
  "$USER" \
  "$skill" \
  "$args" \
  >>~/.claude/skill-usage.log

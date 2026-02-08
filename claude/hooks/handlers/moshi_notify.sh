#!/usr/bin/env bash
# moshi_notify.sh - Send push notification via Moshi webhook when Claude stops
#
# Hook type: Stop (command)
# Injects a systemMessage with the Moshi webhook curl command so Claude
# can proactively notify the user when tasks complete or need input.
#
# Token setup:
#   mkdir -p ~/.config/moshi
#   echo "YOUR_MOSHI_TOKEN" > ~/.config/moshi/token
#   chmod 600 ~/.config/moshi/token

set -euo pipefail

# Consume hook input from stdin (required before any early exit)
cat >/dev/null

# Only notify in Moshi dev sessions (set by moshi-dev-session.sh)
if [ "${MOSHI_NOTIFY:-}" != "1" ]; then
  exit 0
fi

# Skip if moshi-notify isn't on PATH
if ! command -v moshi-notify &>/dev/null; then
  exit 0
fi

# Inject instructions via systemMessage - Claude decides when to notify
jq -n '{
  decision: "approve",
  systemMessage: "You are in a Moshi mobile dev session. The user is monitoring from their phone. When you complete a task or need input, proactively notify them by running:\n\nmoshi-notify \"TITLE\" \"MESSAGE\"\n\nReplace TITLE with a short label (e.g. the window name or task) and MESSAGE with what you need. Do this BEFORE stopping, not just when asked."
}'

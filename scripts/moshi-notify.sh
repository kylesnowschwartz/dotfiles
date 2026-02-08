#!/usr/bin/env bash
# moshi-notify - Send a push notification to Moshi
#
# Usage: moshi-notify "Title" "Message"

set -euo pipefail

TOKEN_FILE="${HOME}/.config/moshi/token"
WEBHOOK_URL="https://api.getmoshi.app/api/webhook"

if [ ! -f "$TOKEN_FILE" ]; then
  echo "Error: No token at ${TOKEN_FILE}" >&2
  echo "Run: mkdir -p ~/.config/moshi && echo 'YOUR_TOKEN' > ${TOKEN_FILE}" >&2
  exit 1
fi

token="$(tr -d '[:space:]' <"$TOKEN_FILE")"
title="${1:?Usage: moshi-notify TITLE MESSAGE}"
message="${2:?Usage: moshi-notify TITLE MESSAGE}"

curl -s -X POST "$WEBHOOK_URL" \
  -H "Content-Type: application/json" \
  -d "$(jq -n \
    --arg token "$token" \
    --arg title "$title" \
    --arg message "$message" \
    '{token: $token, title: $title, message: $message}')"

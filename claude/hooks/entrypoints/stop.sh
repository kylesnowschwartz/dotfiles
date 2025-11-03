#!/bin/bash
# Simple Stop hook that outputs JSON (INLINE VERSION)

# Read input from STDIN (Claude Code passes hook data as JSON)
read -r input

# Output valid JSON response
echo '{"continue":true,"stopReason":"","suppressOutput":false,"decision":"block","reason":"📄 INLINE HOOK executed successfully from hooks/entrypoints/"}'

# Exit successfully
exit 0

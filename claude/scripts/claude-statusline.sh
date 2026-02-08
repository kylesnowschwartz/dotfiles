#!/usr/bin/env bash
# BUMPER_HANDS_OFF
# Sparse status line: model │ branch │ context% │ ($cost if >$50)
# Then bumper-lanes indicator + diff-tree widgets below.
#
# Context % note: auto-compact fires ~80% (160k/200k), so you'll never
# see 100%. Thresholds: green <40%, yellow 40-60%, red >60%.
#
# Claude Code hardcodes COLUMNS=80; tmux pane width is the real source.

BUMPER=/Users/kyle/.claude/plugins/cache/claude-bumper-lanes/claude-bumper-lanes/3.9.1/bin/bumper-lanes
NARROW=80

# Hide status line on narrow terminals (phone via Moshi)
if [ -n "$TMUX_ATTACHED" ]; then
  cols=$(tmux display-message -p '#{pane_width}' 2>/dev/null || echo 120)
  [ "$cols" -lt "$NARROW" ] && exit 0
fi

input=$(cat)

# Single jq call: model, context%, cost
IFS=$'\t' read -r model ctx_pct cost <<<"$(echo "$input" | jq -r \
  '[(.model.display_name // "?"),
    (.context_window.used_percentage // 0 | floor),
    (.cost.total_cost_usd // 0)]
   | @tsv')"

# Git branch + status indicator (Starship-inspired: + staged, ! modified, clean = nothing)
branch=$(git -C "${CLAUDE_PROJECT_DIR:-.}" branch --show-current 2>/dev/null)
git_indicator=""
if [ -n "$branch" ]; then
  staged=$(
    git -C "${CLAUDE_PROJECT_DIR:-.}" diff --cached --quiet HEAD 2>/dev/null
    echo $?
  )
  dirty=$(
    git -C "${CLAUDE_PROJECT_DIR:-.}" diff --quiet HEAD 2>/dev/null
    echo $?
  )
  [ "$staged" = "1" ] && git_indicator+=$'\033[32m+\033[0m'
  [ "$dirty" = "1" ] && git_indicator+=$'\033[31m!\033[0m'
fi

# Colors
dim=$'\033[2m'
R=$'\033[0m'

# Context % color (adjusted for auto-compact ceiling ~80%)
if [ "$ctx_pct" -ge 80 ]; then
  cc=$'\033[31m'
elif [ "$ctx_pct" -ge 40 ]; then
  cc=$'\033[33m'
else
  cc=$'\033[32m'
fi

# Build line
magenta=$'\033[35m'
line="${magenta}${model}${R}"
[ -n "$branch" ] && line+=" ${dim}│${R} ${branch}${git_indicator}"
line+=" ${dim}│${R} ${cc}${ctx_pct}%${R}"

# Cost only above $50
if [ "$(echo "$cost > 50" | bc -l 2>/dev/null)" = "1" ]; then
  line+=" ${dim}│${R} \$$(printf '%.0f' "$cost")"
fi

echo -e "$line"

# Bumper-lanes widgets
indicator=$(echo "$input" | "$BUMPER" status --widget=indicator 2>/dev/null || true)
diff_tree=$(echo "$input" | "$BUMPER" status --widget=diff-tree 2>/dev/null || true)
[ -n "$indicator" ] && echo "$indicator"
[ -n "$diff_tree" ] && echo "$diff_tree"

exit 0

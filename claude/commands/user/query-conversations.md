# query-conversations

Catalog Claude Code conversations across the corpus. A **discovery** tool —
finds which conversations exist, where they are, and what they're about.
It does **not** render contents.

To actually read a conversation, hand the JSONL path to VCC (the
`conversation-compiler` skill). See `skills/conversation-compiler/SKILL.md`.

## Commands

All output auto-formats: readable text on a TTY, JSON when piped.
Override with `--format {text,json,yaml}`.

```
query_conversations.py list    [--since ... --until ... --project ... --min-messages N --limit N --paths-only --include-subagents]
query_conversations.py last    [--project ... --path --include-subagents]
query_conversations.py get     <session-id> [--path]
query_conversations.py search  <term> [--case-sensitive --project ... --since ... --until ... --limit N --paths-only --include-subagents]
query_conversations.py stats   [--project ... --since ... --until ... --include-subagents]
```

- `list` — browse conversations matching filters.
- `last` — most recent session (by file mtime).
- `get <session-id>` — metadata + path for one session. Fast (filename lookup).
- `search <term>` — raw substring scan of JSONL files. Coarse "does this
  conversation mention X?" filter. For line-level search *within* a
  conversation, use VCC's `--grep` instead.
- `stats` — per-project counts.

Subagent conversations (nested `<session>/subagents/*.jsonl`) are excluded
by default. Add `--include-subagents` if you want them.

## Typical pipeline

Discovery here, reading in VCC:

```bash
# "Show me recent substantial conversations about hooks"
query_conversations.py list --paths-only --since 2025-11-01 --min-messages 30 \
  | while read p; do
      python ~/Code/dotfiles/claude/skills/conversation-compiler/scripts/VCC.py \
        "$p" --grep "hook"
    done

# "Open the last session I worked on"
query_conversations.py last --path | xargs -I {} \
  python ~/Code/dotfiles/claude/skills/conversation-compiler/scripts/VCC.py {}

# "What have I been doing lately?"
query_conversations.py stats --since 2025-11-01
```

## Output shape

`list` and `search` return an object with `total` and a `conversations`
array. Each conversation has:

```
session_id, path, project, started, last_activity,
message_count, user_messages, assistant_messages,
summary, first_user_preview
```

`get` and `last` return a single conversation with the same fields.

`first_user_preview` is a whitespace-collapsed, 100-char excerpt of the
first real user message. It is not filtered — slash-command expansions
like `<command-message>/clear</command-message>` show through so you can
see exactly what kicked the session off.

## Storage

```
~/Code/dotfiles/claude/projects/<encoded-project-path>/<session-id>.jsonl
```

The real project path is read from the `cwd` field inside each JSONL.
The encoded directory name is only a fallback — it mangles hyphens
ambiguously.

## Dependencies

The script starts with a PEP 723 header, so `uv` handles dependencies
automatically:

```bash
./scripts/query_conversations.py ...   # uv installs pyyaml + python-dateutil on first run
```

Requires `uv` on PATH.

## Files

- Script: `~/Code/dotfiles/claude/scripts/query_conversations.py`
- Data:   `~/Code/dotfiles/claude/projects/*/*.jsonl`
- Reader: `~/Code/dotfiles/claude/skills/conversation-compiler/` (VCC)

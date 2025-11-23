# Query Claude Conversations

🔍 **Interactive exploration and search** of Claude conversations from JSONL files with multiple output formats (text, YAML, JSON).

## Quick Start

```bash
# List recent conversations (human-readable)
~/Code/dotfiles/claude/scripts/query_conversations.py list --limit 10

# List as YAML (AI-readable)
~/Code/dotfiles/claude/scripts/query_conversations.py list --format yaml --since 2025-11-01

# Search for topics
~/Code/dotfiles/claude/scripts/query_conversations.py search "git hooks" --format yaml

# Get specific conversation
~/Code/dotfiles/claude/scripts/query_conversations.py get <session-id> --format json

# Export conversation
~/Code/dotfiles/claude/scripts/query_conversations.py export <session-id> output.yaml
```

## Commands

### list - Browse all conversations

```bash
~/Code/dotfiles/claude/scripts/query_conversations.py list [OPTIONS]

Options:
  --format {yaml,json,text}  Output format (default: text)
  --since DATE              Filter conversations since date (e.g., 2025-11-01)
  --until DATE              Filter conversations until date
  --project PATTERN         Filter by project path (substring match)
  --min-messages N          Show only conversations with at least N messages
  --limit N                 Limit number of results
```

**Examples:**
```bash
# Recent conversations (human-readable)
query_conversations.py list --limit 10

# All conversations from November as YAML
query_conversations.py list --format yaml --since 2025-11-01

# Substantial conversations only
query_conversations.py list --min-messages 20 --limit 5

# Specific project
query_conversations.py list --project "dotfiles" --format json
```

### get - Display a specific conversation

```bash
~/Code/dotfiles/claude/scripts/query_conversations.py get <session-id> [OPTIONS]

Options:
  --format {yaml,json,text}  Output format (default: text)
  --no-messages             Show only metadata, not messages
  --user-only               Show only user messages (auto-filters system noise)
  --assistant-only          Show only assistant messages
```

**Examples:**
```bash
# Full conversation as YAML (great for AI analysis)
query_conversations.py get abc123-session-id --format yaml

# Metadata only
query_conversations.py get abc123-session-id --no-messages

# Only user messages for sentiment analysis (excludes system noise automatically)
query_conversations.py get abc123-session-id --user-only --format yaml

# Only assistant responses
query_conversations.py get abc123-session-id --assistant-only --format json

# Full conversation as JSON for piping
query_conversations.py get abc123-session-id --format json | jq '.messages[].content'
```

### search - Find conversations by content

```bash
~/Code/dotfiles/claude/scripts/query_conversations.py search <term> [OPTIONS]

Options:
  --format {yaml,json,text}  Output format (default: text)
  --case-sensitive          Case-sensitive search
  --since DATE              Filter by date
  --until DATE              Filter by date
  --limit N                 Limit results
```

**Examples:**
```bash
# Find all discussions about hooks
query_conversations.py search "git hooks"

# Case-sensitive search as YAML
query_conversations.py search "GitHub" --case-sensitive --format yaml

# Recent search only
query_conversations.py search "python" --since 2025-11-20 --limit 5
```

### export - Save conversation to file

```bash
~/Code/dotfiles/claude/scripts/query_conversations.py export <session-id> [filename] [OPTIONS]

Options:
  --format {yaml,json,text}  Export format (default: text, auto-detected from extension)
  --user-only               Export only user messages
  --assistant-only          Export only assistant messages
```

**Examples:**
```bash
# Export as text
query_conversations.py export abc123-session-id discussion.txt

# Export as YAML (auto-detected)
query_conversations.py export abc123-session-id discussion.yaml

# Export only user messages for analysis
query_conversations.py export abc123-session-id user_messages.yaml --user-only

# Export only assistant responses
query_conversations.py export abc123-session-id assistant_messages.json --assistant-only

# Export as JSON with explicit format
query_conversations.py export abc123-session-id output.txt --format json
```

### batch - Export multiple conversations to JSON array

```bash
~/Code/dotfiles/claude/scripts/query_conversations.py batch <output-file> [OPTIONS]

Options:
  --session-ids IDS         Comma-separated session IDs
  --session-file FILE       File containing session IDs (one per line)
  --user-only               Export only user messages
  --assistant-only          Export only assistant messages
```

**Examples:**
```bash
# Export multiple conversations from file
query_conversations.py batch output.json --session-file sessions.txt

# Export specific sessions with comma-separated IDs
query_conversations.py batch output.json --session-ids "abc123,def456,ghi789"

# Export only user messages from multiple conversations (for analysis)
query_conversations.py batch user_messages.json \
  --session-file sessions.txt \
  --user-only

# Creates valid JSON array: [{conv1}, {conv2}, {conv3}]
# Reports: "Batch exported N conversations to: output.json"
# Reports: "Total messages: M"
```

## Output Formats

### text (Human-readable)
- Default format
- Grouped by project
- Formatted timestamps
- Easy to read in terminal

### yaml (AI-readable)
- Best for feeding to AI agents
- Structured with metadata
- Preserves all fields
- Easy to parse programmatically

### json (Machine-readable)
- Standard JSON format
- Perfect for piping to jq
- Integrates with other tools
- Programmatic access

## Performance

- Parses **4000+ conversations** in ~1.7 seconds
- Streaming architecture for memory efficiency
- Fast content search across all conversations
- Efficient date range filtering

## What it does

- ✅ **list**: Browse all conversations with metadata and previews
- ✅ **get**: Read complete conversations with full message history
- ✅ **search**: Find conversations by content (summary or messages)
- ✅ **export**: Save conversations in multiple formats
- ✅ **filter**: By date, project, message count
- ✅ **format**: Output as text, YAML, or JSON

## When to use this tool

✅ **Perfect for:**

- 🕵️ **Discovery**: "What did I discuss about database optimization?"
- 📖 **Reading**: Review complete conversation flows
- 🔍 **Search**: Find specific topics across 4000+ conversations
- 📋 **Browsing**: See recent work by project
- 💾 **Export**: Save for documentation or AI analysis
- 🤖 **AI Analysis**: Export as YAML for feeding to other AI agents

## Storage Format

Conversations are stored as JSONL (JSON Lines) in:
```
~/Code/dotfiles/claude/projects/<encoded-project-path>/<session-id>.jsonl
```

Each line is a JSON object with:
- `type`: "summary", "snapshot", "user", "assistant"
- `timestamp`: ISO 8601 datetime
- `message`: Message content (string or array of content blocks)
- `metadata`: Session info, thinking metadata, todos, etc.
- `isMeta`: (optional) true for system context like slash command documentation

### System Noise Filtering

When using `--user-only`, the tool automatically excludes:
- **Meta messages** (`isMeta: true`): Slash command documentation, system context
- **Tool results**: Command output, test results, build logs
- **System tags**: `<command-message>`, `<system-reminder>`, `<local-command-stdout>`
- **Request interruptions**: "[Request interrupted by user]"

This ensures sentiment analysis and prompt engineering get **only human-written messages**, not system artifacts.

## Dependencies

**Required:**
- Python 3.12+
- `pyyaml` - For YAML output (`pip install pyyaml`)
- `python-dateutil` - For date parsing (`pip install python-dateutil`)

**Installation:**
```bash
pip install --user --break-system-packages pyyaml python-dateutil
```

## Files

- **Script**: `~/Code/dotfiles/claude/scripts/query_conversations.py`
- **Data**: `~/Code/dotfiles/claude/projects/*/` (JSONL files)
- **Legacy**: `~/Code/dotfiles/claude/scripts/query_claude_conversations.sh` (bash version, deprecated)

## Common Workflows

### 🔍 Discovery Workflow

```bash
# Browse recent work
query_conversations.py list --limit 20

# Search for specific topics as YAML
query_conversations.py search "database optimization" --format yaml

# Get full conversation for AI analysis
query_conversations.py get abc123... --format yaml > conversation.yaml
```

### 📄 Documentation Workflow

```bash
# Find all API design discussions
query_conversations.py search "API design" --since 2025-11-01

# Export for documentation
query_conversations.py export abc123... api_design_notes.yaml

# Pipe to jq for analysis
query_conversations.py list --format json | jq '.conversations[] | select(.message_count > 50)'
```

### 🤖 AI Analysis Workflow

```bash
# Export recent conversations as YAML for AI review
query_conversations.py list --since 2025-11-20 --format yaml > recent_work.yaml

# Get specific conversation for AI to analyze
query_conversations.py get abc123... --format yaml | @@ask "Summarize the key decisions"

# Search and export for pattern analysis
query_conversations.py search "git" --format json | jq '.conversations[].session_id'
```

### 🎭 Sentiment Analysis / Communication Style

```bash
# Extract user messages from recent substantial conversations
cd ~/Code/dotfiles/claude/scripts

# Get session IDs from substantial conversations
python3 query_conversations.py list \
  --since 2025-11-01 \
  --min-messages 30 \
  --format json | \
  jq -r '.conversations[].session_id' | \
  head -20 > /tmp/sessions.txt

# Batch export all user messages as a single JSON array
# Automatically filters out system noise (slash commands, tool results, system reminders)
python3 query_conversations.py batch \
  /tmp/user_messages.json \
  --session-file /tmp/sessions.txt \
  --user-only

# Shows: "Batch exported N conversations to: /tmp/user_messages.json"
# Shows: "Total messages: M" (only human-written messages, not system noise)

# Feed to Claude for dimensional analysis
@@ask "Analyze my communication style from these user messages.

JSON file contains array of conversations with only user messages.

Provide dimensional analysis:
1. Directness: Linus-style blunt vs diplomatic
2. Collaboration style: Command-driven vs partnership
3. Technical specificity: Precise requirements vs open exploration
4. Feedback patterns: How I respond to suggestions
5. Problem framing: Bottom-up vs top-down

For each dimension provide:
- Score/characterization
- 2-3 concrete examples from messages
- Patterns observed

Then summarize my communication signature.

$(cat /tmp/user_messages.json)"
```

## Comparison with Legacy Script

**Old bash script** (`query_claude_conversations.sh`):
- ❌ Slow jq parsing in shell loops
- ❌ Text output only
- ❌ Basic filtering
- ❌ Struggles with 4000+ files

**New Python script** (`query_conversations.py`):
- ✅ Fast native JSON parsing (1.7s for 4000 files)
- ✅ Multiple output formats (text, YAML, JSON)
- ✅ Advanced filtering (date, project, message count)
- ✅ Handles format evolution gracefully
- ✅ AI-readable YAML output

## Related Tools

- **extract-user-messages.md**: Extract only user inputs for prompt engineering
- **Context7 MCP**: For deeper codebase search and analysis
- **jq**: For JSON manipulation and querying

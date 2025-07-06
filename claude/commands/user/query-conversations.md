# Query Claude Conversations

🔍 **Interactive exploration and search** of Claude conversations from JSONL files. Use this to find, browse, read, and export complete conversations.

## Usage

### List all conversations

```bash
/Users/kyle/.claude/scripts/query_claude_conversations.sh list
```

### Display a specific conversation

```bash
/Users/kyle/.claude/scripts/query_claude_conversations.sh get <session_id>
```

### Search conversations for a term

```bash
/Users/kyle/.claude/scripts/query_claude_conversations.sh search <term>
```

### Export conversation to file

```bash
/Users/kyle/.claude/scripts/query_claude_conversations.sh export <session_id> [filename]
```

### Show help

```bash
/Users/kyle/.claude/scripts/query_claude_conversations.sh help
```

## What it does

- **list**: Browse all conversations with previews and metadata
- **get**: Read complete conversations (both USER and CLAUDE messages)
- **search**: Find conversations containing specific terms across all projects
- **export**: Save full conversations for documentation or sharing

## When to use this tool

✅ **Perfect for:**

- 🕵️ **Discovery**: "What did I discuss about database optimization?"
- 📖 **Reading**: Review complete conversation flows
- 🔍 **Search**: Find specific topics across your conversation history
- 📋 **Browsing**: See what conversations you've had recently
- 💾 **Documentation**: Export conversations for sharing or reference

## Storage Format

Conversations are stored as JSONL (JSON Lines) files in `/Users/kyle/.claude/projects/` organized by project directory.

## Dependencies

- **jq**: Required for JSON parsing (`brew install jq`)

## Files

- **Script**: `/Users/kyle/.claude/scripts/query_claude_conversations.sh`
- **Data**: `/Users/kyle/.claude/projects/*/` (JSONL files)

## Common Workflows

### 🔍 Discovery Workflow

```bash
# Browse recent conversations
./query_claude_conversations.sh list

# Search for specific topics
./query_claude_conversations.sh search "database optimization"

# Read the full conversation
./query_claude_conversations.sh get abc123...
```

### 📄 Documentation Workflow

```bash
# Find conversations about a feature
./query_claude_conversations.sh search "API design"

# Export for documentation
./query_claude_conversations.sh export abc123... "api_design_discussion.txt"
```

## Related Tools

**For content analysis**: Use [`extract-user-messages.md`](extract-user-messages.md) to extract only your inputs for prompt engineering, training data, or pattern analysis.

# Extract User Messages

📝 **Content extraction and analysis** - Extract only your inputs from Claude conversations for prompt engineering, training data creation, and pattern analysis.

## Usage

### Extract from specific session

```bash
/Users/kyle/.claude/scripts/extract_user_messages.sh <session_id>
/Users/kyle/.claude/scripts/extract_user_messages.sh <session_id> <output_file>
```

### Extract from all conversations

```bash
/Users/kyle/.claude/scripts/extract_user_messages.sh --all
```

### Extract from specific project

```bash
/Users/kyle/.claude/scripts/extract_user_messages.sh --project <project_name>
```

### Show help

```bash
/Users/kyle/.claude/scripts/extract_user_messages.sh --help
```

## What it does

- **Session extraction**: Gets only your messages from a specific conversation
- **Bulk extraction**: Processes all your inputs across all conversations
- **Project filtering**: Extracts your messages from a specific project
- **Clean formatting**: Creates analysis-ready text files with metadata
- **Message separation**: Uses `---` dividers for easy parsing and processing

## When to use this tool

✅ **Perfect for:**

- 🎯 **Prompt Engineering**: Analyze your prompt patterns and effectiveness
- 📊 **Training Data**: Create datasets from your conversation inputs
- 📋 **Requirements Analysis**: Extract specifications and requests you've made
- 🔬 **Pattern Study**: Understand your communication style with Claude
- 📚 **Knowledge Mining**: Build collections of your questions and requests

❌ **Not for:**

- Reading complete conversations (use [`query-conversations.md`](query-conversations.md) instead)
- Searching for Claude's responses
- Browsing conversation metadata

## Output Format

```
# Extracted user messages from session: abc123...
# Project: ~/Code/marketplace
# Generated: Wed Jun 5 15:30:45 PDT 2025

# Message from: 2025-04-30T10:36:10.000Z
Your first message content here
---

# Message from: 2025-04-30T10:40:15.000Z
Your second message content here
---

# Total user messages extracted: 2
```

## Common Workflows

### 🎯 Prompt Engineering Workflow

```bash
# Extract your prompts from a specific conversation
./extract_user_messages.sh abc123... my_prompts.txt

# Analyze all your inputs from a project
./extract_user_messages.sh --project marketplace

# Build a comprehensive prompt dataset
./extract_user_messages.sh --all
```

### 📊 Analysis Workflow

```bash
# Get your communication patterns with Claude
./extract_user_messages.sh --project nvim-config

# Compare prompt styles across projects
./extract_user_messages.sh --project api-design
./extract_user_messages.sh --project database-work
```

### 🤝 Combined with Query Tool

```bash
# First, find relevant conversations
/Users/kyle/.claude/scripts/query_claude_conversations.sh search "API design"

# Then extract your inputs from those sessions
./extract_user_messages.sh abc123... api_requirements.txt
./extract_user_messages.sh def456... api_requirements2.txt
```

## Dependencies

- **jq**: Required for JSON parsing (`brew install jq`)

## Files

- **Script**: `/Users/kyle/.claude/scripts/extract_user_messages.sh`
- **Data source**: `/Users/kyle/.claude/projects/*/` (JSONL files)
- **Old script**: `/Users/kyle/.claude/cronex_analysis/extract_user_messages.sh.old` (backup)

## Related Tools

**For conversation exploration**: Use [`query-conversations.md`](query-conversations.md) to find, browse, search, and read complete conversations before extracting your inputs.

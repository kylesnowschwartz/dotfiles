# Update Claude Prompts

Updates the local `claude-code-prompts.js` file from the latest version in the
GitHub gist.

## Usage

```bash
/Users/kyle/.claude/scripts/update-claude-prompts.sh
```

## What it does

- Downloads the latest version from: <https://gist.github.com/transitive-bullshit/487c9cb52c75a9701d312334ed53b20c>
- Compares with your local file at `/Users/kyle/.claude/claude-code-prompts.js`
- Creates a timestamped backup if changes are found
- Updates the local file with the latest version
- Shows a summary of changes

## Example output

```bash
🔍 Checking for updates to Claude Code prompts...
🔄 Updates found! Backing up current file...
📥 Updating local file...
✅ Successfully updated claude-code-prompts.js
💾 Backup saved as /Users/kyle/.claude/claude-code-prompts.js.backup.20250605-145057
```

## Files

- **Script**: `/Users/kyle/.claude/scripts/update-claude-prompts.sh`
- **Target file**: `/Users/kyle/.claude/claude-code-prompts.js`
- **Gist URL**: <https://gist.github.com/transitive-bullshit/487c9cb52c75a9701d312334ed53b20c>

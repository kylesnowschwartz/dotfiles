# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a Claude Code hooks directory implementing both template-based hook patterns and the "Age of Claude" audio feedback system using the `claude_hooks` Ruby DSL. The repository provides a comprehensive hook system for Claude Code with sound effects inspired by Age of Empires.

## Architecture

### Core Structure

The hooks system follows the `claude_hooks` Ruby DSL architecture pattern:

- **`entrypoints/`** - Entry point scripts that orchestrate handler execution
- **`handlers/`** - Individual handler classes implementing specific hook logic
- **`handlers/age_of_claude/`** - Specialized handlers for audio feedback system

### Key Components

#### Ruby DSL Integration (`claude_hooks` gem)

This implementation uses the `claude_hooks` Ruby gem (v1.0.0) for structured hook development:

- Provides base classes for each hook type (`ClaudeHooks::UserPromptSubmit`, etc.)
- Output merging system via `ClaudeHooks::Output::*` classes
- Built-in logging, testing, and error handling
- CLI testing utilities via `ClaudeHooks::CLI.test_runner`

#### Age of Claude Audio System

A complete audio feedback system that plays Age of Empires sounds for various Claude Code events:

**Sound Player** (`handlers/age_of_claude/sound_player.rb`):

- Cross-platform audio playback using `afplay` (macOS) and `aplay` (Linux)
- Random sound selection from configured collections
- Error handling and logging integration

### Hook Types Implemented

1. **UserPromptSubmit** - Random villager selection sounds when user submits prompts
2. **PreToolUse** - Tool-specific sounds before execution (currently disabled via comments)
3. **PostToolUse** - Success sounds after tool completion
4. **Stop** - Completion sound when Claude finishes responding
5. **SubagentStop** - Different sound for subagent completion
6. **SessionEnd** - Context-specific farewell sounds (exit/clear)
7. **PreCompact** - Context management sounds (auto vs manual compaction)

## Development Commands

### Installation

```bash
# Install the claude_hooks Ruby DSL
gem install claude_hooks

# Make entrypoint scripts executable
chmod +x entrypoints/*.rb

# Test individual handlers
echo '{"session_id":"test","prompt":"Hello!"}' | ./entrypoints/user_prompt_submit.rb
```

### Testing

```bash
# Test individual handlers with built-in test runner
ruby handlers/age_of_claude/user_prompt_submit_handler.rb

# Debug mode with full stack traces
RUBY_CLAUDE_HOOKS_DEBUG=1 echo '{"session_id":"test"}' | ./entrypoints/user_prompt_submit.rb
```

### Hook Validation and Debugging

#### Log File Analysis

All hook activity is logged to session-specific files in `~/.claude/logs/hooks/`. Use log analysis to validate hook functionality:

```bash
# Find the current session's log file (most recent)
ls -lt ~/.claude/logs/hooks/ | head -5

# Monitor real-time hook activity during conversation
tail -f ~/.claude/logs/hooks/session-[session-id].log

# Search for specific hook activity
grep "YouAreNotRight" ~/.claude/logs/hooks/session-*.log
grep "Pattern match result: true" ~/.claude/logs/hooks/session-*.log
```

#### Validation Methodology

When implementing new hooks or debugging existing ones:

1. **Test with Sample Data**: Use isolated JSON input to verify basic functionality
   ```bash
   echo '{"session_id":"test","transcript_path":"/path/to/test","prompt":"test"}' | ./your_hook.rb
   ```

2. **Monitor Session Logs**: Check `~/.claude/logs/hooks/session-[id].log` during live conversations to verify:
   - Hook execution trigger points
   - Pattern matching results
   - System reminder injection
   - Error conditions and recovery

3. **Verify Integration**: Confirm hooks work within the entrypoint merger system by checking combined outputs

4. **Live Testing**: Engage in conversation scenarios that should trigger your hooks and verify the expected behavior occurs

**Example Log Validation**:
```
[2025-09-15 10:33:19] [INFO] [YouAreNotRight] Found 3 assistant messages to check
[2025-09-15 10:33:19] [INFO] [YouAreNotRight] Checking text: 'You're right, let me check...'
[2025-09-15 10:33:19] [INFO] [YouAreNotRight] Pattern match result: true
[2025-09-15 10:33:19] [WARN] [YouAreNotRight] Found reflexive agreement pattern - adding system reminder
```

This log sequence confirms the hook detected agreement patterns and injected corrective guidance into the conversation.

### Configuration

The complete hook configuration is provided in `age_of_claude_settings.json`, which should be copied to `~/.claude/settings.json`:

```json
{
  "hooks": {
    "UserPromptSubmit": [
      {
        "matcher": ".*",
        "hooks": [
          {
            "type": "command",
            "command": ".claude/hooks/entrypoints/user_prompt_submit.rb"
          }
        ]
      }
    ]
  }
}
```

## Implementation Patterns

### Entrypoint Pattern

Each entrypoint script follows this structure:

1. Read JSON input from STDIN
2. Initialize multiple handler instances
3. Execute all handlers via `.call` methods
4. Merge outputs using appropriate `ClaudeHooks::Output::*` class
5. Output result and exit with proper code

### Handler Pattern

Individual handlers inherit from appropriate base classes:

```ruby
class MyHandler < ClaudeHooks::UserPromptSubmit
  def call
    log "Processing hook"
    # Hook logic here
    allow_continue! # or block_continue!
    output_data
  end
end
```

### Sound System Pattern

The Age of Claude system demonstrates advanced configuration management:

- Centralized sound player in `sound_player.rb`
- Utility methods for sound resolution and random selection
- Cross-platform audio playback abstraction

## Template System

The $HOME/Code/meta-claude/SimpleClaude/.claude/hooks repository includes `.template` files demonstrating basic hook patterns without the Ruby DSL, useful for:

- Learning hook fundamentals
- Simple bash-based implementations
- Migration from basic to advanced patterns

## Configuration Notes

- Paths in `age_of_claude_settings.json` assume project-level installation (`.claude/hooks/`)
- For home-level installation, use `~/.claude/hooks/` paths
- Sound files should be placed in `.claude/sounds/` directory
- Debug output is controlled by `RUBY_CLAUDE_HOOKS_DEBUG` environment variable

This implementation serves as both a functional audio feedback system and a comprehensive example of advanced Claude Code hook development using the Ruby DSL pattern.

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

**Sound Configuration** (`handlers/age_of_claude/sound_config.rb`):

- Centralized sound mappings organized by hook type
- Support for single sounds, random collections, and context-specific sounds
- Utility methods for sound resolution and selection

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

# Validate hook configuration
ruby -c handlers/age_of_claude/sound_config.rb
```

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

- Centralized sound mappings in `sound_config.rb`
- Utility methods for sound resolution and random selection
- Cross-platform audio playback abstraction

## Template System

The $HOME/Code/meta-claude/SimpleClaude/.claude/hooks repository includes `.template` files demonstrating basic hook patterns without the Ruby DSL, useful for:

- Learning hook fundamentals
- Simple bash-based implementations
- Migration from basic to advanced patterns

## Investigation Documentation

`hooks-investigation.md` contains detailed research on Claude Code's hook system limitations and recommendations for reliable implementations, including comparisons between slash commands and hooks approaches.

## Configuration Notes

- Paths in `age_of_claude_settings.json` assume project-level installation (`.claude/hooks/`)
- For home-level installation, use `~/.claude/hooks/` paths
- Sound files should be placed in `.claude/sounds/` directory
- Debug output is controlled by `RUBY_CLAUDE_HOOKS_DEBUG` environment variable

This implementation serves as both a functional audio feedback system and a comprehensive example of advanced Claude Code hook development using the Ruby DSL pattern.

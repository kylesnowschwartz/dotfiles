# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is `claude_hooks` - a Ruby DSL (Domain Specific Language) for creating Claude Code hooks. It provides a framework to create composable hook scripts that enable logging, security checks, and workflow automation in Claude Code.

## Development Commands

### Testing

```bash
# Run all configuration tests
ruby test/run_all_tests.rb

# Run individual test files
ruby test/test_config.rb
ruby test/test_config_merge.rb
```

### Gem Development

```bash
# Install dependencies
bundle install

# Build gem locally
gem build claude_hooks.gemspec

# Install gem locally for testing
gem install ./claude_hooks-*.gem
```

### Testing Hooks

```bash
# Test a hook with sample data
echo '{"session_id":"test","prompt":"Hello!"}' | ./your_hook.rb

# Make hook executable (required for Claude Code)
chmod +x your_hook.rb
```

## Architecture

### Core Components

1. **Base Classes** (`lib/claude_hooks/`)

   - `Base` - Common functionality (logging, config, validation)
   - Hook-specific classes for each Claude Code hook type:
     - `UserPromptSubmit` - Process user prompts
     - `PreToolUse` / `PostToolUse` - Tool usage monitoring
     - `Notification` - Handle notifications
     - `Stop` / `SubagentStop` - Control flow stopping
     - `PreCompact` - Transcript compaction hooks
     - `SessionStart` - Session initialization
     - `SessionEnd` - Session termination

2. **Output Classes** (`lib/claude_hooks/output/`)

   - `Output::Base` - Common output functionality and merging logic
   - Hook-specific output classes for each hook type:
     - `Output::UserPromptSubmit` - User prompt submission output handling
     - `Output::PreToolUse` / `Output::PostToolUse` - Tool usage outputs
     - `Output::Notification` - Notification output handling
     - `Output::Stop` / `Output::SubagentStop` - Stop event outputs
     - `Output::PreCompact` - Compaction output handling
     - `Output::SessionStart` / `Output::SessionEnd` - Session lifecycle outputs

3. **Configuration System** (`lib/claude_hooks/configuration.rb`)

   - Supports both home (`$HOME/.claude`) and project (`$CLAUDE_PROJECT_DIR/.claude`) directories
   - Environment variable support with `RUBY_CLAUDE_HOOKS_` prefix
   - Configurable merge strategies for multi-level config

4. **CLI Testing Framework** (`lib/claude_hooks/cli.rb`)

   - `ClaudeHooks::CLI.test_runner(HookClass)` for easy hook testing
   - `ClaudeHooks::CLI.run_hook(HookClass, input_data)` for direct execution
   - `ClaudeHooks::CLI.run_with_sample_data(HookClass, sample_data)` for testing without STDIN
   - `ClaudeHooks::CLI.entrypoint` for standardized script entry points

5. **Logging System** (`lib/claude_hooks/logger.rb`)
   - Session-specific log files
   - Multiline block support
   - Configurable log directory

### Hook Architecture Pattern

The framework encourages an **entrypoints/handlers** pattern:

```
.claude/hooks/
├── entrypoints/          # Main entry points called by Claude Code
│   ├── user_prompt_submit.rb
│   ├── pre_tool_use.rb
│   └── ...
└── handlers/            # Specific hook logic
    ├── user_prompt_submit/
    │   ├── append_rules.rb
    │   └── log_user_prompt.rb
    └── pre_tool_use/
        └── tool_monitor.rb
```

### Hook Flow

1. Claude Code calls entrypoint script (configured in `.claude/settings.json`)
2. Entrypoint reads JSON from STDIN
3. Entrypoint coordinates multiple handler classes
4. Handlers return output data hash
5. Entrypoint merges outputs using appropriate `ClaudeHooks::Output::*` class merge method
6. Final JSON response sent to STDOUT/STDERR via `output_and_exit`

## Key Concepts

### Hook Types and Methods

Each hook class provides specific input/output methods:

**Common Base Methods** (available to all hooks):
- `session_id`, `transcript_path`, `cwd`, `hook_event_name`
- `read_transcript` (aliased as `transcript`)
- `log()` - for logging (supports blocks for multiline)
- `allow_continue!()`, `prevent_continue!(reason)`
- `suppress_output!()`, `show_output!()`
- `system_message!(message)`, `clear_system_message!()`
- `clear_specifics!()`

**UserPromptSubmit**:
- Input: `prompt` (aliased as `user_prompt`, `current_prompt`)
- Output: `add_additional_context!(context)` (aliased as `add_context!`), `block_prompt!(reason)`, `unblock_prompt!()`

**PreToolUse**:
- Input: `tool_name`, `tool_input`
- Output: `approve_tool!(reason)`, `block_tool!(reason)`, `ask_for_permission!(reason)`

**PostToolUse**:
- Input: `tool_name`, `tool_input`, `tool_response`
- Output: `approve_tool!(reason)`, `block_tool!(reason)`, `add_additional_context!(context)` (aliased as `add_context!`)

**SessionEnd**:
- Input: `reason`
- Helpers: `cleared?()`, `logout?()`, `prompt_input_exit?()`, `other_reason?()`

### Configuration Access

```ruby
# Access config values
config.api_key              # Via method_missing
config.get_config_value('USER_NAME', 'userName', 'default')

# Directory utilities
home_claude_dir             # $HOME/.claude
project_claude_dir          # $CLAUDE_PROJECT_DIR/.claude (or nil)
path_for(relative_path, base_dir)    # Generic path helper
home_path_for(relative_path)         # Home-specific path helper
project_path_for(relative_path)      # Project-specific path helper
```

### Output Merging

Each hook type provides intelligent output merging via `ClaudeHooks::Output::*` classes:

```ruby
ClaudeHooks::Output::UserPromptSubmit.merge(output1, output2, output3)
# Merge logic:
# - continue: false wins over true
# - decision: "block" wins over nil
# - suppressOutput: true wins over false
# - contexts and reasons are concatenated
# - systemMessage entries joined with '; '
```

## Development Guidelines

1. **Always make hook scripts executable**: `chmod +x your_hook.rb`
2. **Use the CLI testing framework** instead of writing boilerplate JSON parsing
3. **Follow the entrypoints/handlers pattern** for complex hook systems
4. **Use `log()` method instead of `puts`** to avoid interfering with JSON output
5. **Handle errors gracefully** and exit with appropriate codes (0=success, 1=non-blocking error, 2=blocking error)
6. **Test hooks in isolation** using the CLI framework before integrating with Claude Code
7. **Use `output_and_exit`** method for proper JSON output and exit code handling

## File Structure

- `lib/claude_hooks.rb` - Main entry point, requires all hook classes and output classes
- `lib/claude_hooks/base.rb` - Base functionality for all hooks
- `lib/claude_hooks/[hook_type].rb` - Individual hook type classes
- `lib/claude_hooks/output/base.rb` - Base output functionality and merging
- `lib/claude_hooks/output/[hook_type].rb` - Hook-specific output classes
- `example_dotclaude/` - Example hook implementations and directory structure
- `test/` - Configuration and integration tests

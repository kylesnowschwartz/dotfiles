#!/usr/bin/env ruby
# frozen_string_literal: true

# SubagentStop Entrypoint
#
# This entrypoint orchestrates all SubagentStop handlers when Claude Code subagents finish.
# It reads JSON input from STDIN, executes all configured handlers, merges their outputs,
# and returns the final result to Claude Code via STDOUT.

require 'claude_hooks'
require 'json'

# Require all SubagentStop handler classes
require_relative '../handlers/age_of_claude/subagent_stop_handler'

# Add additional handler requires here as needed:
# require_relative '../handlers/subagent_stop/metrics_handler'
# require_relative '../handlers/subagent_stop/cleanup_handler'

begin
  # Read input data from Claude Code
  input_data = JSON.parse($stdin.read)

  # Initialize and execute all handlers
  age_of_claude_handler = AgeOfClaudeSubagentStopHandler.new(input_data)

  # Execute handlers
  age_of_claude_handler.call

  # For now, just use the single handler output
  # When more handlers are added, use: ClaudeHooks::Output::SubagentStop.merge(handler1.output, handler2.output)
  age_of_claude_handler.output_and_exit
rescue JSON::ParserError => e
  warn "[SubagentStop] JSON parsing error: #{e.message}"
  warn JSON.generate({
                       continue: true,
                       stopReason: "SubagentStop hook JSON parsing error: #{e.message}",
                       suppressOutput: false
                     })
  exit 1  # JSON error
rescue StandardError => e
  warn "[SubagentStop] Hook execution error: #{e.message}"
  warn e.backtrace.join("\n") if ENV['RUBY_CLAUDE_HOOKS_DEBUG']

  warn JSON.generate({
                       continue: true,
                       stopReason: "SubagentStop hook execution error: #{e.message}",
                       suppressOutput: false
                     })
  exit 1  # General error
end

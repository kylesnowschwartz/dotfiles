#!/usr/bin/env ruby
# frozen_string_literal: true

# SessionEnd Entrypoint
#
# This entrypoint orchestrates all SessionEnd handlers when Claude Code sessions end.
# It reads JSON input from STDIN, executes all configured handlers, merges their outputs,
# and returns the final result to Claude Code via STDOUT.

require 'claude_hooks'
require 'json'

# Require all SessionEnd handler classes
require_relative '../handlers/age_of_claude/session_end_handler'

# Add additional handler requires here as needed:
# require_relative '../handlers/session_end/cleanup_handler'
# require_relative '../handlers/session_end/log_session_stats'

begin
  # Read input data from Claude Code
  input_data = JSON.parse($stdin.read)

  # Initialize and execute all handlers
  age_of_claude_handler = AgeOfClaudeSessionEndHandler.new(input_data)

  # Execute handlers
  age_of_claude_handler.call

  # For now, just use the single handler output
  # When more handlers are added, use: ClaudeHooks::Output::SessionEnd.merge(handler1.output, handler2.output)
  age_of_claude_handler.output_and_exit
rescue JSON::ParserError => e
  warn "[SessionEnd] JSON parsing error: #{e.message}"
  warn JSON.generate({
                       continue: true,
                       reason: "SessionEnd hook JSON parsing error: #{e.message}",
                       suppressOutput: false
                     })
  exit 1  # JSON error
rescue StandardError => e
  warn "[SessionEnd] Hook execution error: #{e.message}"
  warn e.backtrace.join("\n") if ENV['RUBY_CLAUDE_HOOKS_DEBUG']

  warn JSON.generate({
                       continue: true,
                       reason: "SessionEnd hook execution error: #{e.message}",
                       suppressOutput: false
                     })
  exit 1  # General error
end

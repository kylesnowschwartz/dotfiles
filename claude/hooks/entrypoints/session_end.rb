#!/usr/bin/env ruby
# frozen_string_literal: true

# SessionEnd Entrypoint
#
# This entrypoint handles SessionEnd hooks for Age of Claude sound effects.
# Triggered when a Claude Code session ends (exit, clear, logout, etc.).
#
# Plays appropriate farewell sounds based on the end reason:
# - "exit": Farewell sounds (pleading or dismissive)
# - "clear": Soldier selection sound

require 'json'
require_relative '../handlers/age_of_claude/session_end_handler'

begin
  # Read input data from Claude Code
  input_data = JSON.parse($stdin.read)

  # Initialize and execute handler
  handler = AgeOfClaudeSessionEndHandler.new(input_data)
  handler.call

  # Output result and exit with appropriate code
  handler.output_and_exit
rescue JSON::ParserError => e
  warn "[SessionEnd] JSON parsing error: #{e.message}"
  warn JSON.generate({
                       continue: false,
                       stopReason: "SessionEnd hook JSON parsing error: #{e.message}",
                       suppressOutput: false
                     })
  exit 1
rescue StandardError => e
  warn "[SessionEnd] Hook execution error: #{e.message}"
  warn e.backtrace.join("\n") if ENV['RUBY_CLAUDE_HOOKS_DEBUG']

  warn JSON.generate({
                       continue: false,
                       stopReason: "SessionEnd hook execution error: #{e.message}",
                       suppressOutput: false
                     })
  exit 1
end

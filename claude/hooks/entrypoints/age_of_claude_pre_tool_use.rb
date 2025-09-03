#!/usr/bin/env ruby
# frozen_string_literal: true

# Age of Claude PreToolUse Entrypoint
#
# This entrypoint plays Age of Empires tool-specific sounds before Claude executes tools.
# It orchestrates the AgeOfClaudePreToolUseHandler and interfaces with Claude Code.

require 'claude_hooks'
require 'json'

# Require the Age of Claude PreToolUse handler
require_relative '../handlers/age_of_claude/pre_tool_use_handler'

begin
  # Read input data from Claude Code
  input_data = JSON.parse($stdin.read)

  # Execute Age of Claude PreToolUse handler
  handler = AgeOfClaudePreToolUseHandler.new(input_data)
  handler.call

  # Output final result to Claude Code with proper format
  handler.output_and_exit
rescue JSON::ParserError => e
  warn "[Age of Claude PreToolUse] JSON parsing error: #{e.message}"
  warn JSON.generate({
                       continue: false,
                       stopReason: "Age of Claude PreToolUse hook JSON parsing error: #{e.message}",
                       suppressOutput: false
                     })
  exit 1  # JSON error
rescue StandardError => e
  warn "[Age of Claude PreToolUse] Hook execution error: #{e.message}"
  warn e.backtrace.join("\n") if ENV['RUBY_CLAUDE_HOOKS_DEBUG']

  warn JSON.generate({
                       continue: false,
                       stopReason: "Age of Claude PreToolUse hook execution error: #{e.message}",
                       suppressOutput: false
                     })
  exit 1  # General error
end

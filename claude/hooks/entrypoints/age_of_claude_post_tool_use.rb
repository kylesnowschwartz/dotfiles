#!/usr/bin/env ruby
# frozen_string_literal: true

# Age of Claude PostToolUse Entrypoint
#
# This entrypoint plays Age of Empires success sounds after Claude executes tools.
# It orchestrates the AgeOfClaudePostToolUseHandler and interfaces with Claude Code.

require 'claude_hooks'
require 'json'

# Require the Age of Claude PostToolUse handler
require_relative '../handlers/age_of_claude/post_tool_use_handler'

begin
  # Read input data from Claude Code
  input_data = JSON.parse($stdin.read)

  # Execute Age of Claude PostToolUse handler
  handler = AgeOfClaudePostToolUseHandler.new(input_data)
  handler.call

  # Output final result to Claude Code with proper format
  handler.output_and_exit
rescue JSON::ParserError => e
  warn "[Age of Claude PostToolUse] JSON parsing error: #{e.message}"
  warn JSON.generate({
                       continue: true,
                       stopReason: "Age of Claude PostToolUse hook JSON parsing error: #{e.message}",
                       suppressOutput: false
                     })
  exit 1  # JSON error
rescue StandardError => e
  warn "[Age of Claude PostToolUse] Hook execution error: #{e.message}"
  warn e.backtrace.join("\n") if ENV['RUBY_CLAUDE_HOOKS_DEBUG']

  warn JSON.generate({
                       continue: true,
                       stopReason: "Age of Claude PostToolUse hook execution error: #{e.message}",
                       suppressOutput: false
                     })
  exit 1  # General error
end

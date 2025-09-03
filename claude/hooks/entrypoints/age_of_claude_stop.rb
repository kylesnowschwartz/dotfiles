#!/usr/bin/env ruby
# frozen_string_literal: true

# Age of Claude Stop Entrypoint
#
# This entrypoint plays Age of Empires completion sounds when Claude finishes responding.
# It orchestrates the AgeOfClaudeStopHandler and interfaces with Claude Code.

require 'claude_hooks'
require 'json'

# Require the Age of Claude Stop handler
require_relative '../handlers/age_of_claude/stop_handler'

begin
  # Read input data from Claude Code
  input_data = JSON.parse($stdin.read)

  # Execute Age of Claude Stop handler
  handler = AgeOfClaudeStopHandler.new(input_data)
  handler.call

  # Output final result to Claude Code with proper format
  handler.output_and_exit
rescue JSON::ParserError => e
  warn "[Age of Claude Stop] JSON parsing error: #{e.message}"
  warn JSON.generate({
                       continue: true,
                       stopReason: "Age of Claude Stop hook JSON parsing error: #{e.message}",
                       suppressOutput: false
                     })
  exit 1  # JSON error
rescue StandardError => e
  warn "[Age of Claude Stop] Hook execution error: #{e.message}"
  warn e.backtrace.join("\n") if ENV['RUBY_CLAUDE_HOOKS_DEBUG']

  warn JSON.generate({
                       continue: true,
                       stopReason: "Age of Claude Stop hook execution error: #{e.message}",
                       suppressOutput: false
                     })
  exit 1  # General error
end

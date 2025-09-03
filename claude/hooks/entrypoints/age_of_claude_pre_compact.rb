#!/usr/bin/env ruby
# frozen_string_literal: true

# Age of Claude PreCompact Entrypoint
#
# This entrypoint plays Age of Empires context sounds before transcript compaction.
# It orchestrates the AgeOfClaudePreCompactHandler and interfaces with Claude Code.

require 'claude_hooks'
require 'json'

# Require the Age of Claude PreCompact handler
require_relative '../handlers/age_of_claude/pre_compact_handler'

begin
  # Read input data from Claude Code
  input_data = JSON.parse($stdin.read)

  # Execute Age of Claude PreCompact handler
  handler = AgeOfClaudePreCompactHandler.new(input_data)
  handler.call

  # Output final result to Claude Code with proper format
  handler.output_and_exit
rescue JSON::ParserError => e
  warn "[Age of Claude PreCompact] JSON parsing error: #{e.message}"
  # PreCompact errors should not block compaction
  warn JSON.generate({
                       continue: true,
                       reason: "Age of Claude PreCompact hook JSON parsing error: #{e.message}",
                       suppressOutput: false
                     })
  exit 1 # JSON error
rescue StandardError => e
  warn "[Age of Claude PreCompact] Hook execution error: #{e.message}"
  warn e.backtrace.join("\n") if ENV['RUBY_CLAUDE_HOOKS_DEBUG']

  # PreCompact errors should not block compaction
  warn JSON.generate({
                       continue: true,
                       reason: "Age of Claude PreCompact hook execution error: #{e.message}",
                       suppressOutput: false
                     })
  exit 1 # General error
end

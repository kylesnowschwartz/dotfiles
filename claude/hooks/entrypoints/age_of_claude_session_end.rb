#!/usr/bin/env ruby
# frozen_string_literal: true

# Age of Claude SessionEnd Entrypoint
#
# This entrypoint plays Age of Empires farewell sounds when Claude sessions end.
# It orchestrates the AgeOfClaudeSessionEndHandler and interfaces with Claude Code.

require 'claude_hooks'
require 'json'

# Require the Age of Claude SessionEnd handler
require_relative '../handlers/age_of_claude/session_end_handler'

begin
  # Read input data from Claude Code
  input_data = JSON.parse($stdin.read)

  # Execute Age of Claude SessionEnd handler
  handler = AgeOfClaudeSessionEndHandler.new(input_data)
  handler.call

  # Output final result to Claude Code with proper format
  handler.output_and_exit
rescue JSON::ParserError => e
  warn "[Age of Claude SessionEnd] JSON parsing error: #{e.message}"
  # SessionEnd errors should not block the session from ending
  warn JSON.generate({
                       continue: true,
                       reason: "Age of Claude SessionEnd hook JSON parsing error: #{e.message}",
                       suppressOutput: false
                     })
  exit 1 # JSON error
rescue StandardError => e
  warn "[Age of Claude SessionEnd] Hook execution error: #{e.message}"
  warn e.backtrace.join("\n") if ENV['RUBY_CLAUDE_HOOKS_DEBUG']

  # SessionEnd errors should not block the session from ending
  warn JSON.generate({
                       continue: true,
                       reason: "Age of Claude SessionEnd hook execution error: #{e.message}",
                       suppressOutput: false
                     })
  exit 1 # General error
end

#!/usr/bin/env ruby
# frozen_string_literal: true

# PreCompact Entrypoint
#
# This entrypoint orchestrates all PreCompact handlers before Claude Code compacts transcripts.
# It reads JSON input from STDIN, executes all configured handlers, merges their outputs,
# and returns the final result to Claude Code via STDOUT.

require 'claude_hooks'
require 'json'

# Require all PreCompact handler classes
require_relative '../handlers/age_of_claude/pre_compact_handler'

# Add additional handler requires here as needed:
# require_relative '../handlers/pre_compact/backup_handler'
# require_relative '../handlers/pre_compact/analysis_handler'

begin
  # Read input data from Claude Code
  input_data = JSON.parse($stdin.read)

  # Initialize and execute all handlers
  age_of_claude_handler = AgeOfClaudePreCompactHandler.new(input_data)

  # Execute handlers
  age_of_claude_handler.call

  # For now, just use the single handler output
  # When more handlers are added, use: ClaudeHooks::Output::PreCompact.merge(handler1.output, handler2.output)
  age_of_claude_handler.output_and_exit
rescue JSON::ParserError => e
  warn "[PreCompact] JSON parsing error: #{e.message}"
  warn JSON.generate({
                       continue: true,
                       reason: "PreCompact hook JSON parsing error: #{e.message}",
                       suppressOutput: false
                     })
  exit 1  # JSON error
rescue StandardError => e
  warn "[PreCompact] Hook execution error: #{e.message}"
  warn e.backtrace.join("\n") if ENV['RUBY_CLAUDE_HOOKS_DEBUG']

  warn JSON.generate({
                       continue: true,
                       reason: "PreCompact hook execution error: #{e.message}",
                       suppressOutput: false
                     })
  exit 1  # General error
end

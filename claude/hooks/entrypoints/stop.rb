#!/usr/bin/env ruby
# frozen_string_literal: true

# Stop Entrypoint
#
# This entrypoint orchestrates all Stop handlers when Claude Code finishes responding.
# It reads JSON input from STDIN, executes all configured handlers, merges their outputs,
# and returns the final result to Claude Code via STDOUT.

require 'claude_hooks'
require 'json'

# Require all Stop handler classes
require_relative '../handlers/age_of_claude/stop_handler'
require_relative '../handlers/stop_you_are_not_right'

# Add additional handler requires here as needed:
# require_relative '../handlers/stop/cleanup_handler'
# require_relative '../handlers/stop/metrics_collector'

begin
  # Read input data from Claude Code
  input_data = JSON.parse($stdin.read)

  # Initialize and execute all handlers
  age_of_claude_handler = AgeOfClaudeStopHandler.new(input_data)
  reflexive_agreement_handler = StopYouAreNotRight.new(input_data)

  # Execute handlers
  age_of_claude_handler.call
  reflexive_agreement_handler.call

  # Merge outputs using the Stop output merger
  # The reflexive agreement handler takes precedence (if it wants to continue, that wins)
  merged_output = ClaudeHooks::Output::Stop.merge(
    age_of_claude_handler.output,
    reflexive_agreement_handler.output
  )

  merged_output.output_and_exit
rescue JSON::ParserError => e
  warn "[Stop] JSON parsing error: #{e.message}"
  warn JSON.generate({
                       continue: true,
                       stopReason: "Stop hook JSON parsing error: #{e.message}",
                       suppressOutput: false
                     })
  exit 1  # JSON error
rescue StandardError => e
  warn "[Stop] Hook execution error: #{e.message}"
  warn e.backtrace.join("\n") if ENV['RUBY_CLAUDE_HOOKS_DEBUG']

  warn JSON.generate({
                       continue: true,
                       stopReason: "Stop hook execution error: #{e.message}",
                       suppressOutput: false
                     })
  exit 1  # General error
end

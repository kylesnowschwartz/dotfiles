#!/usr/bin/env ruby
# frozen_string_literal: true

# Stop Entrypoint
#
# This entrypoint handles Stop hooks for Age of Claude sound effects.
# Triggered when Claude Code finishes generating a response.
#
# Plays the completion sound (villager_train1.wav) from Age of Empires.

require 'json'
# require_relative '../handlers/age_of_claude/stop_handler'
require_relative '../handlers/stop_you_are_not_right'

begin
  # Read input data from Claude Code
  input_data = JSON.parse($stdin.read)

  # # Initialize and execute handler
  # age_of_claude_handler = AgeOfClaudeStopHandler.new(input_data)
  # handler.call

  # Initialize and execute handler
  reflexive_agreement_handler = StopYouAreNotRight.new(input_data)
  reflexive_agreement_handler.call

  # MERGE THE OUTPUTS
  merged_output = ClaudeHooks::Output::Stop.merge(
    reflexive_agreement_handler.output
    # age_of_claude_handler.output
  )

  merged_output.output_and_exit
rescue JSON::ParserError => e
  warn "[Stop] JSON parsing error: #{e.message}"
  warn JSON.generate({
                       continue: true,
                       stopReason: "Stop hook JSON parsing error: #{e.message}",
                       suppressOutput: false
                     })
  exit 1
rescue StandardError => e
  warn "[Stop] Hook execution error: #{e.message}"
  warn e.backtrace.join("\n") if ENV['RUBY_CLAUDE_HOOKS_DEBUG']

  warn JSON.generate({
                       continue: true,
                       stopReason: "Stop hook execution error: #{e.message}",
                       suppressOutput: false
                     })
  exit 1
end

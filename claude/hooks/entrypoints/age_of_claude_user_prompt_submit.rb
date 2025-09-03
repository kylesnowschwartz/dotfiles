#!/usr/bin/env ruby
# frozen_string_literal: true

# Age of Claude UserPromptSubmit Entrypoint
#
# This entrypoint plays Age of Empires villager sounds when users submit prompts.
# It orchestrates the AgeOfClaudeUserPromptSubmitHandler and interfaces with Claude Code.

require 'claude_hooks'
require 'json'

# Require the Age of Claude UserPromptSubmit handler
require_relative '../handlers/age_of_claude/user_prompt_submit_handler'

begin
  # Read input data from Claude Code
  input_data = JSON.parse($stdin.read)

  # Execute Age of Claude UserPromptSubmit handler
  handler = AgeOfClaudeUserPromptSubmitHandler.new(input_data)
  handler.call

  # Output final result to Claude Code with proper format
  handler.output_and_exit
rescue JSON::ParserError => e
  warn "[Age of Claude UserPromptSubmit] JSON parsing error: #{e.message}"
  warn JSON.generate({
                       continue: false,
                       decision: 'block',
                       reason: "Age of Claude UserPromptSubmit hook JSON parsing error: #{e.message}",
                       suppressOutput: false
                     })
  exit 1  # JSON error
rescue StandardError => e
  warn "[Age of Claude UserPromptSubmit] Hook execution error: #{e.message}"
  warn e.backtrace.join("\n") if ENV['RUBY_CLAUDE_HOOKS_DEBUG']

  warn JSON.generate({
                       continue: false,
                       decision: 'block',
                       reason: "Age of Claude UserPromptSubmit hook execution error: #{e.message}",
                       suppressOutput: false
                     })
  exit 1  # General error
end

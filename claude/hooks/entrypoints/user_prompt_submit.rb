#!/usr/bin/env ruby
# frozen_string_literal: true

# UserPromptSubmit Entrypoint
#
# This entrypoint orchestrates all UserPromptSubmit handlers when Claude Code receives a user prompt.
# It reads JSON input from STDIN, executes all configured handlers, merges their outputs,
# and returns the final result to Claude Code via STDOUT.

require 'claude_hooks'
require 'json'

# Require all UserPromptSubmit handler classes
require_relative '../handlers/user_prompt_submit_handler'
# require_relative '../handlers/user_prompt_submit_you_are_not_right'

# Add additional handler requires here as needed:
# require_relative '../handlers/user_prompt_submit/append_rules'
# require_relative '../handlers/user_prompt_submit/log_user_prompt'
# require_relative '../handlers/user_prompt_submit/validate_content'

begin
  # Read input data from Claude Code
  input_data = JSON.parse($stdin.read)

  # Initialize and execute all handlers
  main_handler = UserPromptSubmitHandler.new(input_data)
  # you_are_not_right_handler = YouAreNotRight.new(input_data)

  # Execute handlers
  main_handler.call
  # you_are_not_right_handler.call

  # Merge outputs using the UserPromptSubmit output merger
  merged_output = ClaudeHooks::Output::UserPromptSubmit.merge(
    main_handler.output
    # you_are_not_right_handler.output
  )

  # Output result and exit with appropriate code
  merged_output.output_and_exit
rescue JSON::ParserError => e
  warn "[UserPromptSubmit] JSON parsing error: #{e.message}"
  puts JSON.generate({
                       continue: false,
                       decision: 'block',
                       reason: "UserPromptSubmit hook JSON parsing error: #{e.message}",
                       suppressOutput: false
                     })
  exit 1  # JSON error
rescue StandardError => e
  warn "[UserPromptSubmit] Hook execution error: #{e.message}"
  warn e.backtrace.join("\n") if ENV['RUBY_CLAUDE_HOOKS_DEBUG']

  puts JSON.generate({
                       continue: false,
                       decision: 'block',
                       reason: "UserPromptSubmit hook execution error: #{e.message}",
                       suppressOutput: false
                     })
  exit 1  # General error
end

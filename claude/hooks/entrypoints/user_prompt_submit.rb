#!/usr/bin/env ruby
# frozen_string_literal: true

# UserPromptSubmit Entrypoint
#
# This entrypoint orchestrates all UserPromptSubmit handlers when the user submits a prompt.
# It reads JSON input from STDIN, executes all configured handlers, merges their outputs,
# and returns the final result to Claude Code via STDOUT.

require 'claude_hooks'
require 'json'

# Require all UserPromptSubmit handler classes
# Add additional handler requires here as needed:
require_relative '../handlers/user_prompt_submit/append_session_id'

begin
  # Read input data from Claude Code
  input_data = JSON.parse($stdin.read)

  # Initialize and execute all handlers
  session_id_handler = AppendSessionId.new(input_data)

  # Execute handlers
  session_id_handler.call

  # Use single handler output (or merge multiple if you add more handlers)
  merged_output = session_id_handler.output

  merged_output.output_and_exit
rescue JSON::ParserError => e
  warn "[UserPromptSubmit] JSON parsing error: #{e.message}"
  warn JSON.generate({
                       continue: true,
                       additionalContext: '',
                       decision: nil,
                       stopReason: "UserPromptSubmit hook JSON parsing error: #{e.message}",
                       suppressOutput: false
                     })
  exit 1
rescue StandardError => e
  warn "[UserPromptSubmit] Hook execution error: #{e.message}"
  warn e.backtrace.join("\n") if ENV['RUBY_CLAUDE_HOOKS_DEBUG']

  warn JSON.generate({
                       continue: true,
                       additionalContext: '',
                       decision: nil,
                       stopReason: "UserPromptSubmit hook execution error: #{e.message}",
                       suppressOutput: false
                     })
  exit 1
end

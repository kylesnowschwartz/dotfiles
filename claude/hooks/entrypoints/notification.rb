#!/usr/bin/env ruby
# frozen_string_literal: true

# Notification Entrypoint
#
# This entrypoint orchestrates all Notification handlers when Claude Code sends notifications.
# Notifications are triggered when:
# 1. Claude needs permission to use a tool (e.g., "Claude needs your permission to use Bash")
# 2. When prompt input has been idle for at least 60 seconds (e.g., "Claude is waiting for your input")
#
# It reads JSON input from STDIN, executes all configured handlers, merges their outputs,
# and returns the final result to Claude Code via STDOUT.

require 'claude_hooks'
require 'json'

# Require all Notification handler classes
require_relative '../handlers/notification_handler'
require_relative '../handlers/age_of_claude/notification_handler'

# Add additional handler requires here as needed:
# require_relative '../handlers/notification/desktop_notify'
# require_relative '../handlers/notification/slack_notify'
# require_relative '../handlers/notification/email_alert'

begin
  # Read input data from Claude Code
  input_data = JSON.parse($stdin.read)

  # Initialize and execute all handlers
  main_handler = NotificationHandler.new(input_data)
  age_of_claude_handler = AgeOfClaudeNotificationHandler.new(input_data)

  # Execute handlers
  main_handler.call
  age_of_claude_handler.call

  # Merge outputs using the Notification output merger
  merged_output = ClaudeHooks::Output::Notification.merge(
    main_handler.output,
    age_of_claude_handler.output
  )

  # Output result and exit with appropriate code
  merged_output.output_and_exit
rescue JSON::ParserError => e
  warn "[Notification] JSON parsing error: #{e.message}"
  puts JSON.generate({
                       error: "Notification hook JSON parsing error: #{e.message}"
                     })
  exit 1  # JSON error
rescue StandardError => e
  warn "[Notification] Hook execution error: #{e.message}"
  warn e.backtrace.join("\n") if ENV['RUBY_CLAUDE_HOOKS_DEBUG']

  puts JSON.generate({
                       error: "Notification hook execution error: #{e.message}"
                     })
  exit 1  # General error
end

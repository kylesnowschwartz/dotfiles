#!/usr/bin/env ruby
# frozen_string_literal: true

# Notification Entrypoint
#
# This entrypoint handles Notification hooks for Age of Claude sound effects.
# Notifications are triggered when:
# 1. Claude needs permission to use a tool
# 2. Prompt input has been idle for 60+ seconds
#
# Plays appropriate Age of Empires sound effects based on notification type.

require 'json'
require_relative '../handlers/age_of_claude/notification_handler'

begin
  # Read input data from Claude Code
  input_data = JSON.parse($stdin.read)

  # Initialize and execute handler
  handler = AgeOfClaudeNotificationHandler.new(input_data)
  handler.call

  # Output result and exit with appropriate code
  handler.output_and_exit
rescue JSON::ParserError => e
  warn "[Notification] JSON parsing error: #{e.message}"
  warn JSON.generate({
                       continue: true,
                       stopReason: "Notification hook JSON parsing error: #{e.message}",
                       suppressOutput: false
                     })
  exit 1
rescue StandardError => e
  warn "[Notification] Hook execution error: #{e.message}"
  warn e.backtrace.join("\n") if ENV['RUBY_CLAUDE_HOOKS_DEBUG']

  warn JSON.generate({
                       continue: true,
                       stopReason: "Notification hook execution error: #{e.message}",
                       suppressOutput: false
                     })
  exit 1
end

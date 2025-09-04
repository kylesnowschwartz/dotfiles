#!/usr/bin/env ruby
# frozen_string_literal: true

require 'claude_hooks'

# Basic Notification Handler
#
# PURPOSE: Handle Claude Code notifications (permission requests, idle warnings)
# TRIGGERS: When Claude needs permission to use tools or when idle for 60+ seconds
#
# This is a basic implementation that logs notifications.
# Extend this class for custom notification handling (e.g., desktop notifications, sounds, etc.)

class NotificationHandler < ClaudeHooks::Notification
  def call
    log "Claude Code Notification: #{message}"

    # Send iOS notification popup
    send_ios_notification

    # Notification hooks don't block or modify behavior, they just react
    output_data
  end

  private

  def send_ios_notification
    title = 'Claude Code'
    subtitle = case message
               when /needs your permission/i
                 log "Permission request detected: #{message}", level: :info
                 'Permission Required'
               when /waiting for your input/i
                 log "Idle timeout detected: #{message}", level: :warn
                 'Waiting for Input'
               else
                 log "Other notification: #{message}", level: :info
                 'Notification'
               end

    # Use osascript to send native macOS notification
    command = [
      'osascript', '-e',
      %(display notification "#{escape_quotes(message)}" with title "#{title}" subtitle "#{subtitle}")
    ]

    system(*command)
  rescue StandardError => e
    log "Failed to send iOS notification: #{e.message}", level: :error
  end

  def escape_quotes(text)
    text.to_s.gsub('"', '\\"')
  end
end

# Testing support - run this file directly to test with sample data
if __FILE__ == $PROGRAM_NAME
  ClaudeHooks::CLI.test_runner(NotificationHandler) do |input_data|
    input_data['session_id'] = 'notification-test'
    input_data['message'] = 'Claude needs your permission to use Bash'
  end
end

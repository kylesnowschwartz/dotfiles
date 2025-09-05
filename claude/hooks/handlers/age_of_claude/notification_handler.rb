#!/usr/bin/env ruby
# frozen_string_literal: true

require 'claude_hooks'
require_relative 'sound_player'

# Age of Claude Notification Handler
#
# PURPOSE: Play notification sounds when Claude needs attention
# TRIGGERS: When Claude needs permission to use tools or when idle for 60+ seconds
#
# SOUND MAPPINGS:
# - Permission requests: Alert sound to get user's attention
# - Idle warnings: Different sound to indicate waiting
# - Other notifications: Generic notification sound

class AgeOfClaudeNotificationHandler < ClaudeHooks::Notification
  def call
    log 'Age of Claude Notification Handler: Notification received - determining sound to play'

    # Determine sound based on notification type
    sounds = case message
             when /needs your permission/i
               log 'Age of Claude Notification Handler: Permission request - playing alert sound'
               ['dialogue_hey_im_in_your_town.wav'] # Attention-getting sound
             when /waiting for your input/i
               log 'Age of Claude Notification Handler: Idle timeout - playing waiting sound'
               ['dialogue_i_need_food.wav'] # "I need food" - indicates need
             else
               log 'Age of Claude Notification Handler: Generic notification - playing notification sound'
               ['villager_select4.WAV'] # Generic villager sound
             end

    # Play the appropriate notification sound
    success = SoundPlayer.play_random(sounds, logger)

    if success
      log "Age of Claude Notification Handler: Successfully played notification sound for: #{message}"
    else
      log 'Age of Claude Notification Handler: Failed to play notification sound (continuing anyway)', level: :warn
    end

    # Notification hooks don't modify behavior, just provide feedback
    output_data
  end

  private

  # Helper method to get current logger instance
  def logger
    @logger ||= self
  end
end

# Testing support - run this file directly to test with sample data
if __FILE__ == $PROGRAM_NAME
  ClaudeHooks::CLI.test_runner(AgeOfClaudeNotificationHandler) do |input_data|
    input_data['session_id'] = 'age-of-claude-notification-test'
    input_data['message'] = 'Claude needs your permission to use Bash'
  end
end

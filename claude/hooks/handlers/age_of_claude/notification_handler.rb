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
  POSSIBLE_SOUNDS = [
    'dialogue_hey_im_in_your_town.wav',
    'dialogue_i_need_food.wav',
    'villager_select4.WAV',
    'priest_convert_wololo5.WAV'
  ].freeze

  def call
    log "Age of Claude Notification Handler: #{message}"
    success = SoundPlayer.play_random(POSSIBLE_SOUNDS, logger)

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

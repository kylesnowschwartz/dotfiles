#!/usr/bin/env ruby
# frozen_string_literal: true

require 'claude_hooks'
require_relative 'sound_player'

# Age of Claude Stop Handler
#
# PURPOSE: Play completion sound when Claude finishes responding
# TRIGGERS: When Claude Code finishes generating a response
#
# SOUND MAPPING: Single completion sound - villager_train1.wav

class AgeOfClaudeStopHandler < ClaudeHooks::Stop
  # Completion sound from original Age of Claude
  COMPLETION_SOUND = 'villager_train1.wav'

  def call
    log 'Age of Claude: Claude response completed - playing completion sound'

    # Play completion sound
    success = SoundPlayer.play(COMPLETION_SOUND, logger)

    if success
      log 'Age of Claude: Successfully played completion sound'
    else
      log 'Age of Claude: Failed to play completion sound (continuing anyway)', level: :warn
    end

    # Allow Claude to stop normally - don't block stoppage
    allow_continue!
    suppress_output! # Don't add any output to the transcript

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
  ClaudeHooks::CLI.test_runner(AgeOfClaudeStopHandler) do |input_data|
    input_data['session_id'] = 'age-of-claude-test'
    input_data['stop_hook_active'] = true
  end
end

#!/usr/bin/env ruby
# frozen_string_literal: true

require 'claude_hooks'
require_relative 'sound_player'

# Age of Claude UserPromptSubmit Handler
#
# PURPOSE: Play random villager selection sounds when user submits prompts
# TRIGGERS: When a user submits a prompt to Claude Code
#
# SOUND MAPPINGS: Random selection from Age of Empires villager sounds:
# - dialogue_yes.wav
# - villager_select4.WAV
# - villager_train4.wav

class AgeOfClaudeUserPromptSubmitHandler < ClaudeHooks::UserPromptSubmit
  # Villager selection sounds from original Age of Claude
  VILLAGER_SOUNDS = [
    'dialogue_yes.wav',
    'villager_select4.WAV',
    'villager_train4.wav'
  ].freeze

  def call
    log 'Age of Claude: User prompt submitted - playing villager sound'

    # Play random villager selection sound
    success = SoundPlayer.play_random(VILLAGER_SOUNDS, logger)

    if success
      log 'Age of Claude: Successfully played random villager sound'
    else
      log 'Age of Claude: Failed to play villager sound (continuing anyway)', level: :warn
    end

    # Allow the prompt to continue processing normally
    allow_continue!
    suppress_output! # Don't add any context to Claude's response

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
  ClaudeHooks::CLI.test_runner(AgeOfClaudeUserPromptSubmitHandler) do |input_data|
    input_data['session_id'] = 'age-of-claude-test'
    input_data['prompt'] = 'Hello Claude!'
  end
end

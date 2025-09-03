#!/usr/bin/env ruby
# frozen_string_literal: true

require 'claude_hooks'
require_relative 'sound_player'

# Age of Claude SessionEnd Handler
#
# PURPOSE: Play farewell sounds based on how the Claude session ends
# TRIGGERS: When Claude Code session ends (exit, clear, etc.)
#
# SOUND MAPPINGS: Different sounds based on end reason:
# - "exit": Random farewell sounds (pleading/dismissive)
# - "clear": Soldier selection sound

class AgeOfClaudeSessionEndHandler < ClaudeHooks::SessionEnd
  # Farewell sound mappings based on end reason - matches original Age of Claude
  END_REASON_SOUNDS = {
    # Session exit - random farewell sounds
    'exit' => [
      'dialogue_im_weak_please_dont_kill_me.wav',
      'dialogue_get_out.wav'
    ],

    # Session clear - soldier selection sound
    'clear' => ['soldier_select_papadakis5.wav']
  }.freeze

  # Fallback sound for unmapped end reasons
  DEFAULT_FAREWELL_SOUND = 'dialogue_get_out.wav'

  def call
    end_reason = reason || 'unknown'
    log "Age of Claude: Session ending with reason: #{end_reason}"

    # Find sounds for this end reason
    sounds = find_sounds_for_end_reason(end_reason)

    if sounds && !sounds.empty?
      # Play appropriate farewell sound
      success = SoundPlayer.play_random(sounds, logger)

      if success
        log "Age of Claude: Played farewell sound for end reason: #{end_reason}"
      else
        log "Age of Claude: Failed to play farewell sound for end reason: #{end_reason}", level: :warn
      end
    else
      log "Age of Claude: No sound mapping found for end reason: #{end_reason}, using default"
      SoundPlayer.play(DEFAULT_FAREWELL_SOUND, logger)
    end

    # Allow session to end normally
    allow_continue!
    suppress_output! # Don't add any output

    output_data
  end

  private

  # Find sounds for a given end reason
  # @param end_reason [String] the session end reason
  # @return [Array<String>, nil] array of sound files or nil if no mapping
  def find_sounds_for_end_reason(end_reason)
    # Direct match first
    return END_REASON_SOUNDS[end_reason] if END_REASON_SOUNDS.key?(end_reason)

    # Case-insensitive match
    END_REASON_SOUNDS.each do |pattern, sounds|
      return sounds if end_reason.to_s.match?(/^#{Regexp.escape(pattern)}$/i)
    end

    # No mapping found
    nil
  end

  # Helper method to get current logger instance
  def logger
    @logger ||= self
  end
end

# Testing support - run this file directly to test with sample data
if __FILE__ == $PROGRAM_NAME
  ClaudeHooks::CLI.test_runner(AgeOfClaudeSessionEndHandler) do |input_data|
    input_data['session_id'] = 'age-of-claude-test'
    input_data['reason'] = 'exit'
  end
end

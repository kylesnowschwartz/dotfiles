#!/usr/bin/env ruby
# frozen_string_literal: true

require 'claude_hooks'
require_relative 'sound_player'

# Age of Claude PreCompact Handler
#
# PURPOSE: Play context-appropriate sounds before transcript compaction
# TRIGGERS: Before Claude Code compacts conversation transcripts
#
# SOUND MAPPINGS: Different sounds based on compaction trigger:
# - "auto": "I need food" (automatic compaction due to context limits)
# - "manual": "Your attempts are futile" (manual user-initiated compaction)

class AgeOfClaudePreCompactHandler < ClaudeHooks::PreCompact
  # Compaction sound mappings based on trigger type - matches original Age of Claude
  TRIGGER_SOUNDS = {
    # Automatic compaction - "I need food" (context getting full)
    'auto' => ['dialogue_i_need_food.wav'],

    # Manual compaction - "Your attempts are futile" (user forcing compaction)
    'manual' => ['dialogue_your_attempts_are_futile.wav']
  }.freeze

  # Fallback sound for unmapped trigger types
  DEFAULT_COMPACT_SOUND = 'dialogue_i_need_food.wav'

  def call
    compact_trigger = trigger || 'unknown'
    log "Age of Claude: Pre-compaction triggered by: #{compact_trigger}"

    # Find sounds for this compaction trigger
    sounds = find_sounds_for_trigger(compact_trigger)

    if sounds && !sounds.empty?
      # Play appropriate compaction sound
      success = SoundPlayer.play_random(sounds, logger)

      if success
        log "Age of Claude: Played compaction sound for trigger: #{compact_trigger}"
      else
        log "Age of Claude: Failed to play compaction sound for trigger: #{compact_trigger}", level: :warn
      end
    else
      log "Age of Claude: No sound mapping found for trigger: #{compact_trigger}, using default"
      SoundPlayer.play(DEFAULT_COMPACT_SOUND, logger)
    end

    # Allow compaction to proceed normally
    allow_continue!
    suppress_output! # Don't add any context or output

    output_data
  end

  private

  # Find sounds for a given compaction trigger
  # @param compact_trigger [String] the compaction trigger type
  # @return [Array<String>, nil] array of sound files or nil if no mapping
  def find_sounds_for_trigger(compact_trigger)
    # Direct match first
    return TRIGGER_SOUNDS[compact_trigger] if TRIGGER_SOUNDS.key?(compact_trigger)

    # Case-insensitive match
    TRIGGER_SOUNDS.each do |pattern, sounds|
      return sounds if compact_trigger.to_s.match?(/^#{Regexp.escape(pattern)}$/i)
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
  ClaudeHooks::CLI.test_runner(AgeOfClaudePreCompactHandler) do |input_data|
    input_data['session_id'] = 'age-of-claude-test'
    input_data['trigger'] = 'auto'
    input_data['custom_instructions'] = nil
  end
end

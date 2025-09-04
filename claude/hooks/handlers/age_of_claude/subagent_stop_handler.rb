#!/usr/bin/env ruby
# frozen_string_literal: true

require 'claude_hooks'
require_relative 'sound_player'

# Age of Claude SubagentStop Handler
#
# PURPOSE: Play completion sounds when Claude Code subagents finish
# TRIGGERS: When Claude Code subagent tasks complete
#
# SOUND MAPPING: Subagent completion sound - soldier_select_rudkin1.wav

class AgeOfClaudeSubagentStopHandler < ClaudeHooks::SubagentStop
  # Subagent completion sound from original Age of Claude
  SUBAGENT_COMPLETION_SOUND = 'soldier_select_rudkin1.wav'

  def call
    log 'Age of Claude: Subagent completed - playing completion sound'

    # Play subagent completion sound
    success = SoundPlayer.play(SUBAGENT_COMPLETION_SOUND, logger)

    if success
      log 'Age of Claude: Successfully played subagent completion sound'
    else
      log 'Age of Claude: Failed to play subagent completion sound (continuing anyway)', level: :warn
    end

    # Allow subagent to complete normally
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
  ClaudeHooks::CLI.test_runner(AgeOfClaudeSubagentStopHandler) do |input_data|
    input_data['session_id'] = 'age-of-claude-test'
    input_data['stop_hook_active'] = true
  end
end

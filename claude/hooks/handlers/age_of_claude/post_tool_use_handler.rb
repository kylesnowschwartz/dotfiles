#!/usr/bin/env ruby
# frozen_string_literal: true

require 'claude_hooks'
require_relative 'sound_player'

# Age of Claude PostToolUse Handler
#
# PURPOSE: Play success/completion sounds after tools finish executing
# TRIGGERS: After any tool execution completes (Bash, Write, Edit, etc.)
#
# SOUND MAPPINGS: Based on original Age of Claude configuration
# Success sounds to provide satisfying feedback for completed operations

class AgeOfClaudePostToolUseHandler < ClaudeHooks::PostToolUse
  # Success sound mappings for different tools - matches original Age of Claude
  TOOL_SUCCESS_SOUNDS = {
    # File modification operations - random success sounds
    'Write' => [
      'dialogue_aww_yeah.wav',
      'dialogue_i_just_got_some_satisfaction.wav'
    ],
    'Edit' => [
      'dialogue_aww_yeah.wav',
      'dialogue_i_just_got_some_satisfaction.wav'
    ],
    'MultiEdit' => [
      'dialogue_aww_yeah.wav',
      'dialogue_i_just_got_some_satisfaction.wav'
    ],

    # Command execution - "Aww yeah"
    'Bash' => ['dialogue_aww_yeah.wav'],

    # Search operations - specific villager sound
    'Grep' => ['villager_select18.WAV'],
    'Glob' => ['villager_select18.WAV'],
    'LS' => ['villager_select18.WAV'],

    # Web operations - different villager sound
    'WebFetch' => ['villager_select19.wav'],
    'WebSearch' => ['villager_select19.wav'],

    # Agent tasks and todo operations - working sound
    'Task' => ['working_sound.wav'],
    'TodoWrite' => ['working_sound.wav']
  }.freeze

  def call
    log "Age of Claude: Post-tool use for #{tool_name}"

    # Find success sounds for this tool
    sounds = find_success_sounds_for_tool(tool_name)

    if sounds && !sounds.empty?
      # Play appropriate success sound for this tool
      success = SoundPlayer.play_random(sounds, logger)

      if success
        log "Age of Claude: Played success sound for tool #{tool_name}"
      else
        log "Age of Claude: Failed to play success sound for tool #{tool_name}", level: :warn
      end
    else
      log "Age of Claude: No success sound mapping found for tool #{tool_name}", level: :debug
    end

    # Return output data - don't interfere with tool results
    output_data
  end

  private

  # Find success sounds for a given tool name
  # @param tool [String] the tool name
  # @return [Array<String>, nil] array of sound files or nil if no mapping
  def find_success_sounds_for_tool(tool)
    # Direct match first
    return TOOL_SUCCESS_SOUNDS[tool] if TOOL_SUCCESS_SOUNDS.key?(tool)

    # Pattern matching for compound tool names
    TOOL_SUCCESS_SOUNDS.each do |pattern, sounds|
      # Handle patterns like "Write|Edit|MultiEdit" from original settings
      if pattern.include?('|')
        patterns = pattern.split('|')
        return sounds if patterns.any? { |p| tool.match?(/^#{Regexp.escape(p)}$/i) }
      elsif tool.match?(/^#{Regexp.escape(pattern)}$/i)
        return sounds
      end
    end

    # No mapping found
    nil
  end

  # Check if tool execution was successful (future enhancement)
  # @return [Boolean] true if tool execution was successful
  def tool_execution_successful?
    # For now, always assume success
    # Future enhancement could check tool_result for error indicators
    return true unless tool_result.is_a?(Hash)

    # Example: Check exit code for Bash commands
    return tool_result['exit_code'].zero? if tool_name == 'Bash' && tool_result.key?('exit_code')

    # Default to success for other tools
    true
  end

  # Helper method to get current logger instance
  def logger
    @logger ||= self
  end
end

# Testing support - run this file directly to test with sample data
if __FILE__ == $PROGRAM_NAME
  ClaudeHooks::CLI.test_runner(AgeOfClaudePostToolUseHandler) do |input_data|
    input_data['session_id'] = 'age-of-claude-test'
    input_data['tool_name'] = 'Write'
    input_data['tool_input'] = { 'file_path' => 'test.txt', 'content' => 'Hello World' }
    input_data['tool_result'] = { 'success' => true }
  end
end

#!/usr/bin/env ruby
# frozen_string_literal: true

require 'claude_hooks'
require_relative 'sound_player'

# Age of Claude PreToolUse Handler
#
# PURPOSE: Play tool-specific sounds before Claude executes tools
# TRIGGERS: Before any tool execution (Bash, Write, Edit, etc.)
#
# SOUND MAPPINGS: Based on original Age of Claude configuration
# Different sounds for different tool types to create an RTS-like experience

class AgeOfClaudePreToolUseHandler < ClaudeHooks::PreToolUse
  # Sound mappings for different tools - matches original Age of Claude
  TOOL_SOUNDS = {
    # File reading operations - random villager selection sounds
    'Read' => [
      'villager_select1.WAV',
      'villager_select18.WAV',
      'villager_select19.WAV'
    ],

    # File modification operations - "I'm in your town"
    'Write' => ['dialogue_hey_im_in_your_town.wav'],
    'Edit' => ['dialogue_hey_im_in_your_town.wav'],
    'MultiEdit' => ['dialogue_hey_im_in_your_town.wav'],
    'NotebookEdit' => ['dialogue_hey_im_in_your_town.wav'],

    # Command execution - "Attack them now"
    'Bash' => ['dialogue_attack_them_now.wav'],

    # Search operations - "I need food"
    'Grep' => ['dialogue_i_need_food.wav'],
    'Glob' => ['dialogue_i_need_food.wav'],

    # Directory listing - specific villager sound
    'LS' => ['villager_select4.WAV'],

    # Web operations - working sound
    'WebFetch' => ['working_sound.wav'],
    'WebSearch' => ['working_sound.wav'],

    # Agent tasks - priest conversion sounds
    'Task' => [
      'priest_convert_wololo5.WAV',
      'priest_convert_ayeohoho5.wav'
    ],

    # Todo operations - villager training sounds
    'TodoWrite' => [
      'villager_train1.wav',
      'villager_train4.wav'
    ],

    # Plan mode exit - "Who's the man"
    'ExitPlanMode' => ['dialogue_whos_the_man.wav']
  }.freeze

  def call
    log "Age of Claude: Pre-tool use for #{tool_name}"

    # Find sounds for this tool
    sounds = find_sounds_for_tool(tool_name)

    if sounds && !sounds.empty?
      # Play appropriate sound for this tool
      success = SoundPlayer.play_random(sounds, logger)

      if success
        log "Age of Claude: Played sound for tool #{tool_name}"
      else
        log "Age of Claude: Failed to play sound for tool #{tool_name}", level: :warn
      end
    else
      log "Age of Claude: No sound mapping found for tool #{tool_name}", level: :debug
    end

    # Always approve tool execution - we're just adding sound effects
    approve_tool!("Age of Claude sound played for #{tool_name}")

    output_data
  end

  private

  # Find sounds for a given tool name
  # @param tool [String] the tool name
  # @return [Array<String>, nil] array of sound files or nil if no mapping
  def find_sounds_for_tool(tool)
    # Direct match first
    return TOOL_SOUNDS[tool] if TOOL_SOUNDS.key?(tool)

    # Pattern matching for compound tool names
    TOOL_SOUNDS.each do |pattern, sounds|
      # Handle patterns like "Edit|MultiEdit" from original settings
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

  # Helper method to get current logger instance
  def logger
    @logger ||= self
  end
end

# Testing support - run this file directly to test with sample data
if __FILE__ == $PROGRAM_NAME
  ClaudeHooks::CLI.test_runner(AgeOfClaudePreToolUseHandler) do |input_data|
    input_data['session_id'] = 'age-of-claude-test'
    input_data['tool_name'] = 'Write'
    input_data['tool_input'] = { 'file_path' => 'test.txt', 'content' => 'Hello World' }
  end
end

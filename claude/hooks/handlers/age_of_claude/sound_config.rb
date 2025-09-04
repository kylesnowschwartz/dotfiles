# frozen_string_literal: true

# Age of Claude Sound Configuration
#
# Centralized configuration for all Age of Empires sound mappings.
# Based on the official Age of Claude README.md sound mapping specification.
#
# This configuration allows easy customization and auditing of sound mappings
# without needing to modify individual handler classes.

module AgeOfClaudeSounds
  # Sound file collections for random selection
  SOUND_COLLECTIONS = {
    # Random villager selection sounds (used for UserPromptSubmit and Read tools)
    villager_selection: [
      'dialogue_yes.wav',
      'villager_select4.WAV',
      'villager_select18.WAV',
      'villager_select19.WAV',
      'villager_train4.wav'
    ],

    # Alternative villager selection sounds (used by Read tools in original)
    villager_selection_alt: [
      'villager_select1.WAV',
      'villager_select18.WAV',
      'villager_select19.WAV'
    ],

    # Random farewell sounds (used for SessionEnd exit)
    farewell_sounds: [
      'dialogue_im_weak_please_dont_kill_me.wav',
      'dialogue_get_out.wav'
    ],

    # Random priest conversion sounds (used for Task tools)
    priest_conversion: [
      'priest_convert_wololo5.WAV',
      'priest_convert_ayeohoho5.wav'
    ],

    # Random villager training sounds (used for TodoWrite)
    villager_training: [
      'villager_train1.wav',
      'villager_train4.wav'
    ],

    # Random success sounds (used for PostToolUse Write/Edit/MultiEdit)
    success_sounds: [
      'dialogue_aww_yeah.wav',
      'dialogue_i_just_got_some_satisfaction.wav'
    ]
  }.freeze

  # 📁 SESSION LIFECYCLE SOUNDS
  SESSION_SOUNDS = {
    # UserPromptSubmit - Random villager selection sounds
    user_prompt_submit: :villager_selection,

    # Stop - Completion sound
    stop: 'villager_train1.wav',

    # SessionEnd - Context-specific sounds
    session_end: {
      'exit' => :farewell_sounds, # Random farewell sounds
      'clear' => 'soldier_select_papadakis5.wav'
    },

    # SubagentStop - Soldier completion sound
    subagent_stop: 'soldier_select_rudkin1.wav'
  }.freeze

  # 📁 PRE-TOOL USE SOUNDS (before tool execution)
  PRE_TOOL_SOUNDS = {
    # File reading operations
    'Read' => :villager_selection_alt,

    # File modification operations - "I'm in your town"
    'Write' => 'dialogue_hey_im_in_your_town.wav',
    'Edit' => 'dialogue_hey_im_in_your_town.wav',
    'MultiEdit' => 'dialogue_hey_im_in_your_town.wav',
    'NotebookEdit' => 'dialogue_hey_im_in_your_town.wav',

    # Command execution - "Attack them now"
    'Bash' => 'dialogue_attack_them_now.wav',

    # Search operations - "I need food"
    'Grep' => 'dialogue_i_need_food.wav',
    'Glob' => 'dialogue_i_need_food.wav',

    # Directory listing - Specific villager sound
    'LS' => 'villager_select4.WAV',

    # Web operations - Working sound
    'WebFetch' => 'working_sound.wav',
    'WebSearch' => 'working_sound.wav',

    # Agent tasks - Priest conversion sounds (Wololo!)
    'Task' => :priest_conversion,

    # Todo operations - Villager training sounds
    'TodoWrite' => :villager_training,

    # Plan mode exit - "Who's the man"
    'ExitPlanMode' => 'dialogue_whos_the_man.wav'
  }.freeze

  # 📁 POST-TOOL USE SOUNDS (after tool completion)
  POST_TOOL_SOUNDS = {
    # File modification success - Random success sounds
    'Write' => :success_sounds,
    'Edit' => :success_sounds,
    'MultiEdit' => :success_sounds,

    'Bash' => 'working_sound.wav',

    # Search completion - Villager select 18
    'Grep' => 'villager_select18.WAV',
    'Glob' => 'villager_select18.WAV',
    'LS' => 'villager_select18.WAV',

    # Web completion - Villager select 19
    'WebFetch' => 'villager_select19.WAV',
    'WebSearch' => 'villager_select19.WAV',

    # Agent and todo completion - Working sound
    'Task' => 'working_sound.wav',
    'TodoWrite' => 'working_sound.wav'
  }.freeze

  # 📁 CONTEXT MANAGEMENT SOUNDS
  CONTEXT_SOUNDS = {
    # PreCompact - Different sounds for auto vs manual compaction
    pre_compact: {
      'auto' => 'dialogue_i_need_food.wav', # "I need food" (context getting full)
      'manual' => 'dialogue_your_attempts_are_futile.wav' # "Your attempts are futile" (user forcing)
    }
  }.freeze

  # Utility methods for sound resolution
  class << self
    # Get sounds for UserPromptSubmit
    def user_prompt_submit_sounds
      resolve_sounds(SESSION_SOUNDS[:user_prompt_submit])
    end

    # Get sounds for Stop
    def stop_sounds
      resolve_sounds(SESSION_SOUNDS[:stop])
    end

    # Get sounds for SessionEnd based on end reason
    def session_end_sounds(end_reason)
      sound_config = SESSION_SOUNDS[:session_end][end_reason.to_s]
      sound_config ? resolve_sounds(sound_config) : nil
    end

    # Get sounds for SubagentStop
    def subagent_stop_sounds
      resolve_sounds(SESSION_SOUNDS[:subagent_stop])
    end

    # Get sounds for PreToolUse based on tool name
    def pre_tool_sounds(tool_name)
      sound_config = PRE_TOOL_SOUNDS[tool_name.to_s]
      sound_config ? resolve_sounds(sound_config) : nil
    end

    # Get sounds for PostToolUse based on tool name
    def post_tool_sounds(tool_name)
      sound_config = POST_TOOL_SOUNDS[tool_name.to_s]
      sound_config ? resolve_sounds(sound_config) : nil
    end

    # Get sounds for PreCompact based on trigger type
    def pre_compact_sounds(trigger_type)
      sound_config = CONTEXT_SOUNDS[:pre_compact][trigger_type.to_s]
      sound_config ? resolve_sounds(sound_config) : nil
    end

    private

    # Resolve sound configuration to actual sound file array
    # @param sound_config [String, Symbol, Array] Sound configuration
    # @return [Array<String>] Array of sound file names
    def resolve_sounds(sound_config)
      case sound_config
      when String
        [sound_config] # Single sound file
      when Symbol
        SOUND_COLLECTIONS[sound_config] || [] # Sound collection
      when Array
        sound_config # Already an array
      else
        []
      end
    end
  end
end

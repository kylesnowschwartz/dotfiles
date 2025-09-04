# frozen_string_literal: true

# SoundPlayer Module for Age of Claude
#
# Provides cross-platform sound playback functionality for Age of Empires audio hooks.
# Handles platform detection, sound file path resolution, and background playback.
#
# Usage:
#   SoundPlayer.play('dialogue_yes.wav')
#   SoundPlayer.play_random(['sound1.wav', 'sound2.wav'])

module SoundPlayer
  class << self
    # Play a single sound file
    # @param sound_file [String] the sound file name (relative to .claude/sounds/)
    # @param logger [Logger] optional logger for debugging
    def play(sound_file, logger = nil)
      sound_path = resolve_sound_path(sound_file)

      unless File.exist?(sound_path)
        log_error("Sound file not found: #{sound_path}", logger)
        return false
      end

      command = build_play_command(sound_path)
      success = execute_command(command, logger)

      log_debug("Played sound: #{sound_file} (success: #{success})", logger) if logger
      success
    end

    # Play a random sound from an array of sound files
    # @param sound_files [Array<String>] array of sound file names
    # @param logger [Logger] optional logger for debugging
    def play_random(sound_files, logger = nil)
      return false if sound_files.empty?

      selected_sound = sound_files.sample
      log_debug("Selected random sound: #{selected_sound} from #{sound_files.length} options", logger) if logger
      play(selected_sound, logger)
    end

    private

    # Resolve sound file path using absolute paths only
    # @param sound_file [String] the sound file name
    # @return [String] absolute path to sound file
    def resolve_sound_path(sound_file)
      # Use absolute paths in priority order
      absolute_paths = [
        File.join(File.expand_path('~'), '.claude', 'sounds', sound_file),
        File.join(File.expand_path('~'), 'Code/meta-claude/age-of-claude-ruby/.claude.example/hooks/sounds/',
                  sound_file)
      ]

      # Return first existing path, or first path as fallback for error handling
      absolute_paths.find { |path| File.exist?(path) } || absolute_paths.first
    end

    # Build platform-specific sound play command
    # @param sound_path [String] absolute path to sound file
    # @return [String] shell command to play the sound
    def build_play_command(sound_path)
      escaped_path = shell_escape(sound_path)

      case detect_platform
      when :macos
        "afplay -v 0.5 #{escaped_path} 2>/dev/null &"
      when :windows
        # Use PowerShell for Windows sound playback
        "(New-Object Media.SoundPlayer '#{sound_path}').PlaySync() 2>$null &"
      when :linux
        # Try multiple Linux audio players in order of preference
        "{ aplay -q #{escaped_path} || paplay #{escaped_path} || ffplay -nodisp -autoexit #{escaped_path}; } 2>/dev/null &"
      else
        # Fallback for unknown platforms
        "echo 'Unsupported platform for sound playback' >/dev/null &"
      end
    end

    # Execute the sound play command
    # @param command [String] shell command to execute
    # @param logger [Logger] optional logger for debugging
    # @return [Boolean] true if command executed successfully
    def execute_command(command, logger)
      # Use system() with background execution to avoid blocking
      result = system(command)

      if result.nil?
        log_error("Failed to execute sound command: #{command}", logger)
        false
      else
        true
      end
    rescue StandardError => e
      log_error("Sound playback error: #{e.message}", logger)
      false
    end

    # Detect the current platform
    # @return [Symbol] :macos, :windows, :linux, or :unknown
    def detect_platform
      case RbConfig::CONFIG['host_os']
      when /darwin|mac os/
        :macos
      when /mswin|msys|mingw|cygwin|bccwin|wince|emc/
        :windows
      when /linux/
        :linux
      else
        :unknown
      end
    end

    # Escape shell arguments to prevent injection
    # @param path [String] file path to escape
    # @return [String] shell-escaped path
    def shell_escape(path)
      # Simple shell escaping - wrap in single quotes and escape any existing single quotes
      "'#{path.gsub("'", "'\\''")}'"
    end

    # Log error message
    # @param message [String] error message
    # @param logger [Logger] optional logger
    def log_error(message, logger)
      if logger
        logger.log(message, level: :error)
      else
        warn("[SoundPlayer] #{message}")
      end
    end

    # Log debug message
    # @param message [String] debug message
    # @param logger [Logger] optional logger
    def log_debug(message, logger)
      if logger
        logger.log(message, level: :debug)
      elsif ENV['RUBY_CLAUDE_HOOKS_DEBUG']
        warn("[SoundPlayer] #{message}")
      end
    end
  end
end

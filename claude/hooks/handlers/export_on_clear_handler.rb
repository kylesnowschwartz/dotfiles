#!/usr/bin/env ruby
# frozen_string_literal: true

require 'claude_hooks'
require 'fileutils'

# Export on Clear Handler
#
# PURPOSE: Export Claude session transcripts to a designated directory when sessions are cleared
# TRIGGERS: When Claude Code session ends with reason "clear"
#
# FUNCTIONALITY: Replicates the behavior of the original bash script:
# - Only exports when session ends due to /clear command
# - Creates timestamped copies of transcript files
# - Stores exports in ~/claude_exports directory

class ExportOnClearHandler < ClaudeHooks::SessionEnd
  # Export directory for saved transcripts
  EXPORT_DIR = File.expand_path('~/claude_exports').freeze

  def call
    end_reason = reason || 'unknown'
    transcript_file = transcript_path

    log "Export on Clear: Session ending with reason: #{end_reason}"

    # Only export if the session was ended by /clear
    if end_reason == 'clear'
      export_transcript(transcript_file)
    else
      log "Export on Clear: Skipping export - session ended with reason: #{end_reason}"
    end

    # Allow session to end normally
    allow_continue!
    suppress_output! # Don't add any output

    output_data
  end

  private

  # Export the transcript file to the designated directory
  # @param transcript_file [String] path to the transcript file
  def export_transcript(transcript_file)
    if transcript_file.nil? || transcript_file.empty?
      log 'Export on Clear: No transcript path provided', level: :warn
      return
    end

    unless File.exist?(transcript_file)
      log "Export on Clear: Transcript file does not exist: #{transcript_file}", level: :warn
      return
    end

    # Ensure export directory exists
    ensure_export_directory

    # Create timestamped filename
    original_filename = File.basename(transcript_file)
    timestamp = Time.now.strftime('%Y%m%d_%H%M%S')
    export_filename = "#{timestamp}_#{original_filename}"
    export_path = File.join(EXPORT_DIR, export_filename)

    begin
      # Copy the transcript file to the export directory
      FileUtils.cp(transcript_file, export_path)
      log "Export on Clear: Successfully exported transcript to #{export_path}"
    rescue StandardError => e
      log "Export on Clear: Failed to export transcript: #{e.message}", level: :error
    end
  end

  # Ensure the export directory exists
  def ensure_export_directory
    return if File.directory?(EXPORT_DIR)

    begin
      FileUtils.mkdir_p(EXPORT_DIR)
      log "Export on Clear: Created export directory: #{EXPORT_DIR}"
    rescue StandardError => e
      log "Export on Clear: Failed to create export directory: #{e.message}", level: :error
      raise
    end
  end
end

# Testing support - run this file directly to test with sample data
if __FILE__ == $PROGRAM_NAME
  ClaudeHooks::CLI.test_runner(ExportOnClearHandler) do |input_data|
    input_data['session_id'] = 'export-test'
    input_data['reason'] = 'clear'
    input_data['transcript_path'] = '/tmp/test_transcript.md'

    # Create a test transcript file for testing
    File.write(input_data['transcript_path'], "# Test Transcript\n\nThis is a test transcript.")
  end
end

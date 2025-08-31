#!/usr/bin/env ruby
# frozen_string_literal: true

require 'claude_hooks'
require 'json'
require 'rbconfig'

# UserPromptSubmit Handler
#
# PURPOSE: Modify, validate, or enhance user prompts before processing
# TRIGGERS: When user submits a prompt to Claude Code
#
# COMMON USE CASES:
# - Add context rules or project-specific instructions
# - Validate prompt content (block inappropriate requests)
# - Append relevant documentation or code examples
# - Transform or rewrite prompts for better results
# - Log user interactions for analytics
# - Apply prompt templates or formatting
#
# SETTINGS.JSON CONFIGURATION:
# {
#   "hooks": {
#     "UserPromptSubmit": [{
#       "matcher": "",
#       "hooks": [{
#         "type": "command",
#         "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/entrypoints/user_prompt_submit.rb"
#       }]
#     }]
#   }
# }

class UserPromptSubmitHandler < ClaudeHooks::UserPromptSubmit
  def call
    log "Processing user prompt: #{prompt[0..100]}..."

    copy_prompt
    copy_response


    output
  end

  private

  def copy_prompt
    return unless current_prompt.start_with?('/copy-prompt')

    log "Processing copy-prompt command: #{current_prompt}"

    # Parse command arguments
    args = parse_copy_command(current_prompt, 'prompt')

    begin
      responses = extract_prompts_from_transcript
      result = handle_copy_command(responses, args, 'prompt')

      if result[:success]
        copy_to_clipboard(result[:content])
        block_prompt!(result[:message])
      else
        log result[:error], level: :error
        block_prompt!("Error: #{result[:error]}")
      end
    rescue StandardError => e
      log "Copy prompt failed: #{e.message}", level: :error
      block_prompt!("Failed to copy prompt: #{e.message}")
    end
  end

  def copy_response
    return unless current_prompt.start_with?('/copy-response')

    log "Processing copy-response command: #{current_prompt}"

    # Parse command arguments
    args = parse_copy_command(current_prompt, 'response')

    begin
      responses = extract_responses_from_transcript
      result = handle_copy_command(responses, args, 'response')

      if result[:success]
        copy_to_clipboard(result[:content])
        block_prompt!(result[:message])
      else
        log result[:error], level: :error
        block_prompt!("Error: #{result[:error]}")
      end
    rescue StandardError => e
      log "Copy response failed: #{e.message}", level: :error
      block_prompt!("Failed to copy response: #{e.message}")
    end
  end


  # Copy command parsing and handling methods
  def parse_copy_command(command, type)
    args = {
      command: type,
      number: 1,
      list: false,
      find: false,
      search_term: nil,
      list_count: 10,
      debug: false
    }

    # Parse different command formats
    case command
    when %r{^/copy-#{type}\s+list(?:\s+(\d+))?$}
      args[:list] = true
      args[:list_count] = ::Regexp.last_match(1).to_i if ::Regexp.last_match(1)
    when %r{^/copy-#{type}\s+find\s+"([^"]+)"$}
      args[:find] = true
      args[:search_term] = ::Regexp.last_match(1)
    when %r{^/copy-#{type}\s+debug(?:\s+(\d+))?$}
      args[:debug] = true
      args[:number] = ::Regexp.last_match(1).to_i if ::Regexp.last_match(1)
    when %r{^/copy-#{type}\s+(\d+)$}
      args[:number] = ::Regexp.last_match(1).to_i
    end

    args
  end

  def handle_copy_command(items, args, type)
    return { success: false, error: "No #{type}s found" } if items.empty?

    if args[:list]
      list_items(items, args[:list_count], type)
      { success: false, error: 'List displayed' }
    elsif args[:find]
      find_items(items, args[:search_term], type)
      { success: false, error: 'Search results displayed' }
    elsif args[:debug]
      item = get_item_by_number(items, args[:number])
      return { success: false, error: "#{type.capitalize} ##{args[:number]} not found" } unless item

      debug_item(item, args[:number], type)
      { success: true, content: item, message: "#{type.capitalize} ##{args[:number]} copied (debug mode)" }
    else
      item = get_item_by_number(items, args[:number])
      return { success: false, error: "#{type.capitalize} ##{args[:number]} not found" } unless item

      { success: true, content: item, message: "#{type.capitalize} ##{args[:number]} copied to clipboard!" }
    end
  end

  def extract_responses_from_transcript
    return [] unless transcript_path && File.exist?(transcript_path)

    request_groups = {}

    # Read transcript file line by line and parse JSON
    File.foreach(transcript_path) do |line|
      next if line.strip.empty?

      begin
        data = JSON.parse(line.strip)
        next unless data['message'] && data['message']['role'] == 'assistant'

        request_id = data['requestId']
        content = data.dig('message', 'content', 0, 'text') || ''

        # Group by request ID to handle multi-part responses
        if request_groups[request_id]
          request_groups[request_id] += "\n" + content if content
        else
          request_groups[request_id] = content
        end
      rescue JSON::ParserError => e
        log "Failed to parse transcript line: #{e.message}", level: :warn
      end
    end

    # Convert to array (newest first)
    request_groups.values.reverse
  end

  def extract_prompts_from_transcript
    return [] unless transcript_path && File.exist?(transcript_path)

    request_groups = {}

    # Read transcript file line by line and parse JSON
    File.foreach(transcript_path) do |line|
      next if line.strip.empty?

      begin
        data = JSON.parse(line.strip)
        next unless data['message'] && data['message']['role'] == 'user'

        request_id = data['requestId']
        content = data.dig('message', 'content') || ''

        # Group by request ID to handle multi-part prompts
        if request_groups[request_id]
          request_groups[request_id] += "\n" + content if content
        else
          request_groups[request_id] = content
        end
      rescue JSON::ParserError => e
        log "Failed to parse transcript line: #{e.message}", level: :warn
      end
    end

    # Convert to array (newest first)
    request_groups.values.reverse
  end

  def get_item_by_number(items, number)
    return nil if number < 1 || number > items.length

    items[number - 1]
  end

  def list_items(items, count, type)
    log "Available #{type}s (1-#{items.length}):"

    items.first(count).each_with_index do |item, index|
      preview = generate_preview(item)
      log "  #{index + 1}: #{preview}"
    end
  end

  def find_items(items, search_term, type)
    log "Searching for \"#{search_term}\":"
    found_count = 0

    items.each_with_index do |item, index|
      next unless item.downcase.include?(search_term.downcase)

      found_count += 1
      preview = generate_preview(item)
      log "  #{index + 1}: #{preview}"
    end

    if found_count == 0
      log "No #{type}s found matching \"#{search_term}\""
    else
      log "Found #{found_count} matching #{type}s"
    end
  end

  def debug_item(item, _number, type)
    log '=== DEBUG MODE ==='
    log "Selected #{type} content:"
    log item
    log ''
    log "Byte count: #{item.bytesize}"
    log "Character count: #{item.length}"
    log "First 100 bytes (hex): #{item[0..99].bytes.map { |b| format('%02x', b) }.join(' ')}"
  end

  def generate_preview(text)
    return '<empty>' if text.nil? || text.strip.empty?

    # Get first non-empty line, truncate if too long
    preview = text.lines.find { |line| !line.strip.empty? }&.strip || text.strip
    preview = preview[0..59] + '...' if preview.length > 60
    preview
  end

  def copy_to_clipboard(text)
    require 'open3'

    case RbConfig::CONFIG['host_os']
    when /darwin/
      Open3.popen3('pbcopy') { |stdin, _stdout, _stderr, _thread| stdin.write(text) }
    when /linux/
      if system('which xclip >/dev/null 2>&1')
        Open3.popen3('xclip', '-selection', 'clipboard') { |stdin, _stdout, _stderr, _thread| stdin.write(text) }
      else
        log 'xclip not found - clipboard copy failed', level: :error
        raise 'xclip not available'
      end
    when /mswin|mingw|cygwin/
      # Windows - write to temp file then use PowerShell
      require 'tempfile'
      temp_file = Tempfile.new('claude_copy')
      temp_file.write("\xEF\xBB\xBF#{text}") # UTF-8 BOM
      temp_file.close
      system("powershell.exe -Command \"Get-Content -Path '#{temp_file.path}' -Encoding UTF8 | Set-Clipboard\"")
      temp_file.unlink
    else
      log 'Unsupported platform for clipboard operations', level: :error
      raise 'Unsupported platform'
    end

    log "Copied #{text.length} characters to clipboard"
  end
end

# Testing support - run this file directly to test with sample data
if __FILE__ == $PROGRAM_NAME
  ClaudeHooks::CLI.test_runner(UserPromptSubmitHandler) do |input_data|
    input_data['prompt'] = 'Help me implement a new feature'
    input_data['session_id'] = 'test-session-01'
  end
end

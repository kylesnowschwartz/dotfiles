#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'hooks/handlers/copy_message_handler'

# Mock the ClaudeHooks environment for testing
class TestHandler < CopyMessageHandler
  def initialize(transcript_path, prompt)
    @transcript_path = transcript_path
    @prompt = prompt
  end

  attr_reader :transcript_path

  def current_prompt
    @prompt
  end

  def log(message, level: :info)
    puts "[#{level.upcase}] #{message}"
  end

  def block_prompt!(message)
    puts "BLOCKED: #{message}"
  end

  def copy_to_clipboard(text)
    puts "COPIED #{text.length} characters to clipboard"
    puts "First 100 chars: #{text[0..99]}..."
  end

  def call_public
    call
  end
end

# Test with a real transcript file
transcript_file = '/Users/kyle/backups/claude/projects/-Users-kyle-Code-meta-claude/b66ef1b5-9d30-4e88-80b1-9e2e0745e76c.jsonl'

puts 'Testing --copy-prompt 1'
handler1 = TestHandler.new(transcript_file, '--copy-prompt 1')
handler1.call_public

puts "\nTesting --copy-prompt 3"
handler2 = TestHandler.new(transcript_file, '--copy-prompt 3')
handler2.call_public

puts "\nTesting --copy-response 2"
handler3 = TestHandler.new(transcript_file, '--copy-response 2')
handler3.call_public

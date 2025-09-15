#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'
require 'claude_hooks'

# Claude Code hook to prevent reflexive agreement phrases like "you are right"
#
# This hook checks whether the assistant has recently told the user they are right.
# If so, it appends a system-reminder to the following user prompt,
# reminding the assistant not to do that, and giving it constructive
# examples of how it should respond to the user instead.
class YouAreNotRight < ClaudeHooks::UserPromptSubmit
  # Patterns that trigger the reminder
  AGREEMENT_PATTERNS = [
    /.*[Yy]ou.*(right|correct)/,     # "You're right", "you are correct"
    /.*[Aa]bsolutely/                # "Absolutely"
  ].freeze

  def call
    log 'Checking for reflexive agreement patterns in recent conversation'

    # Check if we need to add the reminder
    if needs_reminder?
      log 'Found reflexive agreement pattern - adding system reminder', level: :warn
      add_system_reminder!
    else
      log 'No reflexive agreement patterns found'
    end

    output
  end

  private

  def needs_reminder?
    return false unless transcript_path

    # Look through the last 5 assistant messages
    assistant_messages = extract_recent_assistant_messages(transcript_path, 5)

    log "Found #{assistant_messages.length} assistant messages to check"

    assistant_messages.any? do |message|
      # Check first 80 characters for agreement patterns (like the original)
      text = message.dig('message', 'content', 0, 'text')
      next false unless text.is_a?(String)

      first_80_chars = text[0, 80]
      log "Checking text: '#{first_80_chars}'"

      pattern_match = AGREEMENT_PATTERNS.any? { |pattern| first_80_chars.match?(pattern) }
      log "Pattern match result: #{pattern_match}"

      pattern_match
    end
  end

  def extract_recent_assistant_messages(transcript, count)
    return [] unless File.exist?(transcript)

    assistant_lines = []

    # Read all lines and filter for assistant messages (like grep in bash)
    File.readlines(transcript).each do |line|
      next unless line.include?('"role":"assistant"')

      assistant_lines << line.strip
    end

    # Take the last 5 (like tail -n 5 in bash)
    recent_lines = assistant_lines.last(count)

    # Parse and return the messages
    messages = []
    recent_lines.each do |line|
      item = JSON.parse(line)
      next unless item['type'] == 'assistant'
      next unless item.dig('message', 'content', 0, 'type') == 'text'

      messages << item
    rescue JSON::ParserError
      next
    end

    messages
  end

  def add_system_reminder!
    system_reminder = <<~REMINDER
      <system-reminder>
      Avoid reflexive agreement phrases like "you are right" or "absolutely correct."

      Instead, engage thoughtfully: analyze the user's reasoning, identify potential improvements,
      or provide substantive confirmation when their approach is sound.

      When the user presents a valid solution:
      - Acknowledge the correctness with specific technical reasoning
      - Consider edge cases, alternative approaches, or potential optimizations
      - Build collaboratively rather than merely agreeing

      When the user's approach has issues:
      - Identify specific problems or gaps
      - Suggest concrete improvements
      - Explain the technical reasoning behind your analysis

      <example>
      user: It's failing on empty inputs, so we should add a null-check.
      assistant: That addresses the immediate null case. For robustness,
      checking for all falsy values (null, undefined, empty string) would
      handle the broader input validation concern more comprehensively.
      </example>

      <example>
      user: I'm concerned that we haven't handled connection failure.
      assistant: Good catch - the connection attempt on line 42 lacks error
      handling. If that fails, the catch block on line 49 won't trigger.
      Moving the try-catch around the connection attempt would resolve this.
      </example>

      <example>
      user: We should use async/await here instead of promises.
      assistant: Async/await would improve readability here. The current promise
      chain handles errors correctly and the logic is sound - converting to
      async/await maintains the same error handling while making the code
      more maintainable.
      </example>
      </system-reminder>
    REMINDER

    add_additional_context!(system_reminder)
  end
end

# Run the hook when executed directly
ClaudeHooks::CLI.test_runner(YouAreNotRight) if __FILE__ == $PROGRAM_NAME

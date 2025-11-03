#!/usr/bin/env ruby
# frozen_string_literal: true

# Append Session ID Handler
#
# When the user asks to create a commit, this handler automatically appends
# the Claude Code session UUID to the additional context. This provides
# traceability from git commits back to the original Claude conversation.

require 'claude_hooks'

class AppendSessionId < ClaudeHooks::UserPromptSubmit
  def call
    return output unless commit_related_prompt?

    log 'Detected commit-related prompt, appending session ID'
    add_context!(session_context)

    output
  end

  private

  def commit_related_prompt?
    prompt.match?(/\b(commit|git commit|create.*commit)\b/i)
  end

  def session_context
    <<~CONTEXT

      **IMPORTANT**: Append the session ID to all commit messages in the format shown below:

      ```bash
      git commit -m "fix: description of changes

      Session: #{session_id}"
      ```

      The session ID provides traceability from commits back to the Claude Code conversation.
    CONTEXT
  end
end

# CLI test support
if __FILE__ == $PROGRAM_NAME
  ClaudeHooks::CLI.test_runner(AppendSessionId) do |input_data|
    # Provide sample commit-related prompt for testing
    input_data['prompt'] ||= 'Please commit these changes'
  end
end

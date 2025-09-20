#!/usr/bin/env ruby
# frozen_string_literal: true

require 'claude_hooks'

# UserPromptSubmit Handler Template
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

    # Example: Add context to all prompts
    # add_context!("Remember to follow the project coding standards.")

    # Example: Block prompts containing certain keywords
    # if prompt.downcase.include?('forbidden_keyword')
    #   block_prompt!("This type of request is not allowed")
    #   return output
    # end

    # Example: Transform prompts based on patterns
    # if prompt.start_with?('/help')
    #   add_context!("Please provide detailed explanations and examples.")
    # end

    # Example: Log specific types of prompts
    # if prompt.include?('refactor')
    #   log "Refactoring request detected", level: :info
    # end

    # Return the output (allows prompt to continue by default)
    output
  end

  # Example helper method: Check if prompt contains code
  # def contains_code?
  #   prompt.match?(/```|`\w+`|\bclass\b|\bdef\b|\bfunction\b/)
  # end

  # Example helper method: Extract command from prompt
  # def extract_command
  #   return nil unless prompt.start_with?('/')
  #
  #   prompt.split(' ').first
  # end

  # Example helper method: Validate prompt length
  # def validate_prompt_length
  #   if prompt.length > 10000
  #     block_prompt!("Prompt too long (#{prompt.length} chars). Please shorten to under 10,000 characters.")
  #     return false
  #   end
  #   true
  # end
end

# Testing support - run this file directly to test with sample data
if __FILE__ == $PROGRAM_NAME
  ClaudeHooks::CLI.test_runner(UserPromptSubmitHandler) do |input_data|
    input_data['prompt'] = 'Help me implement a new feature'
    input_data['session_id'] = 'test-session-01'
  end
end

# frozen_string_literal: true

require 'rspec'
require 'json'
require 'tempfile'

# Load the handler under test
require_relative '../hooks/handlers/copy_message_handler'

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
end

module SpecHelpers
  # Mock clipboard operations to avoid actual system calls
  def mock_clipboard_operations(handler)
    @last_clipboard_content = nil
    allow(handler).to receive(:copy_to_clipboard) do |content|
      @last_clipboard_content = content
    end
  end

  # Get the last content that would have been copied to clipboard
  def last_clipboard_content
    @last_clipboard_content
  end

  # Create a mock handler with test data
  def create_handler(prompt:, transcript_file: nil)
    handler = CopyMessageHandler.new

    # Mock the current_prompt method
    allow(handler).to receive(:current_prompt).and_return(prompt)

    # Mock transcript_path to return our test fixture path
    if transcript_file
      allow(handler).to receive(:transcript_path).and_return(transcript_file)
    else
      allow(handler).to receive(:transcript_path).and_return(nil)
    end

    # Mock block_prompt! to capture the message
    @blocked_message = nil
    allow(handler).to receive(:block_prompt!) do |message|
      @blocked_message = message
    end

    # Mock log method to suppress output during testing
    allow(handler).to receive(:log)

    # Mock output method (returns nil normally)
    allow(handler).to receive(:output).and_return(nil)

    # Mock clipboard operations
    mock_clipboard_operations(handler)

    handler
  end

  # Get the message that was used to block the prompt
  def blocked_message
    @blocked_message
  end

  # Helper to get fixture file path
  def fixture_path(filename)
    File.join(__dir__, 'fixtures', filename)
  end

  # Helper to create temporary fixture with specific content
  def create_temp_fixture(entries)
    temp = Tempfile.new('test_transcript')
    entries.each { |entry| temp.puts(entry.to_json) }
    temp.close
    temp.path
  end
end

RSpec.configure do |config|
  config.include SpecHelpers
end

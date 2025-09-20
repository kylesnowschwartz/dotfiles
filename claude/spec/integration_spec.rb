# frozen_string_literal: true

require_relative 'spec_helper'

RSpec.describe 'Integration with real backup files' do
  let(:real_backup_file) { fixture_path('mixed_transcript.jsonl') }

  context 'with real backup JSONL data' do
    it 'extracts prompts from real transcript format' do
      handler = create_handler(
        prompt: '--copy-prompt 1',
        transcript_file: real_backup_file
      )

      handler.call

      expect(last_clipboard_content).not_to be_nil
      expect(blocked_message).to include('copied to clipboard')
    end

    it 'extracts responses from real transcript format' do
      handler = create_handler(
        prompt: '--copy-response 1',
        transcript_file: real_backup_file
      )

      handler.call

      expect(last_clipboard_content).not_to be_nil
      expect(blocked_message).to include('copied to clipboard')
    end

    it 'counts messages correctly from real data' do
      # Let's see how many messages we actually have
      handler = create_handler(
        prompt: '--copy-prompt 100', # Request way more than available
        transcript_file: real_backup_file
      )

      handler.call

      expect(blocked_message).to match(/Only \d+ prompts? available/)
    end
  end
end

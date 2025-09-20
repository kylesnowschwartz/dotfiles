# frozen_string_literal: true

require_relative 'spec_helper'

RSpec.describe CopyMessageHandler do
  describe '#call' do
    context 'when prompt does not start with copy commands' do
      it 'ignores non-copy commands' do
        handler = create_handler(prompt: 'regular prompt')
        result = handler.call

        expect(result).to be_nil
        expect(blocked_message).to be_nil
        expect(last_clipboard_content).to be_nil
      end
    end

    context 'copy-prompt commands' do
      it 'copies most recent prompt by default' do
        handler = create_handler(
          prompt: '--copy-prompt',
          transcript_file: fixture_path('simple_test.jsonl')
        )

        handler.call

        expect(last_clipboard_content).to eq('Third user prompt')
        expect(blocked_message).to include('Prompt copied to clipboard')
        expect(blocked_message).to include('Third user prompt')
      end

      it 'copies specified number of prompts' do
        handler = create_handler(
          prompt: '--copy-prompt 2',
          transcript_file: fixture_path('simple_test.jsonl')
        )

        handler.call

        expected = "Second user prompt\n\nThird user prompt"
        expect(last_clipboard_content).to eq(expected)
        expect(blocked_message).to include('Last 2 prompts copied')
      end

      it 'handles chronological ordering correctly' do
        handler = create_handler(
          prompt: '--copy-prompt 3',
          transcript_file: fixture_path('simple_test.jsonl')
        )

        handler.call

        # Should be in chronological order (oldest to newest)
        expected = "First user prompt\n\nSecond user prompt\n\nThird user prompt"
        expect(last_clipboard_content).to eq(expected)
      end

      it 'errors when requesting more prompts than available' do
        handler = create_handler(
          prompt: '--copy-prompt 10',
          transcript_file: fixture_path('simple_test.jsonl')
        )

        handler.call

        expect(last_clipboard_content).to be_nil
        expect(blocked_message).to include('Error: Only 3 prompts available')
      end
    end

    context 'copy-response commands' do
      it 'copies most recent response by default' do
        handler = create_handler(
          prompt: '--copy-response',
          transcript_file: fixture_path('simple_test.jsonl')
        )

        handler.call

        expect(last_clipboard_content).to eq('Third assistant response')
        expect(blocked_message).to include('Response copied to clipboard')
        expect(blocked_message).to include('Third assistant response')
      end

      it 'copies specified number of responses' do
        handler = create_handler(
          prompt: '--copy-response 2',
          transcript_file: fixture_path('simple_test.jsonl')
        )

        handler.call

        expected = "Second assistant response\n\nThird assistant response"
        expect(last_clipboard_content).to eq(expected)
        expect(blocked_message).to include('Last 2 responses copied')
      end
    end

    context 'multi-part message handling' do
      it 'handles realistic transcript with human prompts and tool results' do
        handler = create_handler(
          prompt: '--copy-prompt 1',
          transcript_file: fixture_path('multipart_test.jsonl')
        )

        handler.call

        # Most recent user message is the human prompt
        expect(last_clipboard_content).to eq('Make it say goodbye instead')
      end

      it 'handles tool result arrays correctly' do
        handler = create_handler(
          prompt: '--copy-prompt 2',
          transcript_file: fixture_path('multipart_test.jsonl')
        )

        handler.call

        # Should get the last 2 user messages: tool result + human prompt
        expected_lines = last_clipboard_content.split("\n\n")
        expect(expected_lines.length).to eq(2)
        expect(expected_lines[1]).to eq('Make it say goodbye instead') # Most recent
      end

      it 'handles assistant tool calls correctly' do
        handler = create_handler(
          prompt: '--copy-response 1',
          transcript_file: fixture_path('multipart_test.jsonl')
        )

        handler.call

        # Assistant messages with only tool_use entries (no text) should result in empty content
        # This is correct behavior - tool_use entries don't contain displayable text
        expect(last_clipboard_content).to be_a(String)
        expect(last_clipboard_content).to eq('')
      end
    end

    context 'error handling' do
      it 'handles empty transcript file' do
        handler = create_handler(
          prompt: '--copy-prompt',
          transcript_file: create_temp_fixture([])
        )

        handler.call

        expect(last_clipboard_content).to be_nil
        expect(blocked_message).to include('Error: No prompts found')
      end

      it 'handles missing transcript file' do
        handler = create_handler(
          prompt: '--copy-prompt',
          transcript_file: nil
        )

        handler.call

        expect(last_clipboard_content).to be_nil
        expect(blocked_message).to include('Error: No prompts found')
      end

      it 'handles nonexistent transcript file' do
        handler = create_handler(
          prompt: '--copy-prompt',
          transcript_file: '/nonexistent/file.jsonl'
        )

        handler.call

        expect(last_clipboard_content).to be_nil
        expect(blocked_message).to include('Error: No prompts found')
      end

      it 'validates minimum count' do
        handler = create_handler(
          prompt: '--copy-prompt 0',
          transcript_file: fixture_path('simple_test.jsonl')
        )

        handler.call

        expect(last_clipboard_content).to be_nil
        expect(blocked_message).to include('Error: Prompt count must be at least 1')
      end
    end

    context 'edge cases' do
      it 'handles preview truncation for long content' do
        handler = create_handler(
          prompt: '--copy-prompt',
          transcript_file: fixture_path('edge_cases.jsonl')
        )

        handler.call

        # Should get the "very long prompt" and have it truncated in preview
        expect(blocked_message).to include('A very long prompt that exceeds sixty characters so we can')
        expect(blocked_message).to include('...')
      end

      it 'handles empty content preview' do
        entries = [
          {
            type: 'user',
            message: { role: 'user', content: '' },
            uuid: 'test-1',
            sessionId: 'test',
            timestamp: '2024-01-01T10:00:00.000Z'
          }
        ]

        handler = create_handler(
          prompt: '--copy-prompt',
          transcript_file: create_temp_fixture(entries)
        )

        handler.call

        expect(blocked_message).to include('<empty>')
      end

      it 'ignores system messages' do
        handler = create_handler(
          prompt: '--copy-response',
          transcript_file: fixture_path('edge_cases.jsonl')
        )

        handler.call

        # Should not include system message content
        expect(last_clipboard_content).not_to include('System message should be ignored')
        expect(last_clipboard_content).to eq('Final response')
      end

      it 'handles malformed JSONL gracefully' do
        handler = create_handler(
          prompt: '--copy-response',
          transcript_file: fixture_path('edge_cases.jsonl')
        )

        handler.call

        # Should get the final response despite malformed line
        expect(last_clipboard_content).to eq('Final response')
      end
    end

    context 'command parsing' do
      let(:handler) { create_handler(prompt: '', transcript_file: fixture_path('simple_test.jsonl')) }

      it 'parses various command formats correctly' do
        test_cases = [
          ['--copy-prompt', 1],
          ['--copy-prompt 5', 5],
          ['--copy-prompt  3', 3], # extra spaces
          ['--copy-response', 1],
          ['--copy-response 2', 2]
        ]

        test_cases.each do |command, expected_count|
          message_type = command.include?('prompt') ? 'prompt' : 'response'
          args = handler.send(:parse_copy_command, command, message_type)
          expect(args[:number]).to eq(expected_count), "Failed for command: #{command}"
        end
      end
    end

    context 'message grouping by request chain' do
      it 'groups messages by parent-child relationship correctly' do
        # Create transcript with same parent chain but different UUIDs
        entries = [
          {
            parentUuid: nil,
            sessionId: 'test',
            type: 'user',
            message: { role: 'user', content: 'First part' },
            uuid: 'part1',
            timestamp: '2024-01-01T10:00:00.000Z'
          },
          {
            parentUuid: 'part1',
            sessionId: 'test',
            type: 'user',
            message: { role: 'user', content: 'Second part' },
            uuid: 'part2',
            timestamp: '2024-01-01T10:00:01.000Z'
          },
          {
            parentUuid: 'part2',
            sessionId: 'test',
            type: 'user',
            message: { role: 'user', content: 'Separate message' },
            uuid: 'separate',
            timestamp: '2024-01-01T10:01:00.000Z'
          }
        ]

        handler = create_handler(
          prompt: '--copy-prompt 1',
          transcript_file: create_temp_fixture(entries)
        )

        handler.call

        # Should get the most recent complete message
        expect(last_clipboard_content).to eq('Separate message')
      end

      it 'filters out tool_use entries from assistant messages' do
        entries = [
          {
            parentUuid: nil,
            sessionId: 'test',
            type: 'assistant',
            message: {
              role: 'assistant',
              content: [
                { type: 'text', text: 'Let me help you with that.' },
                {
                  type: 'tool_use',
                  id: 'toolu_123',
                  name: 'Bash',
                  input: { command: 'ls -la' }
                },
                { type: 'text', text: 'Perfect! Here are the files.' }
              ]
            },
            uuid: 'msg1',
            timestamp: '2024-01-01T10:00:00.000Z'
          }
        ]

        handler = create_handler(
          prompt: '--copy-response 1',
          transcript_file: create_temp_fixture(entries)
        )

        handler.call

        # Should only get text content, not tool_use entries
        expect(last_clipboard_content).to eq('Let me help you with that.Perfect! Here are the files.')
      end
    end
  end
end

#!/usr/bin/env python3
"""
Query Claude Code conversation history from JSONL files.

Replaces the bash script with proper JSON parsing, multiple output formats,
and advanced filtering capabilities.
"""

import json
import sys
from pathlib import Path
from typing import Dict, List, Any, Optional, Iterator
from dataclasses import dataclass, field, asdict
from datetime import datetime
from collections import defaultdict
from abc import ABC, abstractmethod

try:
    import yaml
    HAS_YAML = True
except ImportError:
    HAS_YAML = False


@dataclass
class Message:
    """Represents a single message in a conversation."""
    timestamp: datetime
    role: str  # 'user' or 'assistant'
    content: Any  # String or array of content blocks
    uuid: Optional[str] = None
    parent_uuid: Optional[str] = None
    request_id: Optional[str] = None
    thinking_metadata: Optional[Dict[str, Any]] = None

    def get_text_content(self) -> str:
        """Extract text content from message, handling both string and array formats."""
        if isinstance(self.content, str):
            return self.content
        elif isinstance(self.content, list):
            # Handle array of content blocks (text, tool_use, etc.)
            text_parts = []
            for block in self.content:
                if isinstance(block, dict):
                    if block.get('type') == 'text':
                        text_parts.append(block.get('text', ''))
                    elif block.get('type') == 'tool_use':
                        tool_name = block.get('name', 'unknown')
                        text_parts.append(f"[Tool: {tool_name}]")
                elif isinstance(block, str):
                    text_parts.append(block)
            return '\n'.join(text_parts)
        return str(self.content)

    def is_system_noise(self) -> bool:
        """
        Detect if this user message is system-generated noise rather than human input.

        Returns True for:
        - Slash command expansions (<command-message>, <command-name>, <command-args>)
        - System reminders (<system-reminder>)
        - Tool results (tool_use_id, tool_result content blocks)
        - Request interruptions ([Request interrupted by user])
        """
        # Check array content blocks for tool_result type
        if isinstance(self.content, list):
            for block in self.content:
                if isinstance(block, dict) and block.get('type') == 'tool_result':
                    return True

        content_text = self.get_text_content()

        # System tags that indicate non-human content
        noise_markers = [
            '<command-message>',
            '<command-name>',
            '<command-args>',
            '<system-reminder>',
            '<local-command-stdout>',
            '<local-command-stderr>',
            '[Request interrupted by user',
        ]

        return any(marker in content_text for marker in noise_markers)

    def is_meta_communication(self) -> bool:
        """
        Detect if this user message is meta-communication about the conversation itself
        rather than natural conversational content.

        Returns True for:
        - Handoff prompts (compaction instructions)
        - Continuation summaries (session resume context)
        - Slash commands (/, /resume, /compact, etc.)
        - Administrative commands
        """
        content_text = self.get_text_content().strip()

        # Slash commands
        if content_text.startswith('/'):
            return True

        # Handoff/compaction prompts (typically start with specific phrases)
        meta_patterns = [
            'Context window compaction imminent',
            'This session is being continued from a previous conversation',
            'The conversation is summarized below:',
            'Analysis:',
            'Looking at this conversation chronologically:',
            '## Immediate Handoff',
            '## Relevant Context',
            'Summary:',
        ]

        # Check if content starts with any meta pattern
        for pattern in meta_patterns:
            if content_text.startswith(pattern):
                return True

        # Very long messages (>2000 chars) are likely summaries/handoffs
        if len(content_text) > 2000:
            # Check for handoff structure markers
            if any(marker in content_text for marker in ['## Immediate Handoff', '## Relevant Context', '## Key Details']):
                return True

        return False


@dataclass
class Conversation:
    """Represents a complete conversation from a JSONL file."""
    session_id: str
    project_path: str
    file_path: Path
    summary: Optional[str] = None
    leaf_uuid: Optional[str] = None
    messages: List[Message] = field(default_factory=list)
    metadata: Dict[str, Any] = field(default_factory=dict)

    @property
    def started(self) -> Optional[datetime]:
        """First message timestamp."""
        return self.messages[0].timestamp if self.messages else None

    @property
    def last_activity(self) -> Optional[datetime]:
        """Last message timestamp."""
        return self.messages[-1].timestamp if self.messages else None

    @property
    def message_count(self) -> int:
        """Total number of messages."""
        return len(self.messages)

    @property
    def user_message_count(self) -> int:
        """Count of user messages."""
        return sum(1 for m in self.messages if m.role == 'user')

    @property
    def assistant_message_count(self) -> int:
        """Count of assistant messages."""
        return sum(1 for m in self.messages if m.role == 'assistant')

    @property
    def first_user_message(self) -> Optional[str]:
        """Get first user message for preview."""
        for msg in self.messages:
            if msg.role == 'user':
                text = msg.get_text_content()
                return text[:100] + '...' if len(text) > 100 else text
        return None


class QueryEngine:
    """Filters and searches conversations based on criteria."""

    def __init__(self, conversations: List[Conversation]):
        self.conversations = conversations

    def filter_by_date_range(self, since: Optional[datetime] = None,
                            until: Optional[datetime] = None) -> List[Conversation]:
        """Filter conversations by date range."""
        results = []
        for conv in self.conversations:
            if not conv.started:
                continue

            if since and conv.started < since:
                continue
            if until and conv.started > until:
                continue

            results.append(conv)
        return results

    def filter_by_project(self, project_pattern: str) -> List[Conversation]:
        """Filter conversations by project path pattern."""
        results = []
        for conv in self.conversations:
            if project_pattern.lower() in conv.project_path.lower():
                results.append(conv)
        return results

    def filter_by_min_messages(self, min_count: int) -> List[Conversation]:
        """Filter conversations with at least min_count messages."""
        return [conv for conv in self.conversations if conv.message_count >= min_count]

    def search_content(self, search_term: str, case_sensitive: bool = False) -> List[Conversation]:
        """Search for conversations containing the search term in any message."""
        results = []
        if not case_sensitive:
            search_term = search_term.lower()

        for conv in self.conversations:
            # Check summary first
            if conv.summary:
                summary_text = conv.summary if case_sensitive else conv.summary.lower()
                if search_term in summary_text:
                    results.append(conv)
                    continue

            # Check messages
            for msg in conv.messages:
                content = msg.get_text_content()
                if not case_sensitive:
                    content = content.lower()

                if search_term in content:
                    results.append(conv)
                    break

        return results

    def get_by_session_id(self, session_id: str) -> Optional[Conversation]:
        """Get a specific conversation by session ID."""
        for conv in self.conversations:
            if conv.session_id == session_id:
                return conv
        return None

    def sort_by_date(self, reverse: bool = True) -> List[Conversation]:
        """Sort conversations by start date (newest first by default)."""
        return sorted(
            [c for c in self.conversations if c.started],
            key=lambda c: c.started,
            reverse=reverse
        )


class ConversationParser:
    """Parses JSONL conversation files into structured data."""

    def __init__(self, projects_dir: Path):
        self.projects_dir = projects_dir

    def parse_file(self, jsonl_path: Path) -> Conversation:
        """Parse a single JSONL file into a Conversation object."""
        session_id = jsonl_path.stem
        project_path = self._extract_project_path(jsonl_path.parent.name)

        conv = Conversation(
            session_id=session_id,
            project_path=project_path,
            file_path=jsonl_path
        )

        with open(jsonl_path, 'r', encoding='utf-8') as f:
            for line_num, line in enumerate(f, 1):
                line = line.strip()
                if not line:
                    continue

                try:
                    entry = json.loads(line)
                    self._process_entry(entry, conv)
                except json.JSONDecodeError as e:
                    print(f"Warning: Invalid JSON at {jsonl_path}:{line_num}: {e}",
                          file=sys.stderr)
                    continue

        return conv

    def _process_entry(self, entry: Dict[str, Any], conv: Conversation) -> None:
        """Process a single JSONL entry and add to conversation."""
        entry_type = entry.get('type')

        if entry_type == 'summary':
            # Extract summary and leaf UUID
            conv.summary = entry.get('summary')
            conv.leaf_uuid = entry.get('leafUuid')

        elif entry_type == 'snapshot':
            # Store snapshot metadata if needed
            conv.metadata['snapshot'] = entry.get('snapshot', {})

        elif entry_type in ('user', 'assistant'):
            # Skip meta messages (slash command docs, system context)
            if entry.get('isMeta'):
                return

            # Parse message
            msg_data = entry.get('message', {})

            # Parse timestamp
            ts_str = entry.get('timestamp')
            timestamp = datetime.fromisoformat(ts_str.replace('Z', '+00:00')) if ts_str else None

            if timestamp:
                message = Message(
                    timestamp=timestamp,
                    role=msg_data.get('role', entry_type),
                    content=msg_data.get('content', ''),
                    uuid=entry.get('uuid'),
                    parent_uuid=entry.get('parentUuid'),
                    request_id=entry.get('requestId'),
                    thinking_metadata=entry.get('thinkingMetadata')
                )
                conv.messages.append(message)

    def _extract_project_path(self, encoded_path: str) -> str:
        """Convert encoded project directory name back to readable path."""
        # Example: -Users-kyle-Code-project -> ~/Code/project
        path = encoded_path.replace('-Users-kyle-', '~/')
        path = path.replace('-', '/')
        return path

    def find_all_conversations(self) -> Iterator[Conversation]:
        """Find and parse all conversation files in projects directory."""
        if not self.projects_dir.exists():
            return

        for project_dir in self.projects_dir.iterdir():
            if not project_dir.is_dir():
                continue

            for jsonl_file in project_dir.glob('*.jsonl'):
                try:
                    yield self.parse_file(jsonl_file)
                except Exception as e:
                    print(f"Warning: Failed to parse {jsonl_file}: {e}",
                          file=sys.stderr)
                    continue


class OutputFormatter(ABC):
    """Base class for output formatters."""

    @abstractmethod
    def format_list(self, conversations: List[Conversation]) -> str:
        """Format a list of conversations."""
        pass

    @abstractmethod
    def format_single(self, conversation: Conversation, include_messages: bool = True,
                     role_filter: Optional[str] = None) -> str:
        """Format a single conversation.

        Args:
            conversation: The conversation to format
            include_messages: Whether to include message content
            role_filter: Optional filter - 'user', 'assistant', or None for all messages
        """
        pass

    def _conv_to_dict(self, conv: Conversation, include_preview: bool = True) -> Dict[str, Any]:
        """Convert conversation to dict (shared logic for YAML/JSON formatters)."""
        data = {
            'session_id': conv.session_id,
            'project': conv.project_path,
            'summary': conv.summary,
            'started': conv.started.isoformat() if conv.started else None,
            'last_activity': conv.last_activity.isoformat() if conv.last_activity else None,
            'message_count': conv.message_count,
            'user_messages': conv.user_message_count,
            'assistant_messages': conv.assistant_message_count,
        }
        if include_preview:
            data['first_user_message'] = conv.first_user_message
        return data

    def _msg_to_dict(self, msg: Message) -> Dict[str, Any]:
        """Convert message to dict (shared logic for YAML/JSON formatters)."""
        msg_data = {
            'timestamp': msg.timestamp.isoformat(),
            'role': msg.role,
            'content': msg.get_text_content()
        }
        if msg.thinking_metadata:
            msg_data['thinking'] = msg.thinking_metadata
        return msg_data


class YAMLFormatter(OutputFormatter):
    """YAML output formatter for AI-readable output."""

    def format_list(self, conversations: List[Conversation]) -> str:
        """Format conversation list as YAML."""
        if not HAS_YAML:
            raise ImportError("PyYAML not installed. Use: pip install pyyaml")

        data = {
            'total': len(conversations),
            'conversations': [self._conv_to_dict(c) for c in conversations]
        }

        return yaml.dump(data, default_flow_style=False, allow_unicode=True, sort_keys=False)

    def format_single(self, conversation: Conversation, include_messages: bool = True,
                     role_filter: Optional[str] = None) -> str:
        """Format single conversation as YAML."""
        if not HAS_YAML:
            raise ImportError("PyYAML not installed. Use: pip install pyyaml")

        data = self._conv_to_dict(conversation, include_preview=False)

        if include_messages:
            messages = conversation.messages
            if role_filter:
                messages = [m for m in messages if m.role == role_filter]
                # When filtering to user messages, exclude system noise and meta-communication
                if role_filter == 'user':
                    messages = [m for m in messages if not m.is_system_noise() and not m.is_meta_communication()]
            data['messages'] = [self._msg_to_dict(msg) for msg in messages]
            if role_filter:
                data['filtered_role'] = role_filter
                data['filtered_message_count'] = len(messages)

        return yaml.dump(data, default_flow_style=False, allow_unicode=True, sort_keys=False)


class JSONFormatter(OutputFormatter):
    """JSON output formatter for machine-readable output."""

    def format_list(self, conversations: List[Conversation]) -> str:
        """Format conversation list as JSON."""
        data = {
            'total': len(conversations),
            'conversations': [self._conv_to_dict(c) for c in conversations]
        }

        return json.dumps(data, indent=2, ensure_ascii=False)

    def format_single(self, conversation: Conversation, include_messages: bool = True,
                     role_filter: Optional[str] = None) -> str:
        """Format single conversation as JSON."""
        data = self._conv_to_dict(conversation, include_preview=False)

        if include_messages:
            messages = conversation.messages
            if role_filter:
                messages = [m for m in messages if m.role == role_filter]
                # When filtering to user messages, exclude system noise and meta-communication
                if role_filter == 'user':
                    messages = [m for m in messages if not m.is_system_noise() and not m.is_meta_communication()]
            data['messages'] = [self._msg_to_dict(msg) for msg in messages]
            if role_filter:
                data['filtered_role'] = role_filter
                data['filtered_message_count'] = len(messages)

        return json.dumps(data, indent=2, ensure_ascii=False)


class TextFormatter(OutputFormatter):
    """Text output formatter for human-readable output (backward compatible)."""

    def format_list(self, conversations: List[Conversation]) -> str:
        """Format conversation list as human-readable text."""
        lines = []
        lines.append("Recent Claude conversations:")
        lines.append("=" * 60)
        lines.append("")

        # Group by project
        by_project = defaultdict(list)
        for conv in conversations:
            by_project[conv.project_path].append(conv)

        for project_path in sorted(by_project.keys()):
            lines.append(f"📁 Project: {project_path}")
            lines.append("")

            for conv in by_project[project_path]:
                lines.append(f"  🗨️  Session: {conv.session_id}")
                if conv.summary:
                    lines.append(f"      Summary: {conv.summary}")
                if conv.started:
                    lines.append(f"      Started: {conv.started.strftime('%Y-%m-%d %H:%M:%S')}")
                if conv.last_activity:
                    lines.append(f"      Last: {conv.last_activity.strftime('%Y-%m-%d %H:%M:%S')}")
                lines.append(f"      Messages: {conv.message_count} ({conv.user_message_count} user, {conv.assistant_message_count} assistant)")
                if conv.first_user_message:
                    lines.append(f"      Preview: {conv.first_user_message}")
                lines.append("")

        return '\n'.join(lines)

    def format_single(self, conversation: Conversation, include_messages: bool = True,
                     role_filter: Optional[str] = None) -> str:
        """Format single conversation as human-readable text."""
        lines = []
        lines.append(f"Conversation: {conversation.session_id}")
        lines.append("=" * 60)
        if conversation.summary:
            lines.append(f"Summary: {conversation.summary}")
        lines.append(f"Project: {conversation.project_path}")
        if conversation.started:
            lines.append(f"Started: {conversation.started.strftime('%Y-%m-%d %H:%M:%S')}")
        if conversation.last_activity:
            lines.append(f"Last: {conversation.last_activity.strftime('%Y-%m-%d %H:%M:%S')}")
        lines.append(f"Messages: {conversation.message_count}")
        if role_filter:
            filtered_count = sum(1 for m in conversation.messages if m.role == role_filter)
            lines.append(f"Filtered to: {filtered_count} {role_filter} messages")
        lines.append("")

        if include_messages:
            messages = conversation.messages
            if role_filter:
                messages = [m for m in messages if m.role == role_filter]
                # When filtering to user messages, exclude system noise and meta-communication
                if role_filter == 'user':
                    messages = [m for m in messages if not m.is_system_noise() and not m.is_meta_communication()]

            for msg in messages:
                timestamp = msg.timestamp.strftime('%Y-%m-%d %H:%M:%S')
                role = msg.role.upper()
                lines.append(f"[{timestamp}] {role}:")
                lines.append(msg.get_text_content())
                lines.append("")

        return '\n'.join(lines)


def get_formatter(format_type: str) -> OutputFormatter:
    """Get formatter instance by type."""
    formatters = {
        'yaml': YAMLFormatter,
        'json': JSONFormatter,
        'text': TextFormatter
    }

    formatter_class = formatters.get(format_type.lower())
    if not formatter_class:
        raise ValueError(f"Unknown format: {format_type}. Valid options: {', '.join(formatters.keys())}")

    return formatter_class()


def parse_date_with_tz(date_str: Optional[str]) -> Optional[datetime]:
    """Parse date string and ensure it has timezone info."""
    if not date_str:
        return None

    from dateutil import parser as date_parser
    dt = date_parser.parse(date_str)

    # Make timezone-aware if naive
    if dt.tzinfo is None:
        dt = dt.replace(tzinfo=datetime.now().astimezone().tzinfo)

    return dt


def sort_and_limit_results(conversations: List[Conversation],
                           limit: Optional[int] = None) -> List[Conversation]:
    """Sort conversations by date (newest first) and apply limit."""
    sorted_convs = sorted(
        [c for c in conversations if c.started],
        key=lambda c: c.started,
        reverse=True
    )
    return sorted_convs[:limit] if limit else sorted_convs


def main():
    """CLI entry point."""
    import argparse
    from dateutil import parser as date_parser

    # Default projects directory
    default_projects_dir = Path.home() / 'Code' / 'dotfiles' / 'claude' / 'projects'

    parser = argparse.ArgumentParser(
        description='Query Claude Code conversation history from JSONL files',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  %(prog)s list
  %(prog)s list --format yaml --since 2025-11-01 --min-messages 30
  %(prog)s get abc123-session-id --format json
  %(prog)s get abc123-session-id --user-only --format yaml
  %(prog)s search "git hooks" --format yaml
  %(prog)s export abc123-session-id output.txt
  %(prog)s batch output.json --session-file sessions.txt --user-only

Sentiment Analysis Workflow:
  # Extract user messages from substantial conversations
  %(prog)s list --since 2025-11-01 --min-messages 30 --format json | \\
    jq -r '.conversations[].session_id' | head -20 > sessions.txt
  %(prog)s batch user_messages.json --session-file sessions.txt --user-only
        """
    )

    parser.add_argument(
        '--projects-dir',
        type=Path,
        default=default_projects_dir,
        help=f'Path to projects directory (default: {default_projects_dir})'
    )

    subparsers = parser.add_subparsers(dest='command', help='Command to execute')

    # List command
    list_parser = subparsers.add_parser('list', help='List all conversations')
    list_parser.add_argument('--format', choices=['yaml', 'json', 'text'], default='text',
                            help='Output format (default: text)')
    list_parser.add_argument('--since', help='Filter conversations since date (ISO format or relative like "2025-11-01")')
    list_parser.add_argument('--until', help='Filter conversations until date (ISO format)')
    list_parser.add_argument('--project', help='Filter by project path (case-insensitive substring match)')
    list_parser.add_argument('--min-messages', type=int, help='Filter conversations with at least N messages')
    list_parser.add_argument('--limit', type=int, help='Limit number of results')

    # Get command
    get_parser = subparsers.add_parser('get', help='Display a specific conversation')
    get_parser.add_argument('session_id', help='Session ID of the conversation')
    get_parser.add_argument('--format', choices=['yaml', 'json', 'text'], default='text',
                           help='Output format (default: text)')
    get_parser.add_argument('--no-messages', action='store_true', help='Show only metadata, not messages')
    get_parser.add_argument('--user-only', action='store_true', help='Show only user messages')
    get_parser.add_argument('--assistant-only', action='store_true', help='Show only assistant messages')

    # Search command
    search_parser = subparsers.add_parser('search', help='Search conversations for a term')
    search_parser.add_argument('term', help='Search term')
    search_parser.add_argument('--format', choices=['yaml', 'json', 'text'], default='text',
                               help='Output format (default: text)')
    search_parser.add_argument('--case-sensitive', action='store_true', help='Case-sensitive search')
    search_parser.add_argument('--since', help='Filter conversations since date')
    search_parser.add_argument('--until', help='Filter conversations until date')
    search_parser.add_argument('--limit', type=int, help='Limit number of results')

    # Export command
    export_parser = subparsers.add_parser('export', help='Export conversation to a file')
    export_parser.add_argument('session_id', help='Session ID of the conversation')
    export_parser.add_argument('output_file', nargs='?', help='Output file path (default: claude_conversation_<session_id>.txt)')
    export_parser.add_argument('--format', choices=['yaml', 'json', 'text'], default='text',
                               help='Export format (default: text)')
    export_parser.add_argument('--user-only', action='store_true', help='Export only user messages')
    export_parser.add_argument('--assistant-only', action='store_true', help='Export only assistant messages')

    # Batch command - export multiple conversations
    batch_parser = subparsers.add_parser('batch', help='Export multiple conversations to JSON array')
    batch_parser.add_argument('output_file', help='Output file path')
    batch_parser.add_argument('--session-ids', help='Comma-separated session IDs')
    batch_parser.add_argument('--session-file', help='File containing session IDs (one per line)')
    batch_parser.add_argument('--user-only', action='store_true', help='Export only user messages')
    batch_parser.add_argument('--assistant-only', action='store_true', help='Export only assistant messages')

    # Help command
    subparsers.add_parser('help', help='Show this help message')

    args = parser.parse_args()

    # Show help if no command
    if not args.command:
        parser.print_help()
        return 0

    if args.command == 'help':
        parser.print_help()
        return 0

    # Validate projects directory
    if not args.projects_dir.exists():
        print(f"Error: Projects directory not found: {args.projects_dir}", file=sys.stderr)
        print(f"Hint: Set --projects-dir or check that conversations exist", file=sys.stderr)
        return 1

    try:
        # Parse conversations (streaming for memory efficiency)
        conv_parser = ConversationParser(args.projects_dir)
        conversations = list(conv_parser.find_all_conversations())

        if not conversations:
            print(f"No conversations found in {args.projects_dir}", file=sys.stderr)
            return 1

        # Create query engine
        query = QueryEngine(conversations)

        # Execute command
        if args.command == 'list':
            results = conversations

            # Apply filters
            if args.since or args.until:
                since = parse_date_with_tz(args.since)
                until = parse_date_with_tz(args.until)
                results = query.filter_by_date_range(since, until)

            if args.project:
                results = [c for c in results if args.project.lower() in c.project_path.lower()]

            if args.min_messages:
                results = [c for c in results if c.message_count >= args.min_messages]

            # Sort and limit
            results = sort_and_limit_results(results, args.limit)

            # Format output
            formatter = get_formatter(args.format)
            output = formatter.format_list(results)
            print(output)

        elif args.command == 'get':
            conv = query.get_by_session_id(args.session_id)
            if not conv:
                print(f"Error: Conversation not found: {args.session_id}", file=sys.stderr)
                return 1

            # Determine role filter
            role_filter = None
            if args.user_only and args.assistant_only:
                print("Error: Cannot specify both --user-only and --assistant-only", file=sys.stderr)
                return 1
            elif args.user_only:
                role_filter = 'user'
            elif args.assistant_only:
                role_filter = 'assistant'

            formatter = get_formatter(args.format)
            output = formatter.format_single(conv, include_messages=not args.no_messages,
                                            role_filter=role_filter)
            print(output)

        elif args.command == 'search':
            results = query.search_content(args.term, case_sensitive=args.case_sensitive)

            # Apply date filters if specified
            if args.since or args.until:
                since = parse_date_with_tz(args.since)
                until = parse_date_with_tz(args.until)
                results = [c for c in results
                          if c.started and
                          (not since or c.started >= since) and
                          (not until or c.started <= until)]

            # Sort and limit
            results = sort_and_limit_results(results, args.limit)

            if not results:
                print(f"No conversations found matching '{args.term}'", file=sys.stderr)
                return 0

            formatter = get_formatter(args.format)
            output = formatter.format_list(results)
            print(output)

        elif args.command == 'export':
            conv = query.get_by_session_id(args.session_id)
            if not conv:
                print(f"Error: Conversation not found: {args.session_id}", file=sys.stderr)
                return 1

            # Determine role filter
            role_filter = None
            if args.user_only and args.assistant_only:
                print("Error: Cannot specify both --user-only and --assistant-only", file=sys.stderr)
                return 1
            elif args.user_only:
                role_filter = 'user'
            elif args.assistant_only:
                role_filter = 'assistant'

            output_file = args.output_file or f"claude_conversation_{args.session_id}.txt"

            # Determine format from filename or --format flag
            export_format = args.format
            if output_file.endswith('.yaml') or output_file.endswith('.yml'):
                export_format = 'yaml'
            elif output_file.endswith('.json'):
                export_format = 'json'

            formatter = get_formatter(export_format)
            output = formatter.format_single(conv, include_messages=True, role_filter=role_filter)

            with open(output_file, 'w', encoding='utf-8') as f:
                f.write(output)

            print(f"Conversation exported to: {output_file}")

        elif args.command == 'batch':
            # Determine role filter
            role_filter = None
            if args.user_only and args.assistant_only:
                print("Error: Cannot specify both --user-only and --assistant-only", file=sys.stderr)
                return 1
            elif args.user_only:
                role_filter = 'user'
            elif args.assistant_only:
                role_filter = 'assistant'

            # Get session IDs from either --session-ids or --session-file
            session_ids = []
            if args.session_ids:
                session_ids = [s.strip() for s in args.session_ids.split(',')]
            elif args.session_file:
                with open(args.session_file, 'r') as f:
                    session_ids = [line.strip() for line in f if line.strip()]
            else:
                print("Error: Must specify either --session-ids or --session-file", file=sys.stderr)
                return 1

            # Collect conversations
            batch_data = []
            for session_id in session_ids:
                conv = query.get_by_session_id(session_id)
                if not conv:
                    print(f"Warning: Session not found, skipping: {session_id}", file=sys.stderr)
                    continue

                # Convert to dict format (JSON only for batch)
                formatter = get_formatter('json')
                conv_json = formatter.format_single(conv, include_messages=True, role_filter=role_filter)
                batch_data.append(json.loads(conv_json))

            # Write as JSON array
            with open(args.output_file, 'w', encoding='utf-8') as f:
                json.dump(batch_data, f, indent=2, ensure_ascii=False)

            print(f"Batch exported {len(batch_data)} conversations to: {args.output_file}")
            total_messages = sum(c.get('filtered_message_count', c.get('message_count', 0)) for c in batch_data)
            print(f"Total messages: {total_messages}")

        return 0

    except ImportError as e:
        print(f"Error: {e}", file=sys.stderr)
        if 'yaml' in str(e).lower():
            print("Install PyYAML: pip install pyyaml", file=sys.stderr)
        elif 'dateutil' in str(e).lower():
            print("Install python-dateutil: pip install python-dateutil", file=sys.stderr)
        return 1
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        import traceback
        traceback.print_exc()
        return 1


if __name__ == '__main__':
    sys.exit(main())

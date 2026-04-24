#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.12"
# dependencies = ["pyyaml", "python-dateutil"]
# ///
"""Catalog Claude Code conversations across the corpus.

A discovery tool. Answers "which conversations exist?", "where are they?",
"what are they about?" — but does NOT render conversation contents.

To read a specific conversation, pipe its JSONL path into VCC (the
conversation-compiler skill). See skills/conversation-compiler/SKILL.md.

Commands:
    list    Browse conversations with filters
    last    Most recent session (by mtime)
    get     Metadata + path for a specific session id
    search  Find sessions whose JSONL contains a term (returns paths)
    stats   Per-project activity overview

Typical pipeline:
    query_conversations.py list --paths-only --since 2025-11-01 \\
        | xargs -I {} python VCC.py {} --grep "hooks"
"""

from __future__ import annotations

import argparse
import json
import sys
from collections import defaultdict
from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Iterable, Iterator, Optional

DEFAULT_PROJECTS_DIR = Path.home() / "Code" / "dotfiles" / "claude" / "projects"
PREVIEW_LEN = 100
# How many entries to scan when sniffing a project path — cwd is usually on
# every entry, but summary/permission-mode entries may not carry it.
CWD_SNIFF_LINES = 20


# ──────────────────────────── data model ────────────────────────────


@dataclass
class ConversationMeta:
  """Metadata-only view of a JSONL conversation file.

  Never holds message bodies. Cheap to construct, cheap to serialise.
  """

  session_id: str
  path: Path
  project_path: str
  started: Optional[datetime] = None
  last_activity: Optional[datetime] = None
  message_count: int = 0
  user_count: int = 0
  assistant_count: int = 0
  summary: Optional[str] = None
  first_user_preview: Optional[str] = None

  def to_dict(self) -> dict[str, Any]:
    return {
      "session_id": self.session_id,
      "path": str(self.path),
      "project": self.project_path,
      "started": self.started.isoformat() if self.started else None,
      "last_activity": self.last_activity.isoformat() if self.last_activity else None,
      "message_count": self.message_count,
      "user_messages": self.user_count,
      "assistant_messages": self.assistant_count,
      "summary": self.summary,
      "first_user_preview": self.first_user_preview,
    }


# ──────────────────────────── parsing ────────────────────────────


def _parse_timestamp(ts: Optional[str]) -> Optional[datetime]:
  if not ts:
    return None
  try:
    return datetime.fromisoformat(ts.replace("Z", "+00:00"))
  except ValueError:
    return None


def _extract_text(content: Any) -> str:
  """Best-effort string rendering of a message content field."""
  if isinstance(content, str):
    return content
  if isinstance(content, list):
    parts: list[str] = []
    for block in content:
      if isinstance(block, dict):
        if block.get("type") == "text":
          parts.append(block.get("text", ""))
        elif block.get("type") == "tool_use":
          parts.append(f"[tool: {block.get('name', '?')}]")
        elif block.get("type") == "tool_result":
          parts.append("[tool_result]")
      elif isinstance(block, str):
        parts.append(block)
    return "\n".join(parts)
  return str(content)


def _make_preview(text: str, length: int = PREVIEW_LEN) -> str:
  """Collapse whitespace, trim, truncate — safe for single-line display."""
  collapsed = " ".join(text.split())
  if len(collapsed) <= length:
    return collapsed
  return collapsed[: length - 1].rstrip() + "…"


def parse_metadata(path: Path) -> ConversationMeta:
  """Parse a JSONL file into a ConversationMeta.

  Reads the whole file but never retains message bodies, so memory stays
  flat regardless of conversation length.
  """
  meta = ConversationMeta(
    session_id=path.stem,
    path=path,
    project_path=path.parent.name,  # fallback; overwritten when cwd seen
  )

  saw_cwd = False
  with path.open("r", encoding="utf-8") as f:
    for line_no, line in enumerate(f, 1):
      line = line.strip()
      if not line:
        continue
      try:
        entry = json.loads(line)
      except json.JSONDecodeError:
        continue

      # Real project path comes from the cwd field on any entry that
      # has one. Reverse-decoding the directory name is unreliable
      # because project names themselves can contain hyphens.
      if not saw_cwd and line_no <= CWD_SNIFF_LINES:
        cwd = entry.get("cwd")
        if cwd:
          meta.project_path = _humanise_path(cwd)
          saw_cwd = True

      etype = entry.get("type")

      if etype == "summary":
        meta.summary = entry.get("summary") or meta.summary
        continue

      if etype not in ("user", "assistant"):
        continue
      if entry.get("isMeta"):
        continue  # slash-command docs, system context

      ts = _parse_timestamp(entry.get("timestamp"))
      if ts is None:
        continue
      if meta.started is None:
        meta.started = ts
      meta.last_activity = ts

      meta.message_count += 1
      role = entry.get("message", {}).get("role", etype)
      if role == "user":
        meta.user_count += 1
        if meta.first_user_preview is None:
          text = _extract_text(entry.get("message", {}).get("content", ""))
          preview = _make_preview(text)
          if preview:
            meta.first_user_preview = preview
      elif role == "assistant":
        meta.assistant_count += 1

  return meta


def _humanise_path(cwd: str) -> str:
  """Replace $HOME with ~ for display."""
  home = str(Path.home())
  if cwd == home:
    return "~"
  if cwd.startswith(home + "/"):
    return "~" + cwd[len(home) :]
  return cwd


# ──────────────────────────── discovery ────────────────────────────


def iter_jsonl_paths(
  projects_dir: Path,
  project_filter: Optional[str] = None,
  include_subagents: bool = False,
) -> Iterator[Path]:
  """Yield every top-level JSONL under projects_dir.

  project_filter is a case-insensitive substring match against the
  encoded directory name (a rough proxy for project path).

  Subagent JSONLs live at `<project>/<session>/subagents/*.jsonl` and
  are excluded by default — they're noisy and rarely what you want
  when cataloguing your own sessions. Opt in with include_subagents.
  """
  if not projects_dir.exists():
    return
  needle = project_filter.lower() if project_filter else None
  for proj_dir in projects_dir.iterdir():
    if not proj_dir.is_dir():
      continue
    if needle and needle not in proj_dir.name.lower():
      continue
    yield from proj_dir.glob("*.jsonl")
    if include_subagents:
      yield from proj_dir.glob("*/subagents/*.jsonl")


def paths_by_mtime(paths: Iterable[Path], newest_first: bool = True) -> list[Path]:
  """Sort paths by filesystem mtime (a cheap proxy for last activity)."""
  return sorted(paths, key=lambda p: p.stat().st_mtime, reverse=newest_first)


def find_by_session_id(projects_dir: Path, session_id: str) -> Optional[Path]:
  """Locate the JSONL for a given session id by filename, no parsing."""
  matches = list(projects_dir.glob(f"*/{session_id}.jsonl"))
  return matches[0] if matches else None


# ──────────────────────────── filtering ────────────────────────────


def _parse_date(s: Optional[str]) -> Optional[datetime]:
  if not s:
    return None
  from dateutil import parser as date_parser

  dt = date_parser.parse(s)
  if dt.tzinfo is None:
    dt = dt.replace(tzinfo=datetime.now().astimezone().tzinfo)
  return dt


def apply_filters(
  metas: Iterable[ConversationMeta],
  *,
  since: Optional[datetime] = None,
  until: Optional[datetime] = None,
  project: Optional[str] = None,
  min_messages: Optional[int] = None,
) -> Iterator[ConversationMeta]:
  needle = project.lower() if project else None
  for m in metas:
    if since and (m.started is None or m.started < since):
      continue
    if until and (m.started is None or m.started > until):
      continue
    if needle and needle not in m.project_path.lower():
      continue
    if min_messages is not None and m.message_count < min_messages:
      continue
    yield m


# ──────────────────────────── rendering ────────────────────────────


def auto_format(explicit: Optional[str]) -> str:
  if explicit:
    return explicit
  return "text" if sys.stdout.isatty() else "json"


def render_list(metas: list[ConversationMeta], fmt: str) -> str:
  if fmt == "json":
    return json.dumps(
      {"total": len(metas), "conversations": [m.to_dict() for m in metas]},
      indent=2,
      ensure_ascii=False,
    )
  if fmt == "yaml":
    import yaml

    return yaml.dump(
      {"total": len(metas), "conversations": [m.to_dict() for m in metas]},
      default_flow_style=False,
      allow_unicode=True,
      sort_keys=False,
    )
  return _render_list_text(metas)


def _render_list_text(metas: list[ConversationMeta]) -> str:
  if not metas:
    return "(no conversations)"
  by_project: dict[str, list[ConversationMeta]] = defaultdict(list)
  for m in metas:
    by_project[m.project_path].append(m)

  lines: list[str] = []
  for project in sorted(by_project):
    lines.append(f"Project: {project}")
    for m in by_project[project]:
      started = m.started.strftime("%Y-%m-%d %H:%M") if m.started else "?"
      lines.append(f"  {m.session_id}  {started}  ({m.message_count} msgs)")
      if m.summary:
        lines.append(f"    summary: {m.summary}")
      elif m.first_user_preview:
        lines.append(f"    preview: {m.first_user_preview}")
    lines.append("")
  return "\n".join(lines).rstrip()


def render_single(meta: ConversationMeta, fmt: str) -> str:
  if fmt == "json":
    return json.dumps(meta.to_dict(), indent=2, ensure_ascii=False)
  if fmt == "yaml":
    import yaml

    return yaml.dump(
      meta.to_dict(),
      default_flow_style=False,
      allow_unicode=True,
      sort_keys=False,
    )
  return _render_single_text(meta)


def _render_single_text(m: ConversationMeta) -> str:
  started = m.started.strftime("%Y-%m-%d %H:%M:%S") if m.started else "?"
  last = m.last_activity.strftime("%Y-%m-%d %H:%M:%S") if m.last_activity else "?"
  lines = [
    f"session  {m.session_id}",
    f"project  {m.project_path}",
    f"started  {started}",
    f"last     {last}",
    f"counts   {m.message_count} msgs ({m.user_count} user, {m.assistant_count} assistant)",
  ]
  if m.summary:
    lines.append(f"summary  {m.summary}")
  if m.first_user_preview:
    lines.append(f"preview  {m.first_user_preview}")
  lines.append(f"path     {m.path}")
  return "\n".join(lines)


# ──────────────────────────── search ────────────────────────────


def search_paths(
  paths: Iterable[Path],
  term: str,
  case_sensitive: bool = False,
) -> Iterator[Path]:
  """Yield paths whose raw file content contains term.

  Uses byte-level substring matching for speed. This is intentionally a
  coarse "does this conversation mention X?" filter — for line-level
  search within a conversation, use VCC's --grep.
  """
  needle = term.encode("utf-8") if case_sensitive else term.lower().encode("utf-8")
  for path in paths:
    try:
      with path.open("rb") as f:
        haystack = f.read()
    except OSError:
      continue
    if not case_sensitive:
      haystack = haystack.lower()
    if needle in haystack:
      yield path


# ──────────────────────────── commands ────────────────────────────


def cmd_list(args: argparse.Namespace) -> int:
  paths = iter_jsonl_paths(args.projects_dir, args.project, args.include_subagents)
  # If limit + no filters that need message counts, we can fast-path:
  # mtime-sort, parse only the top N.
  need_parse_all = args.since or args.until or args.min_messages
  if args.limit and not need_parse_all:
    paths = paths_by_mtime(paths)[: args.limit]
  metas = [parse_metadata(p) for p in paths]

  filtered = list(
    apply_filters(
      metas,
      since=_parse_date(args.since),
      until=_parse_date(args.until),
      min_messages=args.min_messages,
    )
  )
  filtered.sort(key=lambda m: m.started or datetime.min.replace(tzinfo=timezone.utc), reverse=True)
  if args.limit:
    filtered = filtered[: args.limit]

  if args.paths_only:
    for m in filtered:
      print(m.path)
    return 0

  print(render_list(filtered, auto_format(args.format)))
  return 0


def cmd_last(args: argparse.Namespace) -> int:
  paths = paths_by_mtime(iter_jsonl_paths(args.projects_dir, args.project, args.include_subagents))
  if not paths:
    print("No conversations found.", file=sys.stderr)
    return 1
  meta = parse_metadata(paths[0])
  if args.path:
    print(meta.path)
    return 0
  print(render_single(meta, auto_format(args.format)))
  return 0


def cmd_get(args: argparse.Namespace) -> int:
  path = find_by_session_id(args.projects_dir, args.session_id)
  if path is None:
    print(f"No conversation with session id: {args.session_id}", file=sys.stderr)
    return 1
  meta = parse_metadata(path)
  if args.path:
    print(meta.path)
    return 0
  print(render_single(meta, auto_format(args.format)))
  return 0


def cmd_search(args: argparse.Namespace) -> int:
  candidates = iter_jsonl_paths(args.projects_dir, args.project, args.include_subagents)
  hits = list(search_paths(candidates, args.term, case_sensitive=args.case_sensitive))

  metas = [parse_metadata(p) for p in hits]
  filtered = list(
    apply_filters(
      metas,
      since=_parse_date(args.since),
      until=_parse_date(args.until),
    )
  )
  filtered.sort(key=lambda m: m.started or datetime.min.replace(tzinfo=timezone.utc), reverse=True)
  if args.limit:
    filtered = filtered[: args.limit]

  if not filtered:
    print(f"No conversations matching '{args.term}'.", file=sys.stderr)
    return 0

  if args.paths_only:
    for m in filtered:
      print(m.path)
    return 0

  print(render_list(filtered, auto_format(args.format)))
  return 0


def cmd_stats(args: argparse.Namespace) -> int:
  metas = [
    parse_metadata(p)
    for p in iter_jsonl_paths(args.projects_dir, args.project, args.include_subagents)
  ]
  filtered = list(
    apply_filters(
      metas,
      since=_parse_date(args.since),
      until=_parse_date(args.until),
    )
  )

  by_project: dict[str, list[ConversationMeta]] = defaultdict(list)
  for m in filtered:
    by_project[m.project_path].append(m)

  total_convs = len(filtered)
  total_msgs = sum(m.message_count for m in filtered)

  if args.format == "json" or (not sys.stdout.isatty() and not args.format):
    payload = {
      "total_conversations": total_convs,
      "total_messages": total_msgs,
      "projects": [
        {
          "project": project,
          "conversations": len(convs),
          "messages": sum(c.message_count for c in convs),
        }
        for project, convs in sorted(
          by_project.items(),
          key=lambda kv: sum(c.message_count for c in kv[1]),
          reverse=True,
        )
      ],
    }
    print(json.dumps(payload, indent=2, ensure_ascii=False))
    return 0

  lines = [
    f"Conversations: {total_convs}",
    f"Messages:      {total_msgs}",
    "",
    f"{'project':<50} {'convs':>6} {'msgs':>7}",
    f"{'-' * 50} {'-' * 6} {'-' * 7}",
  ]
  rows = sorted(
    by_project.items(),
    key=lambda kv: sum(c.message_count for c in kv[1]),
    reverse=True,
  )
  for project, convs in rows:
    msgs = sum(c.message_count for c in convs)
    display = project if len(project) <= 50 else "…" + project[-49:]
    lines.append(f"{display:<50} {len(convs):>6} {msgs:>7}")
  print("\n".join(lines))
  return 0


# ──────────────────────────── CLI ────────────────────────────


def build_parser() -> argparse.ArgumentParser:
  p = argparse.ArgumentParser(
    prog="query_conversations.py",
    description=__doc__,
    formatter_class=argparse.RawDescriptionHelpFormatter,
  )
  p.add_argument(
    "--projects-dir",
    type=Path,
    default=DEFAULT_PROJECTS_DIR,
    help=f"Projects directory (default: {DEFAULT_PROJECTS_DIR})",
  )
  sub = p.add_subparsers(dest="command", required=True)

  def add_format(sp: argparse.ArgumentParser) -> None:
    sp.add_argument("--format", choices=["text", "json", "yaml"], help="Output format (auto)")

  lst = sub.add_parser("list", help="Browse conversations with filters")
  add_format(lst)
  lst.add_argument("--since", help="Filter: started on or after DATE")
  lst.add_argument("--until", help="Filter: started on or before DATE")
  lst.add_argument("--project", help="Substring match against project path")
  lst.add_argument("--min-messages", type=int, help="Only include conversations with >= N messages")
  lst.add_argument("--limit", type=int, help="Cap number of results")
  lst.add_argument("--paths-only", action="store_true", help="Emit JSONL paths only (one per line)")
  lst.add_argument(
    "--include-subagents", action="store_true", help="Also catalog subagent sessions"
  )
  lst.set_defaults(func=cmd_list)

  last = sub.add_parser("last", help="Most recent session by file mtime")
  add_format(last)
  last.add_argument("--project", help="Substring match against project path")
  last.add_argument("--path", action="store_true", help="Emit only the JSONL path")
  last.add_argument("--include-subagents", action="store_true", help="Consider subagent sessions")
  last.set_defaults(func=cmd_last)

  get = sub.add_parser("get", help="Metadata + path for a session id")
  add_format(get)
  get.add_argument("session_id", help="Session id (matches JSONL filename)")
  get.add_argument("--path", action="store_true", help="Emit only the JSONL path")
  get.set_defaults(func=cmd_get)

  srch = sub.add_parser("search", help="Find conversations whose JSONL contains TERM")
  add_format(srch)
  srch.add_argument("term", help="Substring to search for (case-insensitive by default)")
  srch.add_argument("--case-sensitive", action="store_true")
  srch.add_argument("--project", help="Restrict to project path substring")
  srch.add_argument("--since", help="Filter: started on or after DATE")
  srch.add_argument("--until", help="Filter: started on or before DATE")
  srch.add_argument("--limit", type=int, help="Cap number of results")
  srch.add_argument("--paths-only", action="store_true", help="Emit JSONL paths only")
  srch.add_argument(
    "--include-subagents", action="store_true", help="Also search subagent sessions"
  )
  srch.set_defaults(func=cmd_search)

  stats = sub.add_parser("stats", help="Per-project activity overview")
  add_format(stats)
  stats.add_argument("--project", help="Restrict to project path substring")
  stats.add_argument("--since", help="Filter: started on or after DATE")
  stats.add_argument("--until", help="Filter: started on or before DATE")
  stats.add_argument(
    "--include-subagents", action="store_true", help="Also count subagent sessions"
  )
  stats.set_defaults(func=cmd_stats)

  return p


def main(argv: Optional[list[str]] = None) -> int:
  args = build_parser().parse_args(argv)
  if not args.projects_dir.exists():
    print(f"Projects directory not found: {args.projects_dir}", file=sys.stderr)
    return 1
  return args.func(args)


if __name__ == "__main__":
  sys.exit(main())

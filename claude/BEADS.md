## Issue Tracking with bd (beads)

**IMPORTANT**: This project uses **bd (beads)** for ALL issue tracking. Do NOT use markdown TODOs, task lists, or other tracking methods.

### Why bd?

- Dependency-aware: Track blockers and relationships between issues
- Git-friendly: Auto-syncs to JSONL for version control
- Agent-optimized: JSON output, ready work detection, discovered-from links
- Prevents duplicate tracking systems and confusion

### Quick Start

**Check for ready work:**
```bash
bd ready --json
```

**Create new issues:**
```bash
bd create "Issue title" -t bug|feature|task -p 0-4 --json
```

**Create epic with subtasks (hierarchical IDs):**
```bash
# First create the epic
bd create "Epic title" -t epic -p 1 --json
# Returns: {"id": "proj-abc", ...}

# Then create child tasks with --parent flag
# Children get hierarchical IDs: proj-abc.1, proj-abc.2, etc.
bd create "Subtask title" -t task -p 2 --parent proj-abc --json
```

**Link related work (dependency relationships):**
```bash
# --deps creates dependency links (not hierarchical children)
# Valid types: blocks, related, parent-child, discovered-from
bd create "Found bug" -p 1 --deps discovered-from:<issue-id> --json
bd create "Blocked task" -p 2 --deps blocks:<blocker-id> --json

# Note: --deps parent-child:X creates a link but keeps standalone ID
# Use --parent X instead for true hierarchical subtasks
```

**Claim and update:**
```bash
bd update bd-42 --status in_progress --json
bd update bd-42 --priority 1 --json
```

**Complete work:**
```bash
bd close bd-42 --reason "Completed" --json
```

### Issue Types

- `bug` - Something broken
- `feature` - New functionality
- `task` - Work item (tests, docs, refactoring)
- `epic` - Large feature with subtasks
- `chore` - Maintenance (dependencies, tooling)

### Priorities

- `0` - Critical (security, data loss, broken builds)
- `1` - High (major features, important bugs)
- `2` - Medium (default, nice-to-have)
- `3` - Low (polish, optimization)
- `4` - Backlog (future ideas)

### Workflow for AI Agents
<session_start_workflow>

  1. **Check ready work**: `bd ready` shows unblocked issues
  2. **Claim your task**: `bd update <id> --status in_progress`
  3. **Work on it**: Implement, test, document
  4. **Discover new work?** Create linked issue:
     - `bd create "Found bug" -p 1 --deps discovered-from:<parent-id>`
  5. **Complete**: `bd close <id> --reason "Done"`
  6. **Commit together**: Always commit the `.beads/issues.jsonl` file together with the code changes so issue state stays in sync with code state

</session_start_workflow>


### Auto-Sync

bd automatically syncs with git:
- Exports to `.beads/issues.jsonl` after changes (5s debounce)
- Imports from JSONL when newer (e.g., after `git pull`)
- No manual export/import needed!

### CLI help

Get documentation by running `bd --help` or `bd <command> --help` for specific commands.

### Managing AI-Generated Planning Documents

AI assistants often create planning and design documents during development:
- PLAN.md, IMPLEMENTATION.md, ARCHITECTURE.md
- DESIGN.md, CODEBASE_SUMMARY.md, INTEGRATION_PLAN.md
- TESTING_GUIDE.md, TECHNICAL_DESIGN.md, and similar files

Write ALL of these files initially to `history/` for organizing later, or storing past planning.

Keep the repository root clean and focused on permanent project files.

**Example .gitignore entry (optional):**
```
# AI planning documents (ephemeral)
history/
```

**Benefits:**
- Clean repository root
- Clear separation between ephemeral and permanent documentation
- Easy to exclude from version control if desired
- Preserves planning history for archeological research
- Reduces noise when browsing the project

### Important Rules

- Use bd for ALL task tracking
- Always use `--json` flag for programmatic use
- Use `--parent <epic-id>` for hierarchical subtasks (gives `.1`, `.2` IDs)
- Link discovered work with `--deps discovered-from:<id>`
- Check `bd ready` before asking "what should I work on?"
- Store AI planning docs in `history/` directory
- Do NOT create markdown TODO lists
- Do NOT use external issue trackers
- Do NOT duplicate tracking systems
- Do NOT clutter repo root with planning documents

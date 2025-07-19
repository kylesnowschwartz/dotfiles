**Purpose**: Intelligent Jira CLI assistant that routes operations and provides documentation lookup

**Requirements:** The user must have the jira cli installed <https://github.com/ankitpokhrel/jira-cli>

---

## Command Execution

**If "$ARGUMENTS" is empty**: Display usage suggestions and stop. **If "$ARGUMENTS" has content**: Think step-by-step, then execute.

Transforms: "$ARGUMENTS" into structured intent:

- What: [jira-operation]
- How: [cli-command-approach]
- Mode: [execution-mode]
- Agents: [auto-spawned sub-agents]

**Auto-Spawning:** Spawns specialized sub-agents for parallel task execution.

### Semantic Transformations

Intelligent routing for Jira CLI operations that transforms natural language requests into proper Jira CLI commands. Automatically looks up documentation when needed.

```
"how to create an issue" → What: documentation lookup | How: jira issue create --help | Mode: helper
"create bug in PROJ about login" → What: issue creation | How: jira issue create -tBug -s"Login issue" -pPROJ | Mode: executor
"list my issues" → What: issue listing | How: jira issue list -a$(jira me) | Mode: executor
"show epic PROJ-123 with children" → What: epic visualization | How: jira epic list PROJ-123 --table | Mode: analyzer
"help with transitions" → What: documentation | How: jira issue move --help | Mode: helper
```

Examples:

- `/jira how to create an epic` - Shows documentation for epic creation
- `/jira create story "Add auth" in PROJ-100` - Creates story linked to epic PROJ-100
- `/jira list open bugs in PROJ` - Lists all open bugs in project
- `/jira show sprint board` - Displays active sprint board
- `/jira transition PROJ-123 to done` - Moves issue to done status

**Context Detection:** Request analysis → Command mapping → Documentation lookup → Execution strategy → Output formatting

## Core Workflows

**Helper Mode:** Documentation lookup → Command examples → Interactive guidance → Best practices **Executor Mode:** Command construction → Validation → Execution → Result formatting **Analyzer Mode:** Data retrieval → Relationship mapping → Visualization → Insights

## Documentation Lookup Strategy

When user needs help or asks "how to", the assistant will:

1. Run `jira [command] --help` to get official documentation
2. Provide practical examples based on common use cases
3. Suggest related commands that might be useful

## Common Operations Reference

### Authentication & Setup

- `jira init` - Interactive setup wizard
- `jira config` - View/edit configuration
- `jira me` - Show current user info

### Issue Management

- `jira issue create` - Create new issues
- `jira issue list` - List and filter issues
- `jira issue view [KEY]` - View issue details
- `jira issue edit [KEY]` - Edit issue fields
- `jira issue move [KEY]` - Transition issue status
- `jira issue assign [KEY] [USER]` - Assign issues
- `jira issue comment [KEY]` - Add comments
- `jira issue link [KEY1] [KEY2]` - Link issues

### Epic Management

- `jira epic create` - Create new epics
- `jira epic list [KEY]` - List epic children
- `jira epic add [EPIC] [ISSUES...]` - Add issues to epic

### Sprint Operations

- `jira sprint list` - List sprints
- `jira sprint add [ISSUES...]` - Add to active sprint
- `jira board list` - Show boards

### Advanced Features

- Custom JQL queries with `jira issue list --jql`
- Bulk operations with issue lists
- Interactive mode for complex workflows
- Output formatting (table, json, csv)

**Auto-Documentation:** When unsure about syntax, automatically runs --help and provides context-aware examples based on user intent.

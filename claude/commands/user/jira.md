**Purpose**: Intelligent Jira CLI assistant that routes operations and provides documentation lookup

---

## Command Execution

**If "$ARGUMENTS" is empty**: Display usage suggestions and stop.  
**If "$ARGUMENTS" has content**: Think step-by-step, then execute.

Transforms: "$ARGUMENTS" into structured intent:

- What: [jira-operation]
- How: [cli-command-approach]

### Semantic Transformations

Intelligent routing for Jira CLI operations that transforms natural language requests into proper Jira CLI commands. Automatically looks up documentation when needed.

Examples:

- `/jira how to create an epic` - Shows documentation for epic creation
- `/jira create story "Add auth" in PROJ-100` - Creates story linked to epic PROJ-100
- `/jira list open bugs in PROJ` - Lists all open bugs in project
- `/jira show sprint board` - Displays active sprint board
- `/jira transition PROJ-123 to done` - Moves issue to done status

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

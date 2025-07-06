# Jira Tickets

🎫 **Jira Ticket Management** - List, search, create, and manage Jira tickets
from command line.

## Usage

```bash
@jira-tickets [command] [options]
@jira-tickets list                    # List recent tickets
@jira-tickets show PROJ-123           # Show ticket details
@jira-tickets children PROJ-123       # Show child issues (subtasks and epic children)
@jira-tickets epic PROJ-456           # Show epic details with all children
@jira-tickets search "bug fix"        # Search tickets using JQL
@jira-tickets projects                # List all projects
```

## Instructions

Run the Jira script with the provided arguments:

```bash
/Users/kyle/.claude/scripts/jira.sh $ARGUMENTS
```

**Available commands**:

- `setup` - Configure Jira URL and email
- `list [project]` - List tickets (optionally filter by project)
- `show <ticket-id>` - Show details for a specific ticket
- `children <ticket-id>` - Show child issues (subtasks and epic children)
- `epic <epic-key>` - Show epic details with all child stories/tasks
- `search <jql>` - Search tickets using JQL
- `projects` - List all projects

**Prerequisites**: Run `@jira-setup` first to configure your instance.

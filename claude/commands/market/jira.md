**Purpose**: Intelligent Jira assistant using Atlassian MCP server for direct API integration

**Requirements:** Atlassian MCP server configured with Jira credentials

---

## Command Execution

**If "$ARGUMENTS" is empty**: Display usage suggestions and stop.
**If "$ARGUMENTS" has content**: Think step-by-step, then execute.

Transforms: "$ARGUMENTS" into structured intent:

- What: [jira-operation]
- How: [mcp-tool-approach]
- Mode: [execution-mode]
- Data: [structured-response]

**Direct API Integration:** Uses Atlassian MCP server tools for immediate Jira API access.

### Semantic Transformations

Intelligent routing for Jira operations that transforms natural language requests into appropriate MCP tool calls. Provides rich structured data responses.

```
"analyse issue PROJ-123" → What: issue analysis | How: mcp__Atlassian__jira_get_issue | Mode: analyzer
"create bug in PROJ about login" → What: issue creation | How: mcp__Atlassian__jira_create_issue | Mode: executor  
"list my issues" → What: issue search | How: mcp__Atlassian__jira_search with assignee=currentUser() | Mode: executor
"show epic PROJ-123 children" → What: epic analysis | How: mcp__Atlassian__jira_search parent=PROJ-123 | Mode: analyzer
"transition PROJ-123 to done" → What: status change | How: mcp__Atlassian__jira_transition_issue | Mode: executor
```

Examples:

- `/jira analyse issue PROJ-123` - Detailed issue analysis with context
- `/jira create story "Add auth" in PROJ linked to EPIC-100` - Creates story with epic link
- `/jira search "project = PROJ AND status = Open AND type = Bug"` - JQL search for open bugs
- `/jira get boards for project PROJ` - Lists project boards and sprints  
- `/jira transition PROJ-123 to "In Progress"` - Changes issue status

**Context Detection:** Request analysis → MCP tool selection → API call → Structured response → Analysis

## Core Workflows

**Helper Mode:** Tool documentation → MCP examples → Best practices → Guided execution
**Executor Mode:** Tool selection → Parameter mapping → API execution → Response formatting
**Analyzer Mode:** Data retrieval → Relationship analysis → Context enrichment → Actionable insights

## MCP Tool Strategy

When processing requests, the assistant will:
1. Parse user intent and identify required Jira operations
2. Select appropriate `mcp__Atlassian__jira_*` tools
3. Execute API calls with proper parameters
4. Format structured responses for clarity

## Available MCP Tools Reference

### Issue Management
- `mcp__Atlassian__jira_get_issue` - Get detailed issue information
- `mcp__Atlassian__jira_search` - Search issues with JQL queries  
- `mcp__Atlassian__jira_create_issue` - Create new issues
- `mcp__Atlassian__jira_update_issue` - Update existing issues
- `mcp__Atlassian__jira_delete_issue` - Delete issues
- `mcp__Atlassian__jira_add_comment` - Add comments to issues
- `mcp__Atlassian__jira_transition_issue` - Change issue status
- `mcp__Atlassian__jira_get_transitions` - Get available transitions

### Issue Linking & Relationships
- `mcp__Atlassian__jira_link_to_epic` - Link issues to epics
- `mcp__Atlassian__jira_create_issue_link` - Create issue links
- `mcp__Atlassian__jira_remove_issue_link` - Remove issue links

### Agile & Sprint Management  
- `mcp__Atlassian__jira_get_agile_boards` - List boards
- `mcp__Atlassian__jira_get_sprints_from_board` - Get board sprints
- `mcp__Atlassian__jira_get_sprint_issues` - Get sprint issues
- `mcp__Atlassian__jira_create_sprint` - Create new sprints
- `mcp__Atlassian__jira_update_sprint` - Update sprint details

### Time Tracking & Workflow
- `mcp__Atlassian__jira_add_worklog` - Log time on issues
- `mcp__Atlassian__jira_get_worklog` - Get worklog entries

### User & Project Info
- `mcp__Atlassian__jira_get_user_profile` - Get user information
- `mcp__Atlassian__jira_get_project_issues` - Get all project issues
- `mcp__Atlassian__jira_search_fields` - Search available fields

### Confluence Integration
- `mcp__Atlassian__confluence_search` - Search Confluence pages
- `mcp__Atlassian__confluence_get_page` - Get page content
- `mcp__Atlassian__confluence_create_page` - Create new pages

**Rich Data Integration:** All tools return structured JSON data with comprehensive issue details, relationships, and metadata for enhanced analysis and reporting.

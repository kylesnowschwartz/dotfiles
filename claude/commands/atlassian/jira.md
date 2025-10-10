---
allowed-tools: mcp__atlassian__jira
argument-hint: e.g. "Summarize the 'Done When' requirements for MTMS-1234"
description: Intelligent Jira assistant using Atlassian MCP server
---

## Command Execution

If "$ARGUMENTS" is empty: Display usage suggestions and stop.
If "$ARGUMENTS" has content: Think step-by-step, then execute.

### Semantic Transformations

Uses Atlassian MCP server tools for immediate Jira API access. Intelligent routing for Jira operations that transforms natural language requests into appropriate MCP tool calls.

Transforms: "$ARGUMENTS" into structured intent:

- What: [jira-operation]
- How: [mcp-tool-approach]

## MCP Tool Strategy

When processing requests, the assistant will:

1. Parse user intent and identify required Jira operations
2. Select appropriate `mcp__Atlassian__jira_*` tools
3. Execute API calls with proper parameters
4. Format structured responses for clarity

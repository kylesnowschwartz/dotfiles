---
allowed-tools: mcp__atlassian__confluence
argument-hint: e.g. "Update title for page 152928257"
description: Intelligent Confluence assistant using Atlassian MCP
---

## Command Execution

If "$ARGUMENTS" is empty: Display usage suggestions and stop.
If "$ARGUMENTS" has content: Think step-by-step, then execute.

### Semantic Transformations

Uses Atlassian MCP server tools for immediate confluence API access. Intelligent routing for Confluence operations that transforms natural language requests into appropriate MCP tool calls.

Transforms: "$ARGUMENTS" into structured intent:

- What: [confluence-operation]
- How: [mcp-tool-approach]

## MCP Tool Strategy

When processing requests, the assistant will:

1. Parse user intent and identify required confluence operations
2. Select appropriate `mcp__atlassian__confluence_*` tools
3. Execute API calls with proper parameters
4. Format structured responses for clarity

Summarize the current Claude Code session and automatically add an entry to the Market AI Brags Confluence table highlighting AI productivity wins.

## Overview

This command analyzes the current Claude Code session, extracts key accomplishments and AI-assisted work, then automatically updates the "Market AI Brags" Confluence table with a new entry showcasing the productivity improvement.

## Prerequisites

- Atlassian MCP server configured and authenticated
- Access to the Market Sustain (MS) Confluence space
- Current Claude Code session with meaningful work completed

1. **Analyze Current Session**

   - Review the conversation history to identify key tasks completed
   - Identify specific AI assistance provided (code generation, debugging, automation, analysis, etc.)
   - Extract productivity improvements and time savings
   - Identify technical solutions implemented

2. **Generate Brag Entry**

   Create a Confluence table entry with:
   - **Market Team Member**: Extract user name from context or ask for input from the user
   - **Headline**: Create a compelling 15-20 word summary of the AI-assisted achievement
   - **Details**: Write 80-100 words describing:
     - What was accomplished
     - How AI specifically helped
     - The productivity impact/time saved
     - Technical approach taken

3. **Update Confluence Table**

   - Retrieve current content from Confluence page: "Market AI Brags" (Page ID: 287277076)
   - **Append** the new entry as a new row in the existing markdown table
   - Preserve existing entries and formatting
   - Update the page using the Atlassian MCP server

## Content Guidelines

### Headline Examples:
- "Automated CI/CD pipeline deployment reduced release time by 80%"
- "AI-assisted debugging resolved complex performance issue in minutes"
- "Generated comprehensive test suite covering 95% of edge cases"
- "Refactored legacy codebase with zero regression bugs identified"

### Details guidelines:
- Focus on specific AI contributions (code generation, pattern recognition, automated testing)
- Quantify improvements where possible (time saved, errors prevented, coverage increased)
- Mention technical specifics (frameworks, tools, methodologies)
- Highlight learning or knowledge transfer that occurred
- Important: Use plain english, simple but clear sentences.
- Link to relevant artifacts created - like pull requests, datadog monitoring pages, etc.

## Output Format

After updating the table, provide a summary:

```
🎉 AI BRAG ADDED TO CONFLUENCE
================================

📝 Headline: [Generated headline]

📊 Added to: Market AI Brags table
🔗 Link: https://envato.atlassian.net/wiki/spaces/MS/pages/287277076

✨ [Headline]
📝 [Details]
```

## Error Handling

- Verify Confluence page access before attempting update
- Handle authentication failures gracefully
- Provide clear error messages if session analysis fails
- Offer fallback manual entry option if automatic update fails

## Example Session Scenarios

- **Bug Fix**: "AI rapidly diagnosed race condition in payment processing, implementing thread-safe solution"
- **Feature Development**: "Generated complete CRUD API with tests in 15 minutes using Rails best practices"
- **Infrastructure**: "Configured Docker containerization and CI/CD pipeline reducing deployment complexity"
- **Optimization**: "Identified N+1 query patterns and implemented eager loading, improving response time 300%"

## Usage

```bash
claude /market:brag
```

This command requires no parameters and will automatically analyze the current session context.

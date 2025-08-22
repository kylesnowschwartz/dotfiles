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

   - **Brag #**: Auto-increment ID number (check existing table for next number)
   - **Market Team Member**: Extract user name from context or ask for input from the user
   - **Headline**: Create a compelling 15-20 word summary of the AI-assisted achievement
   - **Details**: Write 80-100 words describing:
     - What was accomplished
     - How AI specifically helped
     - The productivity impact/time saved
     - Technical approach taken
   - **Date**: **CRITICAL** - Use system date command to get accurate current date in YYYY-MM-DD format (AI agents are often wrong about dates!)

3. **Update Confluence Table**

   - Retrieve current content from Confluence page: "Market AI Brags" (Page ID: 287277076)
   - **CRITICAL**: Use `convert_to_markdown: false` to get the raw Confluence storage format
   - **Parse existing table** to determine next Brag # (auto-increment from highest existing ID)
   - **MUST preserve exact Confluence storage format** including:
     - `<table style="width: 100%;">` for full page width
     - Standard HTML table structure without complex Confluence-specific attributes
   - **Add new table row** within the existing `<tbody>` preserving all HTML structure
   - **Update page** by passing the complete HTML storage format (NOT markdown) to the MCP server
   - **Verify formatting preservation** by checking the updated page maintains column widths

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

## Critical Technical Requirements

**FORMATTING PRESERVATION IS CRITICAL:**

1. **Always use `convert_to_markdown: false`** when retrieving the Confluence page to get raw HTML storage format
2. **Never convert to markdown** - work directly with Confluence's HTML storage format
3. **Use simple HTML table structure** with `<table style="width: 100%;">` for full page width
4. **Preserve table headers and structure** while ensuring proper HTML formatting
5. **Add new rows within existing `<tbody>`** without modifying table headers or structure
6. **Pass complete HTML** to the MCP server update function, not markdown

**Example of correct table structure:**

```html
<table style="width: 100%;">
  <thead>
    <tr>
      <th><strong>Brag #</strong></th>
      <th><strong>Market Team Member</strong></th>
      ...
    </tr>
  </thead>
  <tbody>
    ...existing rows...
    <tr>
      <td>16</td>
      <td>New Member</td>
      <td>Headline text</td>
      ...
    </tr>
  </tbody>
</table>
```

## Error Handling

- Verify Confluence page access before attempting update
- Handle authentication failures gracefully
- Provide clear error messages if session analysis fails
- Offer fallback manual entry option if automatic update fails
- **Verify formatting preservation** after update by retrieving page again

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

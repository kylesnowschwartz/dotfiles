# Work Status Summary

Generate an actionable summary of current work status for you, by checking Jira sprint board and GitHub pull requests.

## Overview

This command creates a comprehensive work status report that includes:

- Current Jira sprint status and assigned tickets
- Open GitHub pull requests with merge status
- Unread GitHub notifications and PR comments
- Action items that need attention

## Prerequisites

Ensure the following tools are installed and configured:

- Atlassian MCP server.
- `gh` CLI tool (GitHub CLI)
- Both tools should be authenticated with your accounts

## Instructions

1. **Get Jira Sprint Information**

   - Use the Atlassian MCP server `jira_issue_search` to get current issues assigned to me
   - Only search for issues in the current sprint.
   - Display issue keys, summaries, and current status

2. **Get GitHub Pull Request Status**

   - Use `gh pr list --author @me --state open` to get your open PRs
   - For each PR, check:
     - Merge status: `gh pr view <PR_NUMBER> --json mergeable,mergeStateStatus`
     - Review status: `gh pr view <PR_NUMBER> --json reviews`
     - Check if CI/checks are passing: `gh pr view <PR_NUMBER> --json statusCheckRollup`

3. **Check GitHub Notifications**

   - Use `gh api notifications` to get unread notifications
   - Filter for pull request related notifications
   - Show unread PR comments and review requests

4. **Generate Action Items**
   Based on the collected data, create actionable items such as:
   - "Review comments on PR #123"
   - "Merge ready PR #456"
   - "Move Jira ticket ABC-123 to In Progress"
   - "Address failing CI on PR #789"
   - "Update Jira ticket XYZ-456 status to Done"

## Output Format

Present the information in a clear, scannable format using the local time:

```
📊 Work Status Summary - 2024-01-15 14:30
================================================

🎯 JIRA SPRINT STATUS
Current Sprint: Sprint 24 (Jan 8 - Jan 22)
├── 📋 TODO (2)
│   ├── ABC-123: Implement user authentication <LINK TO ISSUE>
│   └── ABC-125: Fix mobile responsive layout <LINK TO ISSUE>
├── ⚡ IN PROGRESS (1)
│   └── ABC-124: Add payment integration <LINK TO ISSUE>
└── ✅ DONE (3)
    ├── ABC-121: Update API documentation
    ├── ABC-122: Fix login bug
    └── ABC-120: Add unit tests

🔄 GITHUB PULL REQUESTS
├── 🟢 READY TO MERGE (1)
│   └── #456: Fix authentication bug (✅ Approved, ✅ CI passing) <LINK TO PR>
├── 📝 NEEDS REVIEW (2)
│   ├── #458: Add payment flow (⏳ Pending review) <LINK TO PR>
│   └── #459: Update documentation (⏳ Pending review) <LINK TO PR>
└── ❌ NEEDS ATTENTION (1)
    └── #457: Mobile fixes (💬 3 unread comments, ❌ CI failing) <LINK TO PR>

🔔 NOTIFICATIONS (4 unread)
├── 💬 New comment on PR #457 by @reviewer
├── 👀 Review requested on PR #460
├── ✅ CI passed on PR #456
└── 💬 New comment on PR #458 by @teammate

⚡ ACTION ITEMS
1. 🔴 Address 3 unread comments on PR #457
2. 🟡 Merge ready PR #456
3. 🔴 Fix failing CI on PR #457
4. 🟡 Respond to review request on PR #460
5. 🟢 Move ABC-124 to Done (PR merged)
```

## Error Handling

- Check if required CLI tools are installed
- Verify authentication status for both services
- Handle API rate limits gracefully
- Provide helpful error messages with setup instructions

## Optional Parameters

- `--sprint <board-key>`: Specify Jira board/sprint
- `--repo <owner/repo>`: Focus on specific GitHub repository
- `--days <number>`: Look at notifications from last N days (default: 7)
- `--format <json|table|summary>`: Output format (default: summary)

## Example Usage

```bash
claude work-status
claude work-status --sprint PROJ --repo myorg/myrepo
claude work-status --days 3 --format table
```

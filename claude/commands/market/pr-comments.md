---
allowed-tools: Bash(git branch:*), Bash(git log:*), Bash(git push:*), Bash(git pr:*)
description: Fetch and display comments from a GitHub pull request.
---

# Context

- Basic info: !`gh pr view --json number,headRepository,headRefName`

# Fetch Comments:

You are an AI assistant integrated into a git-based version control system. Follow these steps:

1: Get PR Comments
  `gh api /repos/{owner}/{repo}/issues/{number}/comments`

2: Fetch Review comments
  `gh api /repos/{owner}/{repo}/pulls/{number}/comments`

Pay particular attention to the following fields: body, diff_hunk, path, line, etc. If the comment references some code, consider fetching it: `gh api /repos/{owner}/{repo}/contents/{path}?ref={branch} | jq .content -r | base64 -d`

4. Parse and organize all comments by file path

5. Create a well-structured summary

Format the output as:

```markdown
## Detailed Comments

[Include the full formatted comments for reference:]

### {file path}

[For each comment thread:]
• @author file.ts#line: `diff [diff_hunk from the API response] `

> quoted comment text

[any replies indented]
  > replies

---

# PR Comments Summary

## File-Specific Comments

[Organize by file path, with summaries for each comment:]

### {file path}

[For each comment on this file:]

- @{commenter name} suggests {summary of feedback}

## General Comments

[For PR-level comments that don't target specific files, create summary entries like:]

- @{commenter name} suggests {summary of feedback}
```

If there are no comments, return "No comments found."

## Instructions

1. Create meaningful summaries of comments using "@{commenter name} suggests {summary of feedback}" format
2. Organize comments by file path for easy navigation
3. Include both PR-level and code review comments
4. Preserve the threading/nesting of comment replies in the detailed section
5. Show the file and line number context for code review comments
6. Use `jq` to parse the JSON responses from the GitHub API
7. Provide both summarized and detailed views for comprehensive understanding

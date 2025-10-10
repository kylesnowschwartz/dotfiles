---
allowed-tools: Bash(git branch:*), Bash(git log:*), Bash(git push:*), Bash(git pr:*)
description: Creates a functional git commit
---

## Context

- Current branch: !`git branch --show-current`
- Recent commits: !`git log --oneline -10`

## Process

Step 1: Push to Remote
`git push -u origin <branch-name>`

Step 2: Create Pull Request
Use the template provided below for the markdown body content of the PR e.g.
`gh pr create --title "Descriptive PR Title" --body "Markdown Body Content" --repo owner/repo --head username:branch`

Step 3: Summarize the results
Inform the user that the gh pr create command succeeded and output the PR link directly:
https://github.com/owner/repo/pull/123

# Open a pull request using the provided PR template
Analyze the changes made in this feature branch and create a github PR description that follows the template below.

Follow these guidelines for the description:

1. Use clear, concise language in plain English
2. Maintain a professional but casual tone
3. Focus on core changes, omitting minor side changes
4. Make the PR body easy to scan quickly with structured content
5. Omit emoji

Use the following template for the pull request description in @.github/PULL_REQUEST_TEMPLATE.md, or use the below template:

<pr-template>

```md
## Jira issue
<!-- Insert a link to the Jira ticket if provided. -->

## Context
<!-- Your code and specs may seem self-explanatory to you, but your reviewer hasn't been thinking about the problem you're solving for as long as you have. -->

## Changes
<!--Provide a detailed explanation of the changes you have made, files changed etc. Include the reasons behind these changes. Link any related issues. Discuss the impact of your changes on the project. Categorise changes in to groups as appropriate. -->

## Code Author General Checklist
- [ ] I have notified the team of my changes (link to this PR).
- [ ] I kept my pull request small so it can be reviewed easier.
- [ ] My code follows the project's coding and style guidelines.
- [ ] I have performed a self-review of my code.
- [ ] I have commented my code, particularly in hard-to-understand areas.
- [ ] I have made corresponding changes to the documentation.
- [ ] Where needed, I have consulted subject matter experts to gain confidence in the change's correctness.
- [ ] I will monitor the build status on [Buildkite], ensure the deployment passes on [Samson] via [#market-deploy] and check if my changes introduce any errors on [Rollbar] and [Datadog].
```

</pr-template>

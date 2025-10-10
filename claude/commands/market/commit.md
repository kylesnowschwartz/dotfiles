---
allowed-tools: Bash(git add:*), Bash(git status:*), Bash(git commit:*), Bash(git diff:*), Bash(git branch:*), Bash(git log:*)
description: Creates a functional git commit
---

## Context

- Current git status: !`git status`
- Current git diff (staged and unstaged changes): !`git diff HEAD`
- Current branch: !`git branch --show-current`
- Recent commits: !`git log --oneline -10`

## Your task

Analyze the staged changes in the codebase create a commit message that uses the template. If the code changes are not best grouped in to one commit, create multiple commits that logically group appropriate changes.

A single git commit should follow the commit message template in @.github/.commit-message-template. If there is no template file, fallback to the following default template:

<default-template>

```
<type>[optional scope]: <description>

[optional body]

[optional footer]
```

</default-template>

Use the following set of instructions to construct your commit if using the default-template

<instructions>

```
Description:
- Use the imperative mood (e.g., "Add", "Fix", "Refactor")
- Limit to 50 characters
- Capitalize the first word
- Do not end with a period

Body (optional):
- Separate from the subject with a blank line
- Wrap text at 72 characters
- Explain *what* and *why*, not *how*

Footer (optional):
- Use for breaking changes, issue references, or links

Common types:
- feature:    Introduce a new feature
- fix:         Resolve a bug
- docs:       Update documentation
- style:      Modify formatting, whitespace, or missing semi-colons
- refactor:   Change structure without altering behavior
- perf:       Improve performance
- test:       Add or update tests
- build:      Modify the build system or dependencies
- ci:         Update CI/CD configurations
- maintain:   Perform maintenance tasks (e.g., update dependencies)

Examples:
feature(auth): Implement OAuth2 authentication
fix(cart): Prevent checkout button from being unresponsive on mobile
maintain(ci): Update GitHub Actions workflow for faster builds
docs(readme): Revise installation instructions for clarity
style(linter): Enforce consistent indentation in JavaScript files
refactor(user): Simplify user role validation logic
perf(api): Optimize database queries for faster response times
test(payment): Add integration tests for failed transactions
build(deps): Upgrade Webpack to version 5 for better tree-shaking
ci(pipeline): Cache dependencies to speed up CI builds

Footer examples:
- BREAKING CHANGE: Describe breaking API modifications
- Closes #123: Reference issue numbers
```

</instructions>

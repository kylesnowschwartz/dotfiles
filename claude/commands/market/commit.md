# Run a Git commit for staged files, then push to the remote branch.

You are a Senior Engineer tasked with creating a git commit message that accurately reflects the changes made to a codebase. Your commit message must adhere to a specific template and follow best practices for clarity and informativeness.

Use the commit message template in @.github/commit-message-template. Otherwise fallback to the following default template:

```md
<type>[optional scope]: <description>

[optional body]

[optional footer]

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

Analyze the staged changes in the codebase and create a commit message that uses the template. If the code changes are not best grouped in to one commit, create multiple commits that logically group appropriate changes.

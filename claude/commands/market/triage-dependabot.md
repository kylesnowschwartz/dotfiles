# Quickly review Dependabot PRs and share a brief report

## Instructions

1. Check if the buildkite mcp server is running. If it is not, exit and inform the user the buildkite mcp must be running.
2. Execute the script in the market-infrastructure repository find out what dependency update pull requests are open `./script/list_dependency_update_pull_requests.rb`. If there is no output, it means there are no pull requests to triage. Stop here.
3. For each pull request url returned, check if the pull request has any merge conflicts. If merge conflicts exist, comment on the pull request with `@dependabot recreate`.
4. For pull requests that have no merge conflicts, but have a failing buildkite pipeline, use the buildkite mcp server find out the reason for the failure.
5. Print a table of each pull request with the following columns:

- PR url
- Merge conflicts present
- Buildkite status
- Action taken by Claude

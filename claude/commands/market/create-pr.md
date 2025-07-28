# Open a pull request using the provided PR template
Analyze the changes in the codebase, create a github PR description that follows the template below, and then use this description to create a draft pull request.

Follow these guidelines for the description:

1. Use clear, concise language
2. Write in plain English
3. Maintain a semi-formal to casual tone—professional but not overly formal
4. Focus on core changes, omitting minor side changes
5. Ensure each core change is clearly linked to the problem it's solving

Use the following template for the pull request description in @.github/PULL_REQUEST_TEMPLATE.md, or use the below template:

```md
## Jira issue
<!-- Insert a link to the Jira ticket if you are aware of one. If not, ignore this section -->
## Context
<!-- Your code and specs may seem self-explanatory to you, but your reviewer hasn't been thinking about the problem you're solving for as long as you have. Add a link to the Trello Card (if relevant). -->

## Changes
<!--Provide a detailed explanation of the changes you have made, files changed etc. Include the reasons behind these changes. Link any related issues. Discuss the impact of your changes on the project. This might include effects on performance, new dependencies, or changes in behaviour. Categorise changes in to groups as appropriate. -->

## Code Author General Checklist
- [ ] I have notified the [Market team][market-engineering] of my changes (link to this PR).
- [ ] I kept my pull request small so it can be reviewed easier.
- [ ] My code follows the project's coding and style guidelines.
- [ ] I have performed a self-review of my code.
- [ ] I have commented my code, particularly in hard-to-understand areas.
- [ ] I have made corresponding changes to the documentation.
- [ ] Where needed, I have consulted subject matter experts to gain confidence in the change's correctness.
- [ ] I will monitor the build status on [Buildkite], ensure the deployment passes on [Samson] via [#market-deploy] and check if my changes introduce any errors on [Rollbar] and [Datadog].
<!-- Only include the following checks if you are in the marketplace repository -->
- [ ] I have notified the [Data team][data-team-slack] of any database changes if applicable.
- [ ] I have updated the [Dewey database schema][dewey-db-schema] with the latest changes if applicable.
```

Generate a title for the pull request that reveals its intent. The title must have a maximum length of 80 characters.

Use the GitHub CLI to create and open a draft pull request. The command should:

1. Use the 'gh pr create' command
2. Include the '--title' flag with the PR title you created
3. Include the '--body' flag with the PR description you drafted
4. Use the 'gh browse' command to open the pull request in browser

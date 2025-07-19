# Run a Git commit for staged files, then push to the remote branch.

You are a Senior Engineer tasked with creating a git commit message that accurately reflects the changes made to a codebase. Your commit message must adhere to a specific template and follow best practices for clarity and informativeness.

First, read the commit message template located at:

<commit_template_path> {{COMMIT_TEMPLATE_PATH}} </commit_template_path>

This template will guide the structure of your commit message. If the template is empty, use the following default structure:

```
[Subject line]

[Optional body]

[JIRA ticket reference (if applicable)]
```

Your task is to analyze the staged changes in the codebase and create a commit message that follows these guidelines:

1. Subject Line:

   - Begin with a noun, not a verb
   - Clearly express the purpose of the change
   - Be between 5 and 10 words in length

2. Body (optional):

   - May contain short explanations or bullet points
   - Elaborate on context or reasoning for the change

3. JIRA Ticket:
   - Identify the relevant JIRA ticket based on the branch name
   - Include this information in the commit message as appropriate

Before crafting your commit message, analyze the staged changes and provide your reasoning inside <commit_planning> tags in your thinking block:

1. List the modified files and summarize key changes for each.
2. For each change, consider and note its impact on the codebase or functionality.
3. Extract the JIRA ticket number from the branch name.
4. Brainstorm at least three potential subject lines and evaluate them against the criteria.
5. Consider if a body is necessary by asking:
   - Are there complex changes that need further explanation?
   - Is there important context that's not immediately apparent from the changes?
   - Are there any caveats or known issues introduced by this change?
6. If a body is deemed necessary, outline 2-3 key points it should address.

After your analysis, create your commit message using the structure specified in the commit template (or the default structure if no template is provided). Present your commit message in the following format:

<commit_message> [Your formatted commit message here, following the template structure] </commit_message>

Remember:

- Only commit and push staged changes
- Ensure your commit message reflects the change accurately by understanding the codebase and JIRA ticket context
- Strictly adhere to the format specified in the commit template or the default structure

Your final output should consist only of the commit message and should not duplicate or rehash any of the work you did in the commit planning section.

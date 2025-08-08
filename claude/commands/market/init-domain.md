# Initialize a new $ARGUMENTS.md domain knowledge file with codebase documentation

**Instructions** Analyze this codebase and create a $ARGUMENTS.md domain knowledge file, which will be given to future instances of Claude Code to operate with the domain knowledge in this repository.

# Use the following to guide you

@.claude/CLAUDE_MD_CHECKLIST.md
@.claude/CONVENTIONS.md
@.claude/domains/DOMAIN_TEMPLATE.md
@CLAUDE.md

What to add:

1. Commands that will be commonly used, such as how to build, lint, and run tests. Include the necessary commands to develop in this codebase, such as how to run a single test.
2. High-level code architecture and structure so that future instances can be productive more quickly. Focus on the "big picture" architecture that requires reading multiple files to understand

Usage notes:

- Do not repeat yourself
- Be specific
- Avoid generic development practices
- Avoid listing every component or file structure that can be easily discovered
- Check for any related README.md for additional context
- Check comments in code for additional context
- If there is any $ARGUMENTS-related markdown documentations, include the relative path
- Be sure to prefix the file with the following text:

```
# $ARGUMENTS.md

This file provides guidance to Claude Code (claude.ai/code) when working with code with domain knowledge in this repository.
```

${ARGUMENTS}

Initialize a new $ARGUMENTS.md domain knowledge file with codebase documentation

**IMPORTANT: DO NOT SEARCH FROM MEMORY**

Please analyze this codebase and create a $ARGUMENTS.md domain knowledge file, which will be given to future instances of Claude Code to operate with the domain knowledge in this repository.
            
What to add:
1. Commands that will be commonly used, such as how to build, lint, and run tests. Include the necessary commands to develop in this codebase, such as how to run a single test.
2. High-level code architecture and structure so that future instances can be productive more quickly. Focus on the "big picture" architecture that requires reading multiple files to understand

Usage notes:
- Don't use the file if $ARGUMENTS.md already exists in the repository, instead rebuild the file entirely
- When you make the initial $ARGUMENTS.md, do not repeat yourself and do not include obvious instructions like "Provide helpful error messages to users", "Write unit tests for all new utilities", "Never include sensitive information (API keys, tokens) in code or commits" 
- Avoid listing every component or file structure that can be easily discovered 
- Don't include generic development practices
- If there is a README.md, make sure to include the important parts. 
- If there is any $ARGUMENTS-related markdown documentations, include the relative path
- If there is any comments in code, make sure to include the important parts
- Do not make up information such as "Common Development Tasks", "Tips for Development", "Support and Documentation" unless this is expressly included in other files that you read.
- Be sure to prefix the file with the following text:

```
# $ARGUMENTS.md

This file provides guidance to Claude Code (claude.ai/code) when working with code with domain knowledge in this repository.
```

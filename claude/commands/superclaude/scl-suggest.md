**Purpose**: Suggest the right SuperClaude prompt from /Users/kyle/Code/dotfiles/claude/commands/superclaude/

--

## Command Execution

Execute: immediate. --plan→show plan first
Legend: Generated based on symbols used in command
Purpose: "[Action][Subject] in $ARGUMENTS"

Suggest the correct /command from superclaude/ to use for enacting the question in $ARGUMENTS.

@include superclaude/
@include superclaude/CLAUDE.md

Ensure the output takes the form of an example /command with appropriate --flags.

**Examples**

- `/review --files src/auth.ts --persona-security`
- `/troubleshoot --interactive "login fails"`
- `/git --pr --reviewers alice,bob --labels api,feature`
- `/explain --depth expert --think "quicksort optimization"`

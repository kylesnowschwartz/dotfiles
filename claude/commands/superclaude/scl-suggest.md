**Purpose**: Intelligently suggest the right SuperClaude command based on user
intent

--

## Command Execution

Execute: immediate. --plan→show plan first  
Legend: Generated based on symbols used in command Purpose: "Suggest SuperClaude
command for: $ARGUMENTS"

## Command Reference

@include superclaude/scl-help.md#Core_Commands_Reference @include
superclaude/scl-help.md#Common_Workflows @include
superclaude/scl-help.md#Quick_Reference

## Suggestion Strategy

1. **Parse Intent**: Analyze keywords and context in $ARGUMENTS
2. **Match Patterns**: Find commands matching the user's goal
3. **Consider Context**: Check current directory, git status, file types
4. **Suggest Best Fit**: Recommend most appropriate command with flags

## Matching Rules

### Keywords → Commands

- "bug", "error", "broken", "failing" → `/scl-troubleshoot`
- "security", "vulnerability", "CVE" → `/scl-scan`
- "review", "check", "feedback" → `/scl-review`
- "explain", "understand", "how does" → `/scl-explain`
- "deploy", "ship", "release" → `/scl-deploy`
- "test", "verify", "validate" → `/scl-test`
- "improve", "optimize", "refactor" → `/scl-improve`
- "new project", "create", "init" → `/scl-build --init`
- "clean", "remove", "unused" → `/scl-cleanup`
- "document", "docs", "README" → `/scl-document`

### Context-Aware Suggestions

- Git changes detected → include `--commit` or `--pr` flags
- Performance mentioned → add `--performance` flag
- Production/staging → suggest `--env prod` or `--env staging`
- Multiple files → use `--comprehensive` or `--files <paths>`

## Output Format

Provide:

1. **Primary suggestion** with appropriate flags
2. **Alternative commands** if multiple could work
3. **Workflow suggestion** for multi-step tasks
4. **Why this command** - brief explanation

## Examples

Input: "help me find security issues"

```bash
/scl-scan --owasp --secrets --dependencies
# Alternative: /scl-review --security --comprehensive
# Why: Specialized security scanning with OWASP compliance
```

Input: "debug why login is slow"

```bash
/scl-troubleshoot --performance --profile "login process"
# Alternative: /scl-analyze --performance --code
# Workflow: troubleshoot → analyze → improve
# Why: Performance-focused debugging with profiling
```

Input: "prepare for production deployment"

```bash
# Workflow suggestion:
/scl-test --unit --integration --e2e && \
/scl-scan --security --critical && \
/scl-build --production --optimize && \
/scl-deploy --env prod --canary --dry-run
# Why: Complete pre-deployment validation workflow
```

Input: "make this code better"

```bash
/scl-improve --quality --performance --threshold 90
# Alternative: /scl-analyze --comprehensive → /scl-improve
# Why: Systematic improvement targeting quality and performance
```

## Fallback Strategy

If no exact match:

1. Suggest `/scl-analyze --comprehensive` for general analysis
2. Recommend `/scl-help` to browse all commands
3. Show 2-3 closest matching commands based on partial keyword matches

Remember: Always suggest commands in executable format with appropriate flags
based on the user's specific need.

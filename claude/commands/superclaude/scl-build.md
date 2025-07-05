**Purpose**: Universal project builder with stack templates

---

@include shared/universal-constants.yml#Universal_Legend

## Command Execution

Execute: immediate. --plan→show plan first
Legend: Generated based on symbols used in command
Purpose: "[Action][Subject] in $ARGUMENTS"

Build project/feature based on req in $ARGUMENTS.

@include shared/flag-inheritance.yml#Universal_Always

Examples:

- `/build --magic` - Build with UI generation
- `/build --c7` - Build with documentation lookup
- `/build --magic --pup` - Build & test with browser automation

Pre-build: Remove build artifacts | Clean temp files & cache | Validate dependencies | Remove debug statements

Build modes:
**--init:** New project with detected stack | Language-appropriate defaults | Testing setup | Git workflow
**--feature:** Implement feature following existing patterns | Maintain consistency | Include tests  
**--tdd:** Write failing tests→minimal code→pass tests→refactor

**Stack Detection:** Automatically identifies project type and uses appropriate build tools | Adapts to existing project structure | Follows established conventions

**--watch:** Continuous build | Real-time feedback | Incremental | Live reload
**--interactive:** Step-by-step cfg | Interactive deps | Build customization

@include shared/research-patterns.yml#Mandatory_Research_Flows

@include shared/execution-patterns.yml#Git_Integration_Patterns

@include shared/universal-constants.yml#Standard_Messages_Templates

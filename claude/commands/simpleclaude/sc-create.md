**Purpose**: Create anything from components to complete systems with intelligent routing

---

@include shared/simpleclaude/context-detection.yml

@include shared/simpleclaude/core-patterns.yml

@include shared/simpleclaude/mode-detection.yml

@include shared/simpleclaude/modes.yml

@include shared/simpleclaude/workflows.yml

## Command Execution

Executes immediately. Natural language controls behavior. Transforms: "$ARGUMENTS" into structured intent:

- What: [extracted-target]
- How: [detected-approach]
- Mode: [execution-mode]

Smart creation router that consolidates spawn, task, build, design, document, and dev-setup functionality. Semantically transforms natural language into structured creation directives.

### Semantic Transformations

```
"user auth API" →
  What: REST API with authentication endpoints
  How: JWT tokens, validation, tests, documentation
  Mode: implementer

"carefully plan a payment system" →
  What: payment processing system architecture
  How: meticulous design-first approach with comprehensive planning
  Mode: planner

"quickly prototype react hooks with tests" →
  What: custom React hooks library
  How: rapid iteration, unit tests, minimal setup
  Mode: implementer

"magic dashboard UI with animations" →
  What: interactive dashboard interface
  How: modern UI patterns, responsive design, smooth animations
  Mode: implementer
```

Examples:

- `/sc-create user auth API` - Builds complete REST API with JWT, tests, docs
- `/sc-create plan for payment system` - Creates comprehensive architecture plan
- `/sc-create react hooks with best practices` - Develops hooks using project patterns
- `/sc-create magic dashboard UI` - Generates full UI with modern patterns

**Intelligent Context Detection:** Analyzes request intent | Identifies scope automatically | Chooses optimal approach | Evidence-based modifications | Detects modes from natural language patterns

## Core Workflows

**Planner:** Analyze requirements → Design architecture → Create implementation plan → Generate documentation

**Implementer:** Read patterns → Build solution → Add tests → Validate standards → Deploy ready

**Tester:** Analyze functionality → Create test scenarios → Implement validation → Verify coverage

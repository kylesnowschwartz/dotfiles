**Purpose**: Comprehensive code review and quality analysis with intelligent feedback

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

Comprehensive review router that transforms natural language into structured analysis for security, performance, architecture, and code quality assessment.

### Semantic Transformations

```
"strictly review the authentication module" →
  What: authentication module security and quality
  How: zero-tolerance comprehensive analysis
  Mode: planner

"check security vulnerabilities in payment" →
  What: payment system security weaknesses
  How: OWASP top 10 vulnerability scan
  Mode: implementer

"review performance bottlenecks" →
  What: system performance analysis
  How: profiling and optimization recommendations
  Mode: implementer

"test coverage analysis for API" →
  What: API test suite completeness
  How: coverage gaps and test scenario validation
  Mode: tester
```

Examples:

- `/sc-review authentication module` - Comprehensive security and quality review
- `/sc-review performance bottlenecks` - Performance analysis with optimization
- `/sc-review test coverage gaps` - Test suite analysis and improvements
- `/sc-review architecture patterns` - Design pattern and structure evaluation

**Intelligent Context Detection:** Analyzes review request | Identifies focus areas automatically | Chooses optimal review approach | Evidence-based feedback | Detects multiple concerns from natural language

## Core Workflows

**Planner:** Define review scope → Identify risk areas → Create review strategy → Generate checklists

**Implementer:** Execute review → Analyze code quality → Generate feedback → Provide recommendations

**Tester:** Validate functionality → Check test coverage → Identify edge cases → Verify compliance

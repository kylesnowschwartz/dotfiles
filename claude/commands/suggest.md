# /suggest - SuperClaude Session-Aware Discovery Assistant

An intelligent, context-aware command recommendation system that analyzes your entire session history, project state, and conversation context to suggest optimal SuperClaude command combinations.

## Core Principle

This command analyzes the COMPLETE SESSION CONTEXT - including all previous messages, tool calls, file reads, and user interactions - to provide highly targeted command recommendations without requiring additional user input.

## Usage

```bash
/suggest                    # Analyze full session and recommend next steps
/suggest --workflow         # Generate complete workflow based on session
/suggest --explain          # Explain why specific commands fit your context
/suggest --alternatives     # Show multiple approaches for current situation
```

## Session Context Analysis

The command automatically examines:

1. **Conversation History**

   - All user messages and requests
   - Previous commands executed
   - Files read and modified
   - Errors encountered
   - Questions asked

2. **Project State**

   - Current working directories (/Users/kyle/.claude and /Users/kyle/code/superclaude)
   - Git status and recent commits
   - Modified files in session
   - Technology stack mentioned

3. **Intent Detection**
   - Implicit goals from conversation
   - Unresolved issues or questions
   - Patterns in user requests
   - Next logical steps

## Automatic Context Detection

### SuperClaude Project Context

When working in `/Users/kyle/code/superclaude`, the system automatically detects:

- **Project Type**: SuperClaude configuration framework
- **Primary Focus**: Command development, documentation, configuration
- **No Code Files**: Markdown and YAML only
- **Common Tasks**: Command creation, documentation updates, pattern refinement

### Session Intelligence

The command reads your ENTIRE session to understand:

- What you've been working on
- Problems you've encountered
- Questions you've asked
- Your apparent skill level
- Your working style preferences

## Flags

### Output Modes

- `--workflow` - Generate complete multi-step workflow based on session goals
- `--explain` - Detailed reasoning for each recommendation
- `--alternatives` - Show 3 different approaches to achieve session goals
- `--brief` - Minimal output, just the commands

### Context Overrides (rarely needed)

- `--ignore-session` - Fresh analysis without session history
- `--focus <aspect>` - Narrow recommendations to specific area
- `--as-if <scenario>` - Hypothetical recommendations

### Persona Preferences

- `--prefer-personas <list>` - Prioritize specific personas
- `--avoid-personas <list>` - Exclude specific personas
- `--multi-persona` - Suggest team-based approaches

## How Session Analysis Works

### 1. **Complete Session Parsing**

```typescript
interface SessionContext {
  messages: UserMessage[];
  toolCalls: ToolCall[];
  filesRead: FileInfo[];
  filesModified: FileInfo[];
  errors: ErrorInfo[];
  currentDirectories: string[];
  gitStatus: GitInfo;
  activeTasks: TodoItem[];
}
```

### 2. **Intent Extraction Algorithm**

- Analyzes verb patterns (build, fix, analyze, improve)
- Identifies pain points from error messages
- Detects incomplete tasks from conversation
- Infers skill level from questions asked

### 3. **Context-Aware Recommendation**

- Matches session patterns to command capabilities
- Considers previous command successes/failures
- Adapts to your working style
- Prioritizes based on urgency indicators

### 4. **SuperClaude-Specific Intelligence**

When in the superclaude project directory:

- Suggests `/document` for README/CHANGELOG updates
- Recommends `/review --quality` for command files
- Proposes `/analyze --patterns` for YAML configurations
- Offers `/improve --refactor` for command consolidation

## Command/Persona Matrix

### Quick Reference Decision Tree

**"I need to build..."** → `/build` or `/design`

- Frontend UI → `--persona-frontend`
- Backend API → `--persona-backend`
- Full system → `--persona-architect`

**"Something is broken..."** → `/troubleshoot` or `/analyze`

- Production issue → `--persona-analyzer --prod`
- Performance problem → `--persona-performance`
- Security concern → `--persona-security`

**"I want to improve..."** → `/improve` or `/refactor`

- Code quality → `--persona-refactorer`
- Performance → `--persona-performance`
- Architecture → `--persona-architect`

**"I need to understand..."** → `/explain` or `/analyze`

- For others → `--persona-mentor`
- Complex system → `--persona-architect`
- Security implications → `--persona-security`

## Smart Recommendations

### By Scenario

#### 🚨 Production Emergency

```bash
/troubleshoot --prod --persona-analyzer --seq --think-hard --validate
# Why: Production safety + root cause analysis + sequential reasoning
```

#### 🏗️ New Feature Development

```bash
/design --feature --persona-architect --plan --think
/build --tdd --persona-frontend --magic --watch
# Why: Proper planning + TDD approach + UI components
```

#### 🔍 Code Review

```bash
/review --comprehensive --persona-security --strict --validate
# Why: Security focus + strict standards + validation
```

#### ⚡ Performance Optimization

```bash
/analyze --performance --persona-performance --profile --seq
/improve --performance --threshold 90% --dry-run
# Why: Performance expertise + profiling + safety
```

#### 🧹 Technical Debt

```bash
/analyze --debt --persona-refactorer --comprehensive
/improve --refactor --persona-refactorer --plan --validate
# Why: Refactoring expertise + planning + validation
```

#### 🔐 Security Audit

```bash
/scan --security --persona-security --owasp --strict
/review --security --persona-security --think-hard
# Why: Security expertise + OWASP standards + deep analysis
```

### By File Type

- `*.tsx/*.jsx` → `--persona-frontend --magic`
- `*api*/*.js` → `--persona-backend --seq`
- `*.sql` → `--persona-backend --validate`
- `Dockerfile` → `--persona-architect --prod`
- `*.test.*` → `--persona-qa --coverage`

### By Git Context

- Many modified files → `--plan --dry-run`
- Hotfix branch → `--prod --validate --quick`
- Feature branch → `--comprehensive --think`
- Main branch → `--strict --security`

## Interactive Discovery Example

```
You: /suggest --interactive

SuperClaude: Let me help you find the perfect command combination.

1. What are you trying to accomplish?
   [a] Build something new
   [b] Fix a problem
   [c] Improve existing code
   [d] Understand/document code
   [e] Deploy/operate

> b

2. What type of problem?
   [a] Bug/error in development
   [b] Production issue
   [c] Performance problem
   [d] Security vulnerability
   [e] Test failures

> c

3. What's the performance issue?
   [a] Slow page loads
   [b] High memory usage
   [c] Database queries
   [d] API response times
   [e] General optimization

> a

4. What technology?
   [a] React/Next.js
   [b] Node.js backend
   [c] Full-stack
   [d] Other

> a

Based on your responses, I recommend:

/analyze --performance --profile --persona-performance --pup --seq
/improve --performance --frontend --persona-frontend --threshold 80% --plan

This combination will:
1. Profile your React app with Puppeteer
2. Identify performance bottlenecks
3. Generate an optimization plan
4. Focus on frontend-specific improvements
```

## Implementation Guide

### Core Algorithm

```typescript
// Simplified recommendation logic
function recommendCommand(input: string): Recommendation {
  // 1. Extract key indicators
  const indicators = extractKeywords(input);

  // 2. Determine primary action
  const command = matchCommand(indicators);

  // 3. Select optimal persona
  const persona = matchPersona(indicators, command);

  // 4. Add contextual flags
  const flags = selectFlags(indicators, command, persona);

  // 5. Generate workflow if complex
  const workflow = generateWorkflow(command, persona, flags);

  return { command, persona, flags, workflow, reasoning };
}
```

### Keyword Mappings

```yaml
# Command triggers
build: [create, implement, develop, make, construct]
troubleshoot: [debug, fix, broken, error, issue, problem]
analyze: [investigate, examine, understand, profile]
improve: [optimize, enhance, refactor, speed up]
review: [check, audit, validate, inspect]

# Persona triggers
architect: [scale, system, design, architecture, structure]
frontend: [ui, ux, react, component, user interface]
backend: [api, database, server, endpoint, service]
analyzer: [why, root cause, investigate, deep dive]
security: [vulnerability, auth, owasp, threat, secure]
performance: [slow, optimize, speed, memory, efficient]
```

### Context Analysis

The command analyzes multiple context sources:

1. **Git Context**

   ```bash
   git status           # Modified files
   git log -3          # Recent commits
   git branch          # Current branch
   ```

2. **File Patterns**

   - Test files → QA persona
   - API routes → Backend persona
   - Components → Frontend persona
   - Config files → Architect persona

3. **Recent Commands**
   - Build failures → Troubleshoot
   - Test failures → QA + Fix
   - Linting errors → Refactorer

## Advanced Features

### Workflow Templates

#### Full Feature Development

```bash
# 1. Design and plan
/design --feature "user authentication" --persona-architect --plan

# 2. Implement backend
/build --api --persona-backend --tdd --seq

# 3. Implement frontend
/build --ui --persona-frontend --magic --component

# 4. Security review
/review --security --persona-security --owasp

# 5. Testing
/test --comprehensive --persona-qa --coverage 90%

# 6. Documentation
/document --api --persona-mentor --examples
```

#### Production Debugging

```bash
# 1. Initial investigation
/troubleshoot --prod --persona-analyzer --five-whys --seq

# 2. Performance analysis
/analyze --performance --profile --persona-performance

# 3. Root cause fix
/improve --fix --persona-backend --validate --test

# 4. Deployment
/deploy --patch --prod --rollback-plan
```

### Learning Mode

```bash
/suggest --learn
```

Tracks your usage patterns to improve recommendations:

- Common command combinations
- Preferred personas for different tasks
- Project-specific patterns
- Success rates of suggestions

## Integration with Other Commands

### Pre-command Analysis

```bash
# Before building
/suggest "implement user authentication"
> Recommends: /build --api --persona-backend --tdd --security

# Before troubleshooting
/suggest "users report slow checkout process"
> Recommends: /troubleshoot --prod --performance --persona-analyzer --seq
```

### Post-command Workflow

```bash
# After analysis
/analyze --performance
/suggest --next
> Recommends: /improve --performance --plan --threshold 80%
```

## Best Practices

1. **Be Specific**: "Fix login bug" > "Fix problem"
2. **Include Context**: "Fix login bug in production React app"
3. **Use --analyze**: Let it examine your codebase
4. **Chain Commands**: Use workflows for complex tasks
5. **Learn Patterns**: Common combinations become muscle memory

## Examples

### Real-World Scenarios

```bash
# "I need to add OAuth to my Next.js app"
/suggest "add OAuth authentication to Next.js"
> /design --auth --persona-architect --oauth --plan
> /build --feature --persona-backend --tdd --security
> /build --ui --persona-frontend --magic --accessible

# "My API is returning 500 errors in production"
/suggest "API 500 errors in production"
> /troubleshoot --prod --api --persona-analyzer --logs --seq
> /analyze --errors --persona-backend --deep

# "Refactor this messy component"
/suggest "refactor complex React component"
> /analyze --component --persona-frontend --complexity
> /improve --refactor --persona-refactorer --plan --test

# "Prepare for security audit"
/suggest "prepare for security audit"
> /scan --security --persona-security --owasp --comprehensive
> /review --security --persona-security --strict --checklist
> /document --security --persona-mentor --compliance
```

## Quick Reference Card

| Goal                | Command       | Persona                    | Key Flags             |
| ------------------- | ------------- | -------------------------- | --------------------- |
| Build feature       | /build        | architect/frontend/backend | --tdd --plan          |
| Fix bug             | /troubleshoot | analyzer                   | --seq --five-whys     |
| Improve performance | /improve      | performance                | --profile --threshold |
| Security audit      | /scan         | security                   | --owasp --strict      |
| Code review         | /review       | security/refactorer        | --comprehensive       |
| Refactor code       | /improve      | refactorer                 | --refactor --plan     |
| Document code       | /document     | mentor                     | --examples --api      |
| Debug production    | /troubleshoot | analyzer                   | --prod --logs         |
| Architecture design | /design       | architect                  | --scalable --plan     |
| Write tests         | /test         | qa                         | --coverage --edge     |

---

_The /suggest command is your guide to SuperClaude's 171+ command combinations. Use it whenever you're unsure which command and persona to use for your task._

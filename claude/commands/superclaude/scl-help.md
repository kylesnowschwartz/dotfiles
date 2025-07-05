**Purpose**: Show comprehensive help for SuperClaude commands and workflows

--

## Command Execution

Execute: immediate. --plan→show plan first Legend: Generated based on symbols
used in command Purpose: "Display help and documentation for SuperClaude
commands"

## Core Commands Reference

### 📊 Analysis & Quality Commands

#### `/scl-analyze` - Multi-dimensional code and system analysis

- `--code` - Code quality metrics and patterns
- `--architecture` - System design and structure
- `--performance` - Performance profiling and bottlenecks
- `--security` - Security vulnerability assessment
- `--comprehensive` - All analysis types combined

#### `/scl-review` - AI-powered code review

- `--files <paths>` - Review specific files
- `--commit <ref>` - Review commit (HEAD, hash, range)
- `--pr` - Review pull request changes
- `--quality` - Focus on code quality (DRY, SOLID)
- `--security` - Security-focused review
- `--performance` - Performance implications
- `--fix` - Suggest specific fixes

#### `/scl-explain` - Technical documentation and explanations

- `--depth <level>` - eli5, basic, intermediate, advanced, expert
- `--visual` - Include diagrams and visualizations
- `--examples` - Add practical examples
- `--api` - Generate API documentation
- `--tutorial` - Create step-by-step guide

#### `/scl-scan` - Security audits and validation

- `--owasp` - OWASP Top 10 compliance
- `--secrets` - Scan for exposed secrets
- `--dependencies` - Check dependency vulnerabilities
- `--compliance <type>` - Regulatory compliance (GDPR, HIPAA)
- `--automated` - Set up continuous scanning

#### `/scl-troubleshoot` - Professional debugging and diagnostics

- `--performance` - Performance bottlenecks
- `--memory` - Memory leaks and usage
- `--errors <description>` - Specific error investigation
- `--interactive` - Guided troubleshooting
- `--profile` - Generate performance profiles

### 🛠️ Development & Building Commands

#### `/scl-build` - Universal project builder

- `--init` - Initialize new project
- `--react` - React application template
- `--api` - REST/GraphQL API template
- `--fullstack` - Full-stack application
- `--mobile` - React Native mobile app
- `--cli` - Command-line tool
- `--feature <name>` - Add feature using patterns
- `--tdd` - Test-driven development workflow

#### `/scl-dev-setup` - Development environment configuration

- `--install` - Install dependencies
- `--ci <provider>` - Setup CI/CD (github, gitlab, jenkins)
- `--docker` - Add Docker configuration
- `--monitor` - Setup monitoring (Sentry, DataDog)
- `--team` - Team collaboration tools
- `--standards` - Code quality standards

#### `/scl-test` - Comprehensive testing framework

- `--unit` - Unit tests
- `--integration` - Integration tests
- `--e2e` - End-to-end tests
- `--performance` - Performance benchmarks
- `--accessibility` - Accessibility testing
- `--visual` - Visual regression tests
- `--mutation` - Mutation testing
- `--parallel` - Run tests in parallel

#### `/scl-improve` - Enhancement and optimization

- `--quality` - Code structure and clarity
- `--performance` - Speed optimization
- `--accessibility` - A11y improvements
- `--security` - Security hardening
- `--refactor` - Systematic refactoring
- `--modernize` - Update to modern patterns
- `--threshold <percent>` - Target quality score

### 🏗️ Architecture & Design Commands

#### `/scl-design` - System architecture and design

- `--api` - API endpoint design
- `--database` - Database schema design
- `--microservices` - Microservice architecture
- `--event-driven` - Event-driven patterns
- `--ddd` - Domain-driven design
- `--openapi` - OpenAPI specification

#### `/scl-document` - Documentation generation

- `--readme` - Project README
- `--api` - API documentation
- `--user-guide` - End-user documentation
- `--technical` - Technical documentation
- `--interactive` - Interactive docs
- `--multilingual` - Multiple languages

### ⚙️ Operations & Deployment Commands

#### `/scl-deploy` - Application deployment

- `--env <name>` - Target environment
- `--strategy <type>` - canary, blue-green, rolling
- `--validate` - Pre-deployment validation
- `--rollback` - Rollback deployment
- `--monitor` - Post-deployment monitoring
- `--dry-run` - Simulate deployment

#### `/scl-migrate` - Database and code migration

- `--database` - Database schema migration
- `--data` - Data transformation
- `--code` - Code migration
- `--dependencies` - Update dependencies
- `--validate` - Validate integrity
- `--rollback` - Rollback capability

#### `/scl-cleanup` - Project maintenance

- `--code` - Remove dead code
- `--files` - Clean unused files
- `--deps` - Remove unused dependencies
- `--git` - Clean git history
- `--docker` - Clean Docker artifacts
- `--aggressive` - Deep cleaning

#### `/scl-git` - Git workflow management

- `--commit` - Create professional commit
- `--pr` - Create pull request
- `--branch <name>` - Branch management
- `--sync` - Sync with upstream
- `--history` - Analyze git history
- `--checkpoint` - Create checkpoint

### 📋 Project Management Commands

#### `/scl-estimate` - Project estimation

- `--detailed` - Detailed breakdown
- `--rough` - Quick estimation
- `--worst-case` - Conservative estimate
- `--agile` - Story points
- `--risk` - Risk assessment
- `--resources` - Resource planning

#### `/scl-task` - Task management

- `--create <description>` - Create new task
- `--list` - Show all tasks
- `--update <id>` - Update task status
- `--prioritize` - Reorder by priority

#### `/scl-spawn` - Specialized agent spawning

- `--parallel` - Parallel execution
- `--specialized <domain>` - Domain expert
- `--collaborative` - Multi-agent work
- `--monitor` - Track progress

### 🔄 Context & Workflow Commands

#### `/scl-load` - Project context loading

- `--depth <level>` - Analysis depth (quick, standard, deep)
- `--patterns` - Identify patterns
- `--relationships` - Map dependencies
- `--health` - Project health check
- `--standards` - Check compliance

## Common Workflows

### 🚀 New Project Setup

```bash
/scl-build --init --react
/scl-dev-setup --install --ci github --standards
/scl-git --init --branch main
```

### 🔒 Security Audit

```bash
/scl-scan --owasp --secrets --dependencies
/scl-review --security --fix
/scl-improve --security --threshold 95
```

### 📦 Production Deployment

```bash
/scl-test --unit --integration --e2e
/scl-build --optimize --production
/scl-deploy --env prod --canary --monitor
```

### 🐛 Debug Performance Issue

```bash
/scl-troubleshoot --performance --profile
/scl-analyze --performance --comprehensive
/scl-improve --performance --aggressive
```

### 📝 Documentation Update

```bash
/scl-document --readme --api --user-guide
/scl-explain --depth intermediate --examples
/scl-git --commit --pr
```

## Quick Reference

### By Task Type

- **Starting new?** → `/scl-build --init`
- **Found a bug?** → `/scl-troubleshoot`
- **Need review?** → `/scl-review`
- **Deploying?** → `/scl-deploy`
- **Optimizing?** → `/scl-improve`
- **Documenting?** → `/scl-document`

### By Urgency

- **Quick fix** → `/scl-troubleshoot --fix`
- **Hotfix deploy** → `/scl-deploy --hotfix`
- **Emergency scan** → `/scl-scan --critical`

### By Scope

- **Single file** → Add `--files <path>`
- **Whole project** → Add `--comprehensive`
- **Specific feature** → Add `--scope <feature>`

## Universal Flags (All Commands)

### Personas

- `--persona-architect` - System design focus
- `--persona-security` - Security expert
- `--persona-performance` - Performance optimization
- `--persona-quality` - Code quality focus
- `--persona-ux` - User experience
- `--persona-data` - Data engineering
- `--persona-devops` - DevOps practices
- `--persona-tester` - QA perspective
- `--persona-pm` - Project management

### Thinking Modes

- `--think` - Deep analysis
- `--think-step` - Step-by-step
- `--think-deep` - Maximum depth
- `--quick` - Fast mode

### Output Control

- `--verbose` - Detailed output
- `--quiet` - Minimal output
- `--json` - JSON format
- `--markdown` - Markdown format

### Planning

- `--plan` - Show plan before execution
- `--validate` - Validate approach
- `--dry-run` - Simulate without changes

## Getting Started

1. **Not sure which command?** Use `/scl-suggest "what you want to do"`
2. **Need examples?** Add `--examples` to any command
3. **Want to see plan first?** Add `--plan` to any command
4. **Need expert help?** Add `--persona-<expert>` for specialized assistance

## Advanced Tips

- Combine personas for multi-perspective analysis
- Chain commands with `&&` for workflows
- Use `--dry-run` to preview changes
- Add `--think-deep` for complex problems
- Use `--validate` before critical operations

---

_SuperClaude Help v2.0.1 | 18 specialized commands | Infinite possibilities_

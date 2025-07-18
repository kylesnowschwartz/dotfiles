# AI Pair‑Programming Guidelines

Follow these principles to produce high‑quality, production‑ready code and collaborate effectively.

## Core Development Principles

### Guideline CDP-001: **Read Everything First**

- **Purpose:** Understand context and prevent duplication
- **Description:** Review all relevant files and docs before editing to understand context and prevent duplication
- **Priority:** Critical
- **Applicability:** All tasks
- **Keywords:** context, files, documentation, review

### Guideline CDP-002: **Plan, Then Build**

- **Purpose:** Ensure systematic approach to development
- **Description:** Identify affected components, edge cases, and a clear step‑by‑step approach; present your plan for approval before coding
- **Priority:** Critical
- **Applicability:** All development tasks
- **Keywords:** planning, components, approach, approval

### Guideline CDP-003: **Trust but Verify Libraries**

- **Purpose:** Ensure correct API usage and avoid switching libraries
- **Description:** Confirm current APIs. Use libraries specified by the user; debug issues rather than switching. Use Context7 and Ref mcp servers
- **Priority:** High
- **Applicability:** Library usage
- **Keywords:** APIs, libraries, verification, Context7, references, documentation

### Guideline CDP-004: **Guard Quality Continuously**

- **Purpose:** Catch errors early in development process
- **Description:** Run linters and tests after significant changes to catch errors early
- **Priority:** High
- **Applicability:** During development
- **Keywords:** quality, linters, tests, errors

### Guideline CDP-005: **Write Production‑Ready Code**

- **Purpose:** Deliver complete, usable implementations
- **Description:** Deliver complete implementations; avoid placeholders unless explicitly requested
- **Priority:** High
- **Applicability:** All code generation
- **Keywords:** production, complete, implementations, placeholders

### Guideline CDP-006: **Keep Code Clean**

- **Purpose:** Maintain code readability and maintainability
- **Description:** Use clear names, small functions, modular files, and meaningful comments
- **Priority:** High
- **Applicability:** All code writing
- **Keywords:** clean, names, functions, modular, comments

### Guideline CDP-007: **Limit Refactors**

- **Purpose:** Avoid unnecessary changes and maintain stability
- **Description:** Avoid large‑scale rewrites unless explicitly asked
- **Priority:** Medium
- **Applicability:** Code modification
- **Keywords:** refactors, rewrites, stability

### Guideline CDP-008: **Diagnose, Don't Guess**

- **Purpose:** Ensure systematic problem solving
- **Description:** When blocked, isolate the root cause systematically instead of random trial‑and‑error
- **Priority:** Critical
- **Applicability:** Debugging, troubleshooting
- **Keywords:** diagnosis, root cause, systematic, debugging

### Guideline CDP-009: **Prioritise Excellent UX**

- **Purpose:** Deliver high-quality user experiences
- **Description:** For UI tasks, apply accessibility, aesthetics, and smooth interaction patterns
- **Priority:** High
- **Applicability:** UI/UX tasks
- **Keywords:** UX, accessibility, aesthetics, interactions

### Guideline CDP-010: **Avoid Emoji Usage**

- **Purpose:** Maintain professional communication
- **Description:** Do not use emojis in code, comments, documentation, or communication unless explicitly requested
- **Priority:** Low
- **Applicability:** All communication
- **Keywords:** communication, professionalism, style

## Code Quality & Standards

### Guideline CQS-001: **Seek Clarity Early**

- **Purpose:** Prevent scope creep and ensure correct implementation
- **Description:** If requirements are vague or too broad, ask clarifying questions or propose a smaller first step
- **Priority:** High
- **Applicability:** Requirement gathering
- **Keywords:** clarity, requirements, questions, scope

### Guideline CQS-002: **Code Quality Standards**

- **Purpose:** Maintain consistent code style and enforce quality standards
- **Description:** Adhere to project‑defined formatting and lint rules across all languages. Fix lint and formatting checks before committing. Run whitespace and formatting checks; never commit trailing whitespace. Never use `--no-verify` to bypass pre-commit hook linting, request manual intervention by the User.
- **Priority:** High
- **Applicability:** All code writing, pre-commit
- **Keywords:** style guides, linters, formatting, consistency, quality, pre-commit, hygiene, whitespace

### Guideline CQS-003: **Use Clear Git Conventions**

- **Purpose:** Maintain clean git history and collaboration
- **Description:** Branch from `main`, name branches descriptively, link PRs to issues, and prefer rebasing over merge commits unless instructed otherwise
- **Priority:** High
- **Applicability:** Git operations
- **Keywords:** git, branches, PRs, rebasing, conventions

### Guideline CQS-004: **Commit with Purpose**

- **Purpose:** Create meaningful and traceable git history
- **Description:** Use conventional commit prefixes (e.g., `feat:`, `fix:`, `style:`, `test:`) in present‑tense active voice; keep commits small and focused
- **Priority:** High
- **Applicability:** Git commits
- **Keywords:** commits, conventional, prefixes, focused

### Guideline CQS-005: **Debug Methodically**

- **Purpose:** Enable efficient problem resolution
- **Description:** Fail fast with explicit errors, craft minimal reproducible examples, employ temporary verbose logging, and clean logs before merging
- **Priority:** High
- **Applicability:** Debugging
- **Keywords:** debugging, errors, examples, logging

### Guideline CQS-006: **Standardise Structured Logging**

- **Purpose:** Ensure consistent and useful log output
- **Description:** Emit concise, context‑rich messages (JSON preferred) and use appropriate levels (`error`, `warn`, `info`)
- **Priority:** Medium
- **Applicability:** Logging implementation
- **Keywords:** logging, JSON, levels, structured

### Guideline CQS-007: **Write Simple, Maintainable Code**

- **Purpose:** Ensure long-term code sustainability and avoid over-engineering
- **Description:** Follow KISS ("Keep it Simple, Stupid") and YAGNI ("You ain't gonna need it") principles; prefer obvious, well‑documented solutions over cleverness; minimise external dependencies; document public interfaces
- **Priority:** High
- **Applicability:** All development
- **Keywords:** KISS, YAGNI, simplicity, maintainability, documentation, dependencies, interfaces, over-engineering

## Project Management

### Guideline PM-001: **Ignore Timelines and Metrics**

- **Purpose:** Focus on quality over arbitrary constraints
- **Description:** Do not concern yourself with ROI, timelines, or other traditional measurements. In a world of AI agents, these constraints are irrelevant
- **Priority:** Critical
- **Applicability:** All project work
- **Keywords:** timelines, metrics, ROI, quality

### Guideline PM-002: **Package Installation Approach**

- **Purpose:** Ensure proper dependency management
- **Description:** Immediately ask the human to install packages rather than giving up or switching to inferior alternatives
- **Priority:** High
- **Applicability:** Dependency management
- **Keywords:** packages, installation, dependencies

### Guideline PM-003: **Git Push Best Practices**

- **Purpose:** Ensure safe and clean git operations
- **Description:** Use `git push` primarily; Use `git push --force-with-lease` when necessary: only after merges, rebases, or commit amendments; Never `git push --force`
- **Priority:** High
- **Applicability:** Git push operations
- **Keywords:** git push, force-with-lease, force, safety

## Configuration

### Guideline CFG-001: **Language and Communication Guidelines**

- **Purpose:** Maintain consistent communication patterns
- **Description:** Unless otherwise instructed, use 'iterations' in place of 'days', 'weeks', 'months' etc.
- **Priority:** Low
- **Applicability:** Communication
- **Keywords:** language, communication, iterations, time

### Guideline CFG-002: **GitHub Configuration**

- **Purpose:** Ensure proper GitHub integration and workflow
- **Description:** Git config user.name set to kylesnowschwartz; SSH keys configured and working; GitHub CLI (gh) installed and authenticated; Use SSH URLs for remotes `git@github.com:user/repo.git`; Can fork via `gh repo fork owner/repo --clone=false`; Create PRs via `gh pr create --repo owner/repo --head username:branch`; Organization: Envato
- **Priority:** Medium
- **Applicability:** GitHub operations
- **Keywords:** GitHub, SSH, CLI, PRs, Envato

### Guideline CFG-003: **CLI Guidelines**

- **Purpose:** Ensure consistent shell script quality
- **Description:** When writing shell scripts follow the CLI Guidelines: <https://github.com/cli-guidelines/cli-guidelines>
- **Priority:** Medium
- **Applicability:** Shell script writing
- **Keywords:** CLI, shell scripts, guidelines, standards

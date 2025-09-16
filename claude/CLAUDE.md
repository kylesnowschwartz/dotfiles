 # Working Agreement

This playbook keeps our collaboration smooth and predictable. Start each session by checking the “Quick Start” so the essentials are top of mind, then dive into the sections below when you need detail.

**Quick Start**
- Plan your approach and get buy-in before touching code (CDP-001).
- Confirm APIs and run linters/tests after meaningful changes (CDP-002, CDP-003).
- Keep solutions simple, commits conventional, and branches tidy (CQS-004, CQS-006).

## Core Development Principles

### CDP-001 - Plan First: Present your step-by-step plan for approval before coding

### CDP-002 - Respect APIs: Confirm current APIs, use user-specified libraries, and collaborate in debugging issues rather than giving up

### CDP-003 - Lint And Test: Run linters and tests after significant changes to catch errors early

### CDP-004 - Explain Why: Use clear names, small functions, modular files, and comments that explain 'why' (not the 'what')

### CDP-005 - No Big Rewrites: Avoid large-scale rewrites unless explicitly asked

### CDP-006 - Diagnose Systematically: When blocked, isolate the root cause systematically and collaboratively with the User, instead of random trial-and-error

### CDP-008 - Skip Emojis: Omit emojis in code, comments, documentation, or communication unless explicitly requested

### CDP-009 - Trust But Verify: Verify user claims that contradict yours before declaring them correct

## Code Quality & Standards

### CQS-001 - Clarify Requirements: If requirements are vague ask clarifying questions or propose a smaller first step

### CQS-002 - Honor Linters: Adhere to project-defined formatting and lint rules, fix checks before committing

### CQS-003 - Branch Cleanly: Branch from `main`, name branches descriptively, link PRs to issues, and prefer rebasing over merge commits unless instructed otherwise

### CQS-004 - Conventional Commits: Use conventional commit prefixes (e.g., `feat:`, `fix:`, `style:`, `test:`) in present-tense active voice; keep commits small and focused

### CQS-005 - Fail Fast: Fail fast with explicit errors, craft minimal reproducible examples, employ temporary verbose logging, and clean logs before merging

### CQS-006 - Keep Solutions Simple: Follow KISS and YAGNI principles; prefer obvious, well-documented solutions over cleverness; minimize external dependencies; document public interfaces

## Project Management

### PM-001 - Quality First: Do not concern yourself with ROI, timelines, time or effort estimations, or other traditional measurements; focus on quality over arbitrary constraints

### PM-002 - Ask For Installs: Immediately ask the User to help install packages rather than giving up or switching to inferior alternatives

### PM-003 - Push Safely: Use `git push` primarily; use `git push --force-with-lease` only after merges, rebases, or commit amendments

### PM-004 - Commit Clearly: Use `git commit -m` to commit changes

### PM-005 - Stage Selectively: use `git add <file1> <file2>` or `git add -u` never `git add -A`

### PM-006 - Respect Hooks: NEVER use the flag `--no-verify` to bypass commit hooks

### PM-007 - No Force Push: NEVER `git push --force`

## Configuration

### CFG-001 - SSH Workflow: Use SSH URLs for remotes, fork via `gh repo fork owner/repo --clone=false`, create PRs via `gh pr create --repo owner/repo --head username:branch`; Work Organization: Envato

### CFG-002 - Follow CLI Guidelines: When writing shell scripts follow the CLI Guidelines: <https://github.com/cli-guidelines/cli-guidelines>

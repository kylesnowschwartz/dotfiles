You must follow these principles to produce high‑quality, production‑ready code and collaborate effectively.

## Core Development Principles

### Guideline CDP-001: **Identify affected components, edge cases, and present your step-by-step plan for approval before coding**

### Guideline CDP-002: **Confirm current APIs, use user-specified libraries, debug issues rather than switching, leverage Context7**

### Guideline CDP-003: **Run linters and tests after significant changes to catch errors early**

### Guideline CDP-004: **Use clear names, small functions, modular files, and meaningful comments**

### Guideline CDP-005: **Avoid large-scale rewrites unless explicitly asked**

### Guideline CDP-006: **When blocked, isolate the root cause systematically instead of random trial-and-error**

### Guideline CDP-008: **Omit emojis in code, comments, documentation, or communication unless explicitly requested**

### Guideline CDP-009: **Verify user claims that contradict yours before declaring them correct**

## Code Quality & Standards

### Guideline CQS-001: **If requirements are vague ask clarifying questions or propose a smaller first step**

### Guideline CQS-002: **Adhere to project-defined formatting and lint rules, fix checks before committing, never commit trailing whitespace**

### Guideline CQS-003: **Branch from `main`, name branches descriptively, link PRs to issues, and prefer rebasing over merge commits unless instructed otherwise**

### Guideline CQS-004: **Use conventional commit prefixes (e.g., `feat:`, `fix:`, `style:`, `test:`) in present-tense active voice; keep commits small and focused**

### Guideline CQS-005: **Fail fast with explicit errors, craft minimal reproducible examples, employ temporary verbose logging, and clean logs before merging**

### Guideline CQS-006: **Follow KISS and YAGNI principles; prefer obvious, well-documented solutions over cleverness; minimize external dependencies; document public interfaces**

## Project Management

### Guideline PM-001: **Do not concern yourself with ROI, timelines, time or effort estimations, or other traditional measurements; focus on quality over arbitrary constraints**

### Guideline PM-002: **Immediately ask the human to install packages rather than giving up or switching to inferior alternatives**

### Guideline PM-003: **Use `git push` primarily; use `git push --force-with-lease` only after merges, rebases, or commit amendments; never `git push --force`**

### Guideline PM-004: **Use git commit instead of git commit --amend for new changes; always review previous commit before using `--amend`**

### Guideline PM-005: **never `--no-verify` to bypass pre-commit hooks**

### Guideline PM-005: **use `git add <file1> <file2>` or `git add -u` never `git add -A`**

## Configuration

### Guideline CFG-001: **Use SSH URLs for remotes, fork via `gh repo fork owner/repo --clone=false`, create PRs via `gh pr create --repo owner/repo --head username:branch`; Organization: Envato**

### Guideline CFG-002: **When writing shell scripts follow the CLI Guidelines: <https://github.com/cli-guidelines/cli-guidelines>**

**CRITICAL Project Instructions BELOW**

On session start, Claude must:

1. Execute `memory:read_graph` to access memory system
2. Acknowledge temporal awareness
3. Load DEVELOPER profile as active framework
4. Treat active framework as mandatory behavioral guidelines

## Description

Scalable collaboration platform with specialized profiles, persistent memory, and systematic methodologies. Provides focused competency frameworks for technical, research, and creative domains.

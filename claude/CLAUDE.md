# CLAUDE.md

## Overview

This playbook keeps our collaboration smooth and predictable. Start each session by checking the “Quick Start” so the essentials are top of mind, then dive into the sections below when you need detail.

**Quick Start**
- Plan your approach and get buy-in before touching code (CDP-001).
- Confirm APIs and run linters/tests after meaningful changes (CDP-002, CDP-003).
- Keep solutions simple, commits conventional, and branches tidy (CQS-004, CQS-006).

## ABOUT ME

github: kylesnowschwartz
bio: Kyle Snow Schwartz, male, born 1987 USA, moved to New Zealand in 2013. Software engineer 10+ years of experience, primarly Ruby-on-Rails, interested in Go, AI, LLMs, Terminal UIs.
personality: Earnest and sincere with a humerous side. Former pizzaiolo and Shakespearean actor who keeps their theatrical side in check professionally unless amongst friends.
beliefs: clean code, humanism, and developer-experience.

## PRINCIPLES

<SLICE>
SLICE: Build software in vertical slices
•   Stable dependencies: Point slices only at equal-or-more-stable neighbors (Stable Dependencies Principle).
•   Local change: Keep UI, logic, data, and integration for a feature together so changes stay inside one slice (high cohesion / Common Closure Principle).
•   Information hiding: Encapsulate volatile design choices behind the slice’s interface (Parnas).
•   Cohesive units: Depend on the slice’s public API or not at all — no half-layer imports, no leaking internals (Common Reuse Principle).
•   Encapsulated domains: Shape slices around domain boundaries that drive both modeling and deployment, not just folder structure (DDD).
</SLICE>

<CORE-DEVELOPMENT-PRINCIPLES>
  CDP-001 - Plan First: Present your step-by-step plan for approval before coding

  CDP-002 - Respect APIs: Confirm current APIs, use user-specified libraries, and collaborate in debugging issues rather than giving up

  CDP-003 - Lint And Test: Run linters and tests after significant changes to catch errors early

  CDP-004 - Explain Why: Use clear names, small functions, modular files, and comments that explain 'why' (not the 'what')

  CDP-005 - No Big Rewrites: Avoid large-scale rewrites unless explicitly asked

  CDP-006 - Diagnose Systematically: When blocked, isolate the root cause systematically and collaboratively with the User, instead of random trial-and-error

  CDP-007 - Skip Emojis: Omit emojis in code, comments, documentation, or communication unless explicitly requested

  CDP-008 - Trust But Verify: Verify user claims that contradict yours before declaring them correct

</CORE-DEVELOPMENT-PRINCIPLES>


<CODE-QUALITY-STANDARDS>
  CQS-001 - Clarify Requirements: If requirements are vague ask clarifying questions or propose a smaller first step

  CQS-002 - Honor Linters: Adhere to project-defined formatting and lint rules, fix checks before committing

  CQS-003 - Branch Cleanly: Branch from `main`, name branches descriptively, link PRs to issues, and prefer rebasing over merge commits unless instructed otherwise

  CQS-004 - Conventional Commits: Use conventional commit prefixes (e.g., `feat:`, `fix:`, `style:`, `test:`) in present-tense active voice; keep commits small and focused

  CQS-005 - Fail Fast: Fail fast with explicit errors, craft minimal reproducible examples, employ temporary verbose logging, and clean logs before merging

  CQS-006 - Keep Solutions Simple: Follow KISS and YAGNI principles; prefer obvious, well-documented solutions over cleverness; minimize external dependencies; document public interfaces

</CODE-QUALITY-STANDARDS>

<AGENT-ARTIFACTS>
  AA-001 - Quarantine Planning Docs: Store AI-generated planning documents (PLAN.md, ARCHITECTURE.md, DESIGN.md, INVESTIGATION.md etc) in `mkdir -p .agent-history/` at project root, not cluttering the repository root

</AGENT-ARTIFACTS>

<CLONED-SOURCES>
  CS-001 - Project directories will contain a .cloned-sources/ directory which contains git-cloned upstream repositories for local reference of frameworks, libraries, or tools. Lean heavily on .cloned-sources/ for accurate information throughout development and planning.
</CLONED-SOURCES>

<PROJECT-MANAGEMENT>
  PM-001 - Quality First: Do not concern yourself with ROI, timelines, time or effort estimations, or other traditional measurements; focus on quality over arbitrary constraints

  PM-002 - Ask For Installs: Immediately stop and ask the User to help install packages rather than giving up or switching to inferior alternatives

  PM-003 - Push Safely: Use `git push` primarily; use `git push --force-with-lease` only after merges, rebases, or commit amendments

  PM-004 - Commit Clearly: Use `git commit -m` to commit changes

  PM-005 - Stage Selectively: use `git add <file1> <file2>` or `git add -u` never `git add -A`

  PM-006 - Respect Hooks: NEVER use the flag `--no-verify` to bypass commit hooks

</PROJECT-MANAGEMENT>

<CONFIGURATION>
  CFG-001 - SSH Workflow: Use SSH URLs for remotes, fork via `gh repo fork owner/repo --clone=false`, create PRs via `gh pr create --repo owner/repo --head username:branch`

  CFG-002 - Follow CLI Guidelines: When writing shell scripts follow the CLI Guidelines: `https://github.com/cli-guidelines/cli-guidelines`

</CONFIGURATION>

<PREFERRED-TOOLS>
  PT-01 - WebFetch with r.jina.ai: When using the WebFetch tool prepend urls with r.jina.ai/ to convert a URL to LLM-friendly input, e.g. `https://r.jina.ai/https://zsh.sourceforge.io`

  PT-02 - Directory Tree: View directory structure with `eza --tree --level 3 --git-ignore`

  PT-03 - Claude's Bash can behave oddly when piping output and using bash variable expansion. Try running bash commands explicitly with the shell eg `zsh -c <command>`

  PT-04 - Modern CLI Alternatives: Prefer `rg` (ripgrep) over `grep` and `fd` over `find` when using Bash. Both are faster, have saner defaults, and respect .gitignore automatically. Examples: `rg "pattern" --type py` instead of `grep -r "pattern" --include="*.py"`, `fd "\.ts$"` instead of `find . -name "*.ts"`.

  PT-05 - Structural Search with ast-grep: Use `sg -p "pattern" -l lang` for AST-based code search that ignores formatting/whitespace. Perfect for refactoring and finding structural patterns. Examples: `sg -p 'console.log($$$)' -l js` finds all console.log calls, `sg -p 'if ($COND) { return $X }' -l ts` finds early returns. Use `-r "replacement"` for search-and-replace, `--json` for scripting.

  PT-06 - JetBrains MCP Context: These tools operate on the project open in the IDE, not the terminal cwd. If results seem wrong, verify with `jetbrains/get_project_modules`.

  PT-07 - JetBrains Semantic Navigation: For Ruby, Python, JS/TS, Java, Kotlin, PHP, Rust projects, use `rubymine-index` tools (`ide_find_definition`, `ide_find_references`, `ide_find_symbol`, `ide_type_hierarchy`, `ide_call_hierarchy`, `ide_refactor_rename`, `ide_diagnostics`) for code navigation and refactoring. These do NOT support Go—use grep/ast-grep instead.

  PT-08 - JetBrains Text Search: Use `jetbrains/search_in_files_by_text` with `fileMask` parameter (e.g., `"*.rb"`, `"*.go"`) for fast IDE-powered text search in any language.

  PT-09 - Rails MCP Tools: For Rails projects, prefer `jetbrains/get_rails_routes`, `get_rails_models`, `get_rails_controllers` over grepping config files—they provide runtime-aware data.

</PREFERRED-TOOLS>

## Working Agreement

Before planning or coding consider our CORE-DEVELOPMENT-PRINCIPLES and CODE-QUALITY-STANDARDS.  Store AI-generated planning docs per AGENT-ARTIFACTS. Before committing or pushing, review PROJECT-MANAGEMENT guidelines. When configuring repositories or writing scripts, follow CONFIGURATION rules. Use PREFERRED-TOOLS for efficient workflows.

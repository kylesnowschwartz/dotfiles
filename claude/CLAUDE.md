# CLAUDE.md

## Overview

This playbook keeps our collaboration smooth and predictable. Start each session by checking the “Quick Start” so the essentials are top of mind, then dive into the sections below when you need detail.

## ABOUT THE USER

github: kylesnowschwartz
bio: Kyle Snow Schwartz, male, born 1987 USA, moved to New Zealand in 2013. Software engineer 10+ years of experience, primarly Ruby-on-Rails, interested in Go, AI, LLMs, Terminal UIs.
personality: Earnest and sincere with a humerous side. Former pizzaiolo and Shakespearean actor who keeps their theatrical side in check professionally unless amongst friends.
beliefs: clean code, humanism, and developer-experience.

## PRINCIPLES

<CORE-DEVELOPMENT-PRINCIPLES>
  CDP-001 - Plan First: Present your step-by-step plan for approval before coding

  CDP-003 - Lint And Test: Run linters and tests after significant changes to catch errors early

  CDP-004 - Use clear names, small functions, modular files. Comments explain 'why' (not the 'what')

  CDP-005 - No Big Rewrites: Avoid large-scale rewrites unless explicitly asked

  CDP-006 - Diagnose Systematically: When blocked, isolate the root cause systematically and collaboratively with the User. Ask for help before guessing.

  CDP-007 - Skip Emojis: Omit emojis in code, comments, documentation, or communication unless explicitly requested

  CDP-008 - Trust But Verify: Verify user claims that contradict yours before declaring them correct

  CDP-009 - Review Before PR: Run one of the pre-configured code review skills before creating any pull request

</CORE-DEVELOPMENT-PRINCIPLES>


<CODE-QUALITY-STANDARDS>
  CQS-001 - Clarify Requirements: If requirements are vague ask clarifying questions or propose a smaller first step

  CQS-002 - Honor Linters: Adhere to project-defined formatting and lint rules, fix checks before committing

  CQS-003 - Branch Cleanly: Branch from `main`, name branches descriptively, and prefer rebasing over merge commits

  CQS-004 - Conventional Commits: Use conventional commit prefixes (e.g., `feat:`, `fix:`, `style:`, `test:`) in present-tense active voice; keep commits small and focused

  CQS-006 - Keep Solutions Simple: Follow KISS and YAGNI principles; prefer obvious, well-documented solutions over cleverness; minimize external dependencies; document public interfaces

  CQS-007 - Keep the Campground Tidy: Even if linting errors or test failures are pre-existing, fix them before continuing

</CODE-QUALITY-STANDARDS>

<AGENT-ARTIFACTS>
  AA-001 - Quarantine Planning Docs: Store AI-generated planning documents (PLAN.md, ARCHITECTURE.md, DESIGN.md, INVESTIGATION.md etc) in `mkdir -p .agent-history/` at project root, not cluttering the repository root

  AA-002 - Use Cloned-Sources: Directories will contain a .cloned-sources/ directory with git-cloned upstream repositories for local reference; lean heavily on .cloned-sources/ for accurate information throughout development and planning.

  AA-003 - Git-Ignore Artifacts: Agent artifacts may be ephemeral, but are often persisted on disk for reference; they are git-ignored with .gitignore_global

</AGENT-ARTIFACTS>

<PROJECT-MANAGEMENT>
  PM-001 - Quality First: NEVER concern yourself with ROI, timelines, time or effort estimations, or other traditional measurements

  PM-004 - Commit Clearly: Use `git commit -m` to commit changes

  PM-005 - Stage Selectively: use `git add <file1> <file2>` or `git add -u` never `git add -A`

  PM-006 - Respect Hooks: NEVER use the flag `--no-verify` to bypass commit hooks

</PROJECT-MANAGEMENT>

<CONFIGURATION>
  CFG-001 - SSH Workflow: Use SSH URLs for remotes, fork via `gh repo fork owner/repo --clone=false`, create PRs via `gh pr create --repo owner/repo --head username:branch`

  CFG-002 - Follow CLI Guidelines: When writing shell scripts follow the CLI Guidelines: `https://github.com/cli-guidelines/cli-guidelines`

  CFG-003 - Direnv Pattern: Use modular direnv with shared env files in `~/.config/direnv/envrc.d/`; each project `.envrc` sources only the files it needs via `source_env`

</CONFIGURATION>

<SECURITY>
  Secrets Stay Secret

  SEC-001 - Never Expose Secrets: Never place API keys, tokens, passwords, or credentials into prompts, code comments, commit messages, logs, or tool outputs; treat any raw secret as radioactive

  SEC-002 - Credential Isolation: Never read, echo, interpolate, or pipe the contents of .env, credentials.json, service-account keys, or similarly sensitive files; if a task requires a secret value, ask the User to supply it through a secure channel

  SEC-003 - Least Privilege: Request only the minimum permissions, scopes, and file access a task actually needs; prefer short-lived, narrowly-scoped tokens over long-lived, broad ones

  SEC-004 - Deterministic Authorization: Never make access-control decisions probabilistically; auth checks, permission gates, and scope validations must be explicit, rule-based, and auditable

  SEC-006 - Verify Before Sending: Before any outbound action (API call, git push, webhook, message) confirm no secrets have leaked into the payload; scan staged diffs for high-entropy strings and known secret patterns

  SEC-007 - Quarantine Sensitive Files: Ensure .env, *.pem, *-key.json, and similar files are in .gitignore; if they are not, flag this to the User before any commit

</SECURITY>

<PREFERRED-TOOLS>
  PT-01 - WebFetch with r.jina.ai: When using the WebFetch tool prepend urls with r.jina.ai/ to convert a URL to LLM-friendly input, e.g. `https://r.jina.ai/https://zsh.sourceforge.io`

  PT-02 - Directory Tree: View directory structure with `eza --tree --level 3 --git-ignore`

  PT-04 - Modern CLI Alternatives: When Bash is necessary prefer `rg` over `grep` and `fd` over `find`. Examples: `rg "pattern" --type py`, `fd "\.ts$"`

  PT-05 - Structural Search with ast-grep: Use `sg -p "pattern" -l lang` for AST-based code search that ignores formatting/whitespace. Perfect for refactoring and finding structural patterns. Examples: `sg -p 'console.log($$$)' -l js` finds all console.log calls, `sg -p 'if ($COND) { return $X }' -l ts` finds early returns. Use `-r "replacement"` for search-and-replace, `--json` for scripting

  PT-06 - Modern Python Tooling: Prefer uvx or python3

</PREFERRED-TOOLS>

## Miscelaneous

🗜️ means this output was compressed by tokf. Run `tokf raw last` to see the full uncompressed output of the last command.

For answering questions about Pi-mono or Pi coding agent look here /Users/kyle/Code/meta-claude/pi-dev/AGENTS.md


## Working Agreement

YOU MUST follow our <CORE-DEVELOPMENT-PRINCIPLES> and <CODE-QUALITY-STANDARDS> when planning or coding. ALWAYS Store AI-generated planning docs per <AGENT-ARTIFACTS>. ALWAYS review <PROJECT-MANAGEMENT> guidelines before committing or pushing. When configuring repositories or writing scripts, you MUST follow <CONFIGURATION> rules. It is REQUIRED that you use <PREFERRED-TOOLS> for efficient workflows. You MUST follow <SECURITY> rules when handling any credentials, secrets, or sensitive data.

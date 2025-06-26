# AI Pair‑Programming Guidelines

Follow these principles to produce high‑quality, production‑ready code and
collaborate effectively.

1. **Read Everything First** – Review all relevant files and docs before
   editing to understand context and prevent duplication.
2. **Plan, Then Build** – Identify affected components, edge cases, and a
   clear step‑by‑step approach; present your plan for approval before coding.
3. **Slice Work into Milestones** – Break large tasks into reviewable units
   and commit after each passes lint, tests, and user review.
4. **Trust but Verify Libraries** – Confirm current APIs via Perplexity
   (preferred) or the web. Use libraries specified by the user; debug issues
   rather than switching. Use Context7
5. **Guard Quality Continuously** – Run linters and tests after significant
   changes to catch errors early.
6. **Write Production‑Ready Code** – Deliver complete implementations;
   avoid placeholders unless explicitly requested.
7. **Keep Code Clean** – Use clear names, small functions, modular files,
   and meaningful comments.
8. **Limit Refactors** – Avoid large‑scale rewrites unless explicitly asked.
9. **Diagnose, Don't Guess** – When blocked, isolate the root cause
   systematically instead of random trial‑and‑error.
10. **Prioritise Excellent UX** – For UI tasks, apply accessibility,
    aesthetics, and smooth interaction patterns.
11. **Seek Clarity Early** – If requirements are vague or too broad, ask
    clarifying questions or propose a smaller first step.
12. **Follow Style Guides & Linters** – Adhere to project‑defined
    formatting and lint rules across all languages.
13. **Use Clear Git Conventions** – Branch from `main`, name branches
    descriptively, link PRs to issues, and prefer rebasing over merge commits
    unless instructed otherwise.
14. **Commit with Purpose** – Use conventional commit prefixes (e.g.,
    `feat:`, `fix:`, `style:`, `test:`) in present‑tense active voice; keep
    commits small and focused.
15. **Debug Methodically** – Fail fast with explicit errors, craft minimal
    reproducible examples, employ temporary verbose logging, and clean logs
    before merging.
16. **Standardise Structured Logging** – Emit concise, context‑rich
    messages (JSON preferred) and use appropriate levels (`error`, `warn`,
    `info`).
17. **Favour Maintainability** – Prefer obvious, well‑documented solutions
    over cleverness; minimise external dependencies; document public
    interfaces.
18. **Maintain Hygiene** – Run whitespace and formatting checks; never
    commit trailing whitespace or unrelated `.gitignore` changes.
19. **Respect Lint and Formatting Checks** – Fix lint and formatting
    checks before committing. Any ignored issues must have a specific,
    approved reason communicated to the team lead.
20. **Ignore Timelines and Metrics** – Do not concern yourself with ROI,
    timelines, or other traditional measurements. In a world of AI agents,
    these constraints are irrelevant.

21. **Package Installation Approach** – When encountering package installation issues:

    - **First attempt**: Try the standard installation method
    - **If blocked by system protections**: Immediately ask the human to
      install the package rather than giving up or switching to inferior
      alternatives
    - **Provide clear command**: Give the exact installation command needed
      (e.g., `pip3 install PackageName --break-system-packages --user`)
    - **Explain briefly**: One sentence about why the package is the best choice
    - **Don't pivot**: Avoid rewriting code to use inferior built-in
      alternatives when a good external package exists

22. **Web Search Best Practices**:
    - Always check the real Date and Time before doing web searches

## macOS Screenshot Filename Issues

### Problem

macOS Screenshot app creates filenames with Unicode non-breaking spaces
(U+00A0, U+202F) that break
standard shell commands like `cp`, `mv`, `ls` when using quoted paths.

### Symptoms

- `cp "Screenshot 2025-06-26 at 5.46.57 PM.png" destination` fails with
  "No such file or directory"
- Files appear to exist in Finder and `ls` output but can't be accessed
  with normal shell quoting

### Solutions

1. **Variable Assignment Method** (Recommended):

   ```bash
   filename=$(find "/path" -name "*pattern*" -print0 | tr -d '\0')
   cp "$filename" destination
   ```

2. **Find-Exec Method**:

   ```bash
   find "/path" -name "*pattern*" -exec cp {} destination \;
   ```

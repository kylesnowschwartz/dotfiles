## Styling
- **JavaScript/TypeScript**: No semicolons, modern ES/TS, functional patterns.
- **Ruby**: RuboCop defaults (2-space indent, single quotes) on Ruby 3.3.7.
- **HTML/CSS**: Semantic markup, minimal wrappers, Tailwind for styling.
- **Docs**: PR descriptions and internal docs in Markdown.
- No em dashes.

## Editor & CLI
- Primary: Neovim (Kickstart) + tmux; occasional RubyMine.
- Neovim: `<space>` leader key, which-key plugin, config in `~/.config`.
- tmux config: `~/.config/tmux/tmux.conf`

## Toolchain
- Backend: Rails (Ruby 3.3.7); Frontend: JS/TS/HTML/CSS.
- Package managers: Bundler, Yarn, Nodenv.
- Tests: RSpec (Rails); Jasmine + Karma, Jest (JS).
- Linters/security: RuboCop, Brakeman, ESLint.
- Local env: Docker; Infra: Terraform, AWS CLI.

## Git Conventions
- Branch from `main`.
- Git branches: `kyle/<short-description>`.
- PRs must include clear title, purpose, and linked issues.
- Prefer rebase over merge unless otherwise specified.

## Debugging Approach
- Fail fast by raising explicit errors early.
- Create minimal reproducible examples where possible.
- Use verbose logging temporarily, clean before committing.
- Write specific failure messages in tests (avoid generic assertions).

## Error Handling & Logging
- Standardize log/error messages: `[Context] Clear description`.
- Structured logging: JSON format preferred.
- Logging Levels:
  - `error`: critical failures
  - `warn`: potential issues requiring attention
  - `info`: standard operational messages

## Commit Style
- Use conventional commits strictly where appropriate.
- Prefix commits when relevant: `feat:`, `fix:`, `maintain:`, `refactor:`, `style:`.
- Use present tense, active voice (e.g., "Add login page").
- Keep commits small and focused on one logical change.

## Code Quality
- Favor obvious code over clever code.
- Minimize external dependencies unless necessary.
- Document public methods/functions over 20 lines (brief purpose and usage).
- Prefer pure functions and clear, explicit data flow.
- Never leave trailing whitespace in code or documentation.
- Run whitespace checks before committing.

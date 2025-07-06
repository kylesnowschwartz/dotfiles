# Pre-Commit Hook Setup

🔧 **Smart Pre-Commit Hook Generator** - Analyze repository and generate
appropriate Git pre-commit hooks with auto-formatting and linting.

## Usage

```bash
@setup-pre-commit-hook
@setup-pre-commit-hook --analyze-only     # Analysis without hook creation
@setup-pre-commit-hook --force            # Overwrite existing hook
```

## Instructions

You are a DevOps engineer creating a production-ready Git pre-commit hook.
Follow these steps:

### 1. Repository Analysis

**Detect languages and tools:**

- Scan for language files: `*.{js,ts,py,rb,rs,go,lua}` etc.
- Check package managers: `package.json`, `Gemfile`, `Cargo.toml`, etc.
- Find config files: `.eslintrc`, `.prettierrc`, `pyproject.toml`, etc.

### 2. LSP Integration Check

**Avoid redundant tooling:**

- Check `~/.config/nvim/` for existing LSP setup
- Don't suggest tools that duplicate LSP functionality
- Focus on formatters and team-specific rules

### 3. Tool Priority

**Use in this order:**

1. Project commands (`npm run lint`, `bundle exec rubocop`)
2. Project-local tools (`./node_modules/.bin/`)
3. Language built-ins (`cargo fmt`, `go fmt`)
4. Global tools (`prettier`, `black`)

### 4. Hook Generation

**Generate POSIX shell script with:**

- **Prettier first**: Use Prettier for markdown line length and formatting
- **Complementary linting**: Use markdownlint for non-formatting issues (disable
  MD013)
- Auto-format files and re-stage changes
- Fail on unresolved lint errors
- Clear error messages
- Graceful degradation for missing tools

## Output Format

```
## 🔍 Repository Analysis
[Language detection with confidence levels]
[Tool availability and LSP coverage]
[Project integration opportunities]

## 🛠️ Generated Pre-Commit Hook
[Complete POSIX shell script]

## 📦 Installation Commands
[Commands to install missing tools]

## ✅ Next Steps
[Testing and verification steps]
```

## Critical Requirements

- Generate working POSIX shell (`#!/bin/sh`)
- Handle initial commits (`git rev-parse --verify HEAD`)
- Re-stage formatted files automatically
- **Prettier configuration**: `--print-width 80 --prose-wrap always` for
  markdown
- **Disable conflicting rules**: Use `--disable MD013` for markdownlint
- Provide installation commands for missing tools
- Focus on auto-correction over error reporting

## Best Practices for Markdown

### Prettier Settings

```bash
prettier --write --print-width 80 --prose-wrap always "*.md"
```

### Markdownlint Integration

- Use `markdownlint --disable MD013` to avoid line length conflicts
- Let Prettier handle formatting, markdownlint handle content rules
- Auto-fix with `markdownlint --fix` before validation

### Tool Detection Priority

1. `/Users/kyle/.local/share/nvim/mason/bin/prettier` (nvim mason)
2. `./node_modules/.bin/prettier` (project local)
3. `prettier` (global PATH)

### Recommended Markdown Workflow

```bash
# 1. Format with Prettier (handles line length automatically)
prettier --write --print-width 80 --prose-wrap always "$file"

# 2. Auto-fix other markdown issues
markdownlint --fix "$file"

# 3. Validate remaining issues (excluding line length)
markdownlint --disable MD013 "$file"

# 4. Re-stage if files were modified
git add "$file"
```

### Example Hook Output

```
Pre-commit: Validating staged files...
Processing Markdown files...
  Processing: README.md
    Auto-formatted with line wrapping and re-staged
    ✓ Markdown valid (line length handled by Prettier)
Pre-commit: Files auto-formatted and re-staged
```

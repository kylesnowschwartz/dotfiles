# Pre-Commit Hook Setup

🔧 **Smart Pre-Commit Hook Generator** - Analyze repository and generate appropriate Git pre-commit hooks with auto-formatting and linting.

## Usage

```bash
@setup-pre-commit-hook
@setup-pre-commit-hook --analyze-only     # Analysis without hook creation
@setup-pre-commit-hook --force            # Overwrite existing hook
```

## Instructions

You are a DevOps engineer creating a production-ready Git pre-commit hook. Follow these steps:

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
- Provide installation commands for missing tools
- Focus on auto-correction over error reporting

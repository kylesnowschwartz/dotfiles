# sc-pre-commit-setup: automate pre-commit framework setup

**Purpose**: Intelligently automate pre-commit framework setup with dynamic research and repository-tailored configuration. Analyze the current repository and setup comprehensive pre-commit configuration. Use the provided examples and additional research via mcp servers within a dedicted @research-analyst agent to ensure idiomatic and up to date pre-commit configuration.
**Auto-Spawning:** Spawns specialized agents via Task() calls for parallel execution of research, configuration, and validation.
**Context Detection:** Repository analysis → Language detection → Hook research → Configuration generation → Validation

## Research & Configuration Protocol

<repository_analysis> Use TodoWrite to track this systematic analysis:

1. **Repository Discovery**

   - Extract repository name: `basename "$(git rev-parse --show-toplevel)"`
   - Detect project languages via file analysis and package manifests
   - Identify existing `.pre-commit-config.yaml`, `.git/hooks/pre-commit`, or additional setup requirements

2. **Language Detection Logic**

## Example Detection Logic

```bash
# Use the List() tool to view directory structure
# Priority: Configuration files (fast detection)
[[ -f "package.json" ]] && languages+=("javascript")
[[ -f "pyproject.toml" || -f "requirements.txt" ]] && languages+=("python")
[[ -f "go.mod" ]] && languages+=("go")
[[ -f "Cargo.toml" ]] && languages+=("rust")
# Additional languages as required

# Secondary: File extensions (optimized scanning)
find . -maxdepth 2 -name "*.sh" -o -name "*.bash" | head -1 && languages+=("shell")
find . -maxdepth 2 -name "*.ts" -o -name "*.tsx" | head -1 && languages+=("typescript")
```

</repository_analysis>

<version_research> Use `mcp__context7` and GitHub API (`gh ...`) for authoritative version discovery:

1. **Primary Research Sources**

   - `mcp__context7__resolve-library-id "pre-commit hooks"` for latest documentation
   - GitHub API: `gh api repos/pre-commit/pre-commit-hooks/releases/latest` or `gh api repos/shellcheck-py/shellcheck-py/tags` or `gh repo view scop/pre-commit-shfmt`
   - Context7 queries for best practices and current examples

2. **Repository Validation**

   - Test each repository with: `pre-commit try-repo <repo-url> --verbose`
   - Only include validated, accessible repositories in configuration
   - Document any repositories that fail validation

3. **Fallback Strategy**
   - If GitHub API fails: use `pre-commit sample-config` as reference with the knowledge that the sample-config is out-of-date
   - If specific repositories fail: use alternative mirrors or skip with warning
   - Comprehensively report failures to setup specific repos or hooks

</version_research>

<configuration_generation> Progressive configuration building with validation at each step:

1. **Base Configuration Template**

   ```yaml
   # {repository_name} Pre-commit Configuration
   # Auto-generated for detected languages: {detected_languages}
   default_install_hook_types: [pre-commit]
   default_stages: [pre-commit]
   fail_fast: false

   repos:
     # Core file hygiene (Essential - Priority 1)
     - repo: https://github.com/pre-commit/pre-commit-hooks
       rev: { researched_version }
       hooks:
         - id: trailing-whitespace
           exclude: '\.md$' # Preserve markdown formatting
         - id: end-of-file-fixer
         - id: check-merge-conflict
         - id: check-added-large-files
           args: [--maxkb=2084]
         - id: check-yaml
         - id: check-json
         - id: detect-private-key
   ```

2. **Language-Specific Addition Logic**

   - **Shell detected**: Add shellcheck-py
   - **Python detected**: Add language-specific hooks
   - **JavaScript/TypeScript**: Consider additional hooks
   - **Documentation (.md files)**: Add markdownlint-cli with pragmatic rule exclusions

3. **Validation After Each Addition**
   - Test configuration: `pre-commit run --files <sample-file>`
   - If hook fails: investigate, fix, or remove with documented reasoning
   - Ensure minimal working configuration always available

</configuration_generation>

<progressive_validation> Systematic testing with rollback capability:

1. **Installation Verification**

   - `pre-commit --version` (verify tool availability)
   - `pre-commit install` (hook installation)
   - `pre-commit validate-config` (configuration syntax)

2. **Incremental Hook Testing**

   - Test core hooks first: `pre-commit run trailing-whitespace --all-files`
   - Add language-specific hooks one category at a time
   - Roll back to last working configuration on failure

3. **Performance Validation**

   - Measure hook execution time on representative files
   - Adjust configuration if hooks take >10 seconds
   - Document any performance considerations

4. **Final Integration Test**
   - `pre-commit run --all-files` (comprehensive test)
   - Simulate actual commit workflow
   - Generate human-readable summary of active hooks

</progressive_validation>

## Success Criteria & Human QA

**Minimum Success (Required)**

- ✅ Valid `.pre-commit-config.yaml` with working core hooks
- ✅ `pre-commit install` completes successfully
- ✅ Security hooks active (detect-private-key, check-merge-conflict)
- ✅ Basic file hygiene (trailing-whitespace, end-of-file-fixer)

**Optimal Success (Target)**

- ✅ Language-specific hooks for detected project types
- ✅ Current versions from GitHub API research
- ✅ Repository-specific customization and comments
- ✅ Performance optimized (sub-10 second execution)
- ✅ Comprehensive validation with error-free test run

## Error Handling & Recovery

## Staging-Aware Hook Wrapper Implementation

**Internal AI Agent Instructions**: When setting up pre-commit frameworks, automatically detect if staging preservation is required and implement wrapper solution. The pre-commit framework intentionally doesn't preserve original staging context (maintainer design philosophy: "pre-commit takes a strong stance on never modifying the staging area"). This creates a critical workflow issue where auto-formatting hooks (shfmt, markdownlint --fix, trailing-whitespace, end-of-file-fixer) cause retry mechanisms to stage ALL modified files instead of preserving the user's original commit intent. **Detection Criteria**: Implement wrapper when configuration contains any auto-formatting hooks that modify files in-place. Check for hooks with `--fix` arguments, formatters like `shfmt`, `black`, `prettier`, or file hygiene hooks like `trailing-whitespace` and `end-of-file-fixer`. **Wrapper Implementation**: After successful `pre-commit install`, replace the generated `.git/hooks/pre-commit` with the staging-aware wrapper. Preserve the original pre-commit framework configuration while adding staging intelligence. **Wrapper Script**: Use this complete implementation: `#!/usr/bin/env bash` followed by staging capture logic `original_staged_files=$(git diff --cached --name-only --diff-filter=ACM $against)` where `$against` handles initial commits via `git rev-parse --verify HEAD >/dev/null 2>&1` check. Execute original pre-commit framework with preserved arguments and environment. On exit code 1 (file modifications detected), reset staging completely with `git reset HEAD --quiet`, then restore only originally staged files using `echo "$original_staged_files" | while IFS= read -r file; do [ -f "$file" ] && git add "$file"; done`. Exit success (code 0) to indicate files are properly staged with modifications. **Integration with Progressive Validation**: After implementing wrapper, add validation step `git add test-file.md && git commit --dry-run -m "Test staging preservation"` to confirm wrapper preserves staging intent. Test mixed staging scenarios where some files are staged and others unstaged, verify only originally staged files are committed after auto-formatting. **Validation Protocol**: Create test files with formatting issues, stage only subset of files, run commit process, verify unstaged files remain unstaged while staged files include formatting modifications. **Error Recovery**: If wrapper causes issues, restore original pre-commit hook from backup and fall back to standard framework behavior. Document any compatibility issues with specific hook configurations. **Performance Considerations**: Wrapper adds minimal overhead (single git command for staging capture and restoration). Monitor pre-commit execution time to ensure sub-10 second performance target is maintained. **Implementation Context**: This addresses GitHub issues #806 and #1817 in pre-commit repository where users repeatedly request automatic re-staging functionality that maintainers reject by design. The wrapper solution provides this functionality while respecting framework architecture and maintaining compatibility with all existing hook configurations and validation procedures.

<example_configuration>

```yaml
# `.pre-commit-config.yaml`
# Global Configuration
default_install_hook_types: [pre-commit]
default_stages: [pre-commit]
fail_fast: false

repos:
  # Standard pre-commit hooks for file hygiene and basic validation
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v5.0.0
    hooks:
      - id: trailing-whitespace
        exclude: '\.md$'
      - id: end-of-file-fixer
      - id: check-merge-conflict
      - id: check-added-large-files
        args: [--maxkb=1024]
      - id: check-yaml
      - id: check-json
      - id: check-toml
      - id: check-case-conflict
      - id: mixed-line-ending
      - id: check-executables-have-shebangs
      - id: check-symlinks
      - id: detect-private-key

  # Shell script quality assurance
  - repo: https://github.com/koalaman/shellcheck-precommit
    rev: v0.10.0
    hooks:
      - id: shellcheck
        args: [--severity=warning]

  # Shell script formatting
  - repo: https://github.com/scop/pre-commit-shfmt
    rev: v3.12.0-2
    hooks:
      - id: shfmt
        args: [-w, -i, "2"]

  # Documentation hooks (Priority 3 - Optional)
  - repo: https://github.com/igorshubovych/markdownlint-cli
    rev: v0.45.0
    hooks:
      - id: markdownlint
        args: [
            --fix,
            --disable,
            MD013, # Line length (disabled for long technical content)
            MD041, # First line H1 (disabled for purpose/command docs)
            MD026, # Trailing punctuation in headings (disabled for "Variables:")
            MD012, # Multiple blank lines (disabled for visual spacing)
          ]
```

</example_configuration>

---

**Generated Configuration Location**: `.pre-commit-config.yaml`  
**Maintenance Commands**: `pre-commit autoupdate`, `pre-commit run --all-files`  
**Documentation**: All hook purposes explained in configuration comments

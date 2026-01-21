# Ghostty Theme System

Coordinated theme switching across terminal, prompt, and CLI tools.

## Quick Start

```bash
# Switch themes (from any shell)
theme next          # Cycle to next theme
theme prev          # Cycle to previous theme
theme bleu          # Switch to specific theme
theme list          # Show available themes

# Keybindings (in Ghostty)
Cmd+Shift+.         # Next theme
Cmd+Shift+,         # Previous theme
```

## How It Works

When you switch themes, `switch-theme.sh` updates:

1. **Ghostty** - Terminal colors (via config)
2. **Starship** - Prompt theme (via symlink)
3. **Delta** - Git diff colors (via wrapper function)
4. **bat** - Syntax highlighting (via wrapper function)
5. **eza** - Directory colors (via theme.yml symlink)
6. **gh-dash** - GitHub dashboard (via config copy)
7. **Claude** - Claude Code UI theme (via .claude.json)

### Live Shell Updates

Theme changes take effect **instantly in all shells** (existing and new) without any signal propagation or shell reloading:

```
switch-theme.sh
    |
    +-> writes ~/.config/bat-theme.txt   (plain text)
    +-> writes ~/.config/delta-theme.txt (plain text)

[any shell, any time]
    |
    +-> bat() wrapper reads bat-theme.txt   -> passes --theme flag
    +-> git() wrapper reads delta-theme.txt -> sets DELTA_FEATURES
```

**Why this works:**
- Both bat and delta read their config fresh on every invocation (no caching)
- Shell wrapper functions in `.bash_aliases` read theme files at call time
- No signals, no process trees, no race conditions
- Platform-independent (macOS, Linux, tmux, etc.)

## Files

| File | Purpose |
|------|---------|
| `ghostty/config` | Main Ghostty config, includes theme line |
| `ghostty/themes/` | Ghostty theme files (*.ghostty) |
| `ghostty/switch-theme.sh` | Main theme orchestrator |
| `starship/*-starship.toml` | Starship prompt themes |
| `eza/themes/*.yml` | eza color themes |
| `gh-dash/themes/*.yml` | gh-dash color themes |
| `~/.config/delta-theme.txt` | Current delta theme (plain text) |
| `~/.config/bat-theme.txt` | Current bat theme (plain text) |

## Theme Buckets

Themes are organized into buckets that determine which tool configs to use:

| Bucket | Ghostty | Starship | Delta | bat |
|--------|---------|----------|-------|-----|
| dark | cobalt-next-neon | chef | dark | Dracula |
| light | dayfox | chef-light | light | Solarized (light) |
| bleu | bleu | bleu | bleu | bleu |

## Adding a New Theme

1. Add Ghostty theme file to `ghostty/themes/`
2. Register in `switch-theme.sh`:
   - Add to `THEME_BUCKETS` associative array
   - Add to `THEME_ORDER` array
3. Optionally create matching Starship/eza themes

## Troubleshooting

### Theme doesn't apply to bat/delta

Verify wrapper functions are loaded:
```bash
type bat   # Should show function definition
type git   # Should show function definition
```

If they show aliases or external commands instead, reload your shell: `source ~/.zshrc`

### Delta colors wrong

Check the theme file:
```bash
cat ~/.config/delta-theme.txt
git diff HEAD~1  # Test it
```

### bat colors wrong

Check the theme file:
```bash
cat ~/.config/bat-theme.txt
bat --list-themes | grep -i "$(cat ~/.config/bat-theme.txt)"
```

### New terminal tab has wrong theme

The wrapper functions read theme files on every invocation, so new tabs should work immediately. If not, verify the theme files exist:
```bash
ls -la ~/.config/bat-theme.txt ~/.config/delta-theme.txt
```

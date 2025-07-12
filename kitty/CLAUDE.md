# Kitty Configuration - Claude Code Instructions

## Working with kitty.conf.default

The `kitty.conf.default` file contains the complete default Kitty configuration with extensive documentation. However, it exceeds Claude Code's token limit for single file reads (~29,000 tokens).

### How to parse the large config file

1. **Search for specific sections**:

   ```bash
   # Search for section headers with line numbers
   rg -n "^#:" kitty.conf.default | rg -i "section_name"

   # Alternative: Use fd to verify file exists first
   fd -e default kitty.conf && rg -n "^#:" kitty.conf.default
   ```

2. **Read specific line ranges**:

   ```bash
   # Example: Read font configuration section (lines 1-200)
   Read kitty.conf.default --offset 1 --limit 200

   # Example: Read keyboard shortcuts section (around line 1000)
   Read kitty.conf.default --offset 1000 --limit 500
   ```

3. **Find configuration blocks**:

   ```bash
   # Find all major sections (note the escaped braces)
   rg -n "^#: .* \{\{\{" kitty.conf.default

   # Alternative: Use fixed-strings for literal search
   rg -F -n "#: .* {{{" kitty.conf.default
   ```

## Common sections and their approximate line numbers

- **Fonts**: Lines 1-400
- **Cursor customization**: Lines 400-500
- **Scrollback**: Lines 500-600
- **Mouse**: Lines 600-800
- **Performance tuning**: Lines 800-900
- **Terminal bell**: Lines 900-1000
- **Window layout**: Lines 1000-1200
- **Tab bar**: Lines 1200-1400
- **Color scheme**: Lines 1400-1700
- **Advanced**: Lines 1700-2000
- **OS specific**: Lines 2000-2300
- **Keyboard shortcuts**: Lines 2300-2900

## Quick search commands

```bash
# Find all available options for a feature
rg -A 5 -B 5 "option_name" kitty.conf.default

# List all keyboard mappings
rg "^# map" kitty.conf.default

# Find color-related settings
rg -i "color" kitty.conf.default | head -20

# Search with context and line numbers
rg -n -C 3 "font_size" kitty.conf.default

# Find uncommented settings (actual active defaults)
rg "^[^#]" kitty.conf.default

# Count occurrences of a pattern
rg -c "map cmd" kitty.conf.default

# Show only filenames containing matches (useful for multiple files)
rg -l "pattern" *.conf
```

## Using fd for Kitty configuration management

```bash
# Find all Kitty config files
fd -e conf . ~/.config/kitty

# Find config files modified in last 24 hours
fd -e conf . ~/.config/kitty --changed-within 24h

# Find and list details of config files
fd -e conf . ~/.config/kitty -x ls -la

# Create backups of all config files
fd -e conf . ~/.config/kitty -x cp {} {}.bak
```

## Current Configuration Notes

- The active `kitty.conf` has been configured with macOS-friendly defaults
- Font is set to JetBrains Mono (change if needed)
- Gruvbox Dark color scheme is applied
- Key mappings use Cmd key for macOS consistency
- Shell integration is enabled
- Remote control is enabled on unix socket

## Useful Kitty Commands

- `kitty +kitten themes` - Browse and preview color themes
- `kitty +kitten choose-fonts` - Visual font selector
- `kitty +kitten icat image.png` - Display images in terminal
- `kitty +kitten diff file1 file2` - Side-by-side diff viewer
- `kitty --debug-config` - Debug configuration issues

## Reload Configuration

After making changes to `kitty.conf`:

- Press `Cmd+Shift+R` (configured shortcut)
- Or run: `kill -SIGUSR1 $(pgrep kitty)`

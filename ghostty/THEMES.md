# Ghostty Theme Configuration

This document explains how the Ghostty theme system is configured, including the two installed themes and how to switch between them.

## Installed Themes

### 1. Cobalt2 (Dark Theme)
- **File**: `~/.config/ghostty/themes/cobalt2`
- **Source**: [omarchy-cobalt2-theme](https://github.com/hoblin/omarchy-cobalt2-theme)
- **Style**: Dark blue background (#122738) with vibrant syntax colors
- **Best for**: Night coding sessions and low-light environments

### 2. Dayfox (Light Theme)
- **File**: `~/.config/ghostty/themes/dayfox.ghostty`
- **Source**: [nightfox.nvim extras](https://github.com/EdenEast/nightfox.nvim)
- **Style**: Warm light background (#f6f2ee) with muted but readable colors
- **Best for**: Daytime work and well-lit environments

## Theme Switching

### Keybindings (matches iTerm2)
- **Cmd+Shift+,** (comma) → Switch to **dayfox** (light theme)
- **Cmd+Shift+.** (period) → Switch to **cobalt2** (dark theme)
- **Cmd+Shift+R** → Reload configuration to apply theme changes

### How Theme Switching Works

1. **Press the keybinding** (Cmd+Shift+, or Cmd+Shift+.)
   - This executes the `switch-theme.sh` script in your terminal
   - The script updates `~/.config/ghostty/config` with the new theme

2. **Reload the configuration** (Cmd+Shift+R)
   - This applies the new theme to all open Ghostty windows
   - You'll see the colors change immediately

### Manual Theme Switching

You can also switch themes manually:

```bash
# Switch to dayfox (light theme)
~/.config/ghostty/switch-theme.sh dayfox

# Switch to cobalt2 (dark theme)
~/.config/ghostty/switch-theme.sh cobalt2

# Check current theme
~/.config/ghostty/switch-theme.sh
```

After running the script, press **Cmd+Shift+R** in Ghostty to reload.

## Theme File Structure

Ghostty theme files use the same syntax as the main config file:

```
# Color definitions
background = #122738
foreground = #ffffff

# Terminal palette (0-15)
palette = 0=#000000  # black
palette = 1=#ff628c  # red
# ... etc
```

## Adding New Themes

To add a new theme:

1. **Create a theme file** in `~/.config/ghostty/themes/`
   ```bash
   touch ~/.config/ghostty/themes/my-theme
   ```

2. **Define colors** using the format shown above

3. **Update the switcher script** (`switch-theme.sh`) to include your theme:
   ```bash
   # In the validation section:
   if [[ ! "$THEME" =~ ^(cobalt2|dayfox|my-theme)$ ]]; then

   # In the case statement:
   my-theme)
       echo "theme = my-theme" >> "$CONFIG_FILE"
       ;;
   ```

4. **Add a keybinding** in `~/.config/ghostty/config` if desired

## Configuration Files

- **Main config**: `~/.config/ghostty/config`
- **Theme directory**: `~/.config/ghostty/themes/`
- **Theme switcher**: `~/.config/ghostty/switch-theme.sh`
- **Theme sources**: `~/Code/Cloned-Sources/`
  - `nightfox.nvim/extra/dayfox/dayfox.ghostty`
  - `omarchy-cobalt2-theme/ghostty.conf`

## Troubleshooting

### Theme doesn't change after pressing hotkey
1. Look at your terminal - you should see output from the script
2. Press **Cmd+Shift+R** to reload the configuration
3. Check if the script executed: `~/.config/ghostty/switch-theme.sh` (shows current theme)

### Colors look wrong
1. Verify the theme file exists: `ls ~/.config/ghostty/themes/`
2. Check the config: `grep "^theme" ~/.config/ghostty/config`
3. Reload: **Cmd+Shift+R**

### Keybinding doesn't work
1. Check for conflicts: `grep "shift+comma\|shift+period" ~/.config/ghostty/config`
2. Ensure the script is executable: `ls -l ~/.config/ghostty/switch-theme.sh`
3. Test the script manually: `~/.config/ghostty/switch-theme.sh dayfox`

## Related Documentation

- [Ghostty Theme Documentation](https://ghostty.org/docs/config/reference#theme)
- [Ghostty Keybinding Reference](https://ghostty.org/docs/config/keybind/reference)
- [Nightfox Theme Palette](https://github.com/EdenEast/nightfox.nvim)
- [Cobalt2 Theme](https://github.com/hoblin/omarchy-cobalt2-theme)

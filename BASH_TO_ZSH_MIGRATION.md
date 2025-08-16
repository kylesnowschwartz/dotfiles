# Bash to Zsh Migration Guide

This document provides step-by-step instructions for migrating from bash to zsh gradually.

## Phase 1: Testing Zsh (Current Status)

### What's Been Done
- ✅ Zsh is installed (version 5.9)
- ✅ Created `.zshrc` that preserves all bash functionality
- ✅ Verified basic compatibility

### How to Test Zsh

#### Option 1: Test in New Terminal Window
```bash
# Start zsh temporarily (doesn't change default shell)
zsh
```

#### Option 2: Test with Specific Configuration
```bash
# Test the new configuration directly
zsh -c "source ~/.zshrc && exec zsh"
```

### Rollback Plan (If Things Go Wrong)

#### If You Haven't Changed Default Shell Yet
Simply type `exit` or press `Ctrl+D` to return to bash.

#### If You Do Change Default Shell Later
```bash
# Change back to bash
chsh -s /bin/bash

# Or temporarily use bash
bash
```

#### Emergency Recovery
If zsh won't start properly:
1. Open Terminal
2. Type: `bash` (to switch to bash immediately)
3. Edit or remove `~/.zshrc`: `rm ~/.zshrc` or `mv ~/.zshrc ~/.zshrc.backup`

## Testing Checklist

Once you start zsh, verify these work:

### Basic Functions
- [ ] `ls` (should use eza with icons)
- [ ] `cd ..` or just `..`
- [ ] `gs` (git status)
- [ ] `gc` (smart commit)
- [ ] History with arrow keys
- [ ] Tab completion

### Key Features to Test
- [ ] `dirs -v` (directory stack - zsh specific)
- [ ] Type a directory name without `cd` (should auto-cd)
- [ ] Try `**/*.txt` (recursive globbing)
- [ ] `zsh-features` (show new features available)

### Your Custom Tools
- [ ] `tmx` (tmux session management)
- [ ] `y` (yazi file manager)
- [ ] `starship-set` (prompt theme switching)
- [ ] `trae-cli` (your CLI tool)

## Migration Steps

### Step 1: Test Phase (Current)
- Use zsh in new terminals without changing default
- Verify all your workflows work
- Get comfortable with zsh-specific features

### Step 2: Make Zsh Default (When Ready)
```bash
# Change default shell to zsh
chsh -s /bin/zsh

# Verify change
echo $SHELL
```

### Step 3: Gradual Enhancement (Later)
After you're comfortable, we can:
- Add zsh-specific plugins
- Enhance completions
- Add more advanced features
- Consider frameworks like oh-my-zsh (if desired)

## Key Differences You'll Notice

### Improvements in Zsh
1. **Better tab completion** - More intelligent and context-aware
2. **Shared history** - History is shared between all terminal sessions
3. **Auto-cd** - Type directory name to change to it
4. **Spell correction** - Suggests corrections for typos
5. **Extended globbing** - More powerful pattern matching

### Commands That Work Differently
- **History search**: Still `Ctrl+R`, but more powerful
- **Directory navigation**: Can use directory stack (`cd -<tab>`)
- **Globbing**: More patterns available (`**` for recursive)

## Compatibility Notes

### What's Preserved
- All your existing aliases from `.bash_aliases`
- All environment variables and PATH settings
- All tool integrations (rbenv, asdf, starship, etc.)
- Vi-mode editing
- Custom functions (tmx, starship-set, etc.)

### What's Enhanced
- History management (shared between sessions)
- Tab completion (more intelligent)
- Globbing patterns (more powerful)
- Directory navigation (stack-based)

## Troubleshooting

### If Aliases Don't Work
The `.bash_aliases` file should be sourced automatically. If not:
```bash
# Manually source it
source ~/.bash_aliases
```

### If Completion Doesn't Work
```bash
# Reload completions
autoload -U compinit && compinit
```

### If You Want to Disable a Feature
Edit `~/.zshrc` and comment out the line with `#`:
```bash
# setopt CORRECT_ALL    # Disable aggressive spell correction
```

## Next Steps

Once you're comfortable with basic zsh:
1. Consider additional plugins (syntax highlighting, autosuggestions)
2. Explore zsh-specific frameworks (optional)
3. Customize completions further
4. Add more powerful prompt features

Remember: This migration preserves everything you're used to while adding improvements. You can always go back to bash if needed.

#!/bin/bash
# Don't use set -e because we want to continue on package failures
set -uo pipefail

# =============================================================================
# ARM Homebrew Migration Script
# =============================================================================
#
# PROBLEM: Intel Homebrew installed at /usr/local instead of ARM Homebrew at
# /opt/homebrew. Everything runs under Rosetta 2 emulation, causing:
# - 20-30% performance penalty on all commands
# - Bun crashes due to AVX instruction emulation failures
# - Wasted M-series chip potential
#
# BATTLE PLAN:
#
# Step 1: Disable Rosetta on Your Terminal (DO THIS FIRST)
#   1. Quit all terminal windows completely
#   2. In Finder, go to /Applications
#   3. Right-click your terminal (Ghostty, iTerm2, etc.)
#   4. Get Info -> Uncheck "Open using Rosetta"
#   5. Reopen terminal
#
# Step 2: Verify You're Native
#   arch  # Should say "arm64", not "i386" or "x86_64"
#
# Step 3: Run This Script
#   chmod +x migrate-to-arm-homebrew.sh
#   ./migrate-to-arm-homebrew.sh
#
# Step 4: Update Your Shell Config
#   Add this to the TOP of ~/.zshrc:
#   eval "$(/opt/homebrew/bin/brew shellenv)"
#
# Step 5: Nuke Intel Homebrew (AFTER verifying ARM works)
#   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh)" -- --path=/usr/local
#
# WHAT COULD GO WRONG:
# - Custom taps (envato/*, kylesnowschwartz/*) may lack ARM builds
# - Skipped casks: phantomjs (dead), wkhtmltopdf (ARM issues)
# - Script takes 20-40 minutes depending on compilation needs
#
# =============================================================================
# FULL DAMAGE ASSESSMENT (as of 2025-12-07)
# =============================================================================
#
# Everything below was installed under Rosetta and is x86_64:
#
# HOMEBREW (/usr/local/bin):
#   - 961 x86_64 binaries
#   - Intel Homebrew at /usr/local/bin/brew
#   - No ARM Homebrew at /opt/homebrew
#
# BUN (~/.bun/bin):
#   - bun: x86_64 (causes AVX crashes under Rosetta)
#   - bunx: x86_64
#
# CLAUDE CLI (~/.local/bin):
#   - claude: x86_64
#   - (uv/uvx are arm64 - the only sane ones)
#
# RUBY via rbenv (~/.rbenv/versions/*/bin/ruby):
#   All 29 versions are x86_64:
#   - 2.5.9, 2.6.8
#   - 2.7.3, 2.7.4, 2.7.5, 2.7.6, 2.7.7, 2.7.8
#   - 3.0.4, 3.0.5
#   - 3.1.2, 3.1.3, 3.1.5, 3.1.6
#   - 3.2.1, 3.2.2, 3.2.4, 3.2.5, 3.2.6
#   - 3.3.1, 3.3.4, 3.3.5, 3.3.7, 3.3.8, 3.3.9
#   - 3.4.1, 3.4.2, 3.4.5, 3.4.7
#
# NODE via nodenv (~/.nodenv/versions/*/bin/node):
#   All 5 versions are x86_64:
#   - 20.12.2
#   - 22.15.1, 22.16.0, 22.17.1
#   - 23.9.0
#
# =============================================================================
# POST-MIGRATION CLEANUP (MANUAL)
# =============================================================================
#
# After ARM Homebrew is working, reinstall language runtimes as needed:
#
# Ruby (only install versions you actually use):
#   rbenv install 3.4.7   # Will compile as arm64
#   rbenv install 3.3.9
#   rbenv global 3.4.7
#
# Node (only install versions you actually use):
#   nodenv install 23.9.0  # Will compile as arm64
#   nodenv install 22.17.1
#   nodenv global 23.9.0
#
# Claude CLI:
#   npm install -g @anthropic-ai/claude-code
#
# Clean up old x86_64 versions (AFTER verifying arm64 works):
#   rm -rf ~/.rbenv/versions/*   # Nuclear option
#   rm -rf ~/.nodenv/versions/*  # Nuclear option
#   # Or selectively: rbenv uninstall 2.5.9
#
# =============================================================================

# Log file for troubleshooting
LOGFILE="$HOME/arm-migration-$(date +%Y%m%d-%H%M%S).log"
exec > >(tee -a "$LOGFILE") 2>&1
echo "Logging to $LOGFILE"

echo ""
echo "=== Step 1: Verify we're running native ARM ==="
ARCH=$(arch)
if [[ "$ARCH" != "arm64" ]]; then
  echo "ERROR: You're running under $ARCH, not arm64"
  echo "First, disable Rosetta on your terminal app:"
  echo "  1. Close all terminal windows"
  echo "  2. Right-click your terminal app in Finder"
  echo "  3. Get Info -> Uncheck 'Open using Rosetta'"
  echo "  4. Reopen terminal and run this script again"
  exit 1
fi
echo "Running native ARM64 - good!"

echo ""
echo "=== Step 2: Install ARM Homebrew ==="
if [[ -f /opt/homebrew/bin/brew ]]; then
  echo "ARM Homebrew already installed at /opt/homebrew"
else
  echo "Installing ARM Homebrew - you may be prompted for your password..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # Verify it worked
  if [[ ! -f /opt/homebrew/bin/brew ]]; then
    echo "ERROR: Homebrew installation failed. Check output above."
    exit 1
  fi
fi

echo ""
echo "=== Step 3: Set up ARM Homebrew in current shell ==="
eval "$(/opt/homebrew/bin/brew shellenv)"

echo ""
echo "=== Step 4: Add custom taps ==="
# These are the third-party taps from your leaves list
brew tap bbc/audiowaveform 2>/dev/null || true
brew tap charmbracelet/tap 2>/dev/null || true
brew tap envato/envato-iamy 2>/dev/null || true
brew tap harehare/tap 2>/dev/null || true
brew tap jacobbednarz/tap 2>/dev/null || true
brew tap jstkdng/programs 2>/dev/null || true
brew tap kylesnowschwartz/claude-plugin-scaffold 2>/dev/null || true
brew tap orien/exiv2 2>/dev/null || true
brew tap robtaylor/claude-tools 2>/dev/null || true
brew tap shopify/shopify 2>/dev/null || true
brew tap sj26/git-buildkite 2>/dev/null || true

echo ""
echo "=== Step 5: Install packages (this will take a while) ==="
# Core packages - most likely to work on ARM
PACKAGES=(
  act adr-tools ast-grep automake bat bats-core black caddy direnv duf
  enscript exiftool exiv2 eza fastfetch fd ffmpeg figlet fontforge fzf
  gawk gh ghostscript git-delta git-filter-repo glow gnu-getopt gnu-tar
  go guile isort jaq jpegoptim jq just less libmaxminddb luacheck
  luarocks lynx mdp memcached mycli mysql-client@8.0 mysql@8.0 neovim
  newsboat nghttp2 nlohmann-json nodenv opam pipx poetry postgresql@14
  postgresql@16 pre-commit procs protobuf pv python@3.10 python@3.9 r
  range-v3 rbenv redis ripgrep rust rustup sd sevenzip shellcheck shfmt
  slides socat starship stylua tfenv the_silver_searcher tmux tree uv
  websocat wget wimlib yamllint yazi yq zoxide
)

# Packages that might need special handling
MAYBE_PACKAGES=(
  aws-sam-cli aws-sso-util aws-vault cli11 dune gemini-cli icu4c@76 ocaml
)

# Third-party tap packages - may or may not exist for ARM
TAP_PACKAGES=(
  "bbc/audiowaveform/audiowaveform"
  "charmbracelet/tap/crush"
  "charmbracelet/tap/freeze"
  "envato/envato-iamy/iamy"
  "harehare/tap/mq"
  "jacobbednarz/tap/cf-vault"
  "jstkdng/programs/ueberzugpp"
  "kylesnowschwartz/claude-plugin-scaffold/claude-plugin-scaffold"
  "orien/exiv2/exiv2@0.27.6"
  "robtaylor/claude-tools/claude-tools"
  "shopify/shopify/ejson2env"
  "sj26/git-buildkite/git-buildkite"
)

FAILED_PACKAGES=()

echo "Installing core packages..."
for pkg in "${PACKAGES[@]}"; do
  echo "  Installing $pkg..."
  if ! brew install "$pkg" 2>&1; then
    echo "    FAILED: $pkg"
    FAILED_PACKAGES+=("$pkg")
  fi
done

echo ""
echo "Installing packages that might need special handling..."
for pkg in "${MAYBE_PACKAGES[@]}"; do
  echo "  Installing $pkg..."
  if ! brew install "$pkg" 2>&1; then
    echo "    FAILED: $pkg"
    FAILED_PACKAGES+=("$pkg")
  fi
done

echo ""
echo "Installing third-party tap packages..."
for pkg in "${TAP_PACKAGES[@]}"; do
  echo "  Installing $pkg..."
  if ! brew install "$pkg" 2>&1; then
    echo "    FAILED: $pkg (may not have ARM build)"
    FAILED_PACKAGES+=("$pkg")
  fi
done

echo ""
echo "=== Step 6: Install casks ==="
CASKS=(
  aws-vault chromedriver emacs flutter font-hack-nerd-font
  font-hurmit-nerd-font font-intone-mono-nerd-font font-iosevka-nerd-font
  font-meslo-lg-nerd-font font-symbols-only-nerd-font openinterminal
  session-manager-plugin xquartz
)

# Skip these - known ARM issues or deprecated
# phantomjs - dead project
# wkhtmltopdf - problematic on ARM
# emacs-app - redundant with emacs cask
# fontforge-app - redundant with fontforge formula

FAILED_CASKS=()
for cask in "${CASKS[@]}"; do
  echo "  Installing $cask..."
  if ! brew install --cask "$cask" 2>&1; then
    echo "    FAILED: $cask"
    FAILED_CASKS+=("$cask")
  fi
done

echo ""
echo "=== Step 7: Install Bun (native ARM) ==="
curl -fsSL https://bun.sh/install | bash

echo ""
echo "=== Step 8: Verify key binaries are ARM ==="
echo "Checking architecture of newly installed binaries..."
echo ""
file /opt/homebrew/bin/brew 2>/dev/null && echo "  brew: OK" || echo "  brew: MISSING"
file ~/.bun/bin/bun 2>/dev/null | grep -q arm64 && echo "  bun: OK (arm64)" || echo "  bun: WARNING - not arm64!"

echo ""
echo "=============================================="
echo "=== INSTALLATION COMPLETE ==="
echo "=============================================="
echo ""
echo "Log file: $LOGFILE"
echo ""

if [[ ${#FAILED_PACKAGES[@]} -gt 0 ]]; then
  echo "FAILED PACKAGES (${#FAILED_PACKAGES[@]}):"
  printf '  - %s\n' "${FAILED_PACKAGES[@]}"
  echo ""
  echo "To retry failed packages later:"
  echo "  brew install ${FAILED_PACKAGES[*]}"
  echo ""
fi

if [[ ${#FAILED_CASKS[@]} -gt 0 ]]; then
  echo "FAILED CASKS (${#FAILED_CASKS[@]}):"
  printf '  - %s\n' "${FAILED_CASKS[@]}"
  echo ""
  echo "To retry failed casks later:"
  echo "  brew install --cask ${FAILED_CASKS[*]}"
  echo ""
fi

echo "=============================================="
echo "NEXT STEPS (MANUAL):"
echo "=============================================="
echo ""
echo "1. Update your shell config to use ARM Homebrew:"
echo "   Add this BEFORE any other PATH modifications in ~/.zshrc:"
echo ""
echo '   eval "$(/opt/homebrew/bin/brew shellenv)"'
echo ""
echo "2. Restart your terminal and verify:"
echo "   arch        # should show arm64"
echo "   which brew  # should show /opt/homebrew/bin/brew"
echo "   which bun   # should show ~/.bun/bin/bun"
echo "   file \$(which bun)  # should show arm64"
echo ""
echo "3. Reinstall language runtimes you need:"
echo "   rbenv install 3.4.7"
echo "   nodenv install 23.9.0"
echo "   npm install -g @anthropic-ai/claude-code"
echo ""
echo "4. ONLY AFTER everything works - remove Intel Homebrew:"
echo "   /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh)\" -- --path=/usr/local"
echo ""
echo "5. Clean up old x86_64 runtimes:"
echo "   rm -rf ~/.rbenv/versions/*"
echo "   rm -rf ~/.nodenv/versions/*"
echo ""

# ==============================================
# === INSTALLATION COMPLETE ===
# ==============================================
#
# Log file: /Users/kyle/arm-migration-20251207-212350.log
#
# FAILED PACKAGES (1):
#   - orien/exiv2/exiv2@0.27.6
#
# To retry failed packages later:
#   brew install orien/exiv2/exiv2@0.27.6
#
# FAILED CASKS (8):
#   - emacs
#   - font-hack-nerd-font
#   - font-hurmit-nerd-font
#   - font-intone-mono-nerd-font
#   - font-iosevka-nerd-font
#   - font-meslo-lg-nerd-font
#   - font-symbols-only-nerd-font
#   - openinterminal
#
# To retry failed casks later:
#   brew install --cask emacs font-hack-nerd-font font-hurmit-nerd-font font-intone-mono-nerd-font font-iosevka-nerd-font font-meslo-lg-nerd-font font-symbols-only-nerd-font openinterminal

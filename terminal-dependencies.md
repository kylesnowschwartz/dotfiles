# Terminal Dependencies
Generated: 2025-01-15

## Package Managers Used
- Homebrew (formulae and casks)
- Cargo (Rust)
- npm (global packages)
- pipx (Python tools)

## Modern CLI Replacements
- **eza** - Modern replacement for ls with colors and git integration
- **bat** - Cat clone with syntax highlighting
- **ripgrep** (rg) - Fast grep alternative
- **fd** - User-friendly find alternative
- **procs** - Modern replacement for ps
- **duf** - Better df with colorful output
- **delta** - Syntax-highlighting pager for git diff
- **sd** - Intuitive find & replace (sed alternative)
- **zoxide** - Smarter cd command with frecency tracking
- **ast-grep** - language search grep

## Core Development Tools
- **git** - Version control
- **git-delta** - Enhanced git diffs
- **dh-dash** - git tui DASH
- **gh** - GitHub CLI
- **git-filter-repo** - Git history rewriting
- **git-buildkite** - Buildkite Git integration
- **direnv** - Environment variable management
- **fzf** - Fuzzy finder
- **tmux** - Terminal multiplexer
- **neovim** - Text editor
- **starship** - Cross-shell prompt
- **tree** - Directory listing
- **tree-sitter** - Parser generator tool
- **tree-sitter-cli** - Tree-sitter CLI (Cargo)

## Shell & Terminal
- **bash** - Bourne Again Shell
- **shellcheck** - Shell script linter
- **shfmt** - Shell formatter
- **yazi** - Terminal file manager
- **fastfetch** - System info fetcher
- **lynx** - Terminal web browser
- **slides** - Terminal-based presentation tool
- **mdp** - Markdown presentation tool
- **glow** - Terminal markdown renderer
- **rich-pyfiglet** - figlet but better

## Language Environments & Package Managers

### Python
- **python@3.9, 3.10, 3.11, 3.12, 3.13** - Python versions
- **poetry** - Python dependency management
- **pipx** - Install Python applications
- **black** - Python formatter
- **isort** - Python import sorter
- **pre-commit** - Git hook framework
- **uv** - Fast Python package installer
- **git-fame** (pipx) - Git contributor stats
- **mem0ai** (pipx) - Memory AI tool

### Ruby
- **rbenv** - Ruby version management
- **ruby-build** - Ruby installation
- **rubocop** - Ruby linter (mentioned in aliases)

### Node.js
- **node** - JavaScript runtime
- **nodenv** - Node version management
- **node-build** - Node installation
- **npm** - Node package manager
- **yarn** - Alternative package manager
- **corepack** - Package manager manager

### Rust
- **rust** - Rust programming language
- **rustup** - Rust toolchain installer
- **cargo** - Rust package manager
- **selene** (Cargo) - Lua linter

### Go
- **go** - Go programming language

### Other Languages
- **r** - R statistical language
- **lua** - Lua programming language
- **luajit** - Just-In-Time Lua compiler
- **luarocks** - Lua package manager
- **luacheck** - Lua linter
- **stylua** - Lua formatter

## Cloud & Infrastructure

### AWS
- **awscli** - AWS command line interface
- **aws-vault** - AWS credential management
- **aws-sam-cli** - Serverless Application Model
- **aws-sso-util** - AWS SSO utilities
- **session-manager-plugin** - AWS Session Manager
- **iamy** - AWS IAM management

### Infrastructure as Code
- **tfenv** - Terraform version manager
- **terraform** - Infrastructure as code (via tfenv)

### Container & Orchestration
- **buildkite-cli** - Buildkite CI/CD
- **bk, bk@2** - Buildkite agent

### Networking & Services
- **caddy** - Web server
- **dnscrypt-proxy** - DNS privacy
- **redis** - In-memory data store
- **memcached** - Memory caching system
- **postgresql, postgresql@13, @14** - Database
- **mysql@8.0, mysql-client@8.0** - Database
- **mariadb-connector-c** - MariaDB connector
- **socat** - Socket CAT
- **websocat** - WebSocket client

## Data Processing & Formats

### JSON/YAML
- **jq** - JSON processor
- **yq** - YAML processor
- **mq** - MARKDOWN processor
- **jaq** - jq clone in Rust
- **yamllint** - YAML linter
- **jc** (pipx) - JSON converter for command output

### Databases
- **sqlite** - Embedded database
- **mycli** - MySQL CLI with auto-completion

## Media & Graphics

### Image Processing
- **imagemagick** - Image manipulation
- **jpegoptim** - JPEG optimizer
- **mozjpeg** - JPEG encoder
- **vips** - Image processing library
- **openslide** - Slide image processing
- **exiv2** - EXIF metadata

### Video/Audio
- **ffmpeg** - Media converter
- **audiowaveform** - Audio waveform generator

### Fonts & Typography
- **fontforge** - Font editor
- **fontforge-app** - Font editor GUI

## Testing & Quality Tools
- **bats-core** - Bash testing framework
- **act** - Run GitHub Actions locally

## Utilities

### File Operations
- **grep** - Text search
- **gawk** - Pattern scanning
- **gnu-tar** - Archiving utility
- **sevenzip** - 7-Zip archiver
- **wget** - Network downloader
- **pv** - Pipe viewer (progress bar)
- **less** - Pager
- **enscript** - Text to PostScript
- **coreutils** - GNU core utilities
- **gnu-getopt** - Command line parsing

### Security
- **gnupg** - GPG encryption
- **openssh** - SSH client/server
- **cf-vault** - CloudFlare vault
- **ejson2env** - Encrypted JSON to env vars

### System
- **kitchen-sync** - Fast file sync
- **chromedriver** - Chrome automation
- **phantomjs** - Headless browser
- **wkhtmltopdf** - HTML to PDF

### Terminal Productivity
- **openinterminal** - Open terminal from Finder

## NPM Global Packages
- **branchlet** - Git branch management
- **claude-self-reflect** - Claude AI tool
- **claudepoint** - Claude AI tool
- **eslint_d** - Fast ESLint daemon
- **eval-prompt** - Prompt evaluation
- **genaiscript** - AI script generation
- **markdownlint-cli** - Markdown linter
- **mcp-chrome-bridge** - MCP Chrome bridge
- **mcp-hub** - MCP hub
- **mcp-sequentialthinking-tools** - MCP tools
- **pyright-root** - Python type checker
- **token-limit** - Token counting tool
- **typescript** - TypeScript compiler
- **typescript-language-server** - TypeScript LSP
- **cronstrue** - Cron expression parser

## Custom Scripts & Local Binaries (~/local/bin)
- **basic-memory** - Memory tool
- **bm** - Bookmark manager
- **bunx** - Bun executor
- **claude-prompt-editor** - Claude prompt editor
- **copy-claude-response** - Claude response copier
- **distro** - Distribution info
- **ghostty-help** - Ghostty terminal help
- **ghostty-nvimhelp** - Ghostty Neovim help
- **httpx** - HTTP client
- **normalizer** - Text normalizer
- **numpy-config** - NumPy configuration
- **openai** - OpenAI CLI
- **tqdm** - Progress bar
- **f2py** - Fortran to Python

## Libraries & Dependencies (Major ones from Homebrew)
- Various compression: lz4, lzo, zstd, xz, brotli, snappy
- Image formats: libpng, libjpeg, libtiff, webp, giflib, libheif
- Video codecs: x264, x265, libvpx, svt-av1, rav1e
- Audio: flac, lame, opus, libvorbis, mpg123
- Cryptography: openssl@3, libgpg-error, libgcrypt
- Development: cmake, autoconf, automake, libtool, pkg-config
- Databases: libpq (PostgreSQL client)
- Text processing: icu4c, libiconv, libunistring
- Networking: curl, libssh2, nghttp2
- XML/HTML: libxml2, libxslt

## Fonts (Nerd Fonts)
- font-hack-nerd-font
- font-hurmit-nerd-font
- font-intone-mono-nerd-font
- font-iosevka-nerd-font
- font-meslo-lg-nerd-font
- font-symbols-only-nerd-font

## GUI Applications (Casks)
- emacs
- emacs-app
- flutter
- xquartz

## Notes
- Many tools have modern alternatives configured (eza for ls, bat for cat, etc.)
- Multiple versions of some tools installed (Python, PostgreSQL)
- Heavy use of Homebrew on macOS for package management
- Development environment supports multiple languages
- AWS and cloud tooling heavily present
- Modern terminal experience with Starship prompt and enhanced tools

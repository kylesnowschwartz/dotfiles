---
name: semtools
description: This skill should be used when the user asks to "parse PDFs", "search documents semantically", "use semtools", "search across files", "convert documents to markdown", "parse DOCX files", "semantic search", "search with embeddings", or mentions working with large document collections. Provides CLI tools for document parsing and semantic keyword search.
---

# Semtools

Semantic search and document parsing tools for the command line. A collection of high-performance CLI tools built with Rust for speed and reliability.

## Tools Overview

- **`parse`** - Convert documents (PDF, DOCX, PPTX, etc.) to markdown using LlamaParse API
- **`search`** - Local semantic keyword search using multilingual embeddings with cosine similarity
- **`workspace`** - Workspace management for caching embeddings over large collections

**Prerequisites:**
- `parse` requires `LLAMA_CLOUD_API_KEY` (free at https://cloud.llamaindex.ai)
- Install via `npm i -g @llamaindex/semtools` or `cargo install semtools`

## Parse CLI

```bash
parse --help
A CLI tool for parsing documents using various backends

Usage: parse [OPTIONS] <FILES>...

Arguments:
  <FILES>...  Files to parse

Options:
  -c, --config <CONFIG>    Path to the config file. Defaults to ~/.semtools_config.json
  -b, --backend <BACKEND>  The backend type to use for parsing. Defaults to `llama-parse`
  -v, --verbose            Verbose output while parsing
  -h, --help               Print help
```

Parse outputs filepaths to converted markdown files (cached at `~/.parse/`).

## Search CLI

```bash
search --help
A CLI tool for fast semantic keyword search

Usage: search [OPTIONS] <QUERY> [FILES]...

Arguments:
  <QUERY>     Query to search for (positional argument)
  [FILES]...  Files or directories to search

Options:
  -n, --n-lines <N_LINES>            Lines before/after to return as context [default: 3]
      --top-k <TOP_K>                Top-k files or texts to return [default: 3]
  -m, --max-distance <MAX_DISTANCE>  Return all results with distance below threshold (0.0+)
  -i, --ignore-case                  Case-insensitive search (default is false)
  -h, --help                         Print help
```

Search only works with text-based files. Use `parse` first for PDFs/DOCX.

## Workspace CLI

```bash
workspace --help
Manage semtools workspaces

Usage: workspace <COMMAND>

Commands:
  use     Use or create a workspace (prints export command to run)
  status  Show active workspace and basic stats
  prune   Remove stale or missing files from store
  help    Print this message
```

## Common Usage Patterns

### Basic Parse and Search

```bash
# Parse a PDF and search the content
parse document.pdf | xargs cat | search "error handling"

# Search within many files after parsing
parse my_docs/*.pdf | xargs search "API endpoints"

# Search with custom context and distance threshold
search "machine learning" *.txt --n-lines 30 --max-distance 0.3

# Chain parsing with semantic search
parse *.pdf | xargs search "financial projections" --n-lines 30

# Combine with grep for exact-match pre-filtering
parse *.pdf | xargs cat | grep -i "error" | search "network error" --max-distance 0.3

# Pipeline with content search
find . -name "*.md" | xargs parse | xargs search "installation"
```

### Using Workspaces

For repeated searches over the same files, create a workspace first:

```bash
# Create and activate workspace
workspace use my-workspace
export SEMTOOLS_WORKSPACE=my-workspace

# Search (embeddings cached after first run)
search "some keywords" ./large_dir/*.txt --n-lines 30 --top-k 10

# Subsequent searches use cached embeddings
search "different query" ./large_dir/*.txt --n-lines 30 --top-k 10

# Check workspace status
workspace status

# Clean up stale files
workspace prune
```

## Research Strategy for Large Collections

For systematic research across many documents:

```bash
# 1. Pre-parse everything (cached for reuse)
parse ./papers/*.pdf

# 2. Search broad to narrow with keyword combinations
parse *.pdf | xargs cat | search "machine learning, evaluation, benchmark" --n-lines 30 --max-distance 0.4
parse *.pdf | xargs cat | search "specific model, performance metrics" --n-lines 30 --max-distance 0.35

# 3. Combine with grep for filtering
parse *.pdf | xargs cat | search "Abstract" --n-lines 10 | grep -A 10 -i "relevant term"
```

Pre-parsing 900+ PDFs then running multiple searches: ~4 minutes, ~$0.70 in API costs.

## Critical Usage Tips

- **Always parse first** for non-text formats (PDF, DOCX, PPTX). Parse outputs markdown file paths.
- **Set `--ignore-case`** for general searches - tokenizer is case-sensitive by default.
- **Increase `--n-lines`** to 30-50 - default of 3 is too small for useful context.
- **Use workspaces** for repeated searches over the same files - avoids re-embedding.
- **Search uses keywords** - works best with keyword or comma-separated inputs, not full sentences.
- **`--max-distance`** for unknown result counts; `--top-k` for fixed counts.
- **Check `workspace status`** before creating new workspaces.

## Configuration

Config file at `~/.semtools_config.json`:

```json
{
  "parse": {
    "api_key": "your_llama_cloud_api_key",
    "num_ongoing_requests": 10
  }
}
```

Or use environment variable:
```bash
export LLAMA_CLOUD_API_KEY="your_key"
```

## Additional Resources

- **`references/README.md`** - Complete documentation including `ask` tool, advanced configuration options, and detailed parse_kwargs

---

**Repository:** [run-llama/semtools](https://github.com/run-llama/semtools) | MIT License

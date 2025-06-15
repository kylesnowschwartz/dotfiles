# MCP Server Setup Instructions

## Adding MCP Servers at User Level

Use the `-s user` flag to make servers available across all your projects:

### Basic Syntax

```bash
claude mcp add <server-name> -s user -- <command> [args...]
```

### Common MCP Servers

**Figma Developer MCP:**

```bash
claude mcp add figma-developer -s user -- npx -y figma-developer-mcp --figma-api-key=YOUR_FIGMA_TOKEN --stdio
```

**Playwright (Web Automation):**

```bash
claude mcp add playwright -s user -- npx @playwright/mcp
```

**Context7 (Library Docs):**

```bash
claude mcp add context7 -s user -- npx -y @upstash/context7-mcp@latest
```

**File System MCP:**

```bash
claude mcp add filesystem -s user -- npx @modelcontextprotocol/server-filesystem /path/to/directory
```

**SQLite MCP:**

```bash
claude mcp add sqlite -s user -- npx @modelcontextprotocol/server-sqlite --db-path /path/to/database.db
```

### Environment Variables

Add API keys and config with `-e`:

```bash
claude mcp add server-name -s user -e API_KEY=your-key-here -- npx package-name
```

### Management Commands

```bash
claude mcp list              # List all servers
claude mcp get server-name   # Show server details
claude mcp remove server-name -s user  # Remove user-level server
```

### Tips

- Use `-s user` for servers you want in all projects
- Use `-s local` for project-specific servers
- Check server documentation for required environment variables
- Restart Claude Code after adding new servers

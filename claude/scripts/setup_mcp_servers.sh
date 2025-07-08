#!/bin/bash

# Setup MCP Servers Script
# This script adds MCP servers to Claude based on the configuration in .envrc
# It checks for existing servers and warns about duplicates

set -e

# Global flags
SKIP_INSTALLED=false

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
  echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
  echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
  echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
  echo -e "${BLUE}[SETUP]${NC} $1"
}

# Function to check if MCP server exists
check_existing_server() {
  local server_name="$1"
  if claude mcp list | grep -q "^${server_name}:"; then
    return 0 # Server exists
  else
    return 1 # Server doesn't exist
  fi
}

# Function to check if local directory for project-specific MCP exists
check_local_directory() {
  local server_name="$1"
  local target_dir="$2"

  if [[ -n "$target_dir" ]] && [[ -d "$target_dir" ]]; then
    # Check if .claude directory exists (local scope indicator)
    if [[ -d "$target_dir/.claude" ]]; then
      return 0 # Local installation likely exists
    fi
  fi
  return 1 # No local installation
}

# Function to show existing server details
show_existing_server() {
  local server_name="$1"
  print_warning "Server '${server_name}' already exists:"
  claude mcp get "${server_name}"
  echo
}

# Function to show existing local installation details
show_existing_local_installation() {
  local server_name="$1"
  local target_dir="$2"
  print_warning "Server '${server_name}' already exists:"
  (cd "$target_dir" && claude mcp get "${server_name}")
  echo
}

# Function to add MCP server
add_mcp_server() {
  local server_name="$1"
  local command="$2"

  # Extract target directory for rollbar servers
  local target_dir=""
  if [[ "$server_name" == "rollbar-marketplace" ]]; then
    target_dir="/Users/kyle/Code/market/marketplace"
  elif [[ "$server_name" == "rollbar-solid-octane-service" ]]; then
    target_dir="/Users/kyle/Code/market/solid_octane_service"
  fi

  # Check for existing local installation first
  if [[ -n "$target_dir" ]] && check_local_directory "$server_name" "$target_dir"; then
    show_existing_local_installation "$server_name" "$target_dir"
    if [[ "$SKIP_INSTALLED" == true ]]; then
      print_status "Skipping ${server_name} (--skip-installed flag)"
      return 0
    fi
    read -p "Do you want to overwrite local installation? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
      print_warning "Skipping ${server_name}"
      return 0
    fi
  # Check for existing MCP server registration
  elif check_existing_server "${server_name}"; then
    show_existing_server "${server_name}"
    if [[ "$SKIP_INSTALLED" == true ]]; then
      print_status "Skipping ${server_name} (--skip-installed flag)"
      return 0
    fi
    read -p "Do you want to overwrite '${server_name}'? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
      print_warning "Skipping ${server_name}"
      return 0
    fi
  else
    print_status "Ready to install MCP server: ${server_name}"
    if [[ "$SKIP_INSTALLED" == true ]]; then
      # If skip-installed is true, install without prompting
      :
    else
      read -p "Install '${server_name}'? (Y/n): " -n 1 -r
      echo
      if [[ $REPLY =~ ^[Nn]$ ]]; then
        print_warning "Skipping ${server_name}"
        return 0
      fi
    fi
  fi

  print_status "Adding MCP server: ${server_name}"
  eval "${command}"
  if [ $? -eq 0 ]; then
    print_status "✓ Successfully added ${server_name}"
  else
    print_error "✗ Failed to add ${server_name}"
  fi
}

# Parse command line arguments
parse_args() {
  while [[ $# -gt 0 ]]; do
    case $1 in
    --skip-installed)
      SKIP_INSTALLED=true
      shift
      ;;
    -h | --help)
      echo "Usage: $0 [--skip-installed] [-h|--help]"
      echo "  --skip-installed  Skip prompts and automatically install only missing servers"
      echo "  -h, --help       Show this help message"
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      echo "Use -h or --help for usage information"
      exit 1
      ;;
    esac
  done
}

# Main setup function
main() {
  parse_args "$@"

  if [[ "$SKIP_INSTALLED" == true ]]; then
    print_header "Setting up MCP Servers (skipping already installed)"
  else
    print_header "Setting up MCP Servers from .envrc configuration"
  fi
  echo

  # Check if .envrc exists
  if [ ! -f ".envrc" ]; then
    print_error ".envrc file not found in current directory"
    exit 1
  fi

  # Source .envrc to get environment variables
  source .envrc

  # Array of MCP server configurations
  # Format: "server_name:command"
  declare -a mcp_servers=(
    "figma-developer:claude mcp add -s user figma-developer -- npx -y figma-developer-mcp --figma-api-key=$FIGMA_API_KEY --stdio"
    "figma-dev-mode-mcp-server:claude mcp add -s user figma-dev-mode-mcp-server --transport sse http://127.0.0.1:3845/sse"
    "buildkite:claude mcp add buildkite -s user -e BUILDKITE_API_TOKEN=$BUILDKITE_API_TOKEN -- docker run -i --rm -e BUILDKITE_API_TOKEN ghcr.io/buildkite/buildkite-mcp-server stdio
"
    "rollbar-marketplace:cd /Users/kyle/Code/market/marketplace && claude mcp add rollbar-marketplace -s local -t stdio -e ROLLBAR_ACCESS_TOKEN=$ROLLBAR_MARKETPLACE_TOKEN -- node /Users/kyle/Code/rollbar-mcp-server/build/index.js"
    "rollbar-solid-octane-service:cd /Users/kyle/Code/market/solid_octane_service && claude mcp add rollbar-solid-octane-service -s local -t stdio -e ROLLBAR_ACCESS_TOKEN=$ROLLBAR_SOLID_OCTANE_SERVICE_TOKEN -- node /Users/kyle/Code/rollbar-mcp-server/build/index.js"
    "github:claude mcp add github -s user -e GITHUB_PERSONAL_ACCESS_TOKEN=$GITHUB_API_KEY -- docker run -i --rm -e GITHUB_PERSONAL_ACCESS_TOKEN ghcr.io/github/github-mcp-server stdio --dynamic-toolsets"
    "playwright:claude mcp add playwright -s user -- npx @playwright/mcp --image-responses=omit --output-dir=./screenshots --headless --viewport-size 1920,1080"
    "context7:claude mcp add context7 -s user -- npx -y @upstash/context7-mcp@latest"
    "OpenMemory:claude mcp add -s user --transport sse OpenMemory http://localhost:8765/mcp/openmemory/sse/$(whoami)"
    "ref:claude mcp add ref -s user -- npx mcp-remote@0.1.0-0 https://api.ref.tools/mcp --header x-ref-api-key:[REF_API_KEY_REMOVED]"
    "Zapier:claude mcp add -s user --transport sse Zapier https://mcp.zapier.com/api/mcp/a/73617/sse"
    "zen:claude mcp add zen -s user -- /Users/kyle/Code/zen-mcp-server/.zen_venv/bin/python /Users/kyle/Code/zen-mcp-server/server.py"
  )

  # Process each MCP server
  for server_config in "${mcp_servers[@]}"; do
    IFS=':' read -r server_name command <<<"$server_config"
    add_mcp_server "$server_name" "$command"
    echo
  done

  print_header "Setup complete! Here are all configured MCP servers:"
  echo
  claude mcp list
}

# Run main function
main "$@"

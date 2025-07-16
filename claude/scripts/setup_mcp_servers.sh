#!/bin/bash

# Setup MCP Servers Script
# This script adds MCP servers to Claude based on the configuration in .envrc
# It checks for existing servers and warns about duplicates

set -e

# Global flags
SKIP_INSTALLED=false
SCOPE="user" # Default scope

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
  local command="$1"

  # Extract server name from the command
  local server_name
  if [[ "$command" =~ claude\ mcp\ add\ -s\ [^\ ]+\ ([^\ ]+) ]]; then
    server_name="${BASH_REMATCH[1]}"
  elif [[ "$command" =~ claude\ mcp\ add\ ([^\ ]+) ]]; then
    server_name="${BASH_REMATCH[1]}"
  else
    print_error "Could not extract server name from command: $command"
    return 1
  fi

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
    -s | --scope)
      if [[ -n "$2" && "$2" =~ ^(user|local|project)$ ]]; then
        SCOPE="$2"
        shift 2
      else
        echo "Error: Invalid scope '$2'. Valid scopes are: user, local, project"
        exit 1
      fi
      ;;
    -h | --help)
      echo "Usage: $0 [--skip-installed] [-s|--scope SCOPE] [-h|--help]"
      echo "  --skip-installed  Skip prompts and automatically install only missing servers"
      echo "  -s, --scope       Set installation scope (user, local, project). Default: user"
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
    print_header "Setting up MCP Servers (skipping already installed, scope: $SCOPE)"
  else
    print_header "Setting up MCP Servers from .envrc configuration (scope: $SCOPE)"
  fi
  echo

  # Check if .envrc exists
  if [ ! -f ".envrc" ]; then
    print_error ".envrc file not found in current directory"
    exit 1
  fi

  # MCP server configuration functions that return scope-aware commands
  get_figma_dev_mode_server() {
    echo "claude mcp add -s $SCOPE figma-dev-mode-mcp-server --transport sse http://127.0.0.1:3845/sse"
  }

  get_buildkite_server() {
    echo "claude mcp add buildkite -s $SCOPE -e BUILDKITE_API_TOKEN=$BUILDKITE_API_TOKEN -- docker run -i --rm -e BUILDKITE_API_TOKEN ghcr.io/buildkite/buildkite-mcp-server stdio"
  }

  get_rollbar_marketplace_server() {
    if [[ "$SCOPE" == "local" ]]; then
      echo "cd /Users/kyle/Code/market/marketplace && claude mcp add rollbar-marketplace -s local -t stdio -e ROLLBAR_ACCESS_TOKEN=$ROLLBAR_MARKETPLACE_TOKEN -- node $ROLLBAR_MCP_ABSOLUTE_PATH"
    else
      echo "claude mcp add rollbar-marketplace -s $SCOPE -t stdio -e ROLLBAR_ACCESS_TOKEN=$ROLLBAR_MARKETPLACE_TOKEN -- node $ROLLBAR_MCP_ABSOLUTE_PATH"
    fi
  }

  get_rollbar_solid_octane_server() {
    if [[ "$SCOPE" == "local" ]]; then
      echo "cd /Users/kyle/Code/market/solid_octane_service && claude mcp add rollbar-solid-octane-service -s local -t stdio -e ROLLBAR_ACCESS_TOKEN=$ROLLBAR_SOLID_OCTANE_SERVICE_TOKEN -- node $ROLLBAR_MCP_ABSOLUTE_PATH"
    else
      echo "claude mcp add rollbar-solid-octane-service -s $SCOPE -t stdio -e ROLLBAR_ACCESS_TOKEN=$ROLLBAR_SOLID_OCTANE_SERVICE_TOKEN -- node $ROLLBAR_MCP_ABSOLUTE_PATH"
    fi
  }

  get_github_server() {
    echo "claude mcp add github -s $SCOPE -e GITHUB_PERSONAL_ACCESS_TOKEN=$GITHUB_API_KEY -- docker run -i --rm -e GITHUB_PERSONAL_ACCESS_TOKEN ghcr.io/github/github-mcp-server stdio --dynamic-toolsets"
  }

  get_playwright_server() {
    echo "claude mcp add playwright -s $SCOPE -- npx @playwright/mcp --image-responses=omit --output-dir=./screenshots --headless --viewport-size 1920,1080"
  }

  get_context7_server() {
    echo "claude mcp add context7 -s $SCOPE -- npx -y @upstash/context7-mcp@latest"
  }

  get_ref_server() {
    echo "claude mcp add ref -s $SCOPE -- npx mcp-remote@0.1.0-0 https://api.ref.tools/mcp --header x-ref-api-key:$REF_API_KEY"
  }

  get_zapier_server() {
    echo "claude mcp add Zapier -s $SCOPE -t sse https://mcp.zapier.com/api/mcp/a/73617/sse"
  }

  get_zen_server() {
    echo "claude mcp add zen -s $SCOPE -- /Users/kyle/Code/zen-mcp-server/.zen_venv/bin/python /Users/kyle/Code/zen-mcp-server/server.py"
  }

  get_atlassian_server() {
    echo "claude mcp add atlassian -s $SCOPE \
-e CONFLUENCE_URL=$CONFLUENCE_URL \
-e CONFLUENCE_USERNAME=$CONFLUENCE_USERNAME \
-e CONFLUENCE_API_TOKEN=$JIRA_API_TOKEN \
-e JIRA_URL=$JIRA_BASE_URL \
-e JIRA_USERNAME=$JIRA_EMAIL \
-e JIRA_API_TOKEN=$JIRA_API_TOKEN \
-- docker run -i --rm \
-e CONFLUENCE_URL \
-e CONFLUENCE_USERNAME \
-e CONFLUENCE_API_TOKEN \
-e JIRA_URL \
-e JIRA_USERNAME \
-e JIRA_API_TOKEN \
mcp/atlassian"
  }

  # Array of MCP server configuration functions
  declare -a mcp_server_functions=(
    "get_figma_dev_mode_server"
    "get_buildkite_server"
    "get_rollbar_marketplace_server"
    "get_rollbar_solid_octane_server"
    "get_github_server"
    "get_playwright_server"
    "get_context7_server"
    "get_ref_server"
    "get_zapier_server"
    "get_zen_server"
    "get_atlassian_server"
  )

  # Process each MCP server
  for server_function in "${mcp_server_functions[@]}"; do
    command=$($server_function)
    add_mcp_server "$command"
    echo
  done

  print_header "Setup complete! Here are all configured MCP servers:"
  echo
  claude mcp list
}

# Run main function
main "$@"

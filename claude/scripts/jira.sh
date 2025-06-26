#!/bin/bash

# Jira CLI Tool
# Usage: ./jira [command] [options]

set -e

# Configuration - Read from environment variables
JIRA_API_KEY="${JIRA_API_KEY:-}"
JIRA_BASE_URL="${JIRA_BASE_URL:-}"
JIRA_EMAIL="${JIRA_EMAIL:-}"

# Atlassian API version
API_VERSION="3"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Validate required environment variables
if [[ -z "$JIRA_API_KEY" ]]; then
	echo -e "${RED}Error: JIRA_API_KEY environment variable is not set${NC}"
	echo "Please set it in your .envrc file or export it in your shell"
	exit 1
fi

# Function to print usage
usage() {
	echo "Jira CLI Tool"
	echo ""
	echo "Usage: $0 [command] [options]"
	echo ""
	echo "Commands:"
	echo "  setup                    - Configure Jira URL and email"
	echo "  list [project]           - List tickets (optionally filter by project)"
	echo "  show <ticket-id>         - Show details for a specific ticket"
	echo "  children <ticket-id>     - Show child issues (subtasks and epic children)"
	echo "  epic <epic-key>          - Show epic details with all child stories/tasks"
	echo "  search <jql>             - Search tickets using JQL"
	echo "  projects                 - List all projects"
	echo ""
	echo "Examples:"
	echo "  $0 setup"
	echo "  $0 list"
	echo "  $0 list PROJ"
	echo "  $0 show PROJ-123"
	echo "  $0 children PROJ-123"
	echo "  $0 epic PROJ-456"
	echo "  $0 search \"assignee = currentUser()\""
	echo "  $0 projects"
}

# Function to check if jq is installed
check_dependencies() {
	if ! command -v jq &>/dev/null; then
		echo -e "${RED}Error: jq is required but not installed.${NC}"
		echo "Please install jq: brew install jq"
		exit 1
	fi
}

# Function to load configuration
load_config() {
	# Auto-setup if not configured
	if [[ -z "$JIRA_BASE_URL" || -z "$JIRA_EMAIL" ]]; then
		echo -e "${YELLOW}Jira CLI not configured. Setting up now...${NC}"
		setup
	fi
	return 0
}

# Function to setup configuration
setup() {
	echo "Jira CLI Setup Instructions:"
	echo ""
	echo "Please set the following environment variables in your .envrc file:"
	echo ""
	echo "export JIRA_BASE_URL=\"https://your-company.atlassian.net\""
	echo "export JIRA_EMAIL=\"your-email@company.com\""
	echo ""
	echo "After updating .envrc, run 'direnv allow' to reload the environment."
	echo ""
	echo "Your JIRA_API_KEY is already configured."
}

# Function to make API request
api_request() {
	local endpoint="$1"
	local method="${2:-GET}"
	local data="$3"

	if ! load_config; then
		exit 1
	fi

	local auth_string="$JIRA_EMAIL:$JIRA_API_KEY"
	local encoded_auth
	encoded_auth=$(echo -n "$auth_string" | base64)

	local curl_args=(
		-s
		-X "$method"
		-H "Authorization: Basic $encoded_auth"
		-H "Content-Type: application/json"
		-H "Accept: application/json"
		-w "\n%{http_code}"
	)

	if [[ -n "$data" ]]; then
		curl_args+=(-d "$data")
	fi

	curl "${curl_args[@]}" "$JIRA_BASE_URL/rest/api/$API_VERSION/$endpoint"
}

# Function to list tickets
list_tickets() {
	local project="$1"
	local jql=""

	if [[ -n "$project" ]]; then
		jql="project = $project"
	fi

	echo "Fetching tickets..."

	local jql_encoded
	local full_response
	if [[ -n "$jql" ]]; then
		jql_encoded=$(printf '%s' "$jql" | jq -sRr @uri)
		full_response=$(api_request "search?jql=$jql_encoded&maxResults=50&fields=key,summary,status,priority,assignee")
	else
		full_response=$(api_request "search?maxResults=50&fields=key,summary,status,priority,assignee")
	fi

	local http_code
	local response
	http_code=$(echo "$full_response" | tail -n 1)
	response=$(echo "$full_response" | sed '$d')

	if [[ "$http_code" -ne 200 ]]; then
		echo -e "${RED}Error: HTTP $http_code${NC}"
		echo "$response" | jq -r '.errorMessages[]? // .errors? // "Unknown error"' 2>/dev/null || echo "$response"
		exit 1
	fi

	local tickets_output
	tickets_output=$(echo "$response" | jq -r '
	if .issues and (.issues | length > 0) then
		.issues[] |
			"\(.key)\t\(.fields.status.name)\t\(.fields.priority.name // "None")\t\(.fields.assignee.displayName // "Unassigned")\t\(.fields.summary)"
	elif .issues then
		"No tickets found"
	else
		"Error: " + (.errorMessages?[0] // "Invalid response")
	end
	')

	if [[ "$tickets_output" != "No tickets found" && "$tickets_output" != Error:* ]]; then
		echo -e "KEY\tSTATUS\tPRIORITY\tASSIGNEE\tSUMMARY"
		echo "$tickets_output" | column -t -s $'\t'
	else
		echo "$tickets_output"
	fi
}

# Function to show ticket details
show_ticket() {
	local ticket_id="$1"

	if [[ -z "$ticket_id" ]]; then
		echo -e "${RED}Error: Ticket ID required${NC}"
		echo "Usage: $0 show <ticket-id>"
		exit 1
	fi

	echo "Fetching ticket details for $ticket_id..."

	local full_response
	full_response=$(api_request "issue/$ticket_id")
	local http_code
	local response
	http_code=$(echo "$full_response" | tail -n 1)
	response=$(echo "$full_response" | sed '$d')

	if [[ "$http_code" -ne 200 ]]; then
		echo -e "${RED}Error: HTTP $http_code${NC}"
		echo "$response" | jq -r '.errorMessages[]? // .errors? // "Ticket not found or access denied"' 2>/dev/null || echo "$response"
		exit 1
	fi

	echo "$response" | jq -r '
	if .key then
		"Key: \(.key)",
		"Summary: \(.fields.summary)",
		"Status: \(.fields.status.name)",
		"Priority: \(.fields.priority.name // "None")",
		"Assignee: \(.fields.assignee.displayName // "Unassigned")",
		"Reporter: \(.fields.reporter.displayName)",
		"Project: \(.fields.project.name) (\(.fields.project.key))",
		"Issue Type: \(.fields.issuetype.name)",
		"Created: \(.fields.created | sub("\\.[0-9]+"; "") | strptime("%Y-%m-%dT%H:%M:%S%z") | strftime("%Y-%m-%d %H:%M:%S %Z"))",
		"Updated: \(.fields.updated | sub("\\.[0-9]+"; "") | strptime("%Y-%m-%dT%H:%M:%S%z") | strftime("%Y-%m-%d %H:%M:%S %Z"))",
		"",
		"Description:",
		(if .fields.description then
		if .fields.description.type == "doc" then
			[.fields.description.content[] |
				if .type == "paragraph" then
					[.content[]? | select(.type == "text") | .text] | join("")
				elif .type == "codeBlock" then
					"```\\n" + ([.content[]? | select(.type == "text") | .text] | join("")) + "\\n```"
				elif .type == "bulletList" then
					[.content[]? | "• " + ([.content[]?.content[]? | select(.type == "text") | .text] | join(""))] | join("\\n")
				elif .type == "orderedList" then
					[.content[]? | "1. " + ([.content[]?.content[]? | select(.type == "text") | .text] | join(""))] | join("\\n")
				elif .type == "heading" then
					(if (.attrs.level // 1) == 1 then "#" elif (.attrs.level // 1) == 2 then "##" elif (.attrs.level // 1) == 3 then "###" else "####" end) + " " + ([.content[]? | select(.type == "text") | .text] | join(""))
				elif .type == "blockquote" then
					"> " + ([.content[]?.content[]? | select(.type == "text") | .text] | join(""))
				else
					[.content[]? | select(.type == "text") | .text] | join("")
				end] | join("\\n\\n") | if . == "" then "No description" else . end
			else
				.fields.description // "No description"
			end
		else
			"No description"
		end)
	else
		"Error: " + (.errorMessages?[0] // "Invalid response")
	end
	' | sed 's/\\n/\n/g'

	# Check if this issue has children and show them automatically
	local issue_type
	local has_subtasks
	issue_type=$(echo "$response" | jq -r '.fields.issuetype.name')
	has_subtasks=$(echo "$response" | jq -r '.fields.subtasks | length')

	if [[ "$has_subtasks" -gt 0 ]] || [[ "$issue_type" == "Epic" ]]; then
		echo ""
		echo "=========================="
		echo ""
		show_children "$ticket_id"
	fi
}

# Function to search tickets with JQL
search_tickets() {
	local jql="$1"

	if [[ -z "$jql" ]]; then
		echo -e "${RED}Error: JQL query required${NC}"
		echo "Usage: $0 search \"<jql-query>\""
		echo "Example: $0 search \"assignee = currentUser()\""
		exit 1
	fi

	echo "Searching with JQL: $jql"

	local jql_encoded
	local full_response
	jql_encoded=$(printf '%s' "$jql" | jq -sRr @uri)
	full_response=$(api_request "search?jql=$jql_encoded&maxResults=50&fields=key,summary,status,priority,assignee")
	local http_code
	local response
	http_code=$(echo "$full_response" | tail -n 1)
	response=$(echo "$full_response" | sed '$d')

	if [[ "$http_code" -ne 200 ]]; then
		echo -e "${RED}Error: HTTP $http_code${NC}"
		echo "$response" | jq -r '.errorMessages[]? // .errors? // "Invalid JQL query"' 2>/dev/null || echo "$response"
		exit 1
	fi

	local search_output
	search_output=$(echo "$response" | jq -r '
	if .issues and (.issues | length > 0) then
		.issues[] |
			"\(.key)\t\(.fields.status.name)\t\(.fields.priority.name // "None")\t\(.fields.assignee.displayName // "Unassigned")\t\(.fields.summary)"
	elif .issues then
		"No tickets found matching the query"
	else
		"Error: " + (.errorMessages?[0] // "Invalid response")
	end
	')

	if [[ "$search_output" != "No tickets found matching the query" && "$search_output" != Error:* ]]; then
		echo -e "KEY\tSTATUS\tPRIORITY\tASSIGNEE\tSUMMARY"
		echo "$search_output" | column -t -s $'\t'
	else
		echo "$search_output"
	fi
}

# Function to show child issues (subtasks)
show_children() {
	local ticket_id="$1"

	if [[ -z "$ticket_id" ]]; then
		echo -e "${RED}Error: Ticket ID required${NC}"
		echo "Usage: $0 children <ticket-id>"
		exit 1
	fi

	echo "Fetching child issues for $ticket_id..."

	# First get the parent issue to check for subtasks
	local full_response
	full_response=$(api_request "issue/$ticket_id?fields=subtasks,issuelinks,issuetype")
	local http_code
	local response
	http_code=$(echo "$full_response" | tail -n 1)
	response=$(echo "$full_response" | sed '$d')

	if [[ "$http_code" -ne 200 ]]; then
		echo -e "${RED}Error: HTTP $http_code${NC}"
		echo "$response" | jq -r '.errorMessages[]? // .errors? // "Ticket not found or access denied"' 2>/dev/null || echo "$response"
		exit 1
	fi

	# Check if issue has subtasks
	local has_subtasks
	has_subtasks=$(echo "$response" | jq -r '.fields.subtasks | length')

	if [[ "$has_subtasks" -gt 0 ]]; then
		echo -e "${GREEN}Subtasks for $ticket_id:${NC}"
		echo -e "KEY\tSTATUS\tPRIORITY\tASSIGNEE\tSUMMARY"
		echo "$response" | jq -r '.fields.subtasks[] | "\(.key)\t\(.fields.status.name)\t\(.fields.priority.name // "None")\t\(.fields.assignee.displayName // "Unassigned")\t\(.fields.summary)"' | column -t -s $'\t'
	else
		echo -e "${YELLOW}No subtasks found for $ticket_id${NC}"
	fi

	# Check if this is an Epic and search for child issues using Epic Link
	local issue_type
	issue_type=$(echo "$response" | jq -r '.fields.issuetype.name')

	if [[ "$issue_type" == "Epic" ]]; then
		echo ""
		echo -e "${GREEN}Epic children for $ticket_id:${NC}"

		# Search for issues linked to this epic using parent field
		local epic_children_response
		local jql="parent = $ticket_id"
		local jql_encoded
		jql_encoded=$(printf '%s' "$jql" | jq -sRr @uri)
		epic_children_response=$(api_request "search?jql=$jql_encoded&maxResults=100&fields=key,summary,status,priority,assignee,issuetype")

		local children_http_code
		local children_response
		children_http_code=$(echo "$epic_children_response" | tail -n 1)
		children_response=$(echo "$epic_children_response" | sed '$d')

		if [[ "$children_http_code" -eq 200 ]]; then
			local child_count
			child_count=$(echo "$children_response" | jq -r '.issues | length')
			if [[ "$child_count" -gt 0 ]]; then
				echo -e "KEY\tTYPE\tSTATUS\tPRIORITY\tASSIGNEE\tSUMMARY"
				echo "$children_response" | jq -r '.issues[] | "\(.key)\t\(.fields.issuetype.name)\t\(.fields.status.name)\t\(.fields.priority.name // "None")\t\(.fields.assignee.displayName // "Unassigned")\t\(.fields.summary)"' | column -t -s $'\t'
			else
				echo -e "${YELLOW}No child issues found for Epic $ticket_id${NC}"
			fi
		else
			echo -e "${YELLOW}Could not fetch epic children (might need Epic Link custom field)${NC}"
		fi
	fi
}

# Function to show epic details with all children
show_epic_details() {
	local epic_key="$1"

	if [[ -z "$epic_key" ]]; then
		echo -e "${RED}Error: Epic key required${NC}"
		echo "Usage: $0 epic <epic-key>"
		exit 1
	fi

	echo "Fetching epic details for $epic_key..."

	# First show the epic details
	show_ticket "$epic_key"

	echo ""
	echo "=========================="
	echo ""

	# Then show all children
	show_children "$epic_key"
}

# Function to list projects
list_projects() {
	echo "Fetching projects..."

	local full_response
	full_response=$(api_request "project")
	local http_code
	local response
	http_code=$(echo "$full_response" | tail -n 1)
	response=$(echo "$full_response" | sed '$d')

	if [[ "$http_code" -ne 200 ]]; then
		echo -e "${RED}Error: HTTP $http_code${NC}"
		echo "$response" | jq -r '.errorMessages[]? // .errors? // "Failed to fetch projects"' 2>/dev/null || echo "$response"
		exit 1
	fi

	local projects_output
	projects_output=$(echo "$response" | jq -r '
	if type == "array" and length > 0 then
		.[] |
			"\(.key)\t\(.name)\t\(.projectTypeKey)\t\(.lead.displayName // "No lead")"
	elif type == "array" then
		"No projects found"
	else
		"Error: " + (.errorMessages?[0] // "Invalid response")
	end
	')

	if [[ "$projects_output" != "No projects found" && "$projects_output" != Error:* ]]; then
		echo -e "KEY\tNAME\tTYPE\tLEAD"
		echo "$projects_output" | column -t -s $'\t'
	else
		echo "$projects_output"
	fi
}

# Main script logic
main() {
	check_dependencies

	case "$1" in
	"setup")
		setup
		;;
	"list")
		list_tickets "$2"
		;;
	"show")
		show_ticket "$2"
		;;
	"children")
		show_children "$2"
		;;
	"epic")
		show_epic_details "$2"
		;;
	"search")
		search_tickets "$2"
		;;
	"projects")
		list_projects
		;;
	"--help" | "-h" | "help" | "")
		usage
		;;
	*)
		echo -e "${RED}Error: Unknown command '$1'${NC}"
		echo ""
		usage
		exit 1
		;;
	esac
}

main "$@"

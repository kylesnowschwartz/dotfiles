#!/bin/bash

# SuperClaude Context-Aware Command Suggester
# Analyzes git status, recent changes, and file patterns to recommend commands

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color
BOLD='\033[1m'

echo -e "${BLUE}${BOLD}🔍 SuperClaude Context Analyzer${NC}"
echo "================================"

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo -e "${RED}Not in a git repository${NC}"
    exit 1
fi

# Gather context
BRANCH=$(git branch --show-current)
MODIFIED_FILES=$(git diff --name-only 2>/dev/null || echo "")
STAGED_FILES=$(git diff --cached --name-only 2>/dev/null || echo "")
UNTRACKED_FILES=$(git ls-files --others --exclude-standard 2>/dev/null || echo "")
RECENT_COMMITS=$(git log --oneline -5 2>/dev/null || echo "")
FILE_COUNT=$(echo "$MODIFIED_FILES" | grep -c . || echo 0)

echo -e "\n${BOLD}Current Context:${NC}"
echo "- Branch: $BRANCH"
echo "- Modified files: $FILE_COUNT"

# Analyze file types
HAS_TESTS=false
HAS_FRONTEND=false
HAS_BACKEND=false
HAS_CONFIG=false
HAS_DOCS=false
HAS_SECURITY=false

for file in $MODIFIED_FILES $STAGED_FILES; do
    case "$file" in
        *.test.*|*.spec.*|__tests__/*)
            HAS_TESTS=true
            ;;
        *.tsx|*.jsx|*.css|*.scss|components/*|pages/*|src/ui/*)
            HAS_FRONTEND=true
            ;;
        *api/*|*.sql|*controller*|*service*|*model*|server/*)
            HAS_BACKEND=true
            ;;
        *.config.*|*.json|*.yml|*.yaml|Dockerfile|.env*)
            HAS_CONFIG=true
            ;;
        *.md|docs/*|README*)
            HAS_DOCS=true
            ;;
        *auth*|*security*|*password*|*token*)
            HAS_SECURITY=true
            ;;
    esac
done

echo -e "\n${BOLD}Detected Patterns:${NC}"
[[ $HAS_FRONTEND == true ]] && echo "- Frontend changes detected"
[[ $HAS_BACKEND == true ]] && echo "- Backend changes detected"
[[ $HAS_TESTS == true ]] && echo "- Test changes detected"
[[ $HAS_CONFIG == true ]] && echo "- Configuration changes detected"
[[ $HAS_DOCS == true ]] && echo "- Documentation changes detected"
[[ $HAS_SECURITY == true ]] && echo "- Security-related changes detected"

# Check recent commit messages for patterns
if echo "$RECENT_COMMITS" | grep -qi "fix\|bug\|error"; then
    RECENT_FIXES=true
else
    RECENT_FIXES=false
fi

if echo "$RECENT_COMMITS" | grep -qi "feat\|add\|implement"; then
    RECENT_FEATURES=true
else
    RECENT_FEATURES=false
fi

if echo "$RECENT_COMMITS" | grep -qi "refactor\|clean\|improve"; then
    RECENT_REFACTOR=true
else
    RECENT_REFACTOR=false
fi

echo -e "\n${BOLD}${GREEN}📋 Recommended SuperClaude Commands:${NC}\n"

# Primary recommendations based on context
if [[ $FILE_COUNT -eq 0 ]]; then
    echo -e "${YELLOW}No modified files. Starting fresh?${NC}"
    echo -e "  ${BLUE}/design --feature --persona-architect --plan${NC}"
    echo -e "  ${BLUE}/load --context --analyze${NC}"
    echo ""
fi

if [[ $HAS_SECURITY == true ]]; then
    echo -e "${RED}🔐 Security-related changes detected:${NC}"
    echo -e "  ${BLUE}/scan --security --persona-security --owasp --strict${NC}"
    echo -e "  ${BLUE}/review --security --persona-security --think-hard${NC}"
    echo ""
fi

if [[ $HAS_TESTS == true ]]; then
    echo -e "${GREEN}🧪 Test changes detected:${NC}"
    echo -e "  ${BLUE}/test --affected --persona-qa --coverage${NC}"
    echo -e "  ${BLUE}/analyze --coverage --persona-qa --gaps${NC}"
    echo ""
fi

if [[ $HAS_FRONTEND == true ]]; then
    echo -e "${YELLOW}🎨 Frontend changes detected:${NC}"
    echo -e "  ${BLUE}/build --frontend --persona-frontend --magic --watch${NC}"
    echo -e "  ${BLUE}/improve --ui --persona-frontend --accessible${NC}"
    if [[ $BRANCH == *"main"* ]] || [[ $BRANCH == *"master"* ]]; then
        echo -e "  ${BLUE}/review --ui --persona-frontend --strict --validate${NC}"
    fi
    echo ""
fi

if [[ $HAS_BACKEND == true ]]; then
    echo -e "${BLUE}⚙️ Backend changes detected:${NC}"
    echo -e "  ${BLUE}/build --api --persona-backend --tdd --seq${NC}"
    echo -e "  ${BLUE}/test --integration --persona-backend --mock${NC}"
    if [[ $HAS_SECURITY == true ]]; then
        echo -e "  ${BLUE}/scan --api --persona-security --penetration${NC}"
    fi
    echo ""
fi

if [[ $HAS_CONFIG == true ]]; then
    echo -e "${BOLD}⚙️ Configuration changes detected:${NC}"
    echo -e "  ${BLUE}/review --config --persona-architect --validate${NC}"
    echo -e "  ${BLUE}/analyze --impact --persona-architect --dependencies${NC}"
    echo ""
fi

# Branch-specific recommendations
if [[ $BRANCH == *"fix"* ]] || [[ $BRANCH == *"bug"* ]] || [[ $RECENT_FIXES == true ]]; then
    echo -e "${RED}🐛 Bug fix context detected:${NC}"
    echo -e "  ${BLUE}/troubleshoot --bug --persona-analyzer --five-whys --seq${NC}"
    echo -e "  ${BLUE}/test --regression --persona-qa --related${NC}"
    echo ""
fi

if [[ $BRANCH == *"feature"* ]] || [[ $RECENT_FEATURES == true ]]; then
    echo -e "${GREEN}✨ Feature development detected:${NC}"
    echo -e "  ${BLUE}/build --feature --persona-architect --tdd --plan${NC}"
    echo -e "  ${BLUE}/document --feature --persona-mentor --examples${NC}"
    echo ""
fi

if [[ $BRANCH == *"refactor"* ]] || [[ $RECENT_REFACTOR == true ]]; then
    echo -e "${YELLOW}♻️ Refactoring detected:${NC}"
    echo -e "  ${BLUE}/analyze --complexity --persona-refactorer --metrics${NC}"
    echo -e "  ${BLUE}/improve --refactor --persona-refactorer --plan --safe${NC}"
    echo ""
fi

if [[ $BRANCH == *"release"* ]] || [[ $BRANCH == *"prod"* ]]; then
    echo -e "${RED}🚀 Production/Release branch:${NC}"
    echo -e "  ${BLUE}/review --comprehensive --persona-security --prod --strict${NC}"
    echo -e "  ${BLUE}/test --comprehensive --persona-qa --coverage 90%${NC}"
    echo -e "  ${BLUE}/scan --full --persona-security --compliance${NC}"
    echo ""
fi

# Workflow suggestions
echo -e "${BOLD}${GREEN}🔄 Suggested Workflows:${NC}\n"

if [[ $FILE_COUNT -gt 10 ]]; then
    echo -e "${YELLOW}Large changeset detected. Recommended workflow:${NC}"
    echo "  1. ${BLUE}/analyze --impact --persona-architect --dependencies${NC}"
    echo "  2. ${BLUE}/review --comprehensive --persona-refactorer --plan${NC}"
    echo "  3. ${BLUE}/test --affected --persona-qa --smart${NC}"
    echo ""
fi

if [[ $HAS_FRONTEND == true ]] && [[ $HAS_BACKEND == true ]]; then
    echo -e "${YELLOW}Full-stack changes detected. Recommended workflow:${NC}"
    echo "  1. ${BLUE}/analyze --architecture --persona-architect --full-stack${NC}"
    echo "  2. ${BLUE}/build --api --persona-backend --tdd${NC}"
    echo "  3. ${BLUE}/build --ui --persona-frontend --integrated${NC}"
    echo "  4. ${BLUE}/test --e2e --persona-qa --comprehensive${NC}"
    echo ""
fi

# Quick discovery
echo -e "${BOLD}${BLUE}🎯 Quick Discovery:${NC}"
echo -e "  ${GREEN}/suggest --analyze${NC} - Get personalized recommendations"
echo -e "  ${GREEN}/suggest --interactive${NC} - Guided command selection"
echo -e "  ${GREEN}/suggest \"your task description\"${NC} - Natural language query"

echo -e "\n${BOLD}Tip:${NC} Add ${YELLOW}--dry-run${NC} to any command to preview without making changes"

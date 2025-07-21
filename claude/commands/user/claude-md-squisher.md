# Markdown Squisher

**Context Optimization Tool** - Reduce Markdown bloat while preserving all AI functionality.

## Instructions

You are a **Context Optimization Specialist** tasked with dramatically reducing Claude Code session startup context consumption while maintaining all essential AI instructions and capabilities.

### Phase 1: Analysis and Reporting

**Step 1: Context Consumption Analysis**

- Identify all files read at Claude Code session start
- Read and analyze CLAUDE.md and related initialization files
- Calculate current token/character count for session initialization

**Generate Context Consumption Report** Create `context-optimization-report.md` with:

- Current total characters/estimated tokens consumed at startup
- Breakdown by file (filename, size, purpose)
- Identification of redundant content
- Identification of human-oriented content that can be AI-optimized
- Recommended consolidation opportunities
- Estimated reduction potential (target: 60-80% reduction)

**Content Analysis Categories** For each file, categorize content as:

- **Essential AI Instructions**: Must keep, but can be condensed
- **Redundant Information**: Duplicated across files
- **Human Context**: Can be dramatically simplified for AI
- **Verbose Explanations**: Can be converted to concise directives
- **Examples**: Can be reduced or referenced externally

### Phase 2: Optimization Implementation

**Step 2: Create Optimized Core Files**

- Create optimized CLAUDE.md
- Maintain all functional instructions
- Convert human explanations to concise AI directives
- Remove redundant context
- Use bullet points and structured format for faster parsing
- Target: Reduce to 30-40% of current size

**Consolidate Initialization Content**

- Merge critical content from multiple startup files into single sources
- Create concise reference files that point to detailed docs when needed
- Eliminate content duplication across files

**Optimize Content Format for AI**

- Convert narrative explanations to structured lists
- Use consistent, concise command language
- Remove human-friendly but AI-unnecessary context
- Standardize formatting for faster AI parsing

**Step 3: Create Reference System**

- Create lightweight reference index
- Single file that points to detailed documentation when needed
- AI can reference full docs only when specific details required
- Maintain separation between "always loaded" vs "reference when needed"

**Update File References**

- Ensure optimized files properly reference detailed docs
- Update any configuration that points to old file structures

### Implementation Rules

**Content Optimization Guidelines**

- **Preserve Functionality**: Every instruction and rule must be maintained
- **AI-First Language**: Write for Claude AI consumption, not human readers
- **Concise Directives**: Convert explanations to actionable commands
- **Structured Format**: Use consistent markdown structure for fast parsing
- **No Version Dates**: Remove any date/version indicators from content
- **Reference Don't Duplicate**: Point to detailed docs rather than embedding

**File Handling**

- **Backup Strategy**: Not needed (git repository)
- **Naming Convention**: Use kebab-case, concise descriptions
- **Location**: Keep optimized files in same locations as originals
- **Archive**: Move detailed/verbose originals to /archive if they contain useful reference info

### Success Criteria

- Reduce startup context consumption by 60-80%
- Maintain all functional AI instructions and capabilities
- Preserve ability to reference detailed information when needed
- Ensure no broken internal references
- Confirm Claude Code sessions start with dramatically reduced context usage

### Deliverables

- `context-optimization-report.md` - Analysis of current vs optimized consumption
- Optimized core files (CLAUDE.md and other startup files)
- Reference index for accessing detailed documentation
- Updated internal links and references

Execute this analysis and optimization focusing on maximum context reduction while preserving all AI functionality.

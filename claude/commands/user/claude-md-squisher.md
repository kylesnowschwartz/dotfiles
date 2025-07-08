Objective Analyze and optimize the immediate context consumption when starting Claude Code sessions by reducing bloated markdown files while preserving all essential information for AI consumption.

Current Problem CLAUDE.md and other initialization files consume significant context window space

Multiple large documentation files are read at session start

Content is written for humans rather than optimized for AI consumption

Need to maintain functionality while dramatically reducing token consumption

Phase 1: Analysis and Reporting Step 1: Context Consumption Analysis Identify all files read at Claude Code session start

Read and analyze CLAUDE.md

Identify any other files automatically loaded (check .serena/project.yml and other config files)

Calculate current token/character count for session initialization

Generate Context Consumption Report Create a report file: context-optimization-report.md with:

Current total characters/estimated tokens consumed at startup

Breakdown by file (filename, size, purpose)

Identification of redundant content

Identification of human-oriented content that can be AI-optimized

Recommended consolidation opportunities

Estimated reduction potential (target: 60-80% reduction)

Content Analysis Categories For each file, categorize content as:

Essential AI Instructions: Must keep, but can be condensed

Redundant Information: Duplicated across files

Human Context: Can be dramatically simplified for AI

Verbose Explanations: Can be converted to concise directives

Examples: Can be reduced or referenced externally

Phase 2: Optimization Implementation Step 2: Create Optimized Core Files Create optimized CLAUDE.md

Maintain all functional instructions

Convert human explanations to concise AI directives

Remove redundant context

Use bullet points and structured format for faster parsing

Target: Reduce to 30-40% of current size

Consolidate Initialization Content

Merge critical content from multiple startup files into single sources

Create concise reference files that point to detailed docs when needed

Eliminate content duplication across files

Optimize Content Format for AI

Convert narrative explanations to structured lists

Use consistent, concise command language

Remove human-friendly but AI-unnecessary context

Standardize formatting for faster AI parsing

Step 3: Create Reference System Create lightweight reference index

Single file that points to detailed documentation when needed

AI can reference full docs only when specific details required

Maintain separation between "always loaded" vs "reference when needed"

Update file references

Ensure optimized files properly reference detailed docs

Update any configuration that points to old file structures

Implementation Rules Content Optimization Guidelines Preserve Functionality: Every instruction and rule must be maintained

AI-First Language: Write for Claude AI consumption, not human readers

Concise Directives: Convert explanations to actionable commands

Structured Format: Use consistent markdown structure for fast parsing

No Version Dates: Remove any date/version indicators from content

Reference Don't Duplicate: Point to detailed docs rather than embedding

File Handling Backup Strategy: Not needed (git repository)

Naming Convention: Use kebab-case, concise descriptions

Location: Keep optimized files in same locations as originals

Archive: Move detailed/verbose originals to /archive if they contain useful reference info

Success Criteria Reduce startup context consumption by 60-80%

Maintain all functional AI instructions and capabilities

Preserve ability to reference detailed information when needed

Ensure no broken internal references

Confirm Claude Code sessions start with dramatically reduced context usage

Deliverables context-optimization-report.md - Analysis of current vs optimized consumption

Optimized core files (CLAUDE.md and other startup files)

Reference index for accessing detailed documentation

Updated internal links and references

Execute this analysis and optimization focusing on maximum context reduction while preserving all AI functionality.

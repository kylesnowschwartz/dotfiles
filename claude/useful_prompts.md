# Useful Prompts

## Breaking Changes Investigation

Use the git api to know what specific breaking changes were introduced in
@envato/sso-forms-standalone between 3.0.1 and 3.4.1. That will answer your
second question. There might be something known about its functionality but it's
up to you to determine what we can know by gathering information available from
github. We could even clone the repo if truly necessary. The tests are cucumber
tests, meaning we would need to be able to parse a browser to see if any
javascript errors are failing the tests without outputting to the standard logs.
If you need assistance, you should ask me to help.

## API Testing

I need to test the Envato API endpoint
https://api.envato.com/v3/market/author/sale with production purchase code
3e2a5ccb-af24-40b0-bad0-093d12623104 for author ID 1246249 to investigate a user
report.

Context:

- I'm working in the Market workspace (25+ repo collection)
- I have production access via AWS SSM/detached instances
- The marketplace has internal API access with X-Envato-Secret headers
- I can SSH to production via script/aws/get-detached-instance

Goal: Get the actual production API response to verify endpoint behavior.

Please find the fastest path to test this endpoint with real production data,
preferring internal production access over external OAuth flows.

---

You are a senior software architect with expertise in AI tooling integration and
semantic search systems. You have experience with both txtai and Claude Code,
and understand enterprise-grade implementation requirements.

**TASK:** Create a comprehensive txtai integration plan for Claude Code to
enhance codebase understanding in a large production marketplace repository.

**REPOSITORY CONTEXT:**

- Path: /Users/kyle/Code/market/marketplace
- Type: Large production repository
- Goal: Match/exceed Cursor's built-in indexing capabilities
- User: Senior developer focused on production-quality AI assistant features

**REQUIRED DELIVERABLES:**

<implementation_plan> **Technical Architecture:**

- Exact txtai configuration for large codebase indexing
- Integration points with Claude Code's existing tooling
- Performance considerations and optimization strategies

**Step-by-Step Setup:**

1. Prerequisites and dependencies
2. Installation and configuration commands
3. Index creation and maintenance procedures
4. Integration with Claude Code workflows

**Practical Benefits Analysis:**

- Specific capabilities this adds to Claude Code
- Concrete examples of improved developer workflows
- Honest assessment of limitations vs. Cursor's approach </implementation_plan>

**CONSTRAINTS:**

- Focus on production-ready implementation only
- No time estimates or ROI projections
- Be direct about limitations - don't oversell capabilities
- Assume the user can fill knowledge gaps when asked

**SUCCESS CRITERIA:**

- Setup can be completed by following the instructions exactly
- Implementation provides measurable improvement in code understanding
- Solution is robust enough for daily production use
- Clearly demonstrates technical advantages over baseline Claude Code

**REASONING REQUIREMENT:** For each major technical decision, explain:

1. Why this approach over alternatives
2. What specific problem it solves
3. How it integrates with existing workflows

If you need clarification on the repository structure, existing tooling, or
specific use cases, ask specific questions rather than making assumptions.

---

**Role**: You are a Technical Project Architect specializing in AI/ML
marketplace implementations. Your expertise includes multi-agent coordination,
system design, and incremental delivery planning.

**Task**: Analyze the @txtai-marketplace-implementation.md plan and design a
multi-agent execution strategy.

<analysis_steps>

1. **Deep Analysis**: Examine the implementation plan's architecture,
   dependencies, and complexity
2. **Agent Identification**: Determine optimal number and specialization of
   parallel agents
3. **Coordination Design**: Define how agents will work in harmony without
   conflicts
4. **Resource Assessment**: Identify what knowledge/access you need from me
5. **Risk Mitigation**: Plan for integration points and potential blockers

</analysis_steps>

<deliverable_format>

Produce a comprehensive "Multi-Agent Execution Plan" document containing:

<agent_specifications> For each agent:

- **Agent Name & Role**: Clear specialization (e.g., "Backend API Agent",
  "Frontend UX Agent")
- **Concrete Tasks**: 3-5 specific, measurable deliverables
- **Dependencies**: What this agent needs from other agents
- **Success Criteria**: How we'll know this agent succeeded
- **Timeline**: Estimated completion milestones </agent_specifications>

<coordination_matrix>

- **Integration Points**: Where agents must synchronize
- **Communication Protocol**: How agents share progress/blockers
- **Conflict Resolution**: Process for handling overlapping work
  </coordination_matrix>

<human_requirements>

- **Knowledge Needed**: Specific domain expertise you require from me
- **Access Required**: APIs, credentials, or systems I need to provide
- **Decision Points**: Key choices where you need my input </human_requirements>

<clarifying_questions>

List 3-5 specific questions that will significantly improve the execution plan

</clarifying_questions>

</deliverable_format>

<success_criteria> The plan should enable:

- Parallel development with minimal blocking dependencies
- Clear progress tracking and milestone visibility
- Rapid iteration and course correction capability
- Integration readiness at each milestone </success_criteria>

**Examples**:

Good agent coordination example:

- Frontend Agent builds mockups → Backend Agent implements APIs → Integration
  Agent connects them
- Each agent has clear handoff points and doesn't wait for complete completion
  of others

Poor coordination example:

- All agents working on the same component simultaneously
- Agents with unclear boundaries causing duplicate work

Begin your analysis now, requesting any missing context needed to create an
effective multi-agent execution plan.

---

<!-- vim: set textwidth=80 wrap linebreak: -->

---
name: update-worklog
description: Sync worklog.yaml with Jira tickets assigned to me across projects
argument-hint: "[optional: project codes like 'ATH MTMS' or 'all']"
---

# Update Worklog

User Instructions: $ARGUMENT

Synchronize @/Users/kyle/Code/Envato-non-market/envato-author-domain/worklog.yaml with Jira to ensure all assigned tickets are tracked with correct completion dates.

## Workflow

### Step 1: Load Jira CLI Skill

Invoke the `jira-cli:jira-cli` skill to enable Jira commands.

### Step 2: Determine Projects to Query

Check the $ARGUMENT :
- If specific projects provided (e.g., `ATH MTMS`), use those
- If `all` or no argument, query primary project: **ATH, MTMS**
- Can be extended by user request

### Step 3: Fetch Current State

Run in parallel:
1. Read `worklog.yaml` to get current entries
2. Find the oldest `completed` date in worklog.yaml
3. Query Jira for tickets assigned to me, filtering by date:
   ```bash
   # Calculate cutoff: oldest worklog date minus 30 days
   # For each project:
   jira issue list -p PROJECT -a $(jira me) -q "updated >= 'YYYY-MM-DD'" --plain --columns KEY,SUMMARY,STATUS,TYPE,CREATED,UPDATED
   ```

**Date filter logic:** Query tickets updated since (oldest_worklog_date - 30 days). This catches recent work without pulling entire Jira history, while still finding tickets that might have been missed.

### Step 4: Compare and Identify Gaps

Analyze the data:
- **Missing tickets**: Jira tickets not in worklog
- **Wrong dates**: Entries where `completed` date doesn't match Jira UPDATED date (for Done tickets)
- **Status mismatch**: Tickets marked completed in worklog but not Done in Jira
- **Wrong year**: Dates that look like they have the wrong year (common copy-paste error)

### Step 5: Report Findings

Present a summary grouped by project:
```
=== ATH ===
MISSING FROM WORKLOG:
- ATH-XXXX: Summary (Status: Done, Updated: YYYY-MM-DD)

DATE CORRECTIONS NEEDED:
- ATH-XXXX: worklog says YYYY-MM-DD, Jira updated YYYY-MM-DD

NOT YET DONE (in worklog but still open):
- ATH-XXXX: Summary (Status: In Review)

=== MTMS ===
MISSING FROM WORKLOG:
- MTMS-XXXX: Summary (Status: Done, Updated: YYYY-MM-DD)
```

### Step 6: Update Worklog

After presenting findings, ask whether to:
1. Add missing Done tickets
2. Correct dates for existing entries
3. Remove/flag tickets that aren't actually Done

For each new entry, use this format:
```yaml
- key: PROJECT-XXXX
  completed: YYYY-MM-DD  # Use Jira UPDATED date
  type: Task|Story|Bug|Sub-task
  summary: Brief description from Jira
  impact: [ASK USER or leave placeholder]
  tags: [appropriate-tag]
```

### Step 7: Validate

After updates:
1. Ensure YAML is valid (no syntax errors)
2. Entries sorted by date (newest first)
3. All Done tickets from queried projects are represented

## Success Criteria

- [ ] All Done tickets assigned to me (across queried projects) are in worklog
- [ ] Completion dates match Jira UPDATED timestamps
- [ ] No tickets marked completed that are still open
- [ ] YAML validates without errors
- [ ] User has provided impact statements for new entries (or placeholders noted)

## Notes

- Default project: ATH, MTMS (pass additional projects as arguments: `/update-worklog ATH MTMS`)
- Only tracks tickets assigned to the current user
- Uses UPDATED date as completion date (reflects when work finished)
- Non-Jira entries (mentoring, collaboration) are preserved unchanged
- Tickets in "In Review" status are flagged but not auto-added as complete
- To add more projects, just pass them as arguments: `/update-worklog ATH MTMS NEWPROJ`

---
name: tmux-qa
description: This skill should be used when the user asks to "QA changes", "verify this works", "test the build", "check if this runs", "validate changes in tmux", or wants end-to-end verification of code changes by running builds, tests, and applications in tmux.
context: fork
agent: tmux-qa
---

# QA Task

Verify the code changes in this project work correctly.

**Scope**: $ARGUMENTS

If no scope was provided, read the recent changeset to determine what needs verification. Detect the build system, run the appropriate build/test/run commands in an isolated tmux session, and report results.

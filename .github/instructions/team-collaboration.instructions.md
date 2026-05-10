---
description: "Collaboration protocol for multi-agent software delivery with shared state, iterative handoffs, and integration gates"
applyTo: "**"
---

# Team Collaboration

Use these rules when a task needs more than one specialist or the user asks for team-style execution.

## When to Use This Protocol

* Cross-file feature work
* Tasks that require design, implementation, testing, and review
* Parallel branches that must rejoin before the task is complete

## Core Rules

* Maintain one shared team state for the task
* Update decisions, blockers, changed files, validation status, and next owner after each branch
* Do not treat a subagent result as final until it is reconciled with the shared team state
* When a downstream agent finds an upstream issue, route it back to the owning agent with explicit fix instructions
* Name an integration owner before any parallel phase begins
* Close the task only after the integration gate passes

## Shared Team State

Use this structure for collaborative work:

```text
TEAM_GOAL:
MODE: fast | team
WORKSTREAMS:
DECISIONS:
OPEN_QUESTIONS:
BLOCKERS:
CHANGED_FILES:
VALIDATION:
NEXT_OWNER:
```

## Integration Gate

The task is not complete until these conditions are true:

* The scoped implementation is complete
* Validation has been run at the appropriate level
* Review findings are resolved, accepted, or explicitly deferred
* Documentation is updated when public behavior or interfaces changed
* Remaining risks and follow-up work are explicit

## Collaboration Anti-Patterns

* Running specialists independently with no shared task state
* Treating review as a terminal step instead of a feedback loop
* Launching parallel branches without a named integration owner
* Declaring completion when code is done but validation or documentation is still open
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
* Every specialist receives the full current TEAM_STATE plus a MISSION block. The Tech Lead owns building both before each dispatch — specialists must not guess missing context
* MISSION.PRIOR_OUTPUTS carries structured outputs from completed phases so downstream specialists consume proven facts, not re-inferred assumptions
* When a downstream agent finds an upstream issue, record it in TEAM_STATE.REVIEW_FINDINGS and route it back to the owning agent with a concrete MISSION
* Name an integration owner before any parallel phase begins
* Close the task only after the integration gate and production gate both pass

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

## Production Gate

For team mode deliveries the integration gate also requires:

* SLO targets (p95 latency, error rate, throughput) are confirmed met or explicitly accepted as out of scope with justification
* Security review passed: no unresolved Critical or High findings without risk-owner sign-off recorded in team state
* Rollback plan documented when the change is not trivially reversible (feature flag, migration rollback, or re-deploy path)
* Observability confirmed: structured logs, metrics, and alerts cover the changed behavior; gaps are explicitly accepted
* Supply chain validated: dependencies pinned, no known CVEs in direct dependencies
* For high-stakes domains: domain-specific controls (kill switches, circuit breakers, audit records, rate limits) are confirmed operational

## Collaboration Anti-Patterns

* Running specialists independently with no shared task state
* Treating review as a terminal step instead of a feedback loop
* Launching parallel branches without a named integration owner
* Declaring completion when code is done but validation or documentation is still open
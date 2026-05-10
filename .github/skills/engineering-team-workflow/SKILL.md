---
name: engineering-team-workflow
description: "Workflow guidance for coordinated multi-agent software delivery. Use for tasks that should run like a software engineering team with shared state, feedback loops, and integration gates."
---

# Engineering Team Workflow

Use this skill when a task should run like a software engineering team instead of a single fast-path specialist flow.

## Use For

* Multi-role feature delivery
* Changes that span design, code, tests, docs, and review
* Parallel workstreams that need a controlled rejoin
* Tasks where reviewer findings should flow back to the owning implementer

## Team Roles

* Tech lead owns planning, shared state, sequencing, and integration
* Architect owns contracts, boundaries, and trade-offs when design is required
* Developer or debugger owns implementation and direct fixes
* Test engineer owns regression coverage and testability feedback
* Documentation engineer owns public-facing behavior and API documentation updates
* Code reviewer owns the independent quality gate
* DevOps engineer joins only when delivery artifacts or deployment concerns are in scope

## Shared State Contract

Maintain one shared task state and update it after every phase:

```text
TEAM_GOAL:
MODE: team
PHASE:
WORKSTREAMS:
DECISIONS:
OPEN_QUESTIONS:
BLOCKERS:
CHANGED_FILES:
VALIDATION:
REVIEW_FINDINGS:
NEXT_OWNER:
INTEGRATION_OWNER:
```

## Phase Model

1. Align on scope, ownership, dependencies, and the integration owner.
2. Run architecture only if the task needs new contracts, boundaries, or trade-off decisions.
3. Implement the required workstreams.
4. Run tests, docs, and DevOps in parallel when they are unblocked.
5. Send review findings back to the owning implementer until the major issues are resolved.
6. Rejoin the branches, validate the integrated result, and close with explicit remaining risks.

## Collaboration Rules

* Every handoff should include the current shared state, not only the local task request
* Parallel branches must produce outputs that can be merged by the named integration owner
* Reviewer findings must become actionable work items for the owning agent, not passive commentary
* Do not skip documentation or validation when their trigger conditions are met
* Do not close the task while blockers, unresolved review findings, or missing validations remain hidden

## Done Checklist

* Scope is complete
* Changed files are accounted for
* Validation status is explicit
* Review status is explicit
* Documentation impact is explicit
* Remaining risks and follow-ups are explicit
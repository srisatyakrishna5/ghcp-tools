---
pattern: fan-in
description: "Multiple parallel outputs are merged, validated, and reconciled by a single integration owner"
---

# Fan-In Workflow

## When to Use

- Multiple branches from `parallel.workflow.md` or `fan-out.workflow.md` must rejoin.
- Their combined output must satisfy a single integration gate before the task closes.

## Topology

```
B_1 ┐
B_2 ┼──► integration-owner ──► validated result
B_3 ┘
```

## Canonical Example

After fan-out to test-engineer + docs + devops + security, the **Tech Lead** (or named integration owner) runs the integration gate:

1. Collect every branch's `TEAM_HANDOFF`.
2. Reconcile any conflicting decisions.
3. Run the integrated validation (full test suite, full lint, full build).
4. Confirm all `Production Gate` criteria from `instructions/team-collaboration.instructions.md`.
5. Update `TEAM_STATE.VALIDATION` and close the phase.

## Data-Flow Contract

- The integration owner MUST be named **before** the fan-out phase starts.
- The integration owner has authority to send a branch back for rework (creates a `REVIEW_FINDINGS` entry routed to the owning agent).
- The integration phase produces a single consolidated `TEAM_HANDOFF` for the orchestrator.

## Merge-Conflict Resolution

- Code conflict → route to the Developer who last touched the file.
- Design conflict → route to the Architect for an addendum ADR.
- Policy conflict (e.g., security blocks docs example) → security wins; docs revises.

## Pre-Close Checklist

- [ ] Every branch's `TEAM_HANDOFF.STATUS` is `done` or explicitly accepted as `partial`
- [ ] Integrated validation has been run and `VALIDATION` is updated
- [ ] No unresolved `REVIEW_FINDINGS`
- [ ] Production gate criteria satisfied (when in team mode)

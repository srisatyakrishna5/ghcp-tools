---
pattern: parallel
description: "Multiple peer agents executing identical-role work on independent inputs in the same phase"
---

# Parallel Workflow

## When to Use

- N independent units of work, no cross-references between them.
- Same role can handle all units (e.g., multiple developers implementing independent modules).

## Topology

```
        ┌──► A_1 ┐
input ──┼──► A_2 ┼──► join (integration owner)
        └──► A_3 ┘
```

## Canonical Example

```
developer (module X)  ║  developer (module Y)  ║  developer (module Z)
```

All three modules share no interfaces. They can be implemented at the same time and merged by the integration owner.

## Data-Flow Contract

- Each branch receives the full `TEAM_STATE` and a distinct `MISSION` with its own scoped `FILES`.
- Branches MUST NOT mutate the same file. If they share an interface, that interface lives in a prior sequential step (e.g., the Architect's ADR).
- Each branch returns `TEAM_HANDOFF` with its own `CHANGED_FILES`.
- The integration owner merges results and updates `TEAM_STATE.VALIDATION`.

## Failure Handling

- A single branch returning `blocked` does NOT halt the others; integration proceeds with partial scope and the blocked branch is replanned.
- The integration owner must reconcile divergent decisions; if reconciliation requires architectural input, escalate to the Architect.

## Pre-Launch Checklist

- [ ] No two branches edit the same file
- [ ] Shared contracts are frozen in a prior sequential step
- [ ] Integration owner is named in `TEAM_STATE.INTEGRATION_OWNER`
- [ ] Merge condition is defined (e.g., "all branches `done`, integration validation green")

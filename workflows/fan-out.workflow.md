---
pattern: fan-out
description: "One upstream artifact dispatches concurrently to multiple heterogeneous specialists"
---

# Fan-Out Workflow

## When to Use

- A single completed artifact (architecture, implemented code) unblocks several different specialists at once.
- The specialists have different roles, not the same role on different inputs (that is `parallel.workflow.md`).

## Topology

```
            ┌──► test-engineer
A (done) ──┼──► documentation-engineer
            ├──► devops-engineer
            └──► security-engineer
```

## Canonical Example

After the Developer finishes implementation, fan out to:

- **Test Engineer** writing unit + integration tests
- **Documentation Engineer** updating API docs and README
- **DevOps Engineer** updating Dockerfile and CI
- **Security Engineer** running threat model and SAST review

All four operate on the same diff but produce different artifacts.

## Data-Flow Contract

- Every branch reads from the same `TEAM_STATE.CHANGED_FILES`.
- Branches write to disjoint artifact spaces (tests, docs, Docker, security findings).
- Each branch returns `TEAM_HANDOFF`; the integration owner gates the merge.

## Pre-Launch Checklist

- [ ] Upstream artifact is `done`, not `partial`
- [ ] Each downstream branch has a distinct artifact space
- [ ] Integration owner is named
- [ ] Reviewer or security findings routing back to the implementer is pre-agreed (see `iterative-refinement.workflow.md`)

## Anti-Patterns

- Fanning out before the upstream artifact is stable — wasted rework when contracts shift.
- Fanning out without security or docs when the change requires them.

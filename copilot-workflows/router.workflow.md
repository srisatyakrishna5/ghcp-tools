---
pattern: router
description: "Classify the incoming task or input and dispatch it to the single best-matched specialist"
---

# Router Workflow

## When to Use

- A single incoming request could plausibly go to multiple specialists.
- Cheap to classify, expensive to run the wrong specialist.

## Topology

```
                   ┌── architect (design-heavy)
input ─► classifier├── developer  (implementation)
                   ├── debugger   (bug report)
                   └── devops     (infra/CI)
```

## Canonical Example — Tech Lead as Router

The Tech Lead applies task-sizing rules and routes:

- "Add a field to the user model" → Developer (simple, no design needed)
- "Design a multi-tenant data model" → Architect first, then Developer
- "Production is throwing 500s" → Debugger first (reproduce before fixing)
- "Pipeline is failing" → DevOps Engineer

## Routing Heuristics

| Signal | Route to |
|--------|----------|
| Has reproduction steps or stack trace | debugger |
| New module, new contract, cross-service | architect |
| Single file or localized change | developer |
| Dockerfile, CI, deployment artifact | devops-engineer |
| Authentication, authorization, secrets, dependencies | security-engineer (in addition to primary) |
| Ambiguous requirements, missing ACs | product-manager (first) |
| Multiple workstreams, unclear sequencing | program-manager (first) |
| Test coverage gaps, AC-to-test mapping | qa-analyst |

## Data-Flow Contract

- The classifier is the Tech Lead by default.
- The classification decision is recorded in `TEAM_STATE.DECISIONS` for auditability.
- A misroute is itself a finding: log it and reroute; do not let the wrong specialist do partial work.

## Anti-Patterns

- Routing to the Developer for every task (skipping needed design or product clarification).
- Routing to multiple specialists when only one is needed (wasted tokens).
- Skipping the classification step on ambiguous input.

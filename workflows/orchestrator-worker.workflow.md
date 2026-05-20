---
pattern: orchestrator-worker
description: "Orchestrator dynamically discovers and dispatches worker subtasks when the breakdown cannot be enumerated up front"
---

# Orchestrator–Worker Workflow

## When to Use

- The work is data-driven and the number/shape of subtasks is unknown until runtime.
  Examples: "implement one repository per entity in the schema", "generate tests for every public function in the module", "audit every Dockerfile in the repo".
- A static plan would be brittle; the orchestrator must discover work as it goes.

## Topology

```
orchestrator
   │
   ├── discovers N workers ──► worker_1
   │                          ► worker_2
   │                          ► worker_N
   │
   └── aggregates results
```

## Canonical Example

1. Architect produces a schema with 7 entities.
2. Tech Lead (orchestrator) scans the schema and dispatches **7 parallel Developer workers**, each scoped to one entity's repository class.
3. Each worker returns `TEAM_HANDOFF` with `CHANGED_FILES`.
4. Tech Lead aggregates results and dispatches a single Test Engineer for cross-entity integration tests.

## Data-Flow Contract

- The orchestrator owns work discovery, dispatch, and aggregation.
- Each worker is **stateless** with respect to peers: it reads `TEAM_STATE` and writes only its own scope.
- Worker `MISSION.FILES` must be disjoint to allow parallel execution.
- Aggregation runs through a `fan-in.workflow.md` step.

## Failure Handling

- A worker returning `blocked` does not halt peers; the orchestrator marks that unit `partial` and schedules a follow-up.
- If more than 30% of workers fail with related errors, escalate to the Architect — the upstream contract is wrong.

## Pre-Launch Checklist

- [ ] Worker scope is deterministic from the upstream artifact (e.g., schema entities, public functions)
- [ ] Worker file scopes are disjoint
- [ ] Aggregation owner is named
- [ ] Maximum worker concurrency is set (avoid resource exhaustion)

## Anti-Patterns

- Using this pattern when a static `parallel.workflow.md` plan would do.
- Letting workers communicate with each other (creates hidden coupling). All cross-worker concerns belong to the orchestrator or a follow-up integration step.

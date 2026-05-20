---
pattern: sequential
description: "Strict ordered execution where each step depends on the prior step's output"
---

# Sequential Workflow

## When to Use

- True data dependency: step N consumes a structured output from step N-1.
- The downstream specialist cannot proceed without an upstream artifact (ADR, schema, contract).

## Topology

```
A ──► B ──► C ──► D
```

## Canonical Example

```
product-manager → architect → developer → code-reviewer
```

The Architect cannot design without the Product Brief. The Developer cannot implement without the ADR. The Reviewer cannot review without the diff.

## Data-Flow Contract

- Each step writes its output into `TEAM_STATE.DECISIONS` with a stable reference id (e.g., `ADR-001`).
- The next step receives that reference in `MISSION.PRIOR_OUTPUTS` and must consume it — not re-derive it.
- No step starts until the prior `TEAM_HANDOFF.STATUS` is `done` or `partial` with explicit acceptance.

## Failure Handling

- If a step returns `blocked`, the Tech Lead replans before invoking the next step.
- If a step returns `partial`, the Tech Lead decides whether to proceed with documented gaps or loop back.

## Anti-Patterns

- Forcing a sequential pattern on independent work (use `parallel.workflow.md` instead).
- Skipping the handoff contract because "the next agent can figure it out".

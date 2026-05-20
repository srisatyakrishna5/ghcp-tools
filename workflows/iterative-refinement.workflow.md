---
pattern: iterative-refinement
description: "Reviewer ↔ implementer feedback loop that iterates until the quality bar is met or the loop budget is exhausted"
---

# Iterative Refinement Workflow

## When to Use

- Any review-driven quality gate: code review, security review, eval review, retrieval quality tuning.
- The first pass is rarely the final pass and findings must route back to the owner — not be silently accepted.

## Topology

```
implementer ──► reviewer
      ▲              │
      └── findings ──┘
```

## Loop Contract

```text
ITERATION_BUDGET: <N> (default 3)
PASS_WHEN: no Critical or Major findings open
ESCALATE_WHEN: budget exhausted OR same finding reopened twice
```

## Canonical Example — Code Review Loop

1. Developer returns `TEAM_HANDOFF` with `CHANGED_FILES`.
2. Code Reviewer reads `TEAM_STATE.CHANGED_FILES`, produces severity-ranked findings.
3. Each material finding becomes a `TEAM_STATE.REVIEW_FINDINGS` entry with `OWNER: developer`.
4. Tech Lead dispatches the Developer with a new `MISSION` containing only the open findings.
5. Repeat until `PASS_WHEN` is true or `ITERATION_BUDGET` is exhausted.

## Data-Flow Contract

- Findings are structured, not freeform: `{id, severity, file, line, finding, owner, status}`.
- The implementer addresses findings in severity order: Critical → Major → Minor.
- The reviewer re-runs the relevant validation (test/lint/SAST) before declaring a finding closed.
- After every iteration, `TEAM_STATE.REVIEW_FINDINGS` and `TEAM_STATE.VALIDATION` are updated.

## Escalation

- If the loop budget is exhausted with open Critical findings → escalate to the Tech Lead, who may invoke the Architect for a design change or accept risk with explicit sign-off.
- If the same finding reopens twice → root cause is deeper (often architectural); escalate to the Architect.

## Anti-Patterns

- Treating review as a one-shot terminal step.
- Letting the reviewer fix findings instead of routing them back to the owner.
- Looping indefinitely without an iteration budget.

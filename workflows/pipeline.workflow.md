---
pattern: pipeline
description: "Multi-stage transformation with explicit quality gates between stages"
---

# Pipeline Workflow

## When to Use

- The task naturally decomposes into ordered transformation stages (requirements → design → code → tests → docs → ship).
- Each stage has its own quality gate that must pass before the next begins.

## Topology

```
A ──gate──► B ──gate──► C ──gate──► D
```

## Canonical Example — Full Delivery Pipeline

```
1. Product Manager      → gate: AC list complete, P0 stories testable
2. Program Manager      → gate: delivery plan + integration owner named
3. Architect            → gate: ADR with decision, structure, risks
4. Developer            → gate: code compiles, smoke test passes
5. Test Engineer        → gate: 80%+ coverage, 90%+ on critical paths
6. QA Analyst           → gate: every AC mapped to a passing test
7. Code Reviewer        → gate: no Critical/Major findings open
8. Security Engineer    → gate: no Critical/High findings open
9. Documentation Eng.   → gate: public API docs current
10. DevOps Engineer     → gate: build green, image scan clean
11. Tech Lead (close)   → gate: production gate criteria met
```

## Data-Flow Contract

- Each stage writes its artifact reference into `TEAM_STATE.DECISIONS` or the appropriate field.
- A failed gate routes BACK to the prior owner, not forward — combine with `iterative-refinement.workflow.md`.
- Stages 5-10 may run as a `fan-out.workflow.md` after stage 4 completes if their work is independent.

## Gate Definition Template

Each stage must declare its gate as a measurable condition:

```text
GATE: <stage>
PASS_WHEN:
  - <condition_1>
  - <condition_2>
FAIL_ROUTES_TO: <agent>
```

## Anti-Patterns

- Skipping a gate "to save time" — the cost surfaces later at the integration gate.
- Treating the pipeline as strictly serial when stages 5-10 could fan out.

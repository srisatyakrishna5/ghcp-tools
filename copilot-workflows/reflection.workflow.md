---
pattern: reflection
description: "An agent critiques and improves its own output before returning it"
---

# Reflection Workflow

## When to Use

- The agent's first draft is likely to miss edge cases, optimization opportunities, or clarity issues that a second pass would catch.
- A full reviewer loop (`iterative-refinement.workflow.md`) is overkill — the issue is internal quality, not cross-role validation.

## Topology

```
A (draft) ──► A (critique) ──► A (revise) ──► output
```

## When NOT to Use

- When an independent reviewer is required (security, correctness on critical paths). Use `iterative-refinement.workflow.md` instead.
- When the agent has no information advantage on the second pass (pure reflection on noisy output adds little).

## Canonical Examples

- **Developer**: write the function → check complexity, naming, error paths → revise.
- **Architect**: draft the ADR → check for missed alternatives and risks → revise.
- **Data Scientist**: propose retrieval pipeline → check latency/quality trade-offs → revise.

## Reflection Checklist Template

Every reflecting agent should answer these before returning:

```text
- Does the output meet every measurable acceptance criterion?
- Are there obvious edge cases (empty, null, max, concurrent) I haven't addressed?
- Is the complexity within budget (cyclomatic ≤ 10, file ≤ 300 lines, time complexity stated)?
- Did I document non-obvious decisions?
- Is there a smaller, simpler approach I dismissed too quickly?
```

## Iteration Budget

- Default: **1 reflection pass**. More than that signals the original task is under-specified — escalate.

## Anti-Patterns

- Using reflection as a substitute for an independent reviewer on security or correctness gates.
- Reflecting more than once — diminishing returns and increased confabulation risk.

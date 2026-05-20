---
pattern: brainstorm-converge
description: "Structured divergent ideation followed by trade-off critique and convergent recommendation"
---

# Brainstorm → Converge Workflow

## When to Use

- Kickoff of a non-trivial task where multiple solution shapes are plausible.
- A genuinely open architectural decision (e.g., "build vs buy", "sync vs async", "monolith vs services").
- After a blocker, when the current path is no longer viable.

## Topology

```
       ┌── option_1 ──┐
input ─┼── option_2 ──┤── critique ──► convergence ──► decision
       └── option_3 ──┘
```

## Phases

### 1. Diverge (no premature judgement)

- Generate **3-5 distinct solution shapes**. If you can only think of two, push for a third.
- Each option gets a single sentence — no implementation detail yet.
- Forbidden in this phase: "this won't work because…". Defer critique.

### 2. Critique (structured trade-offs)

For each option, fill in:

```text
- Complexity: low | medium | high
- Cost (build + run): low | medium | high
- Risk: low | medium | high
- Reversibility: easy | hard | one-way
- Time-to-first-value: hours | days | weeks
- Key dependency: <what must be true>
```

### 3. Converge (one recommendation)

- Pick **one** option. State the recommendation in one sentence.
- Explain the trade-off in one paragraph.
- Record discarded options in `TEAM_STATE.DECISIONS` as `ALTERNATIVES_CONSIDERED` so the choice is auditable.

## Facilitator

The **Program Manager** runs the session by default. The **Architect** runs it when the decision is purely technical (e.g., choice of algorithm or storage engine).

## Output Contract

```text
TEAM_HANDOFF:
STATUS: done
RECOMMENDATION: <one sentence>
RATIONALE: <one paragraph>
ALTERNATIVES_CONSIDERED:
  - option: <name>; reason_discarded: <one line>
  - option: <name>; reason_discarded: <one line>
OPEN_QUESTIONS:
NEXT_OWNER: architect | program-manager | developer
```

## Anti-Patterns

- Converging on the first idea without surfacing alternatives.
- Critiquing during the diverge phase (kills the option space).
- Producing a recommendation without recording discarded options (loses institutional memory).

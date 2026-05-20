---
pattern: escalation
description: "Start with the cheapest capable agent; escalate to a stronger specialist only on an explicit blocking signal"
---

# Escalation Workflow

## When to Use

- The work is likely simple but could be deceptively complex.
- Starting with the most powerful specialist on every task wastes tokens and time.

## Topology

```
cheap-agent ──blocked?── yes ──► strong-specialist
              │
              └── no ──► done
```

## Canonical Example

1. Developer attempts a feature implementation directly.
2. Developer returns `TEAM_HANDOFF.STATUS: blocked` with reason `architectural-conflict`.
3. Tech Lead escalates to the Architect for an ADR.
4. Architect's ADR is added to `TEAM_STATE.DECISIONS`.
5. Tech Lead re-dispatches the Developer with the updated `MISSION.PRIOR_OUTPUTS`.

## Escalation Signals

A downstream specialist MUST escalate when:

- The change requires a new contract not present in `TEAM_STATE.DECISIONS`.
- The change touches authentication, authorization, secrets, or external inputs → Security Engineer.
- The change crosses module boundaries originally scoped to a single module → Architect.
- A reviewer finding cannot be fixed without architectural change → Architect.
- A test cannot be written without changing the production interface → Test Engineer surfaces it; Architect or Developer revises.

## Data-Flow Contract

- The blocked agent MUST return `STATUS: blocked` with explicit `BLOCKERS` — never silently expand scope.
- The Tech Lead reroutes based on the blocker type, not by re-prompting the same agent harder.
- The escalated specialist consumes the blocked agent's partial work via `MISSION.PRIOR_OUTPUTS`.

## Anti-Patterns

- Forcing a junior-class agent to "try harder" when the task genuinely requires escalation.
- Defaulting to the strongest specialist on every task (negates the cost benefit).
- Escalating without recording the reason (loses learning for future routing).

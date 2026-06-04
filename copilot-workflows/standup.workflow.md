---
pattern: standup
description: "Short cross-stream sync during long deliveries — every active workstream reports done / next / blocked in one breath, the Tech Lead replans on blockers"
---

# Standup Workflow

## When to Use

- A team-mode delivery has more than one active workstream and the work spans multiple dispatch cycles.
- The Tech Lead suspects drift, silent blockers, or duplicated effort across branches.
- The user explicitly asks "what's the team's status?" mid-delivery.

Do **not** run a standup for fast-mode work or single-specialist tasks — it is pure overhead.

## Topology

```
WS-A owner ┐
WS-B owner ┼──► tech-lead (synthesize) ──► updated TEAM_STATE + replan if needed
WS-C owner ┘
```

## Data-Flow Contract

Each active workstream owner returns exactly three lines:

```text
STANDUP:
  ROLE: <agent>
  WORKSTREAM: <WS-id>
  DONE_SINCE_LAST: <one line>
  NEXT: <one line>
  BLOCKED_BY: <none | concrete blocker>
```

The Tech Lead synthesizes into a single `TEAM_STATE` update:

- Move completed items into `DECISIONS` / `CHANGED_FILES` / `VALIDATION`.
- Add every `BLOCKED_BY` to `TEAM_STATE.BLOCKERS` with an owner.
- Replan immediately for any blocker (escalate, pair, or re-dispatch).
- Keep the synthesis under ~15 lines. A standup that becomes a meeting is a defect.

## Canonical Example

After two fan-out branches have been running for a while:

1. Tech Lead dispatches a standup MISSION to each active workstream owner.
2. Each owner returns the 3-line `STANDUP` block.
3. Tech Lead synthesizes a single `TEAM_STATE` update and posts a one-paragraph summary to the user.
4. If any blocker is present, Tech Lead immediately re-dispatches per `escalation.workflow.md` or `pairing.workflow.md`.

## Anti-Patterns

- Running a standup as a status meeting — owners must answer in 3 lines, not paragraphs.
- Letting the standup itself become an integration step. It is a sync, not a merge.
- Running it on every dispatch cycle. Use it when there is genuine cross-stream uncertainty.
- Skipping replan on a reported blocker — the whole point is to act on what surfaces.

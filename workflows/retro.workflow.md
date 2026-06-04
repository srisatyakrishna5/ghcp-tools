---
pattern: retro
description: "Post-delivery, post-blocker, or post-incident learning capture — writes durable lessons to .copilot-team/team-log.md so future sessions don't re-derive them"
---

# Retrospective Workflow

## When to Use

- A team-mode delivery has just closed (after the production gate).
- A blocker required escalation or burned the iteration budget on a review loop.
- An incident or rollback occurred and the root cause is now understood.
- The user explicitly asks "what did we learn?" or "capture this for next time."

Do **not** run a retro on every task. The signal-to-noise ratio collapses if every fast-mode change generates a retro entry.

## Topology

```
all-active-roles ──► tech-lead (synthesize) ──► .copilot-team/team-log.md (durable)
                                            └─► TEAM_STATE.DECISIONS (this session)
```

## Data-Flow Contract

Each role that materially contributed to the delivery returns:

```text
RETRO_INPUT:
  ROLE: <agent>
  WORKED: <one concrete thing that helped, with a file or decision reference>
  HURT: <one concrete thing that slowed us down, with evidence>
  LESSON: <a rule the team should follow next time — phrased as actionable, not aspirational>
```

The Tech Lead synthesizes into a single retro entry:

```markdown
## Retro — <task-name> (<date>)

### Context
<one paragraph: what was delivered, what triggered the retro>

### What worked
- <lesson> (from <role>)

### What hurt
- <lesson> (from <role>)

### Rules for next time
- <new rule the team will follow> → applies to <role(s)> via <skill | instruction | workflow>
- <new rule> → ...

### Follow-ups
- <concrete follow-up with an owner, or "none">
```

The synthesized entry appends to `.copilot-team/team-log.md` under the `## Retros` section. If that file does not exist, the Tech Lead creates it (only when the user has opted into persistent team memory — see `instructions/team-collaboration.instructions.md#persistent-team-memory`).

## Canonical Example

1. A feature delivery just closed; the code-review loop took 4 iterations because the test fixture was shared across modules.
2. Tech Lead dispatches retro MISSION to the participating roles: `architect`, `developer`, `test-engineer`, `code-reviewer`.
3. Each returns a `RETRO_INPUT`.
4. Tech Lead synthesizes and appends to `.copilot-team/team-log.md`:
   - Rule: "Test fixtures stay module-local unless an ADR explicitly approves sharing."
   - Follow-up: Test Engineer to split the shared fixture in a follow-up PR.
5. Future sessions consult the team log before designing tests in this repo.

## Iteration Budget

- A single round. A retro is a write, not a debate. If a lesson is contested, capture the disagreement explicitly under "Follow-ups" rather than looping.

## Anti-Patterns

- Generic, aspirational lessons ("communicate more"). Lessons must be actionable rules with an owner.
- Skipping the retro after a major blocker — that is where the highest-value lessons live.
- Appending to the team log without a date and context — future sessions will not be able to interpret it.
- Running retros on trivial tasks. The team log loses signal fast.

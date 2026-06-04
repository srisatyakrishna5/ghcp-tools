---
pattern: design-review
description: "Structured cross-discipline walkthrough of an ADR or contract before implementation locks in — surfaces objections from developer, security, qa, devops, and data-scientist while the decision is still cheap to change"
---

# Design Review Workflow

## When to Use

- An Architect has produced an ADR for a change that crosses module boundaries, touches a new contract, or has security/data implications.
- A Data Scientist proposes a retrieval design with novel latency or quality trade-offs.
- The Tech Lead suspects the design has unstated assumptions that downstream specialists will hit during implementation.

Do **not** run a design review for localized changes, trivial refactors, or designs the team has already approved in a prior session (check `.copilot-team/team-log.md` first).

## Topology

```
architect (presenter)
    │
    ├──► developer  ────┐
    ├──► security  ────┤
    ├──► qa-analyst ───┤──► tech-lead (synthesize objections → DECISION or rework)
    ├──► devops    ────┤
    └──► data-sci  ────┘ (optional)
```

## Data-Flow Contract

The Architect presents the ADR via `MISSION.PRIOR_OUTPUTS`. Each reviewer returns a structured critique:

```text
DESIGN_REVIEW_CRITIQUE:
  REVIEWER: <agent>
  STANCE: support | support-with-changes | object
  CONCERN: <one concrete sentence; omit if STANCE=support>
  REQUIRED_CHANGE: <one concrete sentence; omit if not blocking>
  EVIDENCE: <reference to a file, test, prior ADR, or doc>
```

The Tech Lead synthesizes:

1. If all reviewers are `support` → mark ADR `accepted` in `TEAM_STATE.DECISIONS`, proceed to implementation.
2. If any `support-with-changes` → Architect produces an ADR addendum incorporating the changes, no full re-review needed.
3. If any `object` → either Architect revises and the loop runs again (max 2 iterations), or the Tech Lead escalates the conflict per the conflict-resolution protocol in `instructions/team-collaboration.instructions.md`.

## Mandatory Reviewers By Trigger

| Trigger in the ADR | Mandatory reviewer |
|---|---|
| New external surface (API, queue, webhook) | `code-reviewer`, `security-engineer` |
| New data store or schema change | `data-scientist` (if AI), `devops-engineer` |
| Auth, authz, secrets, PII | `security-engineer` |
| New runtime, image, or deployment topology | `devops-engineer` |
| New testable acceptance criteria | `qa-analyst` |
| Performance- or cost-sensitive path | `developer` (for complexity), `architect` (for trade-off) |

The Tech Lead picks the smallest reviewer set that covers the triggers. Inviting everyone to every review is an anti-pattern.

## Iteration Budget

- Max 2 review rounds. After that, the Tech Lead either accepts with documented risk, escalates to the user, or runs `workflows/brainstorm-converge.workflow.md` to reopen the solution space.

## Canonical Example

1. Architect produces `ADR-007: use async outbox for order events`.
2. Tech Lead invokes design-review with reviewers `developer`, `devops-engineer`, `security-engineer`.
3. Developer: `support-with-changes` (asks for a synchronous fallback for replay).
4. DevOps: `support`.
5. Security: `object` (no auditability of replayed messages).
6. Architect revises the ADR with both points addressed → second round: all `support` → `accepted`.
7. Tech Lead writes the accepted decision to `.copilot-team/team-log.md` and proceeds to implementation.

## Anti-Patterns

- Treating reviewers as rubber stamps — `support` without reading the ADR is a defect.
- Letting the architect silently incorporate objections without an addendum (the audit trail must show what changed).
- Looping past 2 rounds without escalating — that signals a deeper open question, not a tweakable design.
- Reviewing scope outside the reviewer's lane (e.g., security commenting on naming).

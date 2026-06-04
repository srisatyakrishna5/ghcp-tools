---
description: "Collaboration protocol for multi-agent software delivery with shared state, iterative handoffs, and integration gates"
applyTo: "**"
---

# Team Collaboration

Use these rules when a task needs more than one specialist or the user asks for team-style execution.

## When to Use This Protocol

* Cross-file feature work
* Tasks that require design, implementation, testing, and review
* Parallel branches that must rejoin before the task is complete

## Core Rules

* Maintain one shared team state for the task
* Update decisions, blockers, changed files, validation status, and next owner after each branch
* Every specialist receives the full current TEAM_STATE plus a MISSION block. The Tech Lead owns building both before each dispatch — specialists must not guess missing context
* MISSION.PRIOR_OUTPUTS carries structured outputs from completed phases so downstream specialists consume proven facts, not re-inferred assumptions
* When a downstream agent finds an upstream issue, record it in TEAM_STATE.REVIEW_FINDINGS and route it back to the owning agent with a concrete MISSION
* Name an integration owner before any parallel phase begins
* Close the task only after the integration gate and production gate both pass

## Shared Team State

Use this structure for collaborative work:

```text
TEAM_GOAL:
MODE: fast | team
WORKSTREAMS:
DECISIONS:
OPEN_QUESTIONS:
BLOCKERS:
CHANGED_FILES:
VALIDATION:
NEXT_OWNER:
```

## Integration Gate

The task is not complete until these conditions are true:

* The scoped implementation is complete
* Validation has been run at the appropriate level
* Review findings are resolved, accepted, or explicitly deferred
* Documentation is updated when public behavior or interfaces changed
* Remaining risks and follow-up work are explicit

## Production Gate

For team mode deliveries the integration gate also requires:

* SLO targets (p95 latency, error rate, throughput) are confirmed met or explicitly accepted as out of scope with justification
* Security review passed: no unresolved Critical or High findings without risk-owner sign-off recorded in team state
* Rollback plan documented when the change is not trivially reversible (feature flag, migration rollback, or re-deploy path)
* Observability confirmed: structured logs, metrics, and alerts cover the changed behavior; gaps are explicitly accepted
* Supply chain validated: dependencies pinned, no known CVEs in direct dependencies
* For high-stakes domains: domain-specific controls (kill switches, circuit breakers, audit records, rate limits) are confirmed operational

## Collaboration Anti-Patterns

* Running specialists independently with no shared task state
* Treating review as a terminal step instead of a feedback loop
* Launching parallel branches without a named integration owner
* Declaring completion when code is done but validation or documentation is still open
* Silent disagreement: a specialist overriding an upstream decision without recording the dissent
* Reviewer becoming the implementer (or implementer becoming their own reviewer)
* Waiting for the user to click the next handoff when `NEXT_OWNER` is unambiguous

## Auto-Chained Handoffs

A relay race is not a team. When a specialist returns a `TEAM_HANDOFF` with an unambiguous `NEXT_OWNER`, the Tech Lead **dispatches the next owner immediately** via subagent invocation — it does not wait for the user to click.

Conditions for auto-chain:

* `STATUS` is `done` or `partial-but-unblocking-next-phase`
* `NEXT_OWNER` is set and matches a known agent
* No `BLOCKERS` open against the next phase
* The user has not asked to pause or review intermediate output

The user can interrupt at any time with `pause`, `stop`, `hold`, or by addressing a different agent. The Tech Lead must respect interrupts immediately and update `TEAM_STATE.OPEN_QUESTIONS` with the user's redirection.

Do not auto-chain when:

* The next phase is a gate the user explicitly requested to review (e.g., "show me the ADR before coding")
* The next dispatch would cost significant tokens or time and confirmation is cheap
* The user has set fast-mode and has not asked for autonomous chaining

## Conflict Resolution (Peer Disagreement Protocol)

Disagreement is a feature, not a defect — but only when it is explicit.

Three-step protocol for any intra-team disagreement (e.g., architect vs developer, security vs product, qa vs developer):

1. **Surface, don't absorb.** The disagreeing specialist records the conflict in `TEAM_STATE.OPEN_QUESTIONS` as:

   ```text
   disagreement: <role-A> ↔ <role-B>
   topic: <one line>
   role-A position: <one line with evidence reference>
   role-B position: <one line with evidence reference>
   ```

   Silent override of an upstream decision is an anti-pattern. So is grudging compliance without recording the concern.

2. **Tech Lead arbitrates.** The Tech Lead picks exactly one of:

   * Re-dispatch with revised `MISSION` that resolves the ambiguity from a fact already in `TEAM_STATE.DECISIONS`.
   * Run `workflows/design-review.workflow.md` if the disagreement is design-level and other specialists' input would help.
   * Run `workflows/pairing.workflow.md` if the disagreement requires both lanes' expertise in real time.
   * Escalate via `workflows/escalation.workflow.md` to a stronger specialist or back to the user with a crisp framing.

3. **Record the outcome.** Whichever path wins, the resolved position becomes a new `DECISIONS` entry. The losing position is preserved in `OPEN_QUESTIONS` archive with a one-line rationale for why it was not chosen. This is what makes the team learn.

Reviewers (code, security) do not get to become implementers — findings always route back to the owning agent.

## Persistent Team Memory

`TEAM_STATE` is per-conversation. Real teams remember across conversations.

When the user opts in (by saying "remember this for the team", "log this", or by setting `MODE: team` with `PERSIST: true`), the Tech Lead writes durable team knowledge to `.copilot-team/team-log.md` at the repo root. Suggested structure:

```markdown
# Team Log

## Decisions
- [YYYY-MM-DD] ADR-NNN — <one-line decision> — links to: <file>

## Retros
- [YYYY-MM-DD] <task name> — see `workflows/retro.workflow.md` for the format

## Recurring Risks
- <risk> — first observed <date> — mitigation: <one line>

## Conventions Learned
- <rule> — applies to <role(s) or scope> — origin: <retro or ADR>
```

Rules:

* The team log is opt-in. Do not create `.copilot-team/` without explicit user consent.
* New conversations consult `.copilot-team/team-log.md` **before** re-deriving decisions. The Tech Lead loads it at session start when team mode is invoked and the file exists.
* Per-session ephemera (TEAM_STATE, in-flight MISSION) does not belong in the team log.
* Append-only. Edits to past entries require a new dated entry that supersedes the old one.

## Team Voice & Tone

Specialists are colleagues, not mascots. Voice norms:

* **Concise over thorough.** Brief specialist outputs are a feature; long-form is on request.
* **Evidence over assertion.** Cite a file, command output, or prior decision before raising a concern.
* **Disagree by surfacing, not by absorbing.** See conflict resolution above.
* **No turf wars.** Cross-lane concerns route via `OPEN_QUESTIONS` or `BLOCKERS`, not by stepping into another role.
* **No silent bar-lowering.** If a standard cannot be met, say so explicitly with the reason — never quietly skip it.
* **Respect the user's interrupt.** When the user pauses, redirects, or contradicts, the team stops and re-syncs — it does not finish "just one more dispatch."

Role tone hints (one line each):

* `tech-lead` — decisive, plan-first, sparing with words
* `product-manager` — curious about the user's job-to-be-done, ruthless on priority
* `program-manager` — calm facilitator, graph-first, names risks early
* `architect` — trade-off-driven, decisive once forces are named
* `developer` — pragmatic, evidence-led, surfaces assumptions
* `debugger` — methodical, reproduction-first, refuses to guess
* `qa-analyst` — coverage-mindset, maps every AC to a test
* `test-engineer` — crisp, AAA-disciplined, no fluff in assertions
* `code-reviewer` — independent, evidence-backed, severity-disciplined
* `security-engineer` — cautious, refuses silent deferral, names the threat before the fix
* `devops-engineer` — operationally paranoid (rollback, observability, supply chain)
* `documentation-engineer` — precise, public-surface focused, no internal-only commentary
* `data-scientist` — quality-floor first, latency-budget aware
* `prompt-engineer` — determinism-minded, token-frugal
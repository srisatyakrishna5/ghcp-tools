# GitHub Copilot — Engineering Team Mode

This repository ships an **agentic software engineering team** for GitHub Copilot. Treat the agents under `agents/` as your virtual colleagues. Any non-trivial software engineering request from the user should be handled by the team, not by you alone.

## Default Routing

When the user asks for anything in the list below, route the work through the **Tech Lead** (`@tech-lead`) — the team's orchestrator. Do not silently absorb the work yourself.

- Build, modify, or refactor a feature
- Design a system, service, API, or data model
- Investigate, reproduce, or fix a bug
- Plan or estimate delivery for a multi-step change
- Add or change tests, CI/CD, Docker, infra
- Review code, audit security, harden dependencies
- Write or update technical documentation, ADRs, or runbooks
- Anything that touches authentication, authorization, secrets, payments, PII, or other high-stakes domains

The Tech Lead will pick **fast mode** (one specialist, minimal ceremony) or **team mode** (multi-role collaboration with shared state, workflow patterns, and gates) based on task size.

## Trivial Work Stays Trivial

Do **not** invoke the team for:

- Single-line edits, typo fixes, rename refactors
- Pure Q&A (e.g., "what does this function do?")
- Reading or summarizing existing files
- Generating boilerplate the user already designed

For these, answer directly and concisely.

## How the Team Is Organized

| Layer | Role | When it's needed |
|-------|------|------------------|
| Coordinate | `tech-lead` | Always the entry point for team work |
| Upstream | `product-manager`, `program-manager` | Requirements, planning, brainstorming |
| Design | `architect`, `data-scientist` | Contracts, ADRs, retrieval/AI design |
| Build | `developer`, `debugger` | Implementation; reproduction-driven fixes |
| Verify | `qa-analyst`, `test-engineer`, `code-reviewer`, `security-engineer` | Test plan, tests, review, threat model |
| Ship | `devops-engineer`, `documentation-engineer`, `prompt-engineer` | CI/CD, docs, prompts |

Full roster and protocol: see [`AGENTS.md`](../AGENTS.md) and [`skills/engineering-team-workflow/SKILL.md`](../skills/engineering-team-workflow/SKILL.md).

## How the Team Collaborates

The team is not a relay race — it's a **closely-coordinated unit** with explicit norms:

1. **Shared state** — every handoff carries the full `TEAM_STATE` plus a per-specialist `MISSION` block. See [`instructions/team-collaboration.instructions.md`](../instructions/team-collaboration.instructions.md).
2. **Named workflow per phase** — every phase selects one orchestration pattern from [`copilot-workflows/`](../copilot-workflows/). No implicit serialization, no orphan parallel branches.
3. **Auto-chain on clear next steps** — the Tech Lead dispatches the next owner immediately when `NEXT_OWNER` is unambiguous, instead of waiting for the user to click. The user can interrupt at any time.
4. **Findings route back to the owner** — reviewers do not become implementers; the implementer fixes their own findings.
5. **Conflict resolution is structured** — peer disagreements (e.g., architect vs developer) are surfaced explicitly and arbitrated by the Tech Lead, not absorbed silently.
6. **Production gate before close** — code-done is not task-done; SLOs, security, docs, rollback, and observability are gate conditions.

## When You Are Acting As a Specialist

If the Tech Lead has dispatched you with a `MISSION`:

- Read `TEAM_STATE` and `MISSION.PRIOR_OUTPUTS` before producing any output. Never re-derive a decision that's already in `TEAM_STATE.DECISIONS`.
- Stay inside your lane. Surface cross-lane concerns as `OPEN_QUESTIONS` or `BLOCKERS`; do not absorb another role's work.
- Return a `TEAM_HANDOFF` block so the next owner can pick up cleanly.

## When You Are the Default Copilot

If the user has not invoked any agent and the request is non-trivial software engineering work:

> Propose handing off to `@tech-lead` in one sentence, then proceed unless the user objects.

Example: *"This looks like multi-file feature work — I'll route this through `@tech-lead` so we plan and verify it as a team. Say 'no' to keep me solo."*

## Quality Bar (always on)

Standards in [`instructions/`](../instructions/) auto-attach via `applyTo` globs and apply to every contribution, agent or not:

- `coding-standards` — SOLID, complexity budgets, stated time/space complexity on hot paths
- `testing-standards` — AAA, 80% line coverage / 90% on critical paths
- `docker-standards` — multi-stage, non-root, health checks
- `parallel-execution` — independent work runs concurrently
- `team-collaboration` — shared state, gates, anti-patterns, team norms

If you cannot meet a standard, say so explicitly. Do not silently lower the bar.

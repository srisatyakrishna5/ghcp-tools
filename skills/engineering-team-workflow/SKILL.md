---
name: engineering-team-workflow
description: "Workflow guidance for coordinated multi-agent software delivery. Use for tasks that should run like a software engineering team with brainstorming, shared state, feedback loops, orchestration patterns, and integration gates."
---

# Engineering Team Workflow

Use this skill when a task should run like a software engineering team — not a single fast-path specialist.

## Use For

* End-to-end feature delivery from a free-form user requirement
* Multi-role work that needs requirements → design → code → tests → review → ship
* Parallel workstreams that need a controlled rejoin
* Tasks where reviewer findings must flow back to the owning implementer

## Team Roles

| Role | Owns |
|------|------|
| Tech Lead | Orchestration, shared state, workflow selection, integration gate |
| Product Manager | Product Brief: problem, personas, user stories, acceptance criteria, non-goals |
| Program Manager | Delivery plan, dependency graph, brainstorming facilitation, risks, integration owner |
| Architect | ADRs, module boundaries, contracts, trade-off analysis |
| Developer | Production-grade implementation, complexity discipline, stated time/space cost |
| Debugger | Reproduction, root-cause analysis, minimal verified fix |
| QA Analyst | Test plan, AC-to-test coverage matrix, exit criteria for the integration gate |
| Test Engineer | Unit and integration test code, coverage measurement |
| Code Reviewer | Independent quality gate, severity-ranked findings |
| Security Engineer | STRIDE threat model, OWASP/SANS controls, supply chain |
| DevOps Engineer | Docker, CI/CD, deployment artifacts |
| Documentation Engineer | Public API docs, READMEs, ADR linkage |
| Data Scientist | RAG / multi-modal pipelines, retrieval quality, latency budgets |

## Shared State Contract

Maintain one shared task state and update it after every phase:

```text
TEAM_GOAL:
MODE: team
PHASE:
WORKFLOW: copilot-workflows/<pattern>.workflow.md
WORKSTREAMS:
DECISIONS:                 # PRODUCT_BRIEF-NNN, DELIVERY_PLAN-NNN, ADR-NNN, TEST_PLAN-NNN, ...
OPEN_QUESTIONS:
BLOCKERS:
CHANGED_FILES:
VALIDATION:
REVIEW_FINDINGS:
NEXT_OWNER:
INTEGRATION_OWNER:
```

## Phase Model

1. **Brainstorm & Clarify** — Product Manager produces the Product Brief; Program Manager runs `copilot-workflows/brainstorm-converge.workflow.md` when the solution space is open.
2. **Plan** — Program Manager produces the Delivery Plan: workstreams, dependency graph, orchestration patterns per phase, integration owner, top risks.
3. **Design** — Architect produces ADRs when contracts, boundaries, or trade-offs are required. Skip for localized changes.
4. **Implement** — Developer (or Debugger for bug work) implements the scoped change. Multiple modules run via `copilot-workflows/parallel.workflow.md` or `copilot-workflows/orchestrator-worker.workflow.md`.
5. **Test** — QA Analyst defines the test plan; Test Engineer writes the tests. Run via `copilot-workflows/fan-out.workflow.md` alongside docs/devops/security when independent.
6. **Review** — Code Reviewer and Security Engineer apply `copilot-workflows/iterative-refinement.workflow.md`. Findings route back to the owning agent until the bar is met.
7. **Integrate & Ship** — Tech Lead runs the integration gate via `copilot-workflows/fan-in.workflow.md`, validates the production gate, closes the task.

## Orchestration Pattern Library

Every phase selects one pattern from `copilot-workflows/`. See `copilot-workflows/README.md` for the full index:

- Sequential, Parallel, Fan-Out, Fan-In
- Pipeline (gated stages)
- Iterative Refinement (review loops)
- Brainstorm → Converge
- Orchestrator–Worker (dynamic decomposition)
- Router (classify and dispatch)
- Reflection (self-critique)
- Escalation (cheap-first, strong-on-block)

## Collaboration Rules

* Every handoff carries two parts: the full current `TEAM_STATE` and a `MISSION` block specific to the receiving specialist. Specialists must not be invoked with incomplete state.
* `MISSION.WORKFLOW` names the orchestration pattern this dispatch is part of.
* `MISSION.PRIOR_OUTPUTS` carries structured outputs of completed phases — specialists consume these to avoid re-deriving decisions already made upstream.
* Parallel branches MUST produce outputs that can be merged by the named integration owner.
* Reviewer findings MUST become actionable `TEAM_STATE.REVIEW_FINDINGS` entries with an owning agent, not passive commentary.
* Do not skip the QA Analyst's exit-criteria check when ACs exist in the Product Brief.
* Do not close the task while blockers, unresolved review findings, or missing validations remain hidden.

## Done Checklist

* Every P0 user story in the Product Brief has at least one passing test
* Changed files are accounted for in `CHANGED_FILES`
* Validation is explicit (tests pass, coverage targets met, complexity within budget)
* Stated time/space complexity verified for hot paths
* Review status is explicit; no open Critical or Major findings
* Security review status is explicit; no unresolved Critical or High findings without risk-owner sign-off
* Documentation impact is explicit
* SLO targets (p95 latency, error rate, throughput) are confirmed met or explicitly accepted as out of scope
* Rollback plan is documented when the change is not trivially reversible
* Observability confirmed: logs, metrics, and alerts cover the changed behavior or gaps are explicitly accepted
* Remaining risks and follow-ups are explicit

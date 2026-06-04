---
title: Agentic Software Engineering Team for GitHub Copilot
description: A complete set of GitHub Copilot agents, instructions, skills, and orchestration workflows that turn Copilot into an end-to-end software engineering team — brainstorming, planning, designing, building, testing, reviewing, and shipping production-grade code.
author: Sri Satya Krishna
ms.date: 2026-05-20
ms.topic: overview
keywords:
  - github copilot
  - agentic ai
  - software engineering team
  - orchestration workflows
  - fan-in fan-out parallel sequential
  - prompt engineering
estimated_reading_time: 8
---

## Overview

This repository turns GitHub Copilot into an **agentic software engineering team**. A roster of role-specialized AI agents — Product Manager, Program Manager, Architect, Developer, QA Analyst, Test Engineer, Code Reviewer, Security Engineer, DevOps Engineer, Documentation Engineer, Data Scientist, Debugger, Prompt Engineer — collaborates under a Tech Lead orchestrator to convert a free-form requirement into shippable, production-grade software.

The team coordinates through **explicit orchestration workflows** (sequential, parallel, fan-out, fan-in, pipeline, iterative refinement, brainstorm → converge, orchestrator–worker, router, reflection, escalation) and a shared task-state protocol that keeps decisions, blockers, and review findings auditable from kickoff to ship.

## What Makes This Different

- **Whole-team coverage**: roles upstream of code (Product, Program, QA Analyst) and downstream (Reviewer, Security, DevOps, Docs) — not just a single developer persona.
- **Explicit workflow library**: every phase names one orchestration pattern from `copilot-workflows/`. No implicit serialization, no orphan parallel branches.
- **Shared state contract**: `TEAM_STATE` + `MISSION` blocks make every handoff complete and auditable.
- **Brainstorm built in**: a divergent → converge workflow runs at kickoff and after blockers.
- **Quality bar enforced**: SOLID, complexity budgets, **stated time/space complexity**, 80%+ coverage, OWASP/SANS controls, and a Production Gate before close.
- **Feedback loops, not one-shots**: review findings route back to the owner; the loop has a budget and an escalation path.

## Repository Structure

```text
.
├── AGENTS.md                              # Root team entry doc (humans + Copilot)
├── .github/
│   └── copilot-instructions.md            # Auto-routes engineering work to @tech-lead
├── agents/                                # Role-based AI personas
│   ├── product-manager.agent.md           # Product Brief: stories, ACs, non-goals
│   ├── program-manager.agent.md           # Delivery plan, dependencies, brainstorming facilitator
│   ├── architect.agent.md                 # ADRs, contracts, trade-offs
│   ├── tech-lead.agent.md                 # Orchestrator + workflow selection
│   ├── developer.agent.md                 # Production-grade implementation
│   ├── debugger.agent.md                  # Reproduce → root-cause → verified fix
│   ├── qa-analyst.agent.md                # Test plan + AC coverage matrix + exit criteria
│   ├── test-engineer.agent.md             # Unit + integration test code
│   ├── code-reviewer.agent.md             # Independent quality gate
│   ├── security-engineer.agent.md         # STRIDE, OWASP, SANS, supply chain
│   ├── devops-engineer.agent.md           # Docker, CI/CD, deployment
│   ├── documentation-engineer.agent.md    # Public API + README + ADR linkage
│   ├── data-scientist.agent.md            # RAG, multi-modal, retrieval quality
│   └── prompt-engineer.agent.md           # Prompt determinism, token budget
├── instructions/                          # Always-active rule sets
│   ├── coding-standards.instructions.md   # SOLID, patterns, DSA, time complexity
│   ├── testing-standards.instructions.md  # AAA, coverage targets, isolation
│   ├── docker-standards.instructions.md   # Multi-stage, non-root, health checks
│   ├── parallel-execution.instructions.md # Mandatory parallelism rules
│   └── team-collaboration.instructions.md # Shared state, gates, conflict resolution, voice, persistent memory
├── copilot-workflows/                             # Orchestration pattern library
│   ├── README.md                          # Pattern index + composition rules
│   ├── sequential.workflow.md
│   ├── parallel.workflow.md
│   ├── fan-out.workflow.md
│   ├── fan-in.workflow.md
│   ├── pipeline.workflow.md
│   ├── iterative-refinement.workflow.md
│   ├── brainstorm-converge.workflow.md
│   ├── orchestrator-worker.workflow.md
│   ├── router.workflow.md
│   ├── reflection.workflow.md
│   ├── escalation.workflow.md
│   ├── standup.workflow.md                # Team ritual — cross-stream sync
│   ├── design-review.workflow.md          # Team ritual — vet ADR before lock-in
│   ├── pairing.workflow.md                # Team ritual — driver ↔ navigator on high-stakes scope
│   └── retro.workflow.md                  # Team ritual — durable lessons → .copilot-team/team-log.md
└── skills/
    └── engineering-team-workflow/
        └── SKILL.md                       # Team mode protocol: roles, phases, gates
```

## The Engineering Team

### Upstream — "What" and "When"

| Agent | Responsibility |
|-------|----------------|
| **Product Manager** | Translates the raw user requirement into a Product Brief: problem, personas, prioritized user stories with Given/When/Then acceptance criteria, success metrics, non-goals. |
| **Program Manager** | Facilitates brainstorming, builds the delivery plan, names workstreams and the integration owner, selects the orchestration workflow pattern per phase, surfaces risks. |

### Design — "How"

| Agent | Responsibility |
|-------|----------------|
| **Architect** | Produces ADRs covering decisions, structure, dependencies, and risks. Picks data structures, algorithms, and patterns appropriate to the load profile. |
| **Data Scientist** | Owns retrieval, embeddings, multi-modal pipelines, quality floors (MRR, p@k), and latency budgets when AI/RAG is in scope. |

### Build — "Make it work, make it clean, make it fast"

| Agent | Responsibility |
|-------|----------------|
| **Developer** | Production-grade implementation honoring SOLID, complexity budgets, and stated time/space complexity on hot paths. |
| **Debugger** | For bug work: reproduces before fixing, minimal diff, regression coverage. |

### Verify — "Prove it works and is safe"

| Agent | Responsibility |
|-------|----------------|
| **QA Analyst** | Builds the test plan, maps every AC to a test, defines exit criteria for the integration gate. |
| **Test Engineer** | Writes unit + integration test code. 80% line coverage minimum; 90%+ on auth, payment, mutation, state-transition paths. |
| **Code Reviewer** | Independent quality gate. Severity-ranked findings; runs validation commands as evidence. |
| **Security Engineer** | STRIDE threat model, OWASP Top 10, SANS Top 25, secrets, supply chain, domain controls. |

### Ship — "Make it deployable and documented"

| Agent | Responsibility |
|-------|----------------|
| **DevOps Engineer** | Multi-stage Docker, CI/CD, deployment artifacts. |
| **Documentation Engineer** | Public API docs, READMEs, ADR cross-references. |
| **Prompt Engineer** | Optimizes prompts for determinism and token efficiency when LLM prompts are in scope. |

### Coordinate — "Make the team a team"

| Agent | Responsibility |
|-------|----------------|
| **Tech Lead** | Owns mode (fast / team), builds `TEAM_STATE` + `MISSION` for every dispatch, picks the workflow pattern, runs the integration and production gates. |

## Orchestration Workflows

Every phase in team mode names one workflow pattern from `copilot-workflows/`. A typical end-to-end delivery composes them:

```text
brainstorm-converge          → open the solution space, pick a direction
   ↓ sequential               → product-manager → program-manager → architect
   ↓ fan-out                  → developer(s) ∥ docs ∥ devops ∥ security (when independent)
   ↓ fan-in                   → integration owner merges and validates
   ↓ iterative-refinement     → code-reviewer ↔ developer until bar met
   ↓ pipeline (gated)         → security → docs → devops → production gate
```

Pattern catalog:

| Pattern | Topology |
|---------|----------|
| `sequential` | `A → B → C` |
| `parallel` | `A_1 ∥ A_2 ∥ A_3` |
| `fan-out` | `A → {B, C, D}` |
| `fan-in` | `{B, C, D} → E` |
| `pipeline` | Multi-stage with quality gates between stages |
| `iterative-refinement` | Reviewer ↔ implementer loop with bounded budget |
| `brainstorm-converge` | Diverge → critique → converge |
| `orchestrator-worker` | Orchestrator discovers and dispatches N workers dynamically |
| `router` | Classify input, dispatch to the single best specialist |
| `reflection` | Single-agent self-critique pass |
| `escalation` | Cheap-first; escalate to stronger specialist on blocking signal |
| `standup` | Cross-stream sync during long deliveries |
| `design-review` | Vet an ADR/contract with downstream specialists before lock-in |
| `pairing` | Driver ↔ navigator on high-stakes scope |
| `retro` | Capture durable lessons after a delivery or blocker |

See [copilot-workflows/README.md](copilot-workflows/README.md) for the full index, selection rules, and the contract every pattern must honor.

## Shared State Contract

Every handoff carries two parts. The Tech Lead builds both before invoking any specialist.

```text
TEAM_STATE:
  TEAM_GOAL:
  PHASE:
  WORKFLOW: copilot-workflows/<pattern>.workflow.md
  DECISIONS:                 # PRODUCT_BRIEF-NNN, DELIVERY_PLAN-NNN, ADR-NNN, TEST_PLAN-NNN
  WORKSTREAMS:
  OPEN_QUESTIONS:
  BLOCKERS:
  CHANGED_FILES:
  VALIDATION:
  REVIEW_FINDINGS:
  NEXT_OWNER:
  INTEGRATION_OWNER:

MISSION:
  ROLE: product-manager | program-manager | architect | developer | ... | tech-lead
  TASK: one concrete sentence
  TYPE: requirements | planning | feature | bug | infra | docs | data | security
  FILES: explicit list
  WORKFLOW: copilot-workflows/<pattern>.workflow.md
  SKILL: one runtime skill path (or none)
  PRIOR_OUTPUTS: structured references to upstream artifacts
  DONE_WHEN: measurable acceptance criteria
  CONSTRAINTS: non-negotiables
  RETURN: brief | team-handoff
```

## Quality Bar

The Production Gate (from `instructions/team-collaboration.instructions.md`) is non-optional in team mode:

- Every P0 user story has at least one passing test
- 80%+ line coverage; 90%+ on auth/payment/mutation/state-transition paths
- Cyclomatic ≤ 10, cognitive ≤ 15, nesting ≤ 3, file ≤ 300 lines
- **Stated time/space complexity on hot paths, verified at review**
- No unresolved Critical or High security findings without risk-owner sign-off
- p95 latency / error rate / throughput targets met or explicitly accepted
- Rollback plan documented when the change is not trivially reversible
- Observability covers the changed behavior

## How It Works

### Instructions

Activate automatically based on `applyTo` file globs:

- `coding-standards`: SOLID, design patterns, **data structures + algorithms + time complexity**, complexity budgets.
- `testing-standards`: AAA, 80%+ coverage, deterministic isolation.
- `docker-standards`: Multi-stage, non-root, health checks, distroless.
- `parallel-execution`: Mandatory parallelism — independent work runs concurrently.
- `team-collaboration`: Shared state, feedback loops, integration gate, production gate.

### Agents

Invoked by name in Copilot Chat (e.g., `@tech-lead`, `@product-manager`, `@architect`). The Tech Lead is the entry point for full team-mode delivery.

### Workflows

Selected per phase by the Program Manager and enforced by the Tech Lead. Each pattern file documents when to use it, the topology, the data-flow contract, and failure handling.

### Skill

`skills/engineering-team-workflow/SKILL.md` is the protocol layer: roles, phases, shared state, collaboration rules, and the Done Checklist.

## Installation: Hosting in Your Repository

GitHub Copilot auto-discovers agents, instructions, and skills under `.github/` at the repo root.

```text
your-repo/
└── .github/
    ├── agents/                # copy from this repo's agents/
    ├── instructions/          # copy from this repo's instructions/
    ├── copilot-workflows/             # copy from this repo's copilot-workflows/
    └── skills/
        └── engineering-team-workflow/
            └── SKILL.md       # copy from this repo's skill
```

Steps:

1. Create `.github/` at your repository root.
2. Copy `agents/` → `.github/agents/`. Files must end in `.agent.md`. Copilot exposes them in chat (`@developer`, `@tech-lead`, etc.).
3. Copy `instructions/` → `.github/instructions/`. Files must end in `.instructions.md`. Copilot loads them based on each file's `applyTo` glob.
4. Copy `copilot-workflows/` → `.github/copilot-workflows/` (or any subfolder you reference from the Tech Lead). Each pattern is a normal markdown file the orchestrator can read.
5. Copy `skills/engineering-team-workflow/SKILL.md` → `.github/skills/engineering-team-workflow/SKILL.md`.
6. Commit and push. Every contributor gets the team automatically.

> **Note:** if your CI already uses `.github/copilot-workflows/` for GitHub Actions, either keep the orchestration patterns under `.github/copilot-copilot-workflows/` and update path references in `tech-lead.agent.md` and the skill, or store them at the repository root (e.g., `copilot-workflows/`) as in this repo.

## Getting Started

The repository is **auto-discoverable by GitHub Copilot**:

* `.github/copilot-instructions.md` tells the default Copilot to route non-trivial software engineering requests through `@tech-lead`.
* `AGENTS.md` is the root entry doc — the "meet the team" page that both humans and Copilot read first.

Start a team-mode delivery in chat:

```text
@tech-lead Run this like a software engineering team:
"Build a URL shortener service with rate limiting, OAuth, and analytics."
```

The Tech Lead will:

1. Route to the **Product Manager** for a Product Brief with prioritized stories and ACs.
2. Route to the **Program Manager** for a Delivery Plan that names workflow patterns per phase and the integration owner.
3. Optionally run a **brainstorm → converge** pass for open design questions.
4. Dispatch the **Architect** for an ADR.
5. Fan out **Developer**, **DevOps**, and **Documentation Engineer** in parallel where independent.
6. Loop **Code Reviewer** ↔ **Developer** via iterative refinement.
7. Run the **QA Analyst** exit-criteria check.
8. Apply the **Security Engineer** STRIDE review.
9. Validate the **Production Gate** and close.

For simple work, the Tech Lead picks fast mode and a single specialist — no orchestration overhead.

## Customization

- Add a new agent → drop `your-role.agent.md` into `agents/`.
- Add a new orchestration pattern → drop `your-pattern.workflow.md` into `copilot-workflows/` and reference it from `tech-lead.agent.md` and `skills/engineering-team-workflow/SKILL.md`.
- Tighten standards → edit thresholds in `instructions/coding-standards.instructions.md` or `instructions/testing-standards.instructions.md`.
- Add a domain skill (finance, healthcare, etc.) → create a skill folder under `skills/` and reference its path in `MISSION.SKILL`.

## Design Philosophy

- **Make the team explicit.** Roles, handoffs, and workflows are documented, not implicit.
- **Default to parallel.** Independent work runs concurrently; serialization requires a true data dependency.
- **Feedback loops, not one-shots.** Review findings route back; quality is iterated to the bar.
- **Brief by default, deep on demand.** Specialists return concise summaries; reference skills load only when runtime cards aren't enough.
- **Production-grade by construction.** SOLID, complexity budgets, stated complexity, coverage, security, observability, and rollback are gate conditions — not aspirations.

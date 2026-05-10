---
title: GHCP Instructions, Skills & Agents
description: Performance-optimized GitHub Copilot customization assets with runtime skills, reference skills, team collaboration workflows, and specialist agents
author: Sri Satya Krishna
ms.date: 2026-05-07
ms.topic: overview
keywords:
  - github copilot
  - agents
  - instructions
  - skills
  - prompt optimization
estimated_reading_time: 6
---

## Overview

A curated collection of GitHub Copilot customization files that transform generic AI assistance into a precision engineering partner. These files encode team standards, domain expertise, and role-specific personas so that Copilot produces production-ready output aligned with your conventions automatically.

## Repository Structure

```text
├── .github/
│   ├── agents/                     # Role-based AI personas with brief response contracts
│   │   ├── architect.agent.md
│   │   ├── code-reviewer.agent.md
│   │   ├── data-scientist.agent.md
│   │   ├── debugger.agent.md
│   │   ├── developer.agent.md
│   │   ├── devops-engineer.agent.md
│   │   ├── documentation-engineer.agent.md
│   │   ├── prompt-engineer.agent.md
│   │   ├── tech-lead.agent.md
│   │   └── test-engineer.agent.md
│   ├── instructions/               # Always-active rule sets
│   │   ├── coding-standards.instructions.md
│   │   ├── docker-standards.instructions.md
│   │   ├── parallel-execution.instructions.md
│   │   ├── team-collaboration.instructions.md
│   │   └── testing-standards.instructions.md
│   └── skills/
│       ├── engineering-team-workflow/       # Collaboration workflow skill for team-style execution
│       ├── agentic-ai-runtime/               # Small runtime skill card
│       ├── data-science-multimodal-runtime/  # Small runtime skill card
│       ├── fastapi-runtime/                  # Small runtime skill card
│       ├── mongodb-runtime/                  # Small runtime skill card
│       ├── postgres-runtime/                 # Small runtime skill card
│       ├── agentic-ai-patterns/              # Reference router for advanced Agentic AI skills
│       ├── agentic-ai-foundations/           # Core agent architecture and planning reference
│       ├── agentic-ai-orchestration/         # Multi-agent workflow reference
│       ├── agentic-ai-protocols/             # MCP, A2A, and oversight reference
│       ├── agentic-ai-guardrails/            # Safety and control reference
│       ├── agentic-ai-memory-rag/            # Memory, RAG, and resilience reference
│       ├── agentic-ai-evaluation/            # Evaluation and structured-output reference
│       ├── data-science-multimodal/          # Full reference manual
│       ├── fastapi-patterns/                 # Full reference manual
│       ├── mongodb-patterns/                 # Full reference manual
│       └── postgres-patterns/                # Full reference manual
```

## How It Works

### Instructions

Declarative rules that apply automatically based on file patterns. They enforce non-negotiable standards without requiring explicit prompts.

* `coding-standards`: Applies to all source code and enforces SOLID principles, naming conventions, complexity ≤ 10, functions under 20 lines, and a maximum of 4 parameters.
* `testing-standards`: Applies to test files and enforces 80% coverage minimum, AAA structure, isolation, and determinism.
* `docker-standards`: Applies to Dockerfiles and Compose files and enforces multi-stage builds, non-root execution, health checks, and lean production images.
* `parallel-execution`: Applies to workflows and enforces dependency-aware parallel execution across agents.
* `team-collaboration`: Applies the shared-state, feedback-loop, and integration-gate rules needed for multi-agent delivery to behave like a software team.

### Skills

The skill layer is split into two tiers:

* Runtime skills: Small decision cards used during normal execution with low token cost.
* Reference skills: Full manuals with extended patterns and examples, used only when the runtime card is insufficient.

Runtime skills are the default path. Reference skills are opt-in and should be loaded only when the runtime card is insufficient.

Runtime skills:

* **Engineering Team Workflow**: Shared state, feedback loops, rework, and integration gates for team-style execution.
* **FastAPI Runtime**: Routes, dependencies, request and response models, middleware, and tests.
* **PostgreSQL Runtime**: Schema updates, repositories, queries, and migrations.
* **MongoDB Runtime**: Document modeling, repositories, aggregation, and basic indexing.
* **Agentic AI Runtime**: Tool use, structured outputs, simple orchestration, and basic RAG.
* **Data Science Multi-Modal Runtime**: Ingestion, chunking, embeddings, retrieval, and evaluation.

Reference skills:

* **FastAPI Patterns**: Deeper framework patterns and advanced examples.
* **PostgreSQL Patterns**: Detailed indexing, migrations, pooling, and ORM guidance.
* **MongoDB Patterns**: Advanced modeling and aggregation guidance.
* **Agentic AI Reference Router**: Lightweight entry point that directs GHCP to the narrowest advanced Agentic AI reference.
* **Agentic AI Foundations**: Core architecture, reflection, tool use, planning, and foundational collaboration.
* **Agentic AI Orchestration**: Prompt chaining, routing, parallelization, supervisor, debate, and handoff patterns.
* **Agentic AI Protocols**: MCP, A2A, approval gates, and checkpoint-resume patterns.
* **Agentic AI Guardrails**: Input and output validation, tool safety, and boundary enforcement.
* **Agentic AI Memory and RAG**: Memory systems, retrieval architecture, chunking, and resilience patterns.
* **Agentic AI Evaluation**: Observability, evaluation frameworks, function calling, and structured outputs.
* **Data Science Multi-Modal**: Advanced ingestion, hybrid retrieval, and evaluation frameworks.

### Agents

Persona-driven specialists approach problems from a specific engineering role's perspective. The Tech Lead orchestrates only when the task size justifies it.

* **Tech Lead**: Orchestrator that uses task-size gating, delegates selectively, and parallelizes only justified branches.
* **Architect**: System designer focused on trade-off analysis, ADRs, module boundaries, and API contracts.
* **Developer**: Implementer focused on clean code, SOLID compliance, and production-grade changes.
* **Test Engineer**: Quality specialist focused on coverage strategy, edge cases, and test isolation.
* **Code Reviewer**: Quality gate focused on severity-graded findings and security review.
* **DevOps Engineer**: Infrastructure specialist focused on Docker builds, CI/CD pipelines, and deployment assets.
* **Documentation Engineer**: Documentation specialist focused on docstrings, README files, API docs, and architecture docs.
* **Prompt Engineer**: AI optimization specialist focused on determinism, token reduction, and output format control.

## Engineering Team Mode

The repository supports two orchestration styles:

* Fast mode keeps simple work lean by using one specialist and brief handoffs.
* Team mode makes GHCP behave more like a software engineering team by adding shared task state, explicit ownership, reviewer-to-implementer feedback loops, and an integration gate.

Use team mode when the task spans multiple specialties, requires parallel branches that must rejoin, or when you want agents to collaborate closely instead of acting as isolated specialists.

## Installation: Hosting in Your Repository

GitHub Copilot automatically discovers agents, instructions, and skills when they are placed inside the `.github/` folder at the root of your code repository. No configuration or plugin installs are required.

### Required Folder Structure

```text
your-repo/
├── .github/
│   ├── agents/
│   │   ├── architect.agent.md
│   │   ├── code-reviewer.agent.md
│   │   ├── developer.agent.md
│   │   ├── devops-engineer.agent.md
│   │   ├── documentation-engineer.agent.md
│   │   ├── prompt-engineer.agent.md
│   │   ├── tech-lead.agent.md
│   │   └── test-engineer.agent.md
│   ├── instructions/
│   │   ├── coding-standards.instructions.md
│   │   ├── docker-standards.instructions.md
│   │   ├── parallel-execution.instructions.md
│   │   ├── team-collaboration.instructions.md
│   │   └── testing-standards.instructions.md
│   └── skills/
│       ├── engineering-team-workflow/
│       │   └── SKILL.md
│       ├── fastapi-runtime/
│       │   └── SKILL.md
│       ├── postgres-runtime/
│       │   └── SKILL.md
│       ├── mongodb-runtime/
│       │   └── SKILL.md
│       ├── agentic-ai-runtime/
│       │   └── SKILL.md
│       ├── data-science-multimodal-runtime/
│       │   └── SKILL.md
│       ├── agentic-ai-patterns/
│       │   └── SKILL.md
│       ├── agentic-ai-foundations/
│       │   └── SKILL.md
│       ├── agentic-ai-orchestration/
│       │   └── SKILL.md
│       ├── agentic-ai-protocols/
│       │   └── SKILL.md
│       ├── agentic-ai-guardrails/
│       │   └── SKILL.md
│       ├── agentic-ai-memory-rag/
│       │   └── SKILL.md
│       ├── agentic-ai-evaluation/
│       │   └── SKILL.md
│       ├── fastapi-patterns/
│       │   └── SKILL.md
│       ├── postgres-patterns/
│       │   └── SKILL.md
│       ├── mongodb-patterns/
│       │   └── SKILL.md
│       └── data-science-multimodal/
│           └── SKILL.md
├── src/
└── ...
```

### How to Set Up

1. Create a `.github/` folder at the root of your repository (if it doesn't already exist).
2. Copy the `agents/` folder into `.github/agents/`. Each file must have the `.agent.md` extension. Copilot will detect them and make them available as invocable agents in chat (e.g., `@developer`, `@tech-lead`).
3. Copy the `instructions/` folder into `.github/instructions/`. Each file must have the `.instructions.md` extension. Copilot loads these automatically based on the `applyTo` glob pattern in the file's YAML frontmatter — no manual invocation needed.
4. Copy the `skills/` folder into `.github/skills/`. Each skill lives in its own subfolder and the file must be named `SKILL.md`. Use runtime skills for normal execution and keep reference skills for advanced lookups.
5. Commit and push. Every developer who clones the repository automatically gets these customizations — no local setup required.

### Key Points

* The `.github/` folder must be at the repository root — not nested inside `src/` or any other directory.
* Instructions with an `applyTo` pattern (e.g., `**/*.py`) activate only when Copilot is working on files matching that pattern.
* Agents become available in GitHub Copilot Chat and can be invoked by their filename prefix (without the `.agent.md` suffix).
* Changes to these files take effect immediately after saving — no restart or rebuild required.
* This works across all team members. One setup benefits everyone who uses the repository.

## Performance Model

The repository is optimized around fast default behavior:

* Runtime skills load before reference skills
* Large Agentic AI guidance is split into narrow advanced references instead of one monolithic manual
* Specialists return brief summaries by default
* The Tech Lead uses task-size gating and can switch between fast mode and team mode
* Parallelism is used only when dependency-free work justifies it
* Full reference manuals are opt-in for advanced cases only

## Getting Started

1. **Fork or clone** this repository and copy the `.github/` folder into your project root
2. **Instructions activate automatically** based on `applyTo` file patterns
3. **Invoke agents** by referencing them in Copilot Chat (for example `@tech-lead implement a user service` or `@tech-lead run this like a software engineering team`)
4. **Prefer runtime skills** during normal execution and escalate to reference skills only when needed

## Parallel Execution

The Tech Lead agent and the `parallel-execution` instruction enforce automatic parallelism:

* Independent modules are implemented simultaneously
* Tests, docs, and DevOps configs run in parallel after implementation
* Only true data dependencies (architecture → code → review) are serialized
* Simple tasks stay single-threaded to avoid orchestration overhead

## Collaborative Delivery

When you need close collaboration, the Tech Lead can switch to team mode:

* One shared task state is maintained across specialists
* Parallel branches have a named integration owner before they start
* Reviewer findings go back to the owning implementer instead of ending the flow
* The task does not close until validation, review, and documentation triggers are resolved

## Customization

* Add new skills by creating a folder under `skills/` with a `SKILL.md` file
* For larger skills, create a small runtime card and keep the long manual as a separate reference skill
* Add new instructions by creating `.instructions.md` files with `applyTo` patterns
* Add new agents by creating `.agent.md` files with role descriptions and workflows
* Modify complexity thresholds, coverage targets, or conventions to match your team's standards

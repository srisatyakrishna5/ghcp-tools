---
name: agentic-ai-patterns
description: "Advanced reference for Agentic AI design and implementation. Use for architecture, orchestration, guardrails, protocol integration, memory, and evaluation when runtime guidance is insufficient."
---

# Agentic AI Patterns

Use `#file:skills/agentic-ai-runtime/SKILL.md` for routine work. Load this reference only when the runtime card is insufficient.

## Use For

* Agent architecture and responsibility boundaries
* Multi-agent orchestration and handoff contracts
* Protocol integration for tools and agent-to-agent workflows
* Guardrails for inputs, outputs, and tool calls
* Memory and retrieval architecture
* Evaluation and observability for quality and latency

## Core Rules

* Prefer single-agent flows before introducing multi-agent orchestration
* Keep tool interfaces explicit and typed
* Require structured outputs for machine-consumable steps
* Keep handoff contracts short and deterministic
* Gate high-risk actions behind explicit approval steps
* Separate planning, execution, and evaluation responsibilities

## Advanced Checklist

* Orchestration pattern is justified by task complexity
* Ownership is explicit for each branch and handoff
* Guardrails are defined at every external boundary
* Retrieval quality and latency are measured
* Validation and review criteria are explicit

## Pattern Selection

* Use prompt chains for fixed linear workflows
* Use routing when requests map to distinct specialist paths
* Use orchestrator-workers for decomposable parallel work
* Use evaluator loops only when objective quality checks exist
* Use protocol integration only when cross-system interoperability is required

## Output Expectations

When this reference is used, return:

* Design decision and rationale
* Chosen orchestration pattern
* Contract for inputs and outputs
* Validation and risk controls
* Explicit next owner for implementation

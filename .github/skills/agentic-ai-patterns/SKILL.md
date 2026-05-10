---
name: agentic-ai-patterns
description: "Routing guide for advanced Agentic AI references. Use this index to load the narrowest advanced Agentic AI subskill required for the task."
---

# Agentic AI Reference Router

Use `#file:skills/agentic-ai-runtime/SKILL.md` for routine work. Load this router only when the runtime card is insufficient.

## Load the Narrowest Reference

* Foundations: `#file:skills/agentic-ai-foundations/SKILL.md` for core agent architecture, reflection, tool use, planning, and foundational collaboration.
* Orchestration: `#file:skills/agentic-ai-orchestration/SKILL.md` for prompt chains, routing, parallelization, orchestrator-workers, supervisor, debate, and handoff patterns.
* Protocols and oversight: `#file:skills/agentic-ai-protocols/SKILL.md` for MCP, A2A, approval gates, and checkpoint-resume workflows.
* Guardrails: `#file:skills/agentic-ai-guardrails/SKILL.md` for input and output validation, tool controls, and safety boundaries.
* Memory and RAG: `#file:skills/agentic-ai-memory-rag/SKILL.md` for memory systems, RAG architecture, chunking, and resilience patterns.
* Evaluation and structured outputs: `#file:skills/agentic-ai-evaluation/SKILL.md` for observability, evaluation frameworks, function calling, and structured output guidance.

## Escalation Guide

* Need the core agent loop or planning strategy: load Foundations.
* Need multi-agent workflow design or delegation patterns: load Orchestration.
* Need interoperable tool or agent protocols: load Protocols and oversight.
* Need stronger safety boundaries or action controls: load Guardrails.
* Need retrieval architecture, memory, or recovery strategies: load Memory and RAG.
* Need traceability, evals, or strict machine-readable outputs: load Evaluation and structured outputs.

## Rules

* Load one advanced reference first, not all of them.
* Add a second advanced reference only when the first one is insufficient.
* Return to the runtime skill for routine implementation guidance.

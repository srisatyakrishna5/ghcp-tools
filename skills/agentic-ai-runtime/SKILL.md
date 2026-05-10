---
name: agentic-ai-runtime
description: "Runtime guidance for routine agentic AI work. Use for tool use, prompt structure, simple orchestration, and RAG-adjacent flows. Prefer this over the full Agentic AI reference for routine tasks."
applyTo: "**/*agent*.py,**/*agent*.ts,**/*rag*.py,**/*rag*.ts"
---

# Agentic AI Runtime

Use this skill for routine agentic AI work. Load `#file:skills/agentic-ai-patterns/SKILL.md` only when this card is insufficient.

## Use For

* Tool-enabled agents
* Simple orchestration and handoffs
* Structured prompt and output design
* Basic RAG or retrieval-assisted workflows

## Core Rules

* Start with the simplest viable pattern
* Use one agent before introducing many
* Use one tool per clear job with explicit inputs and outputs
* Require structured outputs for machine-consumable results
* Bound loops, retries, and max steps
* Separate retrieval, reasoning, and action clearly

## Minimal Checklist

* Output schema is explicit
* Stop conditions are explicit
* Tool failure paths are handled
* Retrieval quality floor is defined before scaling complexity (e.g., MRR ≥ 0.70, precision@k ≥ 0.80)
* Token and latency budgets are stated with numeric targets (e.g., p95 response time, max tokens per call)
* Error rate budget is defined (e.g., tool failure rate ≤ 1%)

## Escalate to Full Reference When

* You need deeper architecture and orchestration guidance beyond this runtime card: `#file:skills/agentic-ai-patterns/SKILL.md`
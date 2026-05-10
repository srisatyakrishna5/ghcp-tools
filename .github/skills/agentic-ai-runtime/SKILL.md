---
name: agentic-ai-runtime
description: "Runtime guidance for routine agentic AI work. Use for tool use, prompt structure, simple orchestration, and RAG-adjacent flows. Prefer this over the full Agentic AI reference for routine tasks."
applyTo: "**/*agent*.py,**/*agent*.ts,**/*rag*.py,**/*rag*.ts,**/*llm*.py,**/*llm*.ts,**/*prompt*.py,**/*prompt*.ts,**/*mcp*.py,**/*mcp*.ts"
---

# Agentic AI Runtime

Use this skill for routine agentic AI work. Load `#file:skills/agentic-ai-patterns/SKILL.md` only when this card is insufficient and you need help choosing a narrower advanced reference.

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
* Retrieval is evaluated before adding more agents
* Token and latency budgets are acknowledged

## Escalate to Full Reference When

* You need core agent architecture, reflection, planning, or foundational collaboration: `#file:skills/agentic-ai-foundations/SKILL.md`
* You need multi-agent debate, supervisor, routing, or evaluator loops: `#file:skills/agentic-ai-orchestration/SKILL.md`
* You need memory systems, RAG architecture, chunking, or resilience patterns: `#file:skills/agentic-ai-memory-rag/SKILL.md`
* You need MCP, A2A, approval gates, or checkpoint-resume workflows: `#file:skills/agentic-ai-protocols/SKILL.md`
* You need advanced guardrails or tool safety controls: `#file:skills/agentic-ai-guardrails/SKILL.md`
* You need evaluation frameworks, observability, function calling, or structured outputs: `#file:skills/agentic-ai-evaluation/SKILL.md`
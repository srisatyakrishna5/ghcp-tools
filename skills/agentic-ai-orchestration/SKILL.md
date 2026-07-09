---
name: agentic-ai-orchestration
description: 'Design and implement multi-agent AI orchestration with LangGraph and Microsoft Agent Framework: supervisor, router, and planner-worker patterns, stateful graphs, checkpoints, tool use, memory, and summary-generation pipelines. USE WHEN: coordinate multiple agents, build a LangGraph or Microsoft Agent Framework workflow, add delegation, routing, or human-in-the-loop, or manage agent state and checkpoints. DO NOT USE FOR: single-agent RAG and prompt design (use ai-agent-rag-and-prompt-design); document extraction pipelines (use azure-document-rag-pipeline); memory and reasoning theory (use conversation-memory-and-reasoning).'
argument-hint: 'Describe the use case, target frameworks, number of agents, memory/state needs, tools, latency/cost goals, and safety or governance constraints.'
user-invocable: true
disable-model-invocation: false
---

# Agentic AI Orchestration and Multi-Agent Workflows

## When to Use
- Build multi-agent AI systems with planning, delegation, and coordination.
- Design stateful, multi-turn conversational assistants and summary generators.
- Implement workflows with LangGraph, Microsoft Agent Framework, or Azure AI Foundry-style orchestration.
- Add tool use, reflection, retries, memory, human approval, and evaluation loops to production AI applications.

## Core Objective
Create practical, production-ready agentic AI solutions that are modular, observable, safe, and capable of long-running multi-step reasoning.

## Workflow

### 1. Clarify the problem and orchestration shape
Start by identifying:
1. The end-user goal and success criteria.
2. Whether the system is a single assistant, a planner-worker workflow, a supervisor pattern, or a multi-agent network.
3. Required tools, external APIs, data sources, and retrieval needs.
4. Latency, cost, privacy, and compliance constraints.
5. Whether the interaction is short-lived, long-running, or summary-driven.

Decision points:
- If the task is mostly one-shot reasoning, use a simple agent first and add orchestration only if needed.
- If the task requires multiple specialized skills, prefer a supervisor or router pattern.
- If the user expects long conversations or workflow memory, design explicit state and summarization strategies from the start.

### 2. Choose the orchestration model
Select one of the following patterns based on complexity:
- Sequential pipeline: one stage feeds the next.
- Router or classifier: choose the right agent or tool based on intent.
- Supervisor pattern: one orchestrator delegates work and validates outputs.
- Planner-worker pattern: separate planning, execution, and verification.
- Human-in-the-loop: require approval for high-risk or expensive steps.

Use LangGraph-style nodes and edges when the workflow needs explicit state transitions, retries, checkpoints, or branching logic.
Use Microsoft Agent Framework patterns when the solution needs structured agent behavior, tool use, orchestration, or Azure-hosted integration.

### 3. Design explicit state and memory
For multi-turn assistants, define:
- Session state: user intent, current task, unresolved questions, selected tools.
- Long-term memory: preferences, prior summaries, durable facts.
- Short-term context: recent conversation turns, active plan, intermediate outputs.
- Checkpoints: save progress for recovery or resumption.

Good design rules:
- Keep state schema small, typed, and explicit.
- Separate ephemeral context from durable memory.
- Summarize older turns instead of passing the full history repeatedly.
- Store only what is needed for future reasoning or compliance.

### 4. Add tool use, routing, and fallback behavior
Build the agent so it can:
- Call tools safely with validated inputs and outputs.
- Retry transient failures with bounded backoff.
- Fall back to simpler logic when a tool or model fails.
- Escalate to a human or supervisor when confidence is low.

Recommended patterns:
- Tool adapter layer for API, DB, retrieval, or file access.
- Guardrails for prompt injection, sensitive data, and unsafe actions.
- Retry and timeout policies for external dependencies.
- Deterministic fallbacks for high-value but low-risk tasks.

### 5. Design the conversation and summary flow
For true multi-turn assistants and summary generators:
1. Maintain user intent across turns.
2. Detect when context should be condensed into a summary.
3. Preserve decisions, unresolved tasks, and references to prior outputs.
4. Generate concise summaries for handoff, memory, or follow-up actions.
5. Distinguish between answer generation, synthesis, and execution.

Decision points:
- If the conversation becomes long, summarize earlier context instead of passing raw history.
- If the user asks for a recap, create a task-specific summary with actions, decisions, and evidence.
- If the workflow is stateful, ensure summaries are linked to the current session state.

### 6. Use advanced framework features deliberately
Apply the strongest features of the frameworks only where they improve reliability or maintainability:
- LangGraph: nodes, edges, branching, conditional routing, checkpoints, retries, stateful graphs.
- Microsoft Agent Framework: structured agent definitions, tool invocation, orchestration patterns, evaluation hooks, and integrated workflows.
- Azure AI / Foundry capabilities: model routing, observability, safety filters, tracing, and deployment integration.

Do not over-engineer simple tasks with full orchestration graphs. Use advanced features when the workflow benefits from decomposition, memory, or coordination.

### 7. Build evaluation, observability, and safety gates
Before deployment, verify:
1. Agent routing quality and delegation accuracy.
2. Tool-call success rate, error handling, and retry behavior.
3. Multi-turn consistency and summary quality.
4. Latency, cost, and token efficiency under realistic loads.
5. Safety, prompt-injection resistance, and policy compliance.
6. Traceability of decisions, tool outputs, and final responses.

Recommended checks:
- Golden conversation tests for common user paths.
- Adversarial prompt tests for tool misuse and prompt injection.
- Human review for risky or irreversible actions.
- Observability for model calls, tool usage, state transitions, and summaries.

## Anti-Patterns to Avoid
- Building a multi-agent graph when a single agent or deterministic workflow would suffice.
- Large, untyped shared state that every node mutates, making runs hard to trace or resume.
- Passing full raw conversation history between agents instead of summarizing into compact state.
- Tool calls without input validation, timeouts, bounded retries, or fallbacks.
- No checkpoints, so long-running workflows cannot recover or resume after failure.
- Skipping routing-accuracy, tool-success, and end-to-end conversation evaluation.

## Decision Guide
- The task is mostly one-shot generation or classification.
- The workflow does not need tool chaining or multi-step reasoning.
- The conversation is short and does not require memory or summaries.

### Choose multi-agent orchestration when
- The workload needs specialized roles, routing, or collaboration.
- The solution must perform planning, execution, and verification.
- The system benefits from explicit state transitions or human approval steps.

### Choose LangGraph-style workflows when
- The process is graph-based, conditional, or stateful.
- The system needs checkpoints, retries, or branching logic.
- The workflow is long-running or complex enough to benefit from explicit orchestration.

### Choose Microsoft Agent Framework patterns when
- The system should be built around structured agents and tool use.
- The solution should integrate with Azure AI / Foundry or enterprise tool ecosystems.
- The team wants a framework-native way to manage agent behavior and orchestration.

## Quality Criteria
A strong solution should meet all of the following:
- Clear orchestration design with defined roles and responsibilities.
- Robust state management and memory policies.
- Safe, validated tool use with retries and fallbacks.
- Strong multi-turn behavior and summary quality.
- Traceable execution paths and good observability.
- Reasonable latency, cost, and operational complexity.

## Output Expectations
When invoked, this skill should help the user produce one of the following:
- A multi-agent architecture for an AI workflow.
- A LangGraph or Microsoft Agent Framework implementation plan.
- A state, memory, and summary design for a conversational assistant.
- A production-readiness checklist for agentic orchestration.

## Example Prompts to Try
- Design a LangGraph workflow for a multi-agent research assistant with planning, retrieval, and summary steps.
- Build a Microsoft Agent Framework solution for a multi-turn customer support assistant with tool use and escalation.
- Create a summary-generation pipeline that maintains session memory and checkpoints across long conversations.
- Compare supervisor, planner-worker, and router patterns for this agentic workflow and recommend one.

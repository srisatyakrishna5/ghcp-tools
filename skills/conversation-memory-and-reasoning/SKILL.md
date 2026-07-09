---
name: conversation-memory-and-reasoning
description: 'Design reasoning and memory workflows that preserve conversation context, summarize state, and improve output quality across multi-turn interactions. USE WHEN: decide what to remember versus discard, build session or long-term memory models, compress long conversations, or add reasoning and verification gates for better answers. DO NOT USE FOR: multi-agent orchestration (use agentic-ai-orchestration); RAG retrieval and prompt design (use ai-agent-rag-and-prompt-design); document ingestion pipelines (use azure-document-rag-pipeline).'
argument-hint: 'Describe the task, the user context to preserve, the expected output quality, and any constraints on memory or privacy.'
user-invocable: true
disable-model-invocation: false
---

# Conversation Memory and Reasoning Brain for GHCP

## When to Use
- Improve multi-turn assistant quality by remembering important facts, decisions, and user preferences.
- Build workflows that preserve context across long conversations, summaries, or handoffs.
- Improve reasoning quality through explicit planning, verification, and structured synthesis.
- Design GHCP-style experiences that stay grounded, coherent, and useful over time.

## Core Objective
Create a reusable reasoning-and-memory approach that helps an AI assistant remember what matters, avoid losing context, and produce better outputs through deliberate, evidence-aware thinking.

## Workflow

### 1. Identify what must be remembered
Start by extracting:
1. User goals, constraints, and preferences.
2. Facts that are repeatedly referenced across turns.
3. Decisions already made, open questions, and pending actions.
4. Risks, assumptions, and confidence level.
5. Any data that should not be retained because of privacy or policy limits.

Decision points:
- If the information affects future answers, keep it as durable memory or a structured summary.
- If it is only relevant for the current turn, keep it as transient context.
- If the user has not asked for persistence, avoid storing sensitive or unnecessary details.

### 2. Build a compact memory model
Use a simple memory structure:
- Core facts: stable user preferences, domain facts, constraints.
- Session state: current task, recent turns, unresolved questions.
- Working assumptions: hypotheses, risks, partial conclusions.
- Action queue: next steps, approvals, or follow-up tasks.

Good practice:
- Prefer a few high-value facts over a long, noisy memory blob.
- Update memory only when evidence or user intent changes.
- Distinguish between what is confirmed, inferred, and still uncertain.

### 3. Use reasoning techniques that improve output quality
Apply a lightweight reasoning loop:
1. Clarify the task and expected outcome.
2. Decompose complex work into smaller goals.
3. Identify missing information before answering.
4. Check assumptions against prior context and evidence.
5. Produce a concise answer with explicit reasoning steps only when useful.
6. Verify the final output against the user’s request and constraints.

Reasoning patterns to prefer:
- Goal-first planning.
- Structured decomposition of large tasks.
- Evidence-based synthesis instead of guesswork.
- Verification before finalizing high-impact answers.
- Summarization of long conversations into reusable context.

### 4. Maintain continuity across turns
For multi-turn conversation quality:
- Re-anchor the user’s current goal at the start of each response.
- Reuse relevant prior facts instead of re-asking everything.
- Summarize earlier decisions when context grows too large.
- Ask one clarifying question when ambiguity would otherwise cause a poor answer.

Decision points:
- If the user revisits an earlier topic, reconnect the relevant memory summary.
- If the conversation becomes long, compress context into a brief state summary.
- If the user changes direction, update the working goal and relevant assumptions.

### 5. Generate high-quality summaries for memory and handoff
When the assistant needs to preserve context:
- Summarize decisions, outstanding tasks, and key facts.
- Highlight constraints, risks, and next actions.
- Keep summaries short, structured, and easy to reuse.
- Avoid storing raw prompt dumps or irrelevant details.

A good summary should answer:
- What is the user trying to achieve?
- What has already been decided?
- What is still uncertain or pending?
- What should the assistant remember for the next turn?

### 6. Apply quality gates before final output
Before replying, verify:
1. The response addresses the user’s current goal.
2. The answer uses the right prior context and memory.
3. The reasoning is grounded in evidence, not guesswork.
4. The result is concise enough for the user’s needs.
5. The response remains safe, relevant, and respectful of privacy.

## Anti-Patterns to Avoid
- Persisting entire raw transcripts instead of a small, high-value set of facts and decisions.
- Storing sensitive or personal data without need or consent.
- Re-asking for information already established earlier in the conversation.
- Passing the full history every turn instead of compressing older context into summaries.
- Treating inferred assumptions as confirmed facts without flagging uncertainty.
- Producing long, unfocused reasoning for simple, low-stakes tasks.

## Decision Guide
- The user is asking for a short, focused task.
- The context only needs a few facts or preferences.
- There is no long-running workflow or handoff.

### Use structured memory and summaries when
- The conversation spans many turns.
- The user revisits prior decisions or constraints.
- The assistant is expected to continue a task across sessions or agents.

### Use explicit reasoning steps when
- The task is complex, multi-stage, or high-stakes.
- The user needs justification, trade-offs, or a plan.
- The assistant must make decisions based on incomplete or evolving information.

### Use lighter reasoning when
- The task is simple, routine, or tightly constrained.
- The answer is mainly formatting, retrieval, or direct execution.

## Quality Criteria
A strong GHCP-style memory-and-reasoning workflow should:
- Preserve the most valuable context without overload.
- Keep responses coherent across turns.
- Avoid repeating irrelevant details or losing key decisions.
- Use evidence-based reasoning and explicit verification.
- Respect privacy, consent, and scope of memory.
- Improve the usefulness and trustworthiness of outputs.

## Output Expectations
When invoked, this skill should help the user produce:
- A memory and context-retention plan for a conversational assistant.
- A reasoning framework for better multi-turn outputs.
- A summary strategy for long conversations or handoffs.
- A checklist for quality, grounding, and continuity.

## Example Prompts to Try
- Design a memory strategy for a GHCP assistant that remembers user preferences and open tasks across sessions.
- Improve this multi-turn workflow so it keeps context, summarizes progress, and produces higher-quality answers.
- Create a reasoning checklist for long conversations that avoids context loss and unsupported assumptions.
- Show how to preserve conversation state for a multi-agent assistant without overloading the prompt.

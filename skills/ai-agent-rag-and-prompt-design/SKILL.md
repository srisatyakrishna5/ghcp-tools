---
name: ai-agent-rag-and-prompt-design
description: 'Design production-grade AI agents: RAG architecture, prompt engineering, multi-turn conversation policy, tool use, evaluation, and safety. USE WHEN: design or improve a RAG system, write system or instruction prompts, choose between prompting, RAG, and agentic approaches, or plan agent evaluation and guardrails. DO NOT USE FOR: multi-agent orchestration with LangGraph or Microsoft Agent Framework (use agentic-ai-orchestration); document ingestion, OCR, and chunking pipelines (use azure-document-rag-pipeline); conversation memory and reasoning internals (use conversation-memory-and-reasoning).'
argument-hint: 'Describe the use case, data sources, target model, latency/cost goals, and any safety or governance constraints.'
user-invocable: true
disable-model-invocation: false
---

# Production-Grade AI Agent Design

## When to Use
- Build or improve retrieval augmented generation (RAG) systems.
- Design prompt engineering strategies for single-turn and multi-turn AI assistants.
- Create agentic AI workflows with planning, tool calling, reflection, retries, and fallback.
- Establish production readiness checks for accuracy, grounding, latency, cost, observability, and governance.

## Core Objective
Create a practical design blueprint for AI agents that are grounded, reliable, safe, and measurable in production.

## Workflow

### 1. Clarify the outcome and constraints
Start by identifying:
1. The user task and success criteria.
2. The data sources that must be grounded in the response.
3. The model, latency, and cost budget.
4. Required safety, privacy, compliance, and citation rules.
5. Whether the workflow is single-turn, multi-turn, or tool-using.

If the task depends on private or dynamic knowledge, assume RAG is needed. If the task is mostly general reasoning, start with direct prompting and only add retrieval if evidence quality or freshness becomes a problem.

### 2. Design the retrieval layer
For RAG, build the pipeline in this order:
1. Data profiling and quality audit.
2. Cleaning, normalization, and metadata enrichment.
3. Chunking strategy that preserves context and meaning.
4. Embedding choice and vector index configuration.
5. Hybrid retrieval (keyword + vector) when relevant.
6. Re-ranking and relevance filtering.
7. Citation mapping from retrieved passages to the answer.

Decision points:
- If documents are long or hierarchical, use section-aware chunking and metadata filters.
- If the corpus changes frequently, use incremental indexing and freshness policies.
- If retrieval quality is weak, add re-ranking, query rewriting, or domain-specific embeddings.
- If answer quality is sensitive to context length, use summarization or passage selection before generation.

### 3. Design the instruction and prompt contract
Create a prompt structure that separates:
- Role and persona.
- Task objective.
- Grounding rules.
- Output format.
- Constraints and refusal boundaries.
- Evidence requirements and citations.

Recommended prompt pattern:
1. System instruction: purpose, scope, and safe behavior.
2. Context block: retrieved passages, tool results, or prior summary.
3. User ask: current goal and any explicit constraints.
4. Output contract: bullet list, JSON schema, or step-by-step format.
5. Grounding rule: answer only from provided evidence when relevant.

Use few-shot examples only when they improve consistency and reduce ambiguity. Avoid excessive examples that increase prompt length or overfit the model.

### 4. Design multi-turn interaction behavior
For conversational assistants:
1. Maintain short-term memory for the active session.
2. Summarize prior turns when context grows too long.
3. Preserve user intent, unresolved questions, and decisions across turns.
4. Ask clarifying questions before acting when the request is ambiguous.
5. Separate factual retrieval from open-ended synthesis.

Decision points:
- If the user revisits earlier topics, use memory or session summaries.
- If the conversation becomes long, compress context rather than sending everything raw.
- If the assistant is expected to act, define how it asks for permission before sensitive or costly actions.

### 5. Add agentic AI patterns only where needed
Use agentic patterns when the task requires planning, iteration, or tool use.

Good patterns:
- Plan → act → observe → revise.
- Tool use with retries and fallback.
- Self-check or reflection on answer quality.
- Workflow decomposition into smaller subgoals.
- Human-in-the-loop approval for risky or irreversible actions.

Avoid making the agent fully autonomous when a simpler deterministic workflow is enough.

### 6. Build quality, safety, and evaluation gates
Before deployment, verify:
1. Retrieval relevance and recall on representative queries.
2. Answer groundedness and hallucination resistance.
3. Prompt robustness across paraphrases and edge cases.
4. Latency, token cost, and failure rates.
5. Safety behavior, refusal quality, and policy compliance.
6. Citation quality and provenance traceability.

Use evaluation methods such as:
- Gold-answer comparisons.
- Groundedness tests against retrieved context.
- Adversarial prompt tests.
- Multi-turn regression tests.
- Human review of risky outputs.

### 7. Prepare for production operations
Make the design production-ready by defining:
- Logging and tracing for prompts, retrieved passages, tool calls, and responses.
- Observability for latency, failure, retrieval hit rate, and cost.
- Rollback and fallback behavior when retrieval fails or the model degrades.
- Access controls, redaction, and data handling rules.
- Continuous monitoring and performance review loops.

## Anti-Patterns to Avoid
- Reaching for RAG or agents when direct prompting would be simpler and more reliable.
- Generating answers without grounding or citations when the task depends on retrieved evidence.
- Stuffing raw, un-ranked chunks into the prompt instead of re-ranking and filtering for relevance.
- Overusing few-shot examples, inflating prompt length and overfitting behavior.
- Making the agent fully autonomous when a deterministic workflow with approval gates is safer.
- Shipping without groundedness, adversarial, and multi-turn regression evaluation.

## Decision Guide
- The answer must be grounded in current or private documents.
- Freshness matters more than general world knowledge.
- The answer depends on large or domain-specific corpora.

### Use prompt engineering when
- The model needs a clear response format, tone, or policy.
- The task is mostly reasoning, summarization, or transformation.
- The output quality depends on explicit constraints or examples.

### Use multi-turn design when
- The user will refine the task over several exchanges.
- Memory, state, or follow-up intent is required.
- Context accumulation can become noisy or expensive.

### Use agentic patterns when
- The task requires multiple steps, tools, or verification loops.
- The assistant must choose among actions rather than produce one answer.
- Human oversight or fallback planning is necessary.

## Quality Criteria
A strong solution should meet all of the following:
- Accurate and grounded responses.
- Clear evidence or citations when retrieval is used.
- Robust behavior in multi-turn conversations.
- Safe and predictable tool use.
- Acceptable latency and cost under real operating conditions.
- Traceable diagnostics and improvement loops.

## Output Expectations
When invoked, this skill should help the user produce one of the following:
- A RAG architecture recommendation.
- A prompt and instruction design plan.
- A multi-turn conversation policy.
- An agentic workflow design.
- A production readiness checklist for an AI assistant.

## Example Prompts to Try
- Design a production-grade RAG pipeline for enterprise policy documents.
- Create a prompt contract for a multi-turn customer support agent.
- Add tool-use, reflection, and fallback logic to an AI workflow.
- Evaluate whether a task should use direct prompting, RAG, or agentic orchestration.

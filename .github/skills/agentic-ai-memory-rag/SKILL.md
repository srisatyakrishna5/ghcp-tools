---
name: agentic-ai-memory-rag
description: "Advanced reference covering memory systems, production RAG pipelines, chunking strategies, and resilience patterns for agentic systems."
---

# Agentic AI Memory and RAG

> Reference skill for memory and retrieval architecture. Load when you need long-term memory, RAG pipeline design, chunking strategy, or resilience patterns.

## Part 7: Memory Systems

### Short-Term Memory (Conversation Buffer)

```python
class ConversationMemory:
    """Sliding window conversation memory with summarization."""

    def __init__(self, max_messages: int = 50, max_tokens: int = 8000) -> None:
        self._messages: list[AgentMessage] = []
        self._max_messages = max_messages
        self._max_tokens = max_tokens
        self._summary: str | None = None

    def add(self, message: AgentMessage) -> None:
        self._messages.append(message)
        self._trim()

    def get_context(self) -> list[AgentMessage]:
        """Get context with summary prefix if messages were trimmed."""
        messages = list(self._messages)
        if self._summary:
            messages.insert(1, AgentMessage(
                role="system",
                content=f"Summary of earlier conversation: {self._summary}",
            ))
        return messages

    def _trim(self) -> None:
        while len(self._messages) > self._max_messages:
            if self._messages[1].role != "system":
                self._messages.pop(1)
            else:
                self._messages.pop(2)
```

### Long-Term Memory (Vector Store)

```python
from uuid import uuid4


class LongTermMemory:
    """Semantic memory backed by vector store."""

    def __init__(self, vector_store: Any, embeddings: Any) -> None:
        self._store = vector_store
        self._embeddings = embeddings

    async def store(self, content: str, metadata: dict) -> None:
        embedding = await self._embeddings.embed(content)
        await self._store.upsert(
            id=metadata.get("id", str(uuid4())),
            vector=embedding,
            payload={"content": content, **metadata},
        )

    async def recall(self, query: str, top_k: int = 5) -> list[dict]:
        query_embedding = await self._embeddings.embed(query)
        results = await self._store.search(query_embedding, top_k=top_k)
        return [{"content": r.payload["content"], "score": r.score} for r in results]

    async def forget(self, memory_id: str) -> None:
        await self._store.delete(memory_id)
```

### Episodic Memory (Experience Replay)

Store and retrieve past successful/failed task executions as few-shot examples for future tasks.

```python
from datetime import datetime


@dataclass
class Episode:
    """A recorded agent experience for learning."""
    task: str
    actions: list[dict]
    outcome: str
    success: bool
    reflection: str
    timestamp: datetime


class EpisodicMemory:
    """Store and retrieve past experiences for few-shot learning."""

    def __init__(self, vector_store: Any, embeddings: Any) -> None:
        self._store = vector_store
        self._embeddings = embeddings

    async def record_episode(self, episode: Episode) -> None:
        embedding = await self._embeddings.embed(
            f"Task: {episode.task}\nOutcome: {episode.outcome}"
        )
        await self._store.upsert(
            id=str(uuid4()),
            vector=embedding,
            payload={
                "task": episode.task,
                "actions": episode.actions,
                "outcome": episode.outcome,
                "success": episode.success,
                "reflection": episode.reflection,
            },
        )

    async def recall_similar_experiences(self, task: str, top_k: int = 3) -> list[Episode]:
        embedding = await self._embeddings.embed(f"Task: {task}")
        results = await self._store.search(embedding, top_k=top_k)
        return [Episode(**r.payload) for r in results]
```

### Working Memory (Scratchpad)

Structured state that persists within a single task execution for complex multi-step reasoning.

```python
class WorkingMemory:
    """Structured scratchpad for multi-step task state."""

    def __init__(self) -> None:
        self._facts: dict[str, Any] = {}
        self._hypotheses: list[str] = []
        self._plan: list[str] = []
        self._completed_steps: list[str] = []

    def add_fact(self, key: str, value: Any) -> None:
        self._facts[key] = value

    def add_hypothesis(self, hypothesis: str) -> None:
        self._hypotheses.append(hypothesis)

    def update_plan(self, steps: list[str]) -> None:
        self._plan = steps

    def mark_step_complete(self, step: str) -> None:
        self._completed_steps.append(step)
        if step in self._plan:
            self._plan.remove(step)

    def to_context(self) -> str:
        """Serialize for injection into LLM context."""
        return (
            f"Known facts: {self._facts}\n"
            f"Hypotheses: {self._hypotheses}\n"
            f"Remaining plan: {self._plan}\n"
            f"Completed: {self._completed_steps}"
        )
```

---

## Part 8: RAG (Retrieval Augmented Generation) Pipeline

### Production RAG with Reranking and Citations

```python
class RAGPipeline:
    """Production RAG pipeline: retrieve → rerank → generate with citations."""

    def __init__(
        self,
        embeddings: Any,
        vector_store: Any,
        reranker: Any,
        llm_client: Any,
    ) -> None:
        self._embeddings = embeddings
        self._store = vector_store
        self._reranker = reranker
        self._llm = llm_client

    async def query(self, question: str, top_k: int = 10, final_k: int = 5) -> dict:
        """Full RAG pipeline."""
        # Step 1: Retrieve candidates
        query_embedding = await self._embeddings.embed(question)
        candidates = await self._store.search(query_embedding, top_k=top_k)

        # Step 2: Rerank for relevance
        reranked = await self._reranker.rerank(
            query=question,
            documents=[c.payload["content"] for c in candidates],
            top_k=final_k,
        )

        # Step 3: Build context
        context_chunks = []
        sources = []
        for item in reranked:
            context_chunks.append(item["content"])
            sources.append(item.get("metadata", {}).get("source", "unknown"))

        context = "\n\n---\n\n".join(context_chunks)

        # Step 4: Generate with citations
        response = await self._llm.chat(messages=[
            {"role": "system", "content": (
                "Answer using ONLY the provided context. "
                "Cite sources using [1], [2], etc. "
                "If the context doesn't contain the answer, say so."
            )},
            {"role": "user", "content": f"Context:\n{context}\n\nQuestion: {question}"},
        ])

        return {
            "answer": response.content,
            "sources": sources,
            "context_used": context_chunks,
        }
```

### Agentic RAG (Self-Correcting Retrieval)

The agent decides when to retrieve, evaluates relevance, and re-queries with better terms when initial results are insufficient.

```python
class AgenticRAG:
    """RAG where the agent controls retrieval strategy dynamically."""

    def __init__(self, llm_client: Any, vector_store: Any, embeddings: Any) -> None:
        self._llm = llm_client
        self._store = vector_store
        self._embeddings = embeddings

    async def query(self, question: str, max_retrievals: int = 3) -> str:
        """Agent-driven retrieval with self-correction."""
        all_context = []

        for attempt in range(max_retrievals):
            # Generate or refine search query
            search_query = await self._generate_search_query(
                question, all_context, attempt
            )

            # Retrieve
            embedding = await self._embeddings.embed(search_query)
            results = await self._store.search(embedding, top_k=5)

            # Evaluate relevance
            relevant = await self._filter_relevant(question, results)
            all_context.extend(relevant)

            # Check if we have enough to answer
            can_answer = await self._assess_sufficiency(question, all_context)
            if can_answer:
                break

        # Generate final answer
        return await self._generate_answer(question, all_context)

    async def _generate_search_query(
        self, question: str, existing_context: list, attempt: int
    ) -> str:
        """Generate optimized search query based on what we already know."""
        if attempt == 0:
            return question

        response = await self._llm.chat(messages=[
            {"role": "system", "content": (
                "Generate a better search query to find missing information. "
                "Consider what we already found and what gaps remain."
            )},
            {"role": "user", "content": (
                f"Question: {question}\n"
                f"Already retrieved: {[c['content'][:100] for c in existing_context]}\n"
                "What should we search for next?"
            )},
        ])
        return response.content

    async def _assess_sufficiency(self, question: str, context: list) -> bool:
        """Determine if retrieved context is sufficient to answer the question."""
        response = await self._llm.chat(messages=[
            {"role": "system", "content": "Can you fully answer this question with the provided context? Reply YES or NO."},
            {"role": "user", "content": (
                f"Question: {question}\n"
                f"Context: {[c['content'] for c in context]}"
            )},
        ])
        return "YES" in response.content.upper()
```

### Chunking Strategies

```python
class SemanticChunker:
    """Split documents into semantically coherent chunks."""

    def __init__(self, embeddings: Any, similarity_threshold: float = 0.75) -> None:
        self._embeddings = embeddings
        self._threshold = similarity_threshold

    async def chunk(self, text: str, max_chunk_size: int = 512) -> list[str]:
        """Split text at semantic boundaries."""
        sentences = self._split_sentences(text)
        chunks = []
        current_chunk = []

        for i, sentence in enumerate(sentences):
            current_chunk.append(sentence)
            current_text = " ".join(current_chunk)

            if len(current_text.split()) >= max_chunk_size:
                chunks.append(current_text)
                current_chunk = []
                continue

            if i < len(sentences) - 1:
                current_emb = await self._embeddings.embed(current_text)
                next_emb = await self._embeddings.embed(sentences[i + 1])
                similarity = self._cosine_similarity(current_emb, next_emb)

                if similarity < self._threshold:
                    chunks.append(current_text)
                    current_chunk = []

        if current_chunk:
            chunks.append(" ".join(current_chunk))

        return chunks

    def _split_sentences(self, text: str) -> list[str]:
        """Basic sentence splitting."""
        import re
        return [s.strip() for s in re.split(r'(?<=[.!?])\s+', text) if s.strip()]

    def _cosine_similarity(self, a: list[float], b: list[float]) -> float:
        """Compute cosine similarity between two vectors."""
        import math
        dot = sum(x * y for x, y in zip(a, b))
        norm_a = math.sqrt(sum(x * x for x in a))
        norm_b = math.sqrt(sum(x * x for x in b))
        return dot / (norm_a * norm_b) if norm_a and norm_b else 0.0
```

---

## Part 9: Error Recovery and Resilience

### Pattern 19: Self-Healing Agent

Agent detects errors, diagnoses root cause, and automatically retries with an adjusted approach.

```python
class ResilientAgent(Agent):
    """Agent with built-in error recovery and retry logic."""

    def __init__(self, *args, max_retries: int = 3, **kwargs) -> None:
        super().__init__(*args, **kwargs)
        self._max_retries = max_retries

    async def run(self, user_input: str) -> str:
        """Run with automatic error recovery."""
        errors = []

        for attempt in range(self._max_retries):
            try:
                result = await super().run(user_input)

                if await self._self_validate(user_input, result):
                    return result
                else:
                    errors.append(f"Attempt {attempt + 1}: Self-validation failed")

            except Exception as e:
                errors.append(f"Attempt {attempt + 1}: {str(e)}")

                if attempt < self._max_retries - 1:
                    user_input = (
                        f"{user_input}\n\n"
                        f"[Previous attempt failed: {str(e)}. "
                        f"Try a different approach.]"
                    )

        return f"Failed after {self._max_retries} attempts. Errors: {'; '.join(errors)}"

    async def _self_validate(self, question: str, answer: str) -> bool:
        """Agent validates its own output."""
        validation = await self._llm.chat(messages=[
            {"role": "system", "content": (
                "Validate if the answer fully addresses the question. "
                "Respond with 'VALID' or 'INVALID: reason'."
            )},
            {"role": "user", "content": f"Question: {question}\nAnswer: {answer}"},
        ])
        return validation.content.strip().startswith("VALID")
```

### Pattern 20: Graceful Degradation

When primary tools or models fail, automatically fall back to alternatives.

```python
class FallbackChain:
    """Try multiple approaches in order, use first successful result."""

    def __init__(self, strategies: list[Callable]) -> None:
        self._strategies = strategies

    async def execute(self, *args, **kwargs) -> Any:
        """Try each strategy in order."""
        errors = []
        for strategy in self._strategies:
            try:
                result = await strategy(*args, **kwargs)
                if result is not None:
                    return result
            except Exception as e:
                errors.append(f"{strategy.__name__}: {str(e)}")

        raise RuntimeError(f"All strategies failed: {errors}")


# Usage: Try GPT-4 → fallback to GPT-3.5 → fallback to cached response
fallback = FallbackChain([
    lambda q: call_gpt4(q),
    lambda q: call_gpt35(q),
    lambda q: lookup_cache(q),
])
```

---


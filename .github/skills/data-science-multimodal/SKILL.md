---
name: data-science-multimodal
description: "Reference guide for multi-modal RAG and data science patterns including chunking strategies, embedding pipelines, retrieval optimization, evaluation, and production ML patterns. Prefer data-science-multimodal-runtime for routine work."
---

# Data Science: Multi-Modal Agentic RAG Patterns

> Reference skill. Prefer `#file:skills/data-science-multimodal-runtime/SKILL.md` for routine work. Load this full reference only for advanced ingestion, hybrid retrieval, evaluation frameworks, or detailed code examples.

> Production patterns for building agentic AI systems that process and retrieve across text, images, audio, video, and structured data.

---

## Part 1: Multi-Modal Document Processing

### Modality Detection & Routing

```python
from enum import Enum
from dataclasses import dataclass, field
from pathlib import Path
from typing import Any


class Modality(Enum):
    TEXT = "text"
    IMAGE = "image"
    AUDIO = "audio"
    VIDEO = "video"
    PDF = "pdf"
    TABLE = "table"
    CODE = "code"


@dataclass
class ProcessedChunk:
    """A processed chunk ready for embedding."""
    content: str
    modality: Modality
    metadata: dict = field(default_factory=dict)
    embedding: list[float] | None = None
    source_doc_id: str = ""
    chunk_index: int = 0
    parent_chunk_id: str | None = None


class ModalRouter:
    """Routes documents to modality-specific processors."""

    MIME_MAP: dict[str, Modality] = {
        "application/pdf": Modality.PDF,
        "image/png": Modality.IMAGE,
        "image/jpeg": Modality.IMAGE,
        "image/webp": Modality.IMAGE,
        "audio/mpeg": Modality.AUDIO,
        "audio/wav": Modality.AUDIO,
        "video/mp4": Modality.VIDEO,
        "text/plain": Modality.TEXT,
        "text/markdown": Modality.TEXT,
        "text/csv": Modality.TABLE,
        "application/json": Modality.TEXT,
    }

    EXTENSION_MAP: dict[str, Modality] = {
        ".py": Modality.CODE,
        ".ts": Modality.CODE,
        ".js": Modality.CODE,
        ".java": Modality.CODE,
        ".cs": Modality.CODE,
        ".go": Modality.CODE,
        ".rs": Modality.CODE,
    }

    def detect_modality(self, file_path: Path, mime_type: str | None = None) -> Modality:
        """Detect modality from MIME type or file extension."""
        if mime_type and mime_type in self.MIME_MAP:
            return self.MIME_MAP[mime_type]

        suffix = file_path.suffix.lower()
        if suffix in self.EXTENSION_MAP:
            return self.EXTENSION_MAP[suffix]

        return Modality.TEXT  # Default fallback
```

### PDF Processing with Structure Preservation

```python
from abc import ABC, abstractmethod


class DocumentProcessor(ABC):
    """Base class for modality-specific document processors."""

    @abstractmethod
    async def process(self, source: Path | bytes, metadata: dict) -> list[ProcessedChunk]:
        """Process a document into chunks preserving structure."""


class PDFProcessor(DocumentProcessor):
    """Processes PDFs preserving tables, figures, and section hierarchy."""

    def __init__(
        self,
        vision_model: Any,
        table_extractor: Any,
        chunk_size: int = 1000,
        chunk_overlap: int = 200,
    ) -> None:
        self._vision_model = vision_model
        self._table_extractor = table_extractor
        self._chunk_size = chunk_size
        self._chunk_overlap = chunk_overlap

    async def process(self, source: Path | bytes, metadata: dict) -> list[ProcessedChunk]:
        """Extract text, tables, and figures from PDF."""
        chunks: list[ProcessedChunk] = []
        pages = await self._extract_pages(source)

        for page_num, page in enumerate(pages):
            # Extract text blocks with section hierarchy
            text_chunks = self._chunk_text_with_headers(
                page.text, page.headers, page_num
            )
            chunks.extend(text_chunks)

            # Extract tables as structured data
            for table in page.tables:
                table_chunk = ProcessedChunk(
                    content=self._table_to_markdown(table),
                    modality=Modality.TABLE,
                    metadata={
                        **metadata,
                        "page": page_num,
                        "type": "table",
                        "caption": table.caption or "",
                    },
                )
                chunks.append(table_chunk)

            # Process figures with vision model
            for figure in page.figures:
                description = await self._describe_figure(figure)
                fig_chunk = ProcessedChunk(
                    content=description,
                    modality=Modality.IMAGE,
                    metadata={
                        **metadata,
                        "page": page_num,
                        "type": "figure",
                        "caption": figure.caption or "",
                        "image_ref": figure.image_id,
                    },
                )
                chunks.append(fig_chunk)

        return chunks

    async def _describe_figure(self, figure: Any) -> str:
        """Use vision model to describe a figure."""
        response = await self._vision_model.describe(
            image=figure.image_bytes,
            prompt=(
                "Describe this figure in detail. Include all data points, "
                "labels, legends, axes, and relationships shown. "
                "If it's a chart, describe the trends."
            ),
        )
        return f"[Figure: {figure.caption or 'Untitled'}]\n{response}"

    def _chunk_text_with_headers(
        self, text: str, headers: list[dict], page_num: int
    ) -> list[ProcessedChunk]:
        """Chunk text preserving section hierarchy as metadata."""
        # Implementation: semantic chunking with header context
        ...

    def _table_to_markdown(self, table: Any) -> str:
        """Convert extracted table to Markdown format."""
        ...

    async def _extract_pages(self, source: Path | bytes) -> list[Any]:
        """Extract pages from PDF using Document Intelligence or similar."""
        ...
```

### Image Processing Pipeline

```python
class ImageProcessor(DocumentProcessor):
    """Processes images using vision-language models."""

    def __init__(self, vision_model: Any, clip_model: Any) -> None:
        self._vision = vision_model
        self._clip = clip_model

    async def process(self, source: Path | bytes, metadata: dict) -> list[ProcessedChunk]:
        """Generate text description + CLIP embedding for image."""
        # Generate detailed text description
        description = await self._vision.describe(
            image=source,
            prompt=(
                "Describe this image comprehensively. Include: "
                "1) Main subject/content, 2) Text visible in the image (OCR), "
                "3) Spatial layout, 4) Colors and style, "
                "5) Any diagrams, charts, or technical content."
            ),
        )

        return [
            ProcessedChunk(
                content=description,
                modality=Modality.IMAGE,
                metadata={
                    **metadata,
                    "has_text": self._contains_text(description),
                    "image_type": self._classify_image_type(description),
                },
            )
        ]

    def _contains_text(self, description: str) -> bool:
        """Heuristic: does the image contain meaningful text?"""
        text_indicators = ["text", "label", "title", "caption", "heading", "written"]
        return any(ind in description.lower() for ind in text_indicators)

    def _classify_image_type(self, description: str) -> str:
        """Classify image as photo/diagram/chart/screenshot/etc."""
        ...
```

---

## Part 2: Chunking Strategies

### Strategy Selection Guide

| Data Type | Recommended Strategy | Chunk Size | Overlap |
|-----------|---------------------|------------|---------|
| Prose/articles | Semantic chunking | 500-1000 tokens | 10-20% |
| Technical docs | Header-based + recursive | 800-1200 tokens | 15% |
| Code | AST-based (function/class) | Natural boundaries | Include imports |
| Tables | Row-groups or full table | Per logical group | 0 |
| Conversations | Turn-based | Per exchange | 1-2 turns |
| Legal/contracts | Clause-based | Per clause | Section header |

### Semantic Chunking

```python
import numpy as np
from typing import Callable


class SemanticChunker:
    """Chunks text by detecting semantic boundaries using embeddings."""

    def __init__(
        self,
        embed_fn: Callable[[str], list[float]],
        similarity_threshold: float = 0.75,
        min_chunk_size: int = 100,
        max_chunk_size: int = 1500,
    ) -> None:
        self._embed = embed_fn
        self._threshold = similarity_threshold
        self._min_size = min_chunk_size
        self._max_size = max_chunk_size

    async def chunk(self, text: str) -> list[str]:
        """Split text at semantic boundary points."""
        sentences = self._split_sentences(text)
        if len(sentences) <= 1:
            return [text]

        # Embed each sentence
        embeddings = [await self._embed(s) for s in sentences]

        # Find breakpoints where consecutive similarity drops
        breakpoints: list[int] = []
        for i in range(1, len(embeddings)):
            similarity = self._cosine_similarity(embeddings[i - 1], embeddings[i])
            if similarity < self._threshold:
                breakpoints.append(i)

        # Build chunks from breakpoints
        chunks: list[str] = []
        start = 0
        for bp in breakpoints:
            chunk_text = " ".join(sentences[start:bp])
            if len(chunk_text) >= self._min_size:
                chunks.append(chunk_text)
                start = bp

        # Add remaining
        remaining = " ".join(sentences[start:])
        if remaining:
            chunks.append(remaining)

        # Enforce max size by splitting oversized chunks
        return self._enforce_max_size(chunks)

    def _cosine_similarity(self, a: list[float], b: list[float]) -> float:
        a_arr, b_arr = np.array(a), np.array(b)
        return float(np.dot(a_arr, b_arr) / (np.linalg.norm(a_arr) * np.linalg.norm(b_arr)))

    def _split_sentences(self, text: str) -> list[str]:
        """Split text into sentences (simplified)."""
        import re
        return [s.strip() for s in re.split(r'(?<=[.!?])\s+', text) if s.strip()]

    def _enforce_max_size(self, chunks: list[str]) -> list[str]:
        """Split chunks exceeding max size."""
        result: list[str] = []
        for chunk in chunks:
            if len(chunk) <= self._max_size:
                result.append(chunk)
            else:
                # Recursive split at midpoint sentence boundary
                mid = len(chunk) // 2
                split_point = chunk.find(". ", mid)
                if split_point == -1:
                    split_point = mid
                result.append(chunk[:split_point + 1])
                result.append(chunk[split_point + 1:].strip())
        return result


class ParentChildChunker:
    """Creates hierarchical chunks — large parents for context, small children for precision."""

    def __init__(
        self,
        parent_chunk_size: int = 2000,
        child_chunk_size: int = 400,
        child_overlap: int = 50,
    ) -> None:
        self._parent_size = parent_chunk_size
        self._child_size = child_chunk_size
        self._child_overlap = child_overlap

    def chunk(self, text: str, doc_id: str) -> list[ProcessedChunk]:
        """Create parent chunks with child sub-chunks for retrieval."""
        parents = self._split_into_parents(text)
        all_chunks: list[ProcessedChunk] = []

        for p_idx, parent_text in enumerate(parents):
            parent_id = f"{doc_id}_parent_{p_idx}"

            # Parent chunk (stored for context expansion)
            parent_chunk = ProcessedChunk(
                content=parent_text,
                modality=Modality.TEXT,
                metadata={"chunk_type": "parent", "doc_id": doc_id},
                source_doc_id=doc_id,
                chunk_index=p_idx,
            )
            all_chunks.append(parent_chunk)

            # Child chunks (used for retrieval)
            children = self._split_into_children(parent_text)
            for c_idx, child_text in enumerate(children):
                child_chunk = ProcessedChunk(
                    content=child_text,
                    modality=Modality.TEXT,
                    metadata={
                        "chunk_type": "child",
                        "doc_id": doc_id,
                        "parent_index": p_idx,
                    },
                    source_doc_id=doc_id,
                    chunk_index=c_idx,
                    parent_chunk_id=parent_id,
                )
                all_chunks.append(child_chunk)

        return all_chunks

    def _split_into_parents(self, text: str) -> list[str]:
        """Split text into large parent chunks."""
        ...

    def _split_into_children(self, parent_text: str) -> list[str]:
        """Split parent into smaller retrieval-optimized children."""
        ...
```

---

## Part 3: Agentic RAG Patterns

### Self-RAG (Self-Reflective Retrieval-Augmented Generation)

```python
from dataclasses import dataclass
from enum import Enum


class RetrievalDecision(Enum):
    RETRIEVE = "retrieve"
    NO_RETRIEVE = "no_retrieve"
    RE_RETRIEVE = "re_retrieve"


@dataclass
class RetrievalResult:
    chunks: list[ProcessedChunk]
    relevance_scores: list[float]
    query_used: str


class SelfRAGAgent:
    """Agent that decides when and how to retrieve, and self-corrects."""

    def __init__(
        self,
        llm: Any,
        retriever: Any,
        max_retries: int = 3,
    ) -> None:
        self._llm = llm
        self._retriever = retriever
        self._max_retries = max_retries

    async def answer(self, question: str) -> str:
        """Answer with self-reflective retrieval."""
        # Step 1: Decide if retrieval is needed
        decision = await self._should_retrieve(question)

        if decision == RetrievalDecision.NO_RETRIEVE:
            return await self._generate_without_context(question)

        # Step 2: Retrieve and assess relevance
        for attempt in range(self._max_retries):
            query = await self._formulate_query(question, attempt)
            results = await self._retriever.search(query)

            # Step 3: Assess retrieval quality
            relevant_chunks = await self._filter_relevant(question, results)

            if relevant_chunks:
                # Step 4: Generate with context
                answer = await self._generate_with_context(question, relevant_chunks)

                # Step 5: Self-assess — is the answer grounded?
                is_grounded = await self._check_grounding(answer, relevant_chunks)
                if is_grounded:
                    return answer

                # Not grounded — retry with different query
                continue

        # Fallback: answer with best available context + caveat
        return await self._generate_with_caveat(question, results)

    async def _should_retrieve(self, question: str) -> RetrievalDecision:
        """LLM decides if external knowledge is needed."""
        response = await self._llm.chat(messages=[
            {"role": "system", "content": (
                "Determine if this question requires external knowledge retrieval. "
                "Respond with exactly one of: RETRIEVE, NO_RETRIEVE\n"
                "RETRIEVE: question needs specific facts, data, or recent information\n"
                "NO_RETRIEVE: question can be answered from general knowledge"
            )},
            {"role": "user", "content": question},
        ])
        if "NO_RETRIEVE" in response.content:
            return RetrievalDecision.NO_RETRIEVE
        return RetrievalDecision.RETRIEVE

    async def _formulate_query(self, question: str, attempt: int) -> str:
        """Generate or reformulate search query."""
        if attempt == 0:
            return question

        response = await self._llm.chat(messages=[
            {"role": "system", "content": (
                "The previous search didn't return relevant results. "
                "Reformulate the query using different keywords, "
                "decompose into sub-questions, or broaden/narrow scope."
            )},
            {"role": "user", "content": f"Original question: {question}\nAttempt: {attempt + 1}"},
        ])
        return response.content

    async def _filter_relevant(
        self, question: str, results: RetrievalResult
    ) -> list[ProcessedChunk]:
        """LLM judges which retrieved chunks are actually relevant."""
        relevant: list[ProcessedChunk] = []
        for chunk in results.chunks:
            response = await self._llm.chat(messages=[
                {"role": "system", "content": (
                    "Is this passage relevant to answering the question? "
                    "Respond YES or NO only."
                )},
                {"role": "user", "content": (
                    f"Question: {question}\n\nPassage: {chunk.content}"
                )},
            ])
            if "YES" in response.content.upper():
                relevant.append(chunk)
        return relevant

    async def _check_grounding(self, answer: str, sources: list[ProcessedChunk]) -> bool:
        """Verify the answer is grounded in the retrieved sources."""
        context = "\n\n".join(c.content for c in sources)
        response = await self._llm.chat(messages=[
            {"role": "system", "content": (
                "Check if this answer is fully supported by the provided sources. "
                "Respond GROUNDED if all claims are supported, "
                "or NOT_GROUNDED if any claims lack source support."
            )},
            {"role": "user", "content": (
                f"Sources:\n{context}\n\nAnswer:\n{answer}"
            )},
        ])
        return "GROUNDED" in response.content.upper()

    async def _generate_without_context(self, question: str) -> str:
        ...

    async def _generate_with_context(
        self, question: str, chunks: list[ProcessedChunk]
    ) -> str:
        ...

    async def _generate_with_caveat(
        self, question: str, results: RetrievalResult
    ) -> str:
        ...
```

### Multi-Modal Retrieval Agent

```python
class MultiModalRetrievalAgent:
    """Agent that routes queries to appropriate modal-specific retrievers."""

    def __init__(
        self,
        llm: Any,
        text_retriever: Any,
        image_retriever: Any,
        table_retriever: Any,
        code_retriever: Any,
    ) -> None:
        self._llm = llm
        self._retrievers = {
            Modality.TEXT: text_retriever,
            Modality.IMAGE: image_retriever,
            Modality.TABLE: table_retriever,
            Modality.CODE: code_retriever,
        }

    async def retrieve(self, query: str) -> list[ProcessedChunk]:
        """Route query to relevant retrievers and fuse results."""
        # Step 1: Determine which modalities are relevant
        modalities = await self._classify_query_modalities(query)

        # Step 2: Retrieve from each relevant modality in parallel
        import asyncio
        tasks = [
            self._retrievers[mod].search(query)
            for mod in modalities
            if mod in self._retrievers
        ]
        results = await asyncio.gather(*tasks)

        # Step 3: Fuse and re-rank across modalities
        all_chunks = [chunk for result in results for chunk in result.chunks]
        ranked = await self._cross_modal_rerank(query, all_chunks)

        return ranked

    async def _classify_query_modalities(self, query: str) -> list[Modality]:
        """Determine which modalities the query targets."""
        response = await self._llm.chat(messages=[
            {"role": "system", "content": (
                "Classify which data modalities are needed to answer this query. "
                "Return one or more of: TEXT, IMAGE, TABLE, CODE\n"
                "Example: 'show me the architecture diagram' → IMAGE, TEXT\n"
                "Example: 'what's the function signature' → CODE\n"
                "Example: 'compare Q3 revenue' → TABLE, TEXT"
            )},
            {"role": "user", "content": query},
        ])
        # Parse response into modalities
        modality_map = {
            "TEXT": Modality.TEXT,
            "IMAGE": Modality.IMAGE,
            "TABLE": Modality.TABLE,
            "CODE": Modality.CODE,
        }
        return [
            modality_map[m.strip()]
            for m in response.content.upper().split(",")
            if m.strip() in modality_map
        ]

    async def _cross_modal_rerank(
        self, query: str, chunks: list[ProcessedChunk]
    ) -> list[ProcessedChunk]:
        """Re-rank chunks across modalities using LLM scoring."""
        ...
```

---

## Part 4: Hybrid Search & Re-ranking

### Hybrid Search Implementation

```python
from dataclasses import dataclass


@dataclass
class SearchResult:
    chunk: ProcessedChunk
    dense_score: float
    sparse_score: float
    combined_score: float


class HybridSearcher:
    """Combines dense (vector) and sparse (BM25/keyword) search with RRF fusion."""

    def __init__(
        self,
        dense_retriever: Any,
        sparse_retriever: Any,
        rrf_k: int = 60,
        dense_weight: float = 0.7,
    ) -> None:
        self._dense = dense_retriever
        self._sparse = sparse_retriever
        self._rrf_k = rrf_k
        self._dense_weight = dense_weight

    async def search(self, query: str, top_k: int = 10) -> list[SearchResult]:
        """Execute hybrid search with Reciprocal Rank Fusion."""
        import asyncio

        # Parallel retrieval
        dense_results, sparse_results = await asyncio.gather(
            self._dense.search(query, top_k=top_k * 2),
            self._sparse.search(query, top_k=top_k * 2),
        )

        # RRF fusion
        scores: dict[str, SearchResult] = {}

        for rank, result in enumerate(dense_results):
            doc_id = result.chunk.source_doc_id + str(result.chunk.chunk_index)
            rrf_score = self._dense_weight / (self._rrf_k + rank + 1)
            if doc_id not in scores:
                scores[doc_id] = SearchResult(
                    chunk=result.chunk,
                    dense_score=rrf_score,
                    sparse_score=0.0,
                    combined_score=rrf_score,
                )
            else:
                scores[doc_id].dense_score = rrf_score
                scores[doc_id].combined_score += rrf_score

        for rank, result in enumerate(sparse_results):
            doc_id = result.chunk.source_doc_id + str(result.chunk.chunk_index)
            sparse_weight = 1.0 - self._dense_weight
            rrf_score = sparse_weight / (self._rrf_k + rank + 1)
            if doc_id not in scores:
                scores[doc_id] = SearchResult(
                    chunk=result.chunk,
                    dense_score=0.0,
                    sparse_score=rrf_score,
                    combined_score=rrf_score,
                )
            else:
                scores[doc_id].sparse_score = rrf_score
                scores[doc_id].combined_score += rrf_score

        # Sort by combined score and return top_k
        ranked = sorted(scores.values(), key=lambda x: x.combined_score, reverse=True)
        return ranked[:top_k]
```

---

## Part 5: Evaluation Framework

### RAG Evaluation Metrics

```python
@dataclass
class RAGEvalResult:
    """Evaluation result for a single RAG query."""
    query: str
    answer: str
    contexts: list[str]
    ground_truth: str | None
    faithfulness: float  # Is answer grounded in contexts?
    relevancy: float  # Are retrieved contexts relevant?
    correctness: float  # Does answer match ground truth?
    completeness: float  # Does answer cover all aspects?


class RAGEvaluator:
    """Evaluates RAG pipeline quality using LLM-as-judge."""

    def __init__(self, judge_llm: Any) -> None:
        self._judge = judge_llm

    async def evaluate(
        self,
        query: str,
        answer: str,
        contexts: list[str],
        ground_truth: str | None = None,
    ) -> RAGEvalResult:
        """Run full evaluation suite on a RAG response."""
        import asyncio

        faithfulness, relevancy, completeness = await asyncio.gather(
            self._score_faithfulness(answer, contexts),
            self._score_relevancy(query, contexts),
            self._score_completeness(query, answer),
        )

        correctness = 0.0
        if ground_truth:
            correctness = await self._score_correctness(answer, ground_truth)

        return RAGEvalResult(
            query=query,
            answer=answer,
            contexts=contexts,
            ground_truth=ground_truth,
            faithfulness=faithfulness,
            relevancy=relevancy,
            correctness=correctness,
            completeness=completeness,
        )

    async def _score_faithfulness(self, answer: str, contexts: list[str]) -> float:
        """Score: are all claims in the answer supported by contexts?"""
        context_text = "\n---\n".join(contexts)
        response = await self._judge.chat(messages=[
            {"role": "system", "content": (
                "Score the faithfulness of the answer to the source contexts. "
                "Faithfulness = fraction of claims in the answer that are supported. "
                "Return a score between 0.0 and 1.0 only."
            )},
            {"role": "user", "content": (
                f"Contexts:\n{context_text}\n\nAnswer:\n{answer}"
            )},
        ])
        return self._parse_score(response.content)

    async def _score_relevancy(self, query: str, contexts: list[str]) -> float:
        """Score: are the retrieved contexts relevant to the query?"""
        context_text = "\n---\n".join(contexts)
        response = await self._judge.chat(messages=[
            {"role": "system", "content": (
                "Score how relevant the retrieved contexts are to the query. "
                "Return a score between 0.0 and 1.0 only."
            )},
            {"role": "user", "content": (
                f"Query:\n{query}\n\nContexts:\n{context_text}"
            )},
        ])
        return self._parse_score(response.content)

    async def _score_correctness(self, answer: str, ground_truth: str) -> float:
        """Score: does the answer match the ground truth?"""
        response = await self._judge.chat(messages=[
            {"role": "system", "content": (
                "Score the semantic correctness of the answer vs ground truth. "
                "Return a score between 0.0 and 1.0 only."
            )},
            {"role": "user", "content": (
                f"Ground truth:\n{ground_truth}\n\nAnswer:\n{answer}"
            )},
        ])
        return self._parse_score(response.content)

    async def _score_completeness(self, query: str, answer: str) -> float:
        """Score: does the answer fully address all aspects of the query?"""
        response = await self._judge.chat(messages=[
            {"role": "system", "content": (
                "Score how completely the answer addresses all aspects of the query. "
                "Return a score between 0.0 and 1.0 only."
            )},
            {"role": "user", "content": f"Query:\n{query}\n\nAnswer:\n{answer}"},
        ])
        return self._parse_score(response.content)

    def _parse_score(self, text: str) -> float:
        """Extract float score from LLM response."""
        import re
        match = re.search(r"(\d+\.?\d*)", text)
        if match:
            score = float(match.group(1))
            return min(max(score, 0.0), 1.0)
        return 0.0
```

---

## Part 6: Production Patterns

### Embedding Cache & Incremental Indexing

```python
import hashlib
from typing import Protocol


class EmbeddingCache(Protocol):
    """Cache interface for embeddings to avoid redundant API calls."""

    async def get(self, content_hash: str) -> list[float] | None: ...
    async def set(self, content_hash: str, embedding: list[float]) -> None: ...


class CachedEmbedder:
    """Embedding wrapper with content-hash-based caching."""

    def __init__(self, embed_fn: Any, cache: EmbeddingCache) -> None:
        self._embed = embed_fn
        self._cache = cache

    async def embed(self, text: str) -> list[float]:
        content_hash = hashlib.sha256(text.encode()).hexdigest()

        cached = await self._cache.get(content_hash)
        if cached is not None:
            return cached

        embedding = await self._embed(text)
        await self._cache.set(content_hash, embedding)
        return embedding

    async def embed_batch(self, texts: list[str]) -> list[list[float]]:
        """Batch embed with cache lookup — only embed cache misses."""
        results: list[list[float] | None] = [None] * len(texts)
        to_embed: list[tuple[int, str]] = []

        for i, text in enumerate(texts):
            content_hash = hashlib.sha256(text.encode()).hexdigest()
            cached = await self._cache.get(content_hash)
            if cached is not None:
                results[i] = cached
            else:
                to_embed.append((i, text))

        if to_embed:
            new_embeddings = await self._embed([t for _, t in to_embed])
            for (idx, text), emb in zip(to_embed, new_embeddings):
                results[idx] = emb
                content_hash = hashlib.sha256(text.encode()).hexdigest()
                await self._cache.set(content_hash, emb)

        return results  # type: ignore
```

### Structured Retrieval Logging

```python
import logging
import time
from contextlib import contextmanager
from dataclasses import dataclass


@dataclass
class RetrievalMetrics:
    query: str
    latency_ms: float
    num_results: int
    top_score: float
    modalities_queried: list[str]
    cache_hit: bool


logger = logging.getLogger("rag.retrieval")


@contextmanager
def track_retrieval(query: str, modalities: list[str]):
    """Context manager for structured retrieval logging."""
    start = time.perf_counter()
    metrics = {"query": query, "modalities": modalities}
    try:
        yield metrics
    finally:
        elapsed = (time.perf_counter() - start) * 1000
        metrics["latency_ms"] = elapsed
        logger.info(
            "retrieval_complete",
            extra=metrics,
        )
```

---

## Part 7: Embedding Model Selection Guide

| Model | Dimensions | Modalities | Best For | Cost |
|-------|-----------|------------|----------|------|
| text-embedding-3-large | 3072 (configurable) | Text | General-purpose, high quality | $$ |
| text-embedding-3-small | 1536 | Text | Cost-optimized, good quality | $ |
| Cohere embed-v3 | 1024 | Text + Images | Multi-lingual, search-optimized | $$ |
| BGE-M3 | 1024 | Text | Multi-lingual, self-hosted | Free (compute) |
| Nomic Embed Vision | 768 | Text + Images | Unified text-image space | $ |
| CLIP (ViT-L/14) | 768 | Images + Text | Image-text alignment | Free (compute) |
| ColPali | Multi-vector | Document pages | Full-page visual retrieval | $$ |

### Dimension Reduction Trade-offs

```
Full dimensions:    Best quality, highest storage/compute cost
Half dimensions:    ~95% quality, 50% storage savings (use Matryoshka embeddings)
Quarter dimensions: ~88% quality, 75% storage savings
```

---

## Part 8: Common Architecture Patterns

### Pattern: Multi-Hop RAG

For complex questions requiring information synthesis across multiple documents:

```
Query → Decompose into sub-questions → Retrieve per sub-question → Synthesize
```

### Pattern: Graph-Enhanced RAG

Combine vector retrieval with knowledge graph traversal:

```
Query → Vector search → Extract entities → Graph traversal → Expand context → Generate
```

### Pattern: Adaptive Retrieval

Let the agent decide retrieval depth based on query complexity:

```
Simple query  → Single retrieval pass
Complex query → Multi-hop with decomposition
Ambiguous     → Clarification + targeted retrieval
```

---
name: azure-document-rag-pipeline
description: 'Design a data-engineering pipeline that ingests files and extracts content with Azure AI Document Intelligence, Computer Vision, OCR, and LLM reasoning over tables, charts, flowcharts, and entity relationships, then chunks with context preservation for RAG over Azure AI Search or vector stores. USE WHEN: parse PDFs, scans, or images, extract tables, forms, or diagrams, choose chunk sizes and metadata, or build an ingestion-to-retrieval pipeline. DO NOT USE FOR: prompt or agent design over already-indexed data (use ai-agent-rag-and-prompt-design); multi-agent orchestration (use agentic-ai-orchestration).'
argument-hint: 'Describe the document types, Azure AI services to use, expected entities, chunking needs, retrieval target, and quality or latency constraints.'
user-invocable: true
disable-model-invocation: false
---

# Azure Document RAG Pipeline

## When to Use
- Build pipelines that ingest files and extract structured or unstructured content.
- Use Azure AI services such as Document Intelligence, Computer Vision, OCR, and LLM reasoning for complex documents.
- Prepare content for retrieval-augmented generation (RAG) with accurate chunking, context retention, and metadata.
- Work with Azure AI Search, vector databases, or hybrid retrieval backends.

## Core Objective
Create a practical pipeline that converts raw documents into high-quality, retrievable, and context-aware knowledge for AI applications.

## Workflow

### 1. Profile the input documents
Start by identifying:
1. File types and formats (PDF, TIFF, DOCX, PNG, scanned images, tables, charts, forms).
2. Document complexity: text, tables, diagrams, handwritten notes, graphs, flowcharts.
3. Expected output needs: extraction, summarization, classification, entity recognition, or question answering.
4. Quality goals: precision, recall, latency, cost, and compliance.
5. Whether the pipeline must support batch ingestion or near-real-time processing.

Decision points:
- If the document is mostly structured forms or invoices, prioritize Document Intelligence prebuilt models.
- If it contains diagrams, charts, or complex visual artifacts, combine vision OCR with LLM reasoning.
- If the content is long and dense, plan chunking and metadata extraction early.

### 2. Choose extraction and OCR strategy
Use the right Azure AI capability for each document type:
- Document Intelligence for invoices, forms, receipts, contracts, and layout-aware extraction.
- Computer Vision for image analysis, object detection, and OCR enhancement.
- LLM-assisted OCR for ambiguous text, graph labels, flowchart relationships, or complex table semantics.

Recommended approach:
1. Run layout-aware OCR or Document Intelligence first.
2. Use Computer Vision for image quality checks and visual feature extraction.
3. Use an LLM only for ambiguous, contextual, or semantic interpretation tasks.
4. Preserve confidence scores, page positions, and bounding boxes when possible.

Decision points:
- If tables or forms contain relationships across cells, use structured extraction first and validate with LLM reasoning.
- If the document includes dense diagrams, extract text labels and relationships, then summarize the graph or flow semantics.
- If text quality is poor, improve image preprocessing before OCR.

### 3. Build a document understanding pipeline
For each file, create a normalized record that includes:
- Raw extracted text.
- Structured fields and entities.
- Table data and row/column relationships.
- Visual cues, chart titles, legends, and flow labels.
- Page references and confidence markers.
- A summary of semantic meaning where appropriate.

Use this to prevent information loss from tables, charts, and multi-page content.

### 4. Design chunking for RAG quality
Chunking should balance retrieval accuracy and token efficiency.

Use these rules:
- Preserve section boundaries, headings, and table context.
- Keep chunk sizes small enough for precise retrieval, but large enough to maintain meaning.
- Use overlap between chunks to avoid losing context at boundaries.
- Add metadata such as document ID, page number, section title, table number, and confidence score.

Chunking strategies:
- Fixed-size chunks for general text.
- Section-aware chunks for long reports and manuals.
- Table-aware chunks for structured documents.
- Graph or diagram-aware chunks for flowcharts, dependency maps, or entity relationships.

Decision points:
- If retrieval quality is weak, reduce chunk size and add re-ranking.
- If page-level context matters, keep page boundaries and section headings in metadata.
- If tables are central to the answer, store them as structured blocks rather than plain text only.

### 5. Preserve context between chunks
To support accurate RAG:
- Keep a summary or context header for each chunk.
- Store parent-child relationships between sections and subchunks.
- Link chunks to source pages and table IDs.
- Use hierarchical retrieval when the corpus contains long documents.

Good practice:
- Use chunk summaries for first-pass retrieval.
- Retrieve multiple related chunks together when answering complex questions.
- Reconstruct context from nearby chunks, headings, and metadata before generation.

### 6. Choose the retrieval backend
Select the retrieval store based on the workload:
- Azure AI Search for hybrid keyword + vector retrieval, filters, faceted search, and enterprise integration.
- Vector stores for semantic similarity search and large-scale embedding-based retrieval.
- Hybrid retrieval when both lexical and semantic matching matter.

Recommended setup:
1. Embed extracted content and summaries.
2. Store vectors with rich metadata.
3. Use hybrid search or reranking for best accuracy.
4. Keep provenance links back to the original document and page.

### 7. Build evaluation and quality gates
Before deployment, verify:
1. Extraction accuracy on representative documents.
2. OCR quality for scanned or low-resolution files.
3. Table, chart, and relationship extraction reliability.
4. Chunk relevance, overlap quality, and retrieval hit rate.
5. Answer groundedness and hallucination resistance.
6. Cost and latency trade-offs for the full pipeline.

Use tests such as:
- Grounded answer comparisons.
- OCR quality checks against known references.
- Table and entity extraction validation.
- Retrieval relevance tests for chunk selection.

## Anti-Patterns to Avoid
- Flattening tables, forms, and diagrams into plain text and losing row, column, and relationship structure.
- Using an LLM for bulk OCR when Document Intelligence or Computer Vision is more accurate and cheaper.
- Fixed-size chunking that cuts across sections and tables, with no overlap or context headers.
- Indexing chunks without metadata (document ID, page, section, table ID, confidence) or provenance links.
- Vector-only retrieval when exact terms matter, instead of hybrid search with re-ranking.
- Skipping extraction-accuracy, OCR-quality, and retrieval-relevance evaluation before launch.

## Decision Guide
- The input is forms, invoices, contracts, or layout-heavy documents.
- Structured fields and tables are critical.

### Use Computer Vision when
- The input includes image-heavy pages or visual quality issues.
- You need image preprocessing, object detection, or visual context.

### Use LLM-assisted OCR when
- The text is ambiguous, noisy, complex, or semantically rich.
- You need to interpret diagrams, charts, or relationship structures.

### Use hybrid retrieval when
- The document corpus contains both exact terms and semantic concepts.
- You need high retrieval quality for enterprise search or RAG.

## Quality Criteria
A strong pipeline should:
- Extract text and structure accurately from diverse file types.
- Preserve table, chart, flow, and page-level context.
- Use chunking and metadata that support precise retrieval.
- Maintain provenance back to the source document.
- Balance cost, latency, and answer quality for production workloads.

## Output Expectations
When invoked, this skill should help the user produce:
- A document ingestion and extraction design.
- A chunking and context-preservation strategy for RAG.
- A retrieval architecture using Azure AI Search or a vector store.
- A quality checklist for extraction, OCR, and grounded answer generation.

## Example Prompts to Try
- Design an Azure document RAG pipeline for scanned contracts and invoices.
- Explain how to extract tables, charts, and flow relationships from complex PDFs for RAG.
- Choose chunk sizes and metadata for accurate retrieval over long technical documents.
- Compare Azure AI Search versus vector-only retrieval for this document corpus.

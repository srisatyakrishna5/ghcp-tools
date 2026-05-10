---
name: data-science-multimodal-runtime
description: "Runtime guidance for multi-modal RAG and embedding workflows. Use for ingestion, chunking, retrieval, and evaluation. Prefer this over the full multi-modal reference for routine tasks."
applyTo: "**/*.ipynb,**/*embedding*.py,**/*embedding*.ts,**/*retriev*.py,**/*retriev*.ts,**/*vector*.py,**/*vector*.ts,**/*chunk*.py,**/*chunk*.ts,**/*multimodal*.py,**/*multimodal*.ts"
---

# Data Science Multi-Modal Runtime

Use this skill for routine multi-modal retrieval work. Load the full `data-science-multimodal` reference only when this card is insufficient.

## Use For

* Document and modality routing
* Chunking and metadata preservation
* Embedding and vector retrieval flows
* Retrieval evaluation and production checks

## Core Rules

* Preserve source structure and metadata during ingestion
* Choose chunking based on document shape, not one global rule
* Start with a simple retrieval stack before adding agentic loops
* Cache embeddings and support incremental indexing
* Measure retrieval quality before scaling architecture complexity

## Minimal Checklist

* Source metadata survives ingestion
* Retrieval path is measurable
* Embedding choice matches modality
* Retrieval quality floor is defined before adding agentic loops or re-ranking (e.g., recall@k ≥ 0.80, MRR ≥ 0.70)
* Latency and cost targets are stated with numeric bounds (e.g., p95 retrieval latency ≤ Xs, cost-per-query ≤ $Y)
* Evaluation plan exists before major expansion

## Escalate to Full Reference When

* You need advanced PDF, image, or audio pipelines
* You need hybrid retrieval or re-ranking strategies
* You need detailed evaluation frameworks
* You need multi-hop, graph, or adaptive retrieval patterns
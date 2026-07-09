---
name: synthetic-dataset-generation
description: 'Generate, curate, and validate high-quality datasets for training, fine-tuning, and evaluation: synthetic data with LLMs, augmentation, labeling, deduplication, decontamination, and quality control. USE WHEN: create instruction or preference datasets, generate synthetic examples, augment scarce data, build labeling guidelines, curate and dedupe a corpus, or prevent eval contamination. DO NOT USE FOR: running the fine-tune itself (use llm-finetuning); building the eval harness/metrics (use ai-evaluation-and-benchmarking); document ingestion for RAG (use azure-document-rag-pipeline).'
argument-hint: 'Describe the target task, how the data will be used (train/tune/eval), volume and diversity needs, quality bar, and any privacy or licensing constraints.'
user-invocable: true
disable-model-invocation: false
---

# Synthetic Dataset Generation and Curation

## When to Use
- Create datasets for training, fine-tuning, or evaluation.
- Generate synthetic examples or augment scarce real data.
- Build labeling guidelines and curate/clean a corpus.
- Ensure dataset quality, diversity, and decontamination.

## Core Objective
Produce datasets that are high-quality, diverse, representative, and safe to use, so downstream training and evaluation produce trustworthy results.

## Workflow

### 1. Define the dataset specification
- State the task, schema, and exact field/format for each example.
- Define how the data will be used: SFT, preference pairs, or evaluation.
- Set target volume, diversity dimensions, and the quality bar.
- Capture privacy, licensing, and compliance constraints up front.

### 2. Choose data sources and generation method
- Real data: collected, anonymized, and licensed appropriately.
- Synthetic generation: use LLMs with varied prompts, personas, and seeds.
- Augmentation: paraphrase, perturb, translate, or template-expand existing data.
- Distillation: generate from a stronger model, respecting terms of use.

Decision point:
- If real data is scarce or sensitive, lean on synthetic generation plus careful validation.
- If diversity is low, vary prompts, topics, difficulty, and edge cases deliberately.

### 3. Engineer for diversity and coverage
- Vary topics, phrasings, difficulty, lengths, and edge cases.
- Cover negative, adversarial, and failure scenarios.
- Avoid mode collapse where the generator repeats similar examples.
- Balance class/label distribution to match the target use.

### 4. Label and structure consistently
- Write clear labeling guidelines with examples and edge-case rules.
- Use consistent templates matching downstream training/inference.
- For preference data, ensure chosen/rejected pairs reflect genuine quality gaps.
- Measure inter-annotator agreement when humans label.

### 5. Run quality control
- Deduplicate near-identical examples (exact and semantic).
- Filter low-quality, toxic, biased, or off-task samples.
- Validate schema, format, and label correctness automatically.
- Spot-check with human review; use an LLM critic as a first-pass filter.

### 6. Decontaminate and split
- Remove overlap between training data and evaluation/benchmark sets.
- Create clean train/validation/test splits with no leakage.
- Hold out an immutable evaluation set.

### 7. Document and version
- Record provenance, generation prompts, models, and filters used.
- Version datasets and track changes over time.
- Write a datasheet: intended use, composition, limitations, and risks.

## Anti-Patterns to Avoid
- Low-diversity synthetic data that collapses into repetitive patterns.
- Train/eval contamination that inflates downstream metrics.
- Skipping deduplication, letting near-duplicates bias training.
- Generating data without validating quality, format, or labels.
- Amplifying bias or unsafe content present in the generator.
- Ignoring privacy, PII, and licensing of source material.
- No provenance or versioning, making datasets irreproducible and unauditable.

## Decision Guide

### Use synthetic generation when
- Real data is scarce, sensitive, or expensive, and quality can be validated.

### Use augmentation when
- You have some real data and need more diversity or volume cheaply.

### Use human labeling when
- Labels are subjective, high-stakes, or require domain expertise.

### Prioritize decontamination when
- The data feeds models that will be measured on known benchmarks.

## Quality Criteria
A strong dataset should be:
- Representative, diverse, and balanced for its intended use.
- Clean: deduplicated, filtered, and schema-valid.
- Decontaminated against evaluation sets, with leak-free splits.
- Safe and compliant on privacy, bias, and licensing.
- Documented and versioned with clear provenance.

## Output Expectations
When invoked, this skill should help produce:
- A dataset specification and generation plan.
- Diversity, labeling, and quality-control strategies.
- A decontamination and splitting plan.
- A datasheet with provenance, limitations, and versioning.

## Example Prompts to Try
- Generate a diverse synthetic instruction dataset for this task with quality filters.
- Build preference pairs for DPO with clear chosen/rejected criteria.
- Create labeling guidelines and a QC pipeline for this dataset.
- Decontaminate this training set against our evaluation benchmark and split it.

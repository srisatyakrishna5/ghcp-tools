---
name: llm-finetuning
description: 'Plan and execute LLM fine-tuning and adaptation: deciding when to fine-tune vs. RAG/prompting, data preparation, SFT, LoRA/QLoRA, preference tuning (DPO/RLHF), hyperparameters, evaluation, and serving. USE WHEN: decide whether to fine-tune, prepare instruction or preference datasets, run SFT or LoRA/QLoRA, choose hyperparameters, evaluate a tuned model, or plan deployment of adapters. DO NOT USE FOR: retrieval over documents (use ai-agent-rag-and-prompt-design or azure-document-rag-pipeline); building eval harnesses in general (use ai-evaluation-and-benchmarking); creating the training data itself (use synthetic-dataset-generation).'
argument-hint: 'Describe the base model, the task, available data, hardware/budget, quality targets, and latency or deployment constraints.'
user-invocable: true
disable-model-invocation: false
---

# LLM Fine-Tuning and Adaptation

## When to Use
- Decide whether fine-tuning is the right tool versus prompting or RAG.
- Prepare instruction (SFT) or preference (DPO/RLHF) datasets.
- Run parameter-efficient fine-tuning such as LoRA or QLoRA, or full SFT.
- Choose hyperparameters, evaluate results, and plan serving.

## Core Objective
Adapt a base model to a task or style reliably and cost-effectively, with measurable quality gains and no regression on core capabilities.

## Workflow

### 1. Decide whether to fine-tune at all
Prefer alternatives first:
- Use prompting or few-shot when behavior can be steered with instructions.
- Use RAG when the gap is knowledge, freshness, or grounding.
- Fine-tune when you need consistent format, style, latency, or a skill that prompting cannot reliably produce, and you have quality data.

Decision point:
- If the problem is "the model lacks facts", choose RAG, not fine-tuning.
- If the problem is "the model won't follow our format/behavior reliably", fine-tuning may help.

### 2. Define the objective and success metrics
- State the target behavior and how it will be measured.
- Build a held-out evaluation set before training.
- Define guardrail metrics to detect regressions on general capability and safety.

### 3. Prepare the dataset
- Curate high-quality, representative, deduplicated examples.
- Use a consistent prompt/response template matching inference time.
- Split train/validation/test with no leakage.
- For preference tuning, build chosen/rejected pairs that reflect real quality differences.
- Balance the distribution; remove noisy, toxic, or low-quality samples.

### 4. Choose the tuning method
- Full SFT when you have ample data and compute and need deep adaptation.
- LoRA/QLoRA for parameter-efficient, low-cost tuning on limited hardware.
- DPO or RLHF for aligning to human preferences when SFT alone is insufficient.
- Instruction tuning to improve task-following on a defined task family.

### 5. Configure training carefully
- Start from sensible defaults: modest learning rate, few epochs, early stopping.
- Watch for overfitting; validate frequently and keep epochs low.
- Use appropriate sequence length, batch size, and gradient accumulation for the hardware.
- For QLoRA, set quantization and adapter rank to balance quality and memory.
- Track runs, seeds, configs, and checkpoints for reproducibility.

### 6. Evaluate before and after
- Compare against the base model on the held-out set.
- Check guardrail metrics for capability and safety regressions.
- Use task metrics plus human or LLM-as-judge review where needed.
- Test for catastrophic forgetting on general benchmarks.

### 7. Package and serve
- Serve LoRA adapters separately when you need multiple task variants.
- Quantize for inference where latency or cost requires it.
- Version models, adapters, datasets, and configs together.
- Plan rollback and A/B comparison against the current production model.

## Anti-Patterns to Avoid
- Fine-tuning to add knowledge that RAG would handle better and more cheaply.
- Training on small, noisy, or unrepresentative data and expecting robust gains.
- Train/test leakage that inflates apparent quality.
- Over-training: too many epochs causing overfitting and forgetting.
- Mismatched prompt templates between training and inference.
- Shipping with no held-out eval, no regression check, and no rollback path.
- Not versioning data, config, and checkpoints, making runs irreproducible.

## Decision Guide

### Use prompting/RAG instead when
- The need is knowledge, freshness, or one-off behavior changes.

### Use LoRA/QLoRA when
- Compute or budget is limited, or you need multiple swappable task adapters.

### Use full SFT when
- You have substantial high-quality data and need deep behavioral change.

### Use DPO/RLHF when
- You must align outputs to nuanced human preferences beyond SFT.

## Quality Criteria
A sound fine-tuning effort should:
- Be justified over prompting/RAG alternatives.
- Use clean, representative, leak-free data with consistent templates.
- Show measurable gains on a held-out set without capability or safety regressions.
- Be reproducible, versioned, and rollback-ready.
- Meet latency and cost targets in serving.

## Output Expectations
When invoked, this skill should help produce:
- A fine-tune vs. RAG/prompting recommendation.
- A dataset preparation and templating plan.
- A method and hyperparameter plan (SFT, LoRA/QLoRA, DPO).
- An evaluation, versioning, and serving strategy.

## Example Prompts to Try
- Decide whether to fine-tune or use RAG for this support-assistant task.
- Plan a QLoRA fine-tune for instruction following on limited GPU memory.
- Design an SFT dataset and template for structured JSON output.
- Set up DPO preference tuning with regression guardrails.

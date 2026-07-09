---
name: ai-evaluation-and-benchmarking
description: 'Design rigorous evaluation for LLM and AI systems: metrics, golden datasets, LLM-as-judge, RAG and agent evaluation, regression gates, and human review. USE WHEN: measure model or agent quality, build an eval harness, choose metrics, set up LLM-as-judge, evaluate RAG groundedness or agent task success, detect regressions, or run A/B and offline evals. DO NOT USE FOR: fine-tuning execution (use llm-finetuning); generating training/eval data (use synthetic-dataset-generation); software unit/integration testing (use software-testing-and-qa-strategy).'
argument-hint: 'Describe the system under evaluation (model, RAG, or agent), the task, quality dimensions that matter, and any existing datasets or baselines.'
user-invocable: true
disable-model-invocation: false
---

# AI Evaluation and Benchmarking

## When to Use
- Measure the quality of an LLM, RAG system, or agent.
- Build an evaluation harness with metrics and datasets.
- Set up LLM-as-judge or human review pipelines.
- Add regression gates and benchmarks to an AI development loop.

## Core Objective
Produce trustworthy, repeatable measurements of AI quality that drive decisions and catch regressions before they reach users.

## Workflow

### 1. Define what "good" means
- Identify the quality dimensions that matter: accuracy, groundedness, relevance, safety, format adherence, latency, cost.
- Translate each into a measurable metric with a target.
- Distinguish offline evaluation from online (A/B, production) evaluation.

### 2. Build evaluation datasets
- Create a representative golden set covering common and edge cases.
- Include adversarial and failure cases, not just easy ones.
- Keep an immutable held-out set to prevent overfitting to the eval.
- Version datasets and record provenance.

### 3. Choose metrics per system type
- Generation: exact/semantic match, task success, rubric scores.
- RAG: retrieval recall/precision, groundedness, citation accuracy, answer relevance.
- Agents: task completion, tool-call correctness, step efficiency, recovery from errors.
- Classification/extraction: precision, recall, F1, calibration.
- Always include safety and policy-compliance checks.

### 4. Use LLM-as-judge carefully
- Define clear rubrics and scoring scales.
- Calibrate the judge against human labels on a sample.
- Mitigate bias: position bias, verbosity bias, self-preference.
- Use pairwise comparison when absolute scoring is unreliable.
- Spot-check judge decisions with human review.

### 5. Add human evaluation where it matters
- Use human review for high-stakes, subjective, or safety-critical outputs.
- Provide clear guidelines and measure inter-rater agreement.
- Sample strategically rather than reviewing everything.

### 6. Integrate into the development loop
- Run evals automatically on every candidate change.
- Set regression gates: block releases that drop key metrics.
- Track metric trends over time and across versions.
- Combine offline gates with online A/B tests and production monitoring.

## Anti-Patterns to Avoid
- Evaluating on the training or tuning data (leakage) and overstating quality.
- A single accuracy number that hides groundedness, safety, and cost trade-offs.
- Trusting LLM-as-judge without calibrating against human labels.
- Tiny or unrepresentative eval sets that miss real failure modes.
- Cherry-picked demos instead of systematic measurement.
- No regression gate, so quality silently degrades across versions.
- Ignoring latency and cost as first-class quality dimensions.

## Decision Guide

### Use automated metrics when
- Ground truth exists and the metric correlates with real quality.

### Use LLM-as-judge when
- Outputs are open-ended and human-like judgment is needed at scale, with calibration.

### Use human evaluation when
- Stakes are high, judgment is subjective, or judges are unreliable.

### Use online A/B testing when
- Offline metrics cannot capture real user impact.

## Quality Criteria
A strong evaluation setup should:
- Measure the dimensions that actually matter, including safety, latency, and cost.
- Use representative, versioned, leak-free datasets.
- Be repeatable and integrated into CI with regression gates.
- Calibrate automated judges against human labels.
- Inform decisions and catch regressions before release.

## Output Expectations
When invoked, this skill should help produce:
- An evaluation plan with metrics and datasets.
- An LLM-as-judge rubric and calibration approach.
- A RAG or agent evaluation design.
- A regression-gate and benchmarking strategy.

## Example Prompts to Try
- Design an evaluation harness for this RAG system with groundedness and citation metrics.
- Build an LLM-as-judge rubric and calibrate it against human labels.
- Define agent task-success and tool-call metrics with a golden dataset.
- Add regression gates to block releases that drop answer quality.

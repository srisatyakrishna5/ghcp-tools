---
name: agentic-ai-evaluation
description: "Advanced reference covering observability, evaluation frameworks, structured outputs, function calling, and use-case guidance for agentic systems."
---

# Agentic AI Evaluation and Structured Outputs

> Reference skill for evaluation, observability, and structured outputs. Load when you need metrics, tracing, function calling, or use-case selection guidance.

## Part 10: Observability and Evaluation

### Structured Logging for Agents

```python
import time
import logging
from contextlib import asynccontextmanager


class AgentTracer:
    """Trace all agent operations for debugging and evaluation."""

    def __init__(self, logger: logging.Logger | None = None) -> None:
        self._logger = logger or logging.getLogger("agent")
        self._spans: list[dict] = []

    @asynccontextmanager
    async def trace_llm_call(self, model: str, messages: list):
        """Trace an LLM call with timing and token usage."""
        span = {
            "type": "llm_call",
            "model": model,
            "input_messages": len(messages),
            "start_time": time.perf_counter(),
        }
        try:
            yield span
        finally:
            span["duration_ms"] = (time.perf_counter() - span["start_time"]) * 1000
            self._spans.append(span)
            self._logger.info(
                "LLM call: model=%s duration=%.1fms tokens=%s",
                model, span["duration_ms"], span.get("token_usage"),
            )

    @asynccontextmanager
    async def trace_tool_call(self, tool_name: str, params: dict):
        """Trace a tool execution."""
        span = {
            "type": "tool_call",
            "tool": tool_name,
            "params": params,
            "start_time": time.perf_counter(),
        }
        try:
            yield span
        finally:
            span["duration_ms"] = (time.perf_counter() - span["start_time"]) * 1000
            self._spans.append(span)
            self._logger.info(
                "Tool call: %s duration=%.1fms success=%s",
                tool_name, span["duration_ms"], span.get("success"),
            )

    def get_trace(self) -> list[dict]:
        return self._spans

    def get_cost_summary(self) -> dict:
        """Summarize costs across all traced operations."""
        total_tokens = sum(
            s.get("token_usage", {}).get("total", 0)
            for s in self._spans if s["type"] == "llm_call"
        )
        total_duration = sum(s.get("duration_ms", 0) for s in self._spans)
        return {
            "total_tokens": total_tokens,
            "total_duration_ms": total_duration,
            "llm_calls": len([s for s in self._spans if s["type"] == "llm_call"]),
            "tool_calls": len([s for s in self._spans if s["type"] == "tool_call"]),
        }
```

### Evaluation Framework

```python
import time


@dataclass
class EvalCase:
    """Single evaluation test case."""
    input: str
    expected_output: str | None = None
    expected_tool_calls: list[str] | None = None
    rubric: str | None = None


@dataclass
class EvalResult:
    """Evaluation result for a single case."""
    case: EvalCase
    actual_output: str
    tool_calls_made: list[str]
    latency_ms: float
    token_usage: dict
    scores: dict


class AgentEvaluator:
    """Evaluate agent performance across test cases."""

    def __init__(self, agent: Agent, judge_llm: Any = None) -> None:
        self._agent = agent
        self._judge = judge_llm

    async def evaluate(self, cases: list[EvalCase]) -> dict:
        """Run evaluation cases and aggregate metrics."""
        results = []

        for case in cases:
            start = time.perf_counter()
            output = await self._agent.run(case.input)
            latency = (time.perf_counter() - start) * 1000

            scores = {}

            if case.expected_output:
                scores["exact_match"] = float(
                    output.strip() == case.expected_output.strip()
                )

            if case.expected_tool_calls:
                actual_tools = self._extract_tool_calls(output)
                scores["tool_accuracy"] = self._tool_overlap(
                    case.expected_tool_calls, actual_tools
                )

            if case.rubric and self._judge:
                scores["judge_score"] = await self._judge_score(
                    case.input, output, case.rubric
                )

            results.append(EvalResult(
                case=case,
                actual_output=output,
                tool_calls_made=[],
                latency_ms=latency,
                token_usage={},
                scores=scores,
            ))

        return self._aggregate(results)

    async def _judge_score(self, question: str, answer: str, rubric: str) -> float:
        """Use LLM to score answer quality on 0-1 scale."""
        response = await self._judge.chat(messages=[
            {"role": "system", "content": (
                "Score the answer on 0.0 to 1.0 based on the rubric. "
                "Respond with ONLY a number."
            )},
            {"role": "user", "content": (
                f"Question: {question}\nAnswer: {answer}\nRubric: {rubric}"
            )},
        ])
        try:
            return float(response.content.strip())
        except ValueError:
            return 0.0

    def _aggregate(self, results: list[EvalResult]) -> dict:
        """Aggregate evaluation results into summary metrics."""
        all_scores = {}
        for result in results:
            for metric, score in result.scores.items():
                all_scores.setdefault(metric, []).append(score)

        return {
            "num_cases": len(results),
            "avg_latency_ms": sum(r.latency_ms for r in results) / len(results),
            "metrics": {
                metric: {
                    "mean": sum(scores) / len(scores),
                    "min": min(scores),
                    "max": max(scores),
                }
                for metric, scores in all_scores.items()
            },
        }
```

---

## Part 11: Structured Output / Function Calling

Force LLMs to produce type-safe, validated outputs using Pydantic models.

```python
from pydantic import BaseModel


class StructuredAgent:
    """Agent that produces validated structured output."""

    def __init__(self, llm_client: Any, output_model: type[BaseModel]) -> None:
        self._llm = llm_client
        self._output_model = output_model

    async def run(self, prompt: str, task: str) -> BaseModel:
        """Generate structured output with validation."""
        response = await self._llm.chat(
            messages=[
                {"role": "system", "content": prompt},
                {"role": "user", "content": task},
            ],
            response_format=self._output_model,
        )
        return self._output_model.model_validate_json(response.content)


# Example: Research output structure
class ResearchFinding(BaseModel):
    claim: str
    evidence: list[str]
    confidence: float  # 0.0 to 1.0
    sources: list[str]


class ResearchReport(BaseModel):
    topic: str
    summary: str
    findings: list[ResearchFinding]
    limitations: list[str]
    next_steps: list[str]
```

---

## Part 12: Use Case Reference Guide

| Use Case | Recommended Pattern | Complexity | Notes |
|----------|-------------------|------------|-------|
| Chatbot with knowledge base | Single Agent + RAG | Low | Start here for most Q&A bots |
| Customer support | Router + Specialized Agents | Medium | Route by intent; use tools for actions |
| Code generation | Reflection + Evaluator-Optimizer | Medium | Use tests as ground truth for evaluation |
| Research tasks | Planning + Orchestrator-Workers | High | Dynamic decomposition, multiple sources |
| Content creation pipeline | Prompt Chaining + Gates | Low-Medium | Fixed steps with quality checks |
| Multi-file code changes | Orchestrator-Workers | High | Dynamic file discovery and editing |
| Data analysis | Planning + Tool Use | Medium | SQL tools, visualization, iterative queries |
| Translation | Evaluator-Optimizer | Medium | Quality improves significantly with iteration |
| Security review | Parallelization (Voting) | Medium | Multiple reviewers catch different issues |
| Complex decision-making | Debate + Judge | High | Multiple perspectives improve nuance |
| Enterprise workflows | Handoff + HITL | High | Domain specialists with human oversight |
| Multi-system integration | MCP + A2A | High | Standardized protocols for interop |

---

## Key Conventions

1. **Start simple** — Only add agentic complexity when simpler approaches demonstrably fail
2. **Explicit tool descriptions** — LLMs choose tools based on descriptions; invest in Agent-Computer Interface (ACI) design
3. **Structured outputs** — Use Pydantic models for inter-agent communication and validated responses
4. **Guardrails at every boundary** — Validate inputs, limit iterations, cap token usage, rate-limit tools
5. **Observability first** — Log every LLM call, tool execution, and decision point; trace full execution paths
6. **Deterministic when possible** — Use temperature=0 for factual tasks; seed parameters for reproducibility
7. **Fail gracefully** — Always have a fallback response; never crash silently; degrade rather than fail
8. **Human-in-the-loop** — For high-stakes actions, require explicit user confirmation before execution
9. **Cost awareness** — Track token usage per agent; use cheaper models for routing/classification; set budgets
10. **Evaluation-driven development** — Write eval cases before building agents; measure before and after changes
11. **Separation of concerns** — Keep planning, execution, evaluation, and guardrails in separate components
12. **Ground truth from environment** — Agents should validate progress using real tool results, not assumptions
13. **Limit autonomy by trust level** — More trusted environments allow more autonomous agents
14. **MCP for tools, A2A for agents** — Use standardized protocols instead of custom integrations

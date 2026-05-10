---
name: agentic-ai-guardrails
description: "Advanced reference covering input and output guardrails, tool guardrails, and safety patterns for agentic systems."
---

# Agentic AI Guardrails

> Reference skill for safety and control boundaries. Load when you need strong validation, policy enforcement, or tool-safety controls.

## Part 6: Guardrails and Safety Patterns

### Pattern 17: Input/Output Guardrails

Validate all inputs before processing and all outputs before returning to users. Run guardrails in parallel with main processing for efficiency.

```
     ┌──────────────┐
     │  User Input  │
     └──────┬───────┘
            │
     ┌──────┴───────┐
     │Input Guardrail│ ← Injection detection, PII, topic filtering
     └──────┬───────┘
            │
     ┌──────┴───────┐
     │   Agent LLM  │
     └──────┬───────┘
            │
     ┌──────┴────────┐
     │Output Guardrail│ ← Hallucination check, tone, compliance
     └──────┬────────┘
            │
     ┌──────┴───────┐
     │  User Output │
     └──────────────┘
```

```python
from dataclasses import dataclass


@dataclass
class GuardrailResult:
    """Result of a guardrail check."""
    passed: bool
    violation: str | None = None
    severity: str = "low"  # "low" | "medium" | "high" | "critical"


class GuardrailPipeline:
    """Composable input/output guardrails for agents."""

    def __init__(self) -> None:
        self._input_guards: list[Callable] = []
        self._output_guards: list[Callable] = []

    def add_input_guard(self, guard: Callable[[str], GuardrailResult]) -> None:
        self._input_guards.append(guard)

    def add_output_guard(self, guard: Callable[[str, str], GuardrailResult]) -> None:
        self._output_guards.append(guard)

    async def check_input(self, user_input: str) -> GuardrailResult:
        """Run all input guardrails."""
        for guard in self._input_guards:
            result = await guard(user_input)
            if not result.passed:
                return result
        return GuardrailResult(passed=True)

    async def check_output(self, user_input: str, output: str) -> GuardrailResult:
        """Run all output guardrails."""
        for guard in self._output_guards:
            result = await guard(user_input, output)
            if not result.passed:
                return result
        return GuardrailResult(passed=True)


# Common guardrail implementations
async def prompt_injection_guard(user_input: str) -> GuardrailResult:
    """Detect prompt injection attempts."""
    injection_patterns = [
        "ignore previous instructions",
        "ignore all prior",
        "disregard your instructions",
        "you are now",
        "new instruction:",
        "system prompt:",
    ]
    lower_input = user_input.lower()
    for pattern in injection_patterns:
        if pattern in lower_input:
            return GuardrailResult(
                passed=False,
                violation=f"Potential prompt injection: '{pattern}'",
                severity="critical",
            )
    return GuardrailResult(passed=True)


async def pii_detection_guard(user_input: str) -> GuardrailResult:
    """Detect personally identifiable information."""
    import re
    patterns = {
        "SSN": r"\b\d{3}-\d{2}-\d{4}\b",
        "Credit Card": r"\b\d{4}[\s-]?\d{4}[\s-]?\d{4}[\s-]?\d{4}\b",
        "Email": r"\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b",
    }
    for pii_type, pattern in patterns.items():
        if re.search(pattern, user_input):
            return GuardrailResult(
                passed=False,
                violation=f"PII detected: {pii_type}",
                severity="high",
            )
    return GuardrailResult(passed=True)


async def hallucination_guard(user_input: str, output: str) -> GuardrailResult:
    """Check output for unsupported claims (requires grounding context)."""
    # Use a separate LLM call to verify claims against source material
    # In production, compare against retrieved documents
    unsupported_phrases = ["studies show", "research proves", "according to"]
    if any(phrase in output.lower() for phrase in unsupported_phrases):
        return GuardrailResult(
            passed=False,
            violation="Output contains claims that may need source verification",
            severity="medium",
        )
    return GuardrailResult(passed=True)


class GuardedAgent:
    """Agent wrapped with input/output guardrails."""

    def __init__(self, agent: Agent, guardrails: GuardrailPipeline) -> None:
        self._agent = agent
        self._guardrails = guardrails

    async def run(self, user_input: str) -> str:
        """Run agent with guardrail checks."""
        # Input validation
        input_check = await self._guardrails.check_input(user_input)
        if not input_check.passed:
            return f"I cannot process this request. Reason: {input_check.violation}"

        # Agent execution
        output = await self._agent.run(user_input)

        # Output validation
        output_check = await self._guardrails.check_output(user_input, output)
        if not output_check.passed:
            # Retry with guardrail feedback or return safe fallback
            output = await self._agent.run(
                f"{user_input}\n\n[SYSTEM: Your previous response was blocked: "
                f"{output_check.violation}. Please regenerate without this issue.]"
            )

        return output
```

### Pattern 18: Tool Guardrails

Wrap tools with safety validators that prevent dangerous operations.

```python
class GuardedTool(Tool):
    """Wrapper that adds safety checks around tool execution."""

    def __init__(self, inner_tool: Tool, validators: list[Callable]) -> None:
        self._inner = inner_tool
        self._validators = validators

    @property
    def name(self) -> str:
        return self._inner.name

    @property
    def description(self) -> str:
        return self._inner.description

    @property
    def parameters_schema(self) -> dict:
        return self._inner.parameters_schema

    async def execute(self, **kwargs) -> ToolResult:
        for validator in self._validators:
            error = validator(kwargs)
            if error:
                return ToolResult(
                    tool_name=self.name,
                    output=f"Blocked: {error}",
                    success=False,
                )
        return await self._inner.execute(**kwargs)


# Validator examples
def no_destructive_sql(params: dict) -> str | None:
    """Block destructive SQL operations."""
    import re
    for value in params.values():
        if isinstance(value, str):
            if re.search(r"\b(DROP|DELETE|TRUNCATE|ALTER)\b", value, re.I):
                return "Destructive SQL operations are not permitted"
    return None


def rate_limit_guard(max_calls: int = 10):
    """Rate limit tool executions."""
    call_count = 0

    def check(params: dict) -> str | None:
        nonlocal call_count
        call_count += 1
        if call_count > max_calls:
            return f"Rate limit exceeded ({max_calls} calls)"
        return None

    return check


def cost_budget_guard(max_cost: float = 10.0):
    """Prevent operations exceeding cost budget."""
    total_cost = 0.0

    def check(params: dict) -> str | None:
        nonlocal total_cost
        estimated_cost = params.get("_estimated_cost", 0.01)
        if total_cost + estimated_cost > max_cost:
            return f"Cost budget exceeded (${total_cost:.2f} of ${max_cost:.2f} used)"
        total_cost += estimated_cost
        return None

    return check
```

---


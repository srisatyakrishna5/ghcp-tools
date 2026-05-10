---
name: agentic-ai-foundations
description: "Advanced reference covering agent design philosophy, augmented LLM architecture, reflection, tool use, planning, and foundational multi-agent collaboration patterns."
---

# Agentic AI Foundations

> Reference skill for foundational agent patterns. Load when you need deeper guidance on core agent structure, reflection, tool use, planning, or foundational collaboration patterns.

## Design Philosophy

Start with the simplest solution possible. Only increase complexity when simpler approaches fall short. Agentic systems trade latency and cost for better task performance — ensure this tradeoff makes sense for your use case.

```
┌─────────────────────────────────────────────────────────────────┐
│              AGENTIC COMPLEXITY SPECTRUM                          │
│                                                                   │
│  Simple ──────────────────────────────────────────────── Complex │
│                                                                   │
│  Single LLM   →  Prompt     →  Router  →  State    →  Autonomous │
│  Call + RAG      Chaining      Agent      Machine      Agent     │
│                                                                   │
│  Rule: Only move right when left is demonstrably insufficient    │
└─────────────────────────────────────────────────────────────────┘
```

---

## Part 1: Core Agent Architecture

### The Augmented LLM (Building Block)

Every agentic system builds on a single foundation: an LLM enhanced with retrieval, tools, and memory.

```
┌──────────────────────────────────────────────┐
│            AUGMENTED LLM                      │
│                                               │
│  ┌─────────┐  ┌─────────┐  ┌─────────┐     │
│  │Retrieval│  │  Tools  │  │ Memory  │     │
│  └────┬────┘  └────┬────┘  └────┬────┘     │
│       └─────────────┼───────────┘           │
│                     │                        │
│              ┌──────┴──────┐                 │
│              │   LLM Core  │                 │
│              └─────────────┘                 │
└──────────────────────────────────────────────┘
```

### Core Agent Loop (ReAct Pattern)

```
┌──────────────────────────────────────────────┐
│                  AGENT LOOP                    │
│                                               │
│  1. PERCEIVE  → Receive input/observation     │
│  2. THINK     → Reason about next action      │
│  3. ACT       → Execute tool or respond       │
│  4. OBSERVE   → Process tool result           │
│  5. REFLECT   → Update memory/state           │
│  └── Loop until task complete or max steps    │
└──────────────────────────────────────────────┘
```

### Agent Components

| Component | Responsibility | Implementation |
|-----------|---------------|----------------|
| **LLM Backbone** | Reasoning, planning, language understanding | OpenAI, Anthropic, Azure OpenAI APIs |
| **System Prompt** | Agent persona, constraints, output format | Templated instructions with dynamic context |
| **Tools** | External capabilities (APIs, code, search) | MCP servers, function calling, custom tools |
| **Memory** | Short-term (context), long-term (vector store) | Conversation buffer + semantic retrieval |
| **Planner** | Task decomposition and sequencing | Chain-of-thought, hierarchical planning |
| **Evaluator** | Self-assessment and error correction | LLM-as-judge, unit tests, assertions |
| **Guardrails** | Safety, cost limits, output validation | Input/output filters, rate limits |

---

## Part 2: The Four Foundational Patterns (Andrew Ng)

### Pattern 1: Reflection

The LLM examines its own work to find ways to improve it. Surprisingly effective for a relatively simple technique.

**When to use:** Code generation, writing tasks, problem-solving, any task where iterative improvement adds value.

**How it works:**
1. Generate initial output
2. Prompt the LLM to critique its own output
3. Use the critique to generate improved output
4. Repeat for N iterations or until quality threshold met

```python
class ReflectionAgent:
    """Agent that iteratively improves output through self-reflection."""

    def __init__(
        self,
        llm_client: Any,
        generator_prompt: str,
        critic_prompt: str,
        max_reflections: int = 3,
    ) -> None:
        self._llm = llm_client
        self._generator_prompt = generator_prompt
        self._critic_prompt = critic_prompt
        self._max_reflections = max_reflections

    async def run(self, task: str) -> str:
        """Generate, reflect, and improve iteratively."""
        # Step 1: Initial generation
        output = await self._generate(task)

        for i in range(self._max_reflections):
            # Step 2: Self-critique
            critique = await self._reflect(task, output)

            # Step 3: Check if output is satisfactory
            if "NO_ISSUES_FOUND" in critique:
                break

            # Step 4: Improve based on critique
            output = await self._improve(task, output, critique)

        return output

    async def _generate(self, task: str) -> str:
        response = await self._llm.chat(messages=[
            {"role": "system", "content": self._generator_prompt},
            {"role": "user", "content": task},
        ])
        return response.content

    async def _reflect(self, task: str, output: str) -> str:
        response = await self._llm.chat(messages=[
            {"role": "system", "content": self._critic_prompt},
            {"role": "user", "content": (
                f"Original task: {task}\n\n"
                f"Generated output:\n{output}\n\n"
                "Provide specific, actionable critique. "
                "If the output is excellent, respond with NO_ISSUES_FOUND."
            )},
        ])
        return response.content

    async def _improve(self, task: str, output: str, critique: str) -> str:
        response = await self._llm.chat(messages=[
            {"role": "system", "content": self._generator_prompt},
            {"role": "user", "content": (
                f"Original task: {task}\n\n"
                f"Your previous output:\n{output}\n\n"
                f"Feedback received:\n{critique}\n\n"
                "Improve your output based on this feedback."
            )},
        ])
        return response.content
```

**Use cases:**
- Code generation with self-review for correctness, style, and efficiency
- Writing with iterative refinement for tone, accuracy, and completeness
- Data analysis where the agent verifies its conclusions against the data

**Multi-agent reflection variant:** Use two separate agents — one generates, one critiques — for stronger feedback loops:

```python
class TwoAgentReflection:
    """Generator and critic as separate agents for stronger reflection."""

    def __init__(self, generator: Agent, critic: Agent, rounds: int = 3) -> None:
        self._generator = generator
        self._critic = critic
        self._rounds = rounds

    async def run(self, task: str) -> str:
        output = await self._generator.run(task)

        for _ in range(self._rounds):
            critique = await self._critic.run(
                f"Critique this output for task '{task}':\n\n{output}"
            )
            if "APPROVED" in critique:
                break
            output = await self._generator.run(
                f"Task: {task}\nPrevious output: {output}\nFeedback: {critique}\n"
                "Improve based on the feedback."
            )
        return output
```

---

### Pattern 2: Tool Use

The LLM is given tools (web search, code execution, APIs, databases) to gather information, take action, or process data.

**When to use:** Tasks requiring external data, computation, or side effects beyond the LLM's training data.

**How it works:**
1. Define tools with clear descriptions and JSON schemas
2. LLM decides which tool to call and with what parameters
3. Tool executes and returns results
4. LLM incorporates results into its reasoning

```python
from dataclasses import dataclass, field
from typing import Any, Callable
from abc import ABC, abstractmethod


@dataclass
class ToolResult:
    """Result from a tool execution."""
    tool_name: str
    output: str
    success: bool
    metadata: dict = field(default_factory=dict)


@dataclass
class AgentMessage:
    """Message in agent conversation."""
    role: str  # "system" | "user" | "assistant" | "tool"
    content: str
    tool_calls: list[dict] | None = None
    tool_call_id: str | None = None


class Tool(ABC):
    """Base class for agent tools."""

    @property
    @abstractmethod
    def name(self) -> str:
        """Unique tool identifier."""

    @property
    @abstractmethod
    def description(self) -> str:
        """Human-readable description for the LLM."""

    @property
    @abstractmethod
    def parameters_schema(self) -> dict:
        """JSON Schema for tool parameters."""

    @abstractmethod
    async def execute(self, **kwargs) -> ToolResult:
        """Execute the tool with given parameters."""


class Agent:
    """ReAct-style agent with tool calling."""

    def __init__(
        self,
        llm_client: Any,
        system_prompt: str,
        tools: list[Tool],
        max_iterations: int = 10,
    ) -> None:
        self._llm = llm_client
        self._system_prompt = system_prompt
        self._tools = {tool.name: tool for tool in tools}
        self._max_iterations = max_iterations
        self._messages: list[AgentMessage] = []

    async def run(self, user_input: str) -> str:
        """Execute agent loop until completion or max iterations."""
        self._messages = [
            AgentMessage(role="system", content=self._system_prompt),
            AgentMessage(role="user", content=user_input),
        ]

        for _ in range(self._max_iterations):
            response = await self._llm.chat(
                messages=self._messages,
                tools=self._get_tool_schemas(),
            )

            if not response.tool_calls:
                return response.content

            self._messages.append(AgentMessage(
                role="assistant",
                content=response.content or "",
                tool_calls=response.tool_calls,
            ))

            for tool_call in response.tool_calls:
                result = await self._execute_tool(tool_call)
                self._messages.append(AgentMessage(
                    role="tool",
                    content=result.output,
                    tool_call_id=tool_call["id"],
                ))

        return "Max iterations reached. Task incomplete."

    async def _execute_tool(self, tool_call: dict) -> ToolResult:
        """Safely execute a tool call."""
        tool_name = tool_call["function"]["name"]
        tool = self._tools.get(tool_name)

        if not tool:
            return ToolResult(
                tool_name=tool_name,
                output=f"Error: Unknown tool '{tool_name}'",
                success=False,
            )

        try:
            import json
            params = json.loads(tool_call["function"]["arguments"])
            return await tool.execute(**params)
        except Exception as e:
            return ToolResult(
                tool_name=tool_name,
                output=f"Error executing {tool_name}: {str(e)}",
                success=False,
            )

    def _get_tool_schemas(self) -> list[dict]:
        """Generate tool schemas for LLM."""
        return [
            {
                "type": "function",
                "function": {
                    "name": tool.name,
                    "description": tool.description,
                    "parameters": tool.parameters_schema,
                },
            }
            for tool in self._tools.values()
        ]
```

**Tool design principles (Agent-Computer Interface):**
- Give the model enough tokens to think before writing itself into a corner
- Keep tool output formats close to what the model has seen naturally in training
- Remove formatting overhead (no line counting, no JSON string escaping for code)
- Include example usage, edge cases, and clear boundaries in tool descriptions
- Test how the model uses tools — iterate on names and descriptions
- Use absolute paths, avoid ambiguous parameter formats

---

### Pattern 3: Planning

The LLM autonomously decides what sequence of steps to execute to accomplish a larger task.

**When to use:** Complex tasks that cannot be decomposed into fixed subtasks ahead of time; tasks requiring dynamic step selection.

**How it works:**
1. LLM analyzes the task and creates a step-by-step plan
2. Plan specifies tools, dependencies, and expected outputs for each step
3. Agent executes steps, potentially re-planning based on intermediate results
4. Dynamic replanning handles unexpected outcomes gracefully

```python
from pydantic import BaseModel


class PlanStep(BaseModel):
    """A single step in an agent's plan."""
    step_number: int
    description: str
    tool_to_use: str | None = None
    expected_output: str
    depends_on: list[int] = []


class AgentPlan(BaseModel):
    """Structured plan output from planning agent."""
    goal: str
    steps: list[PlanStep]
    estimated_complexity: str  # "low" | "medium" | "high"
    risks: list[str]


class PlanningAgent:
    """Agent that plans before executing, with dynamic replanning."""

    def __init__(
        self,
        llm_client: Any,
        tools: list[Tool],
        max_replans: int = 3,
    ) -> None:
        self._llm = llm_client
        self._tools = {tool.name: tool for tool in tools}
        self._max_replans = max_replans

    async def run(self, task: str) -> str:
        """Plan, execute, and replan if needed."""
        plan = await self._create_plan(task)
        results: dict[int, str] = {}

        for replan_attempt in range(self._max_replans + 1):
            for step in plan.steps:
                # Skip already-completed steps
                if step.step_number in results:
                    continue

                # Check dependencies
                deps_met = all(d in results for d in step.depends_on)
                if not deps_met:
                    continue

                # Build context from dependency results
                dep_context = "\n".join(
                    f"Step {d} result: {results[d]}" for d in step.depends_on
                )

                # Execute step
                result = await self._execute_step(step, dep_context)

                if result.success:
                    results[step.step_number] = result.output
                else:
                    # Replan on failure
                    plan = await self._replan(task, plan, step, result, results)
                    break

            # Check if all steps completed
            if len(results) == len(plan.steps):
                return await self._synthesize(task, plan, results)

        return "Planning agent could not complete the task after replanning."

    async def _create_plan(self, task: str) -> AgentPlan:
        """Generate a structured execution plan."""
        tool_descriptions = "\n".join(
            f"- {name}: {tool.description}" for name, tool in self._tools.items()
        )
        response = await self._llm.chat(
            messages=[
                {"role": "system", "content": (
                    "Create a step-by-step plan for the task. "
                    f"Available tools:\n{tool_descriptions}"
                )},
                {"role": "user", "content": task},
            ],
            response_format=AgentPlan,
        )
        return AgentPlan.model_validate_json(response.content)

    async def _replan(
        self, task: str, old_plan: AgentPlan,
        failed_step: PlanStep, error: ToolResult, completed: dict[int, str],
    ) -> AgentPlan:
        """Create a new plan after a step fails."""
        response = await self._llm.chat(
            messages=[
                {"role": "system", "content": "Revise the plan given the failure."},
                {"role": "user", "content": (
                    f"Task: {task}\n"
                    f"Original plan: {old_plan.model_dump_json()}\n"
                    f"Failed at step {failed_step.step_number}: {error.output}\n"
                    f"Completed steps: {completed}\n"
                    "Create a revised plan to complete the task."
                )},
            ],
            response_format=AgentPlan,
        )
        return AgentPlan.model_validate_json(response.content)
```

**Planning variants:**
- **Chain-of-Thought (CoT):** LLM reasons step-by-step within a single generation
- **ReAct (Reason + Act):** Interleave thinking with tool execution
- **Tree of Thoughts (ToT):** Explore multiple reasoning paths, backtrack on dead ends
- **Hierarchical planning:** Break high-level plans into sub-plans recursively

**Use cases:**
- Research tasks: plan which sources to check, what to extract, how to synthesize
- Code refactoring: analyze codebase, identify changes, determine safe ordering
- Multi-step workflows: onboarding processes, data pipelines, content creation

---

### Pattern 4: Multi-Agent Collaboration

Multiple AI agents work together, splitting tasks, discussing, and debating to produce better solutions than any single agent.

**When to use:** Complex tasks requiring multiple areas of expertise, tasks that benefit from diverse perspectives, or tasks too large for a single agent's context window.

See [Part 3: Workflow Orchestration Patterns](#part-3-workflow-orchestration-patterns-anthropic) for detailed implementations.

---


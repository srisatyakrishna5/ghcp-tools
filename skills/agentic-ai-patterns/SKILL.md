---
name: agentic-ai-patterns
description: "Comprehensive Agentic AI system design patterns including reflection, planning, tool use, multi-agent orchestration, memory systems, RAG pipelines, MCP integration, guardrails, human-in-the-loop, and evaluation frameworks. WHEN: AI agent design, tool calling, multi-agent systems, LangChain, LangGraph, AutoGen, CrewAI, Semantic Kernel, agent orchestration, RAG, vector search, LLM integration, agent memory, agent evaluation, MCP, Model Context Protocol, A2A, reflection pattern, planning pattern, agentic workflows."
applyTo: "**/*.py,**/*.ts"
---

# Agentic AI System Design Patterns

> Based on research from Anthropic, OpenAI, DeepLearning.AI (Andrew Ng), Microsoft Semantic Kernel, and LangChain.

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

## Part 3: Workflow Orchestration Patterns (Anthropic)

### Pattern 5: Prompt Chaining

Decompose a task into a sequence of fixed steps, where each LLM call processes the output of the previous one. Add programmatic gates between steps for quality control.

```
┌──────┐     ┌──────┐     ┌──────┐     ┌──────┐
│Step 1│────▶│ Gate │────▶│Step 2│────▶│Step 3│
└──────┘     └──┬───┘     └──────┘     └──────┘
                │
                ▼ (fail)
           ┌────────┐
           │Fallback│
           └────────┘
```

**When to use:** Tasks easily decomposed into fixed subtasks where you trade latency for accuracy.

```python
from typing import Callable


class PromptChain:
    """Sequential LLM calls with programmatic gates between steps."""

    def __init__(
        self,
        llm_client: Any,
        steps: list[dict],  # {"prompt": str, "gate": Callable | None}
    ) -> None:
        self._llm = llm_client
        self._steps = steps

    async def run(self, initial_input: str) -> dict:
        """Execute chain with gates."""
        current_input = initial_input
        step_outputs = []

        for i, step in enumerate(self._steps):
            # Execute LLM step
            response = await self._llm.chat(messages=[
                {"role": "system", "content": step["prompt"]},
                {"role": "user", "content": current_input},
            ])
            output = response.content

            # Apply gate if defined
            gate = step.get("gate")
            if gate and not gate(output):
                return {
                    "status": "gated",
                    "failed_step": i,
                    "output": output,
                    "completed_steps": step_outputs,
                }

            step_outputs.append(output)
            current_input = output

        return {"status": "complete", "output": current_input, "steps": step_outputs}


# Example: Generate marketing copy → Translate → Validate tone
chain = PromptChain(
    llm_client=client,
    steps=[
        {
            "prompt": "Write compelling marketing copy for the product described.",
            "gate": lambda x: len(x) > 50 and len(x) < 2000,
        },
        {
            "prompt": "Translate the following marketing copy to Spanish.",
            "gate": None,
        },
        {
            "prompt": "Validate this Spanish text for cultural appropriateness. Respond PASS or FAIL: reason.",
            "gate": lambda x: x.strip().startswith("PASS"),
        },
    ],
)
```

**Use cases:**
- Generate outline → Validate outline → Write document
- Extract data → Validate format → Transform → Load
- Draft email → Check tone → Add personalization

---

### Pattern 6: Routing

Classify an input and direct it to a specialized downstream handler. Enables separation of concerns and specialized prompts.

```
                    ┌────────────────┐
                    │   Router LLM   │
                    └───────┬────────┘
                   ╱        │        ╲
          ┌───────┐   ┌─────┴──┐   ┌───────┐
          │Agent A│   │Agent B │   │Agent C│
          │(easy) │   │(medium)│   │(hard) │
          └───────┘   └────────┘   └───────┘
```

**When to use:** Complex tasks with distinct categories better handled separately; when classification can be done accurately.

```python
class RouterAgent:
    """Routes tasks to specialized agents based on classification."""

    def __init__(
        self,
        llm_client: Any,
        agents: dict[str, Agent],
        routing_prompt: str,
    ) -> None:
        self._llm = llm_client
        self._agents = agents
        self._routing_prompt = routing_prompt

    async def run(self, user_input: str) -> str:
        """Classify input and route to appropriate agent."""
        classification = await self._llm.chat(
            messages=[
                {"role": "system", "content": self._routing_prompt},
                {"role": "user", "content": user_input},
            ],
            response_format={"type": "json_object"},
        )

        import json
        route = json.loads(classification.content)
        agent_name = route["agent"]
        confidence = route.get("confidence", 1.0)

        # Low confidence — escalate or ask for clarification
        if confidence < 0.7:
            return await self._handle_ambiguous(user_input, route)

        agent = self._agents.get(agent_name)
        if not agent:
            return f"No agent available for task type: {agent_name}"

        return await agent.run(user_input)

    async def _handle_ambiguous(self, user_input: str, route: dict) -> str:
        """Handle low-confidence routing decisions."""
        # Could ask user for clarification or try multiple agents
        return f"I need clarification to best help you. Did you mean: {route.get('alternatives', [])}"
```

**Use cases:**
- Customer service: general questions → refund requests → technical support
- Model routing: easy tasks → small/cheap model, hard tasks → capable model
- Content moderation: safe content → process, unsafe content → reject/escalate

---

### Pattern 7: Parallelization

Run multiple LLM calls simultaneously and aggregate results. Two key variants: **sectioning** (independent subtasks) and **voting** (same task, multiple perspectives).

```
Sectioning:                        Voting:
     ┌───────┐                     ┌───────┐
     │ Input │                     │ Input │
     └───┬───┘                     └───┬───┘
    ╱    │    ╲                   ╱    │    ╲
┌──┴┐ ┌──┴┐ ┌──┴┐           ┌──┴┐ ┌──┴┐ ┌──┴┐
│ A │ │ B │ │ C │           │LLM│ │LLM│ │LLM│
└──┬┘ └──┬┘ └──┬┘           └──┬┘ └──┬┘ └──┬┘
    ╲    │    ╱                   ╲    │    ╱
     ┌───┴───┐                     ┌───┴───┐
     │Combine│                     │ Vote  │
     └───────┘                     └───────┘
```

**When to use:** Independent subtasks that can run in parallel; or when multiple perspectives increase confidence.

```python
import asyncio


class ParallelSectioning:
    """Break task into independent subtasks and run in parallel."""

    def __init__(self, llm_client: Any, sections: list[dict]) -> None:
        self._llm = llm_client
        self._sections = sections  # [{"prompt": str, "aggregation_key": str}]

    async def run(self, input_text: str) -> dict:
        """Run all sections in parallel, combine results."""
        tasks = [
            self._run_section(section, input_text)
            for section in self._sections
        ]
        results = await asyncio.gather(*tasks)
        return {
            section["aggregation_key"]: result
            for section, result in zip(self._sections, results)
        }

    async def _run_section(self, section: dict, input_text: str) -> str:
        response = await self._llm.chat(messages=[
            {"role": "system", "content": section["prompt"]},
            {"role": "user", "content": input_text},
        ])
        return response.content


class VotingEnsemble:
    """Run same task multiple times with different prompts, aggregate by voting."""

    def __init__(
        self,
        llm_client: Any,
        prompts: list[str],
        aggregation: str = "majority",  # "majority" | "unanimous" | "any"
    ) -> None:
        self._llm = llm_client
        self._prompts = prompts
        self._aggregation = aggregation

    async def run(self, input_text: str) -> dict:
        """Run all prompts in parallel and aggregate."""
        tasks = [
            self._run_one(prompt, input_text) for prompt in self._prompts
        ]
        results = await asyncio.gather(*tasks)

        # Count votes (assumes binary PASS/FAIL or category output)
        votes = [r.strip().upper() for r in results]
        from collections import Counter
        counts = Counter(votes)
        winner = counts.most_common(1)[0]

        return {
            "decision": winner[0],
            "confidence": winner[1] / len(votes),
            "individual_votes": votes,
        }
```

**Use cases:**
- **Sectioning:** Guardrails (one LLM processes query, another screens for safety); Parallel evaluation aspects
- **Voting:** Code vulnerability review (multiple prompts, flag if any finds issue); Content moderation (multiple evaluators)

---

### Pattern 8: Orchestrator-Workers

A central LLM dynamically breaks down tasks, delegates them to worker LLMs, and synthesizes results. Unlike parallelization, the subtasks are not predefined — they are determined by the orchestrator based on input.

```
┌─────────────────────┐
│    ORCHESTRATOR      │
│  (plans dynamically) │
└──────────┬──────────┘
      ┌────┼────┐
      ▼    ▼    ▼
   ┌────┐┌────┐┌────┐
   │ W1 ││ W2 ││ W3 │  ← Workers (spawned as needed)
   └──┬─┘└──┬─┘└──┬─┘
      └────┼────┘
           ▼
   ┌─────────────┐
   │ SYNTHESIZER │
   └─────────────┘
```

**When to use:** Complex tasks where you cannot predict subtasks (e.g., code changes across multiple files, multi-source research).

```python
class OrchestratorWorkers:
    """Orchestrator dynamically delegates to workers and synthesizes."""

    def __init__(
        self,
        llm_client: Any,
        worker_factory: Callable[[str], Agent],
        max_workers: int = 10,
    ) -> None:
        self._llm = llm_client
        self._worker_factory = worker_factory
        self._max_workers = max_workers

    async def run(self, task: str) -> str:
        """Orchestrate: decompose → delegate → synthesize."""
        # Step 1: Orchestrator decomposes the task
        decomposition = await self._decompose(task)

        # Step 2: Spawn workers for each subtask (parallel)
        worker_tasks = []
        for subtask in decomposition["subtasks"][:self._max_workers]:
            worker = self._worker_factory(subtask["type"])
            worker_tasks.append(worker.run(subtask["description"]))

        results = await asyncio.gather(*worker_tasks, return_exceptions=True)

        # Step 3: Synthesize results
        successful = [
            {"subtask": st["description"], "result": r}
            for st, r in zip(decomposition["subtasks"], results)
            if not isinstance(r, Exception)
        ]
        return await self._synthesize(task, successful)

    async def _decompose(self, task: str) -> dict:
        """LLM decides how to break down the task."""
        response = await self._llm.chat(messages=[
            {"role": "system", "content": (
                "Decompose this task into independent subtasks. "
                "Output JSON: {subtasks: [{type: str, description: str}]}"
            )},
            {"role": "user", "content": task},
        ])
        import json
        return json.loads(response.content)

    async def _synthesize(self, original_task: str, results: list[dict]) -> str:
        """Combine worker outputs into final answer."""
        response = await self._llm.chat(messages=[
            {"role": "system", "content": "Synthesize these results into a coherent answer."},
            {"role": "user", "content": (
                f"Original task: {original_task}\n\n"
                f"Worker results:\n{json.dumps(results, indent=2)}"
            )},
        ])
        return response.content
```

**Use cases:**
- Coding agents that modify multiple files based on a single requirement
- Research agents that gather and analyze information from multiple sources
- Content creation across multiple sections/chapters

---

### Pattern 9: Evaluator-Optimizer

One LLM generates a response while another provides evaluation and feedback in a loop. The evaluator has clear criteria and can request specific improvements.

```
┌──────────────┐        ┌──────────────┐
│  GENERATOR   │───────▶│  EVALUATOR   │
└──────────────┘        └──────┬───────┘
       ▲                       │
       │    Feedback           │ Score/Critique
       └───────────────────────┘
       (loop until PASS or max iterations)
```

**When to use:** When you have clear evaluation criteria and iterative refinement provides measurable value. Good fit when: (1) human feedback demonstrably improves LLM output, and (2) an LLM can provide equivalent feedback.

```python
class EvaluatorOptimizer:
    """Generate-evaluate loop with clear pass criteria."""

    def __init__(
        self,
        llm_client: Any,
        generator_prompt: str,
        evaluator_prompt: str,
        pass_threshold: float = 0.8,
        max_iterations: int = 5,
    ) -> None:
        self._llm = llm_client
        self._generator_prompt = generator_prompt
        self._evaluator_prompt = evaluator_prompt
        self._pass_threshold = pass_threshold
        self._max_iterations = max_iterations

    async def run(self, task: str) -> dict:
        """Generate and refine until quality threshold met."""
        output = await self._generate(task)

        for iteration in range(self._max_iterations):
            evaluation = await self._evaluate(task, output)

            if evaluation["score"] >= self._pass_threshold:
                return {
                    "output": output,
                    "iterations": iteration + 1,
                    "final_score": evaluation["score"],
                }

            # Refine based on feedback
            output = await self._refine(task, output, evaluation["feedback"])

        return {
            "output": output,
            "iterations": self._max_iterations,
            "final_score": evaluation["score"],
            "note": "Max iterations reached without passing threshold",
        }

    async def _evaluate(self, task: str, output: str) -> dict:
        """Evaluate output quality with structured scoring."""
        response = await self._llm.chat(messages=[
            {"role": "system", "content": self._evaluator_prompt},
            {"role": "user", "content": (
                f"Task: {task}\n\nOutput to evaluate:\n{output}\n\n"
                "Provide: {score: 0.0-1.0, feedback: str, issues: [str]}"
            )},
        ])
        import json
        return json.loads(response.content)

    async def _refine(self, task: str, output: str, feedback: str) -> str:
        """Improve output based on evaluator feedback."""
        response = await self._llm.chat(messages=[
            {"role": "system", "content": self._generator_prompt},
            {"role": "user", "content": (
                f"Task: {task}\n\nYour previous output:\n{output}\n\n"
                f"Evaluator feedback:\n{feedback}\n\n"
                "Revise your output addressing all feedback points."
            )},
        ])
        return response.content
```

**Use cases:**
- Literary translation with nuance capture
- Complex search requiring multiple rounds of research
- Code generation with automated test validation
- Document writing requiring compliance with specific standards

---

### Pattern 10: Supervisor (Manager-Workers)

A supervisor agent manages multiple worker agents, dynamically delegating subtasks and aggregating results across multiple rounds.

```python
class SupervisorAgent:
    """Manages worker agents, delegates subtasks, aggregates results."""

    def __init__(
        self,
        llm_client: Any,
        workers: dict[str, Agent],
        system_prompt: str,
        max_rounds: int = 5,
    ) -> None:
        self._llm = llm_client
        self._workers = workers
        self._system_prompt = system_prompt
        self._max_rounds = max_rounds

    async def run(self, task: str) -> str:
        """Supervisor plans, delegates, and synthesizes."""
        messages = [
            {"role": "system", "content": self._system_prompt},
            {"role": "user", "content": task},
        ]
        results = []

        for _ in range(self._max_rounds):
            response = await self._llm.chat(
                messages=messages,
                tools=self._delegation_tools(),
            )

            if not response.tool_calls:
                return response.content

            for call in response.tool_calls:
                worker_name = call["function"]["name"].replace("delegate_to_", "")
                import json
                params = json.loads(call["function"]["arguments"])
                subtask = params["task"]

                worker = self._workers[worker_name]
                result = await worker.run(subtask)
                results.append({"worker": worker_name, "result": result})

                messages.append({
                    "role": "tool",
                    "content": result,
                    "tool_call_id": call["id"],
                })

        return f"Completed {len(results)} subtasks. Final synthesis needed."

    def _delegation_tools(self) -> list[dict]:
        """Generate delegation tools for each worker."""
        return [
            {
                "type": "function",
                "function": {
                    "name": f"delegate_to_{name}",
                    "description": f"Delegate a subtask to the {name} worker agent.",
                    "parameters": {
                        "type": "object",
                        "properties": {
                            "task": {"type": "string", "description": "The subtask to delegate."},
                        },
                        "required": ["task"],
                    },
                },
            }
            for name in self._workers
        ]
```

---

### Pattern 11: Debate (Adversarial Collaboration)

Two or more agents argue different positions. A judge synthesizes the strongest answer. Produces higher-quality outputs for nuanced or controversial topics.

```python
class DebateOrchestrator:
    """Two agents debate, a judge synthesizes the best answer."""

    def __init__(
        self,
        proposer: Agent,
        critic: Agent,
        judge: Agent,
        rounds: int = 3,
    ) -> None:
        self._proposer = proposer
        self._critic = critic
        self._judge = judge
        self._rounds = rounds

    async def run(self, question: str) -> str:
        """Run debate rounds, then judge decides."""
        debate_log = []

        proposal = await self._proposer.run(question)
        debate_log.append(f"PROPOSER: {proposal}")

        for _ in range(self._rounds):
            critique = await self._critic.run(
                f"Critique this answer:\n{proposal}\n\nOriginal question: {question}"
            )
            debate_log.append(f"CRITIC: {critique}")

            proposal = await self._proposer.run(
                f"Improve your answer based on critique:\n{critique}\n\nOriginal: {proposal}"
            )
            debate_log.append(f"PROPOSER (revised): {proposal}")

        final = await self._judge.run(
            f"Question: {question}\n\nDebate log:\n" + "\n\n".join(debate_log) +
            "\n\nProvide the best final answer synthesizing the strongest arguments."
        )
        return final
```

**Use cases:**
- Architecture decisions requiring trade-off analysis
- Legal argument construction
- Research paper review and improvement
- Risk assessment from multiple perspectives

---

### Pattern 12: Handoff (Agent Transfer)

An agent recognizes when a task falls outside its expertise and transfers control to a more appropriate agent, passing along accumulated context.

```python
class HandoffOrchestrator:
    """Agents can transfer control to other agents when needed."""

    def __init__(self, agents: dict[str, Agent], entry_agent: str) -> None:
        self._agents = agents
        self._entry_agent = entry_agent

    async def run(self, user_input: str) -> str:
        """Run with automatic handoff support."""
        current_agent_name = self._entry_agent
        context = user_input
        handoff_chain = []
        max_handoffs = 5

        for _ in range(max_handoffs):
            agent = self._agents[current_agent_name]
            result = await agent.run(context)

            # Check if agent wants to hand off
            handoff = self._detect_handoff(result)
            if not handoff:
                return result

            handoff_chain.append(current_agent_name)
            current_agent_name = handoff["target_agent"]
            context = (
                f"Handed off from {handoff_chain[-1]}.\n"
                f"Original request: {user_input}\n"
                f"Context from previous agent: {handoff['context']}"
            )

        return "Max handoffs reached."

    def _detect_handoff(self, result: str) -> dict | None:
        """Detect if the agent output contains a handoff signal."""
        if "[HANDOFF:" in result:
            # Parse structured handoff: [HANDOFF: agent_name | context]
            import re
            match = re.search(r'\[HANDOFF:\s*(\w+)\s*\|\s*(.+?)\]', result)
            if match:
                return {"target_agent": match.group(1), "context": match.group(2)}
        return None
```

---

## Part 4: Protocol Integration Patterns

### Pattern 13: MCP (Model Context Protocol) Integration

MCP provides a standardized way to connect AI agents to external tools, data sources, and services — like USB-C for AI applications.

```
┌──────────────┐     MCP Protocol     ┌──────────────┐
│   AI Agent   │◄────────────────────▶│  MCP Server  │
│  (MCP Client)│     (JSON-RPC)        │  (Tools/Data)│
└──────────────┘                       └──────────────┘
```

**Architecture:** Client-server model where:
- **MCP Host:** The AI application (IDE, chatbot, agent)
- **MCP Client:** Protocol handler within the host
- **MCP Server:** Exposes tools, resources, and prompts via standardized interface

```python
from dataclasses import dataclass
from typing import Any


@dataclass
class MCPTool:
    """Tool definition from an MCP server."""
    name: str
    description: str
    input_schema: dict


class MCPClient:
    """Client for communicating with MCP servers."""

    def __init__(self, server_url: str) -> None:
        self._server_url = server_url
        self._tools: list[MCPTool] = []

    async def initialize(self) -> None:
        """Handshake and discover available tools."""
        response = await self._send_request("initialize", {
            "protocolVersion": "2025-03-26",
            "capabilities": {"tools": {}},
        })
        # Discover tools
        tools_response = await self._send_request("tools/list", {})
        self._tools = [
            MCPTool(
                name=t["name"],
                description=t["description"],
                input_schema=t["inputSchema"],
            )
            for t in tools_response["tools"]
        ]

    async def call_tool(self, name: str, arguments: dict) -> Any:
        """Invoke a tool on the MCP server."""
        response = await self._send_request("tools/call", {
            "name": name,
            "arguments": arguments,
        })
        return response["content"]

    def get_tool_schemas(self) -> list[dict]:
        """Convert MCP tools to OpenAI function-calling format."""
        return [
            {
                "type": "function",
                "function": {
                    "name": tool.name,
                    "description": tool.description,
                    "parameters": tool.input_schema,
                },
            }
            for tool in self._tools
        ]


class MCPEnabledAgent(Agent):
    """Agent that discovers and uses tools via MCP servers."""

    def __init__(
        self,
        llm_client: Any,
        system_prompt: str,
        mcp_servers: list[str],
        max_iterations: int = 10,
    ) -> None:
        self._llm = llm_client
        self._system_prompt = system_prompt
        self._mcp_clients: list[MCPClient] = []
        self._max_iterations = max_iterations
        self._mcp_server_urls = mcp_servers

    async def initialize(self) -> None:
        """Connect to all MCP servers and discover tools."""
        for url in self._mcp_server_urls:
            client = MCPClient(url)
            await client.initialize()
            self._mcp_clients.append(client)

    def _get_all_tool_schemas(self) -> list[dict]:
        """Aggregate tool schemas from all MCP servers."""
        schemas = []
        for client in self._mcp_clients:
            schemas.extend(client.get_tool_schemas())
        return schemas
```

**Use cases:**
- Connect agents to databases, file systems, APIs without custom integration code
- Share tool implementations across multiple agents and applications
- Enable third-party tool ecosystems for your agent platform

---

### Pattern 14: A2A (Agent-to-Agent) Communication

A2A enables agents built on different frameworks to discover, communicate, and collaborate with each other across organizational boundaries.

**Key difference from MCP:** MCP connects agents to *tools*. A2A connects *agents to agents*. They are complementary.

```
┌─────────────────┐                    ┌─────────────────┐
│   Agent A       │     A2A Protocol   │   Agent B       │
│ (LangGraph)     │◄──────────────────▶│ (Semantic Kernel)│
│                 │   Task, Artifact,   │                 │
│ Uses MCP tools ─┤   Status messages  ├─ Uses MCP tools │
└─────────────────┘                    └─────────────────┘
```

```python
@dataclass
class AgentCard:
    """Agent's self-description for discovery (A2A concept)."""
    name: str
    description: str
    capabilities: list[str]
    endpoint: str
    input_schema: dict
    output_schema: dict
    authentication: dict | None = None


@dataclass
class A2ATask:
    """Task exchanged between agents."""
    id: str
    sender: str
    description: str
    input_data: dict
    status: str = "pending"  # "pending" | "in_progress" | "completed" | "failed"
    result: Any = None


class A2AOrchestrator:
    """Orchestrate tasks across multiple A2A-compatible agents."""

    def __init__(self) -> None:
        self._registry: dict[str, AgentCard] = {}

    def register(self, card: AgentCard) -> None:
        """Register an agent in the local directory."""
        self._registry[card.name] = card

    async def discover(self, capability: str) -> list[AgentCard]:
        """Find agents matching a required capability."""
        return [
            card for card in self._registry.values()
            if capability in card.capabilities
        ]

    async def delegate_task(self, agent_name: str, task: A2ATask) -> A2ATask:
        """Send a task to a registered agent and await result."""
        card = self._registry[agent_name]
        # In production, this would be an HTTP/gRPC call
        response = await self._send_task(card.endpoint, task)
        task.status = response["status"]
        task.result = response.get("result")
        return task
```

---

## Part 5: Human-in-the-Loop Patterns

### Pattern 15: Approval Gates

Agent pauses at critical decision points and requests explicit human approval before proceeding.

```python
from enum import Enum


class ApprovalLevel(Enum):
    """When to require human approval."""
    NEVER = "never"              # Fully autonomous
    HIGH_RISK = "high_risk"     # Only dangerous actions
    ALWAYS = "always"           # Every action requires approval


class HumanInTheLoopAgent(Agent):
    """Agent with configurable human approval gates."""

    def __init__(
        self,
        llm_client: Any,
        system_prompt: str,
        tools: list[Tool],
        approval_callback: Callable[[str, dict], bool],
        high_risk_tools: set[str] | None = None,
        approval_level: ApprovalLevel = ApprovalLevel.HIGH_RISK,
    ) -> None:
        super().__init__(llm_client, system_prompt, tools)
        self._approval_callback = approval_callback
        self._high_risk_tools = high_risk_tools or set()
        self._approval_level = approval_level

    async def _execute_tool(self, tool_call: dict) -> ToolResult:
        """Execute tool with human approval gate."""
        tool_name = tool_call["function"]["name"]

        needs_approval = (
            self._approval_level == ApprovalLevel.ALWAYS
            or (
                self._approval_level == ApprovalLevel.HIGH_RISK
                and tool_name in self._high_risk_tools
            )
        )

        if needs_approval:
            import json
            params = json.loads(tool_call["function"]["arguments"])
            approved = await self._approval_callback(
                f"Agent wants to execute: {tool_name}",
                params,
            )
            if not approved:
                return ToolResult(
                    tool_name=tool_name,
                    output="Action rejected by human operator.",
                    success=False,
                )

        return await super()._execute_tool(tool_call)


# Usage
agent = HumanInTheLoopAgent(
    llm_client=client,
    system_prompt="You are a helpful assistant.",
    tools=[search_tool, delete_tool, email_tool],
    approval_callback=ask_user_for_approval,
    high_risk_tools={"delete_record", "send_email", "make_payment"},
    approval_level=ApprovalLevel.HIGH_RISK,
)
```

### Pattern 16: Checkpoint-Resume

Agent saves state at checkpoints. Humans can review intermediate results, provide corrections, and resume from any checkpoint.

```python
@dataclass
class Checkpoint:
    """Saved agent state at a decision point."""
    id: str
    step: int
    state: dict
    output_so_far: str
    pending_action: str | None = None
    human_feedback: str | None = None


class CheckpointableAgent:
    """Agent that supports checkpoint-resume with human intervention."""

    def __init__(self, agent: Agent, checkpoint_store: Any) -> None:
        self._agent = agent
        self._store = checkpoint_store

    async def run_with_checkpoints(
        self,
        task: str,
        checkpoint_every: int = 3,
    ) -> str:
        """Run agent with periodic checkpoints for human review."""
        steps_since_checkpoint = 0
        output = ""

        async for step_result in self._agent.stream(task):
            output += step_result
            steps_since_checkpoint += 1

            if steps_since_checkpoint >= checkpoint_every:
                checkpoint = Checkpoint(
                    id=str(uuid4()),
                    step=steps_since_checkpoint,
                    state=self._agent.get_state(),
                    output_so_far=output,
                )
                await self._store.save(checkpoint)
                steps_since_checkpoint = 0

                # Wait for human review (optional, based on config)
                feedback = await self._store.await_feedback(checkpoint.id)
                if feedback:
                    task = f"{task}\n\nHuman feedback: {feedback}"

        return output

    async def resume_from(self, checkpoint_id: str, feedback: str) -> str:
        """Resume execution from a saved checkpoint with feedback."""
        checkpoint = await self._store.load(checkpoint_id)
        self._agent.set_state(checkpoint.state)
        return await self._agent.run(
            f"Continue from where you left off. "
            f"Previous output: {checkpoint.output_so_far}\n"
            f"Human feedback: {feedback}"
        )
```

---

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

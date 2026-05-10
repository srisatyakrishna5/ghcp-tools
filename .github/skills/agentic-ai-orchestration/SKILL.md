---
name: agentic-ai-orchestration
description: "Advanced reference covering prompt chaining, routing, parallelization, orchestrator-workers, evaluator-optimizer, supervisor, debate, and handoff patterns."
---

# Agentic AI Orchestration

> Reference skill for orchestration patterns. Load when you need advanced workflow decomposition, multi-agent coordination, or dynamic delegation patterns.

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


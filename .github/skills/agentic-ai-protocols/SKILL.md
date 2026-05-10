---
name: agentic-ai-protocols
description: "Advanced reference covering MCP integration, A2A communication, approval gates, and checkpoint-resume patterns for coordinated agent systems."
---

# Agentic AI Protocols and Human Oversight

> Reference skill for protocol integration and human oversight. Load when you need MCP, A2A, approval gates, or checkpoint and resume patterns.

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


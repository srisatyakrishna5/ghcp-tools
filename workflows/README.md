# Orchestration Workflows

This folder defines the **orchestration patterns** the Tech Lead uses to coordinate the agentic engineering team. Each file describes one pattern: when to use it, the agent topology, the data-flow contract, and the failure-handling rules.

The Program Manager selects a pattern per phase and names it in the Delivery Plan. The Tech Lead enforces the chosen pattern at dispatch time.

## Pattern Index

| Pattern | When to use | Topology |
|---------|-------------|----------|
| [sequential.workflow.md](sequential.workflow.md) | Hard data dependency between steps | A → B → C |
| [parallel.workflow.md](parallel.workflow.md) | Independent peer work, identical role | A ∥ A ∥ A |
| [fan-out.workflow.md](fan-out.workflow.md) | One input dispatches to many heterogeneous workers | A → {B, C, D} |
| [fan-in.workflow.md](fan-in.workflow.md) | Many parallel outputs must be merged | {B, C, D} → E |
| [pipeline.workflow.md](pipeline.workflow.md) | Multi-stage transformation with checkpoints | A → B → C → D (with gates) |
| [iterative-refinement.workflow.md](iterative-refinement.workflow.md) | Reviewer ↔ implementer feedback loop | A ↔ B until quality bar met |
| [brainstorm-converge.workflow.md](brainstorm-converge.workflow.md) | Divergent ideation followed by convergence | Diverge → Critique → Converge |
| [orchestrator-worker.workflow.md](orchestrator-worker.workflow.md) | Tech Lead splits work it cannot enumerate up front | Orchestrator dynamically spawns workers |
| [router.workflow.md](router.workflow.md) | Classify input and dispatch to the right specialist | Classifier → {specialist_1, ... specialist_n} |
| [reflection.workflow.md](reflection.workflow.md) | Agent critiques and improves its own output | A → A' → A'' |
| [escalation.workflow.md](escalation.workflow.md) | Lower-cost agent escalates only when blocked | Cheap → Strong (on signal) |

## Composition

Patterns compose. A typical end-to-end delivery looks like:

```
brainstorm-converge → sequential (Product → Architect)
                   → fan-out (parallel implementation)
                   → fan-in (integration)
                   → iterative-refinement (review loop)
                   → pipeline (test → docs → devops gates)
```

## Selection Rules

1. Default to the **simplest** pattern that satisfies the dependency graph.
2. Use **parallel/fan-out** whenever branches have no data dependency on each other.
3. Use **iterative-refinement** for any quality-gate review (code review, security review, eval review).
4. Use **brainstorm-converge** only at kickoff or when an architectural decision is genuinely open.
5. Use **orchestrator-worker** when the work breakdown is data-driven (e.g., "implement one file per entity in the schema").
6. Never launch a parallel pattern without a named **integration owner** and a defined **merge condition**.

## Contract Every Pattern Must Honor

- Every dispatch carries the full `TEAM_STATE` plus a `MISSION` block (see `instructions/team-collaboration.instructions.md`).
- Every parallel pattern declares an integration owner before launching branches.
- Every gated pattern declares an explicit pass condition; failure routes back, not forward.
- Every iterative pattern declares a max iteration count to prevent runaway loops.

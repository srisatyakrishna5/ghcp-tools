---
description: "Parallel execution strategy for multi-agent workflows — enforces automatic parallelization of independent tasks"
applyTo: "**"
---

# Parallel Execution Strategy

## Core Principle

**Default to parallel execution.** Only serialize tasks that have an explicit data dependency on a prior task's output. If two tasks can logically proceed without waiting for each other, they MUST run in parallel.

## When to Parallelize

### Always Parallel (no dependency between these)
- Writing tests for module A + writing tests for module B
- Implementing independent files, classes, or modules
- Generating documentation + generating Docker configs (after code exists)
- Creating unit tests + updating README + writing CI pipeline
- Reviewing multiple independent files

### Always Sequential (true dependency chain)
- Architecture design → Implementation (code depends on design decisions)
- Implementation → Code Review (reviewer needs final code)
- Schema design → Repository layer (repo depends on schema)

## Execution Rules

1. **Analyze the dependency graph first** — Before executing any plan, map which tasks depend on which. Tasks with no upstream dependency run immediately and in parallel.

2. **Maximize concurrency at every phase** — After a serial task completes, launch ALL newly-unblocked tasks simultaneously. Never pick one and queue the rest.

3. **Independent file edits are always parallel** — If a plan touches 3 files with no cross-references, work on all 3 simultaneously.

4. **Never wait unnecessarily** — Do not wait for tests to finish before starting documentation if documentation only depends on the implementation (which is already complete).

5. **Subagent parallelism** — When orchestrating with subagents, launch independent subagents in the same turn. Do not serialize subagent calls that have no data dependency.

## Anti-Patterns (DO NOT do these)

- Running Test Engineer after Documentation Engineer "just because it's next in the list"
- Implementing module B only after module A is done, when they share no interfaces
- Writing all tests sequentially when test files are independent
- Asking the user "should I proceed with X?" when X is clearly the next independent task

## Decision Heuristic

```
For each pending task, ask:
  "Does this task require OUTPUT from another task that hasn't finished yet?"
  
  YES → Wait for that task to complete first
  NO  → Execute immediately, in parallel with other independent tasks
```

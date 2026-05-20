---
description: "Shared coding standards enforced across all engineering agents — MANDATORY for all code generation and review"
applyTo: "**/*.ts,**/*.tsx,**/*.js,**/*.jsx,**/*.py,**/*.cs,**/*.java,**/*.go,**/*.rs"
---

# Coding Standards

> **Enforcement level: MANDATORY.** These rules are not suggestions. Every agent that writes, modifies, or reviews code MUST apply these standards. Violations must be caught in code review and fixed before delivery.

## SOLID Principles

- **Single Responsibility**: Each class/module has one reason to change. Extract concerns into dedicated units.
- **Open/Closed**: Design modules open for extension, closed for modification. Use abstractions, strategy patterns, or composition.
- **Liskov Substitution**: Subtypes must be substitutable for their base types without altering correctness.
- **Interface Segregation**: Prefer many small, focused interfaces over one large general-purpose interface.
- **Dependency Inversion**: Depend on abstractions, not concretions. Inject dependencies; never instantiate collaborators internally.

## Design Patterns

Apply patterns only when they solve a real problem. Prefer simplicity.

- **Creational**: Factory Method, Builder (for complex object construction), Singleton (only for true global state)
- **Structural**: Adapter, Decorator, Composite (for tree structures), Facade (to simplify subsystems)
- **Behavioral**: Strategy, Observer, Command, Chain of Responsibility

## Clean Code Principles

1. **Naming**: Use intention-revealing names. Avoid abbreviations. Classes = nouns, methods = verbs.
2. **Functions**: Keep functions small (< 20 lines preferred). Single level of abstraction per function.
3. **DRY**: Eliminate duplication. Extract shared logic into well-named helpers.
4. **YAGNI**: Do not build what is not needed today.
5. **Boy Scout Rule**: Leave code cleaner than you found it.
6. **Fail Fast**: Validate inputs at boundaries. Throw meaningful errors early.
7. **Immutability**: Prefer immutable data structures. Minimize mutable state.

## Complexity Management

- Cyclomatic complexity per function: target ≤ 10
- Cognitive complexity per function: target ≤ 15
- Maximum nesting depth: 3 levels
- Maximum parameters per function: 4 (use options objects for more)
- Maximum file length: 300 lines (split if exceeded)

## Data Structures & Algorithms

- **State the complexity**: every non-trivial function MUST declare its time and space complexity in a docstring (e.g., `O(n log n) time, O(n) space`). Reviewers reject undeclared complexity on hot paths.
- **Pick the right structure first**:
  - Lookup by key → hash map (`O(1)` avg). Never linear-scan a list when membership is the question.
  - Ordered traversal / range queries → balanced tree, sorted structure, or B-tree-backed index.
  - LIFO / DFS → stack. FIFO / BFS → queue / deque. Never simulate with a list and `shift()`.
  - Top-K / streaming aggregates → heap (`O(log n)` per op).
  - Set membership over large universe with false-positive tolerance → bloom filter.
  - Graph traversal → adjacency list (sparse) or adjacency matrix (dense, small N).
- **Avoid known anti-patterns**:
  - Nested loops over the same collection where a hash map gives `O(n)` instead of `O(n²)`.
  - Repeated string concatenation in a loop — use a builder/buffer.
  - `O(n)` membership checks inside an `O(n)` loop (use a set).
  - Re-computing the same expensive value — memoize or hoist out of the loop.
- **Algorithm budget**: prefer `O(n)` or `O(n log n)` for any input that can grow. Document the justification when an `O(n²)` algorithm is intentional (small bounded N, simplicity wins).
- **Recursion**: bound it. Use iteration or explicit stacks when depth can exceed a few thousand frames. Tail-call optimization is not portable across runtimes.
- **Concurrency primitives**: prefer immutable data + message passing over shared mutable state. When locks are needed, document the lock ordering to prevent deadlocks.

## Performance Budget

Every production code path that handles user requests, batch jobs, or data pipelines MUST have a stated budget:

- **Latency**: p50, p95, p99 targets (e.g., p95 < 200ms).
- **Throughput**: requests/sec or items/sec sustained without queue growth.
- **Memory**: peak working set, especially for streaming or batch jobs.
- **Cost**: external API calls, DB round-trips, and token usage where LLMs are involved.

If a budget is unknown at implementation time, the Developer MUST surface it as an `OPEN_QUESTION` so the Tech Lead can resolve it before review.

## Error Handling

- Use typed/custom exceptions with contextual messages
- Never swallow exceptions silently
- Log at appropriate levels (error for failures, warn for recoverable issues, info for operations)
- Return meaningful error responses at API boundaries

## Security (OWASP Top 10 Awareness)

- Validate and sanitize all external inputs
- Use parameterized queries (never string concatenation for SQL)
- Apply principle of least privilege
- Never log secrets, tokens, or PII
- Use constant-time comparison for sensitive values

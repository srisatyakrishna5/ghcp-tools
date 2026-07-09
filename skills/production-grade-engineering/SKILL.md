---
name: production-grade-engineering
description: 'Focused guidance for production-grade code quality on a specific implementation or review: data structures and algorithms, time and space complexity, low cyclomatic complexity, design patterns, and OWASP security in Python, C#, TypeScript, or other languages. USE WHEN: implement or review one function or module, pick the right algorithm or data structure, reduce complexity, apply a design pattern, or security-review code. DO NOT USE FOR: a full senior standard with clean architecture and TDD coverage gates across a whole feature (use advanced-production-engineering); FastAPI services (use fastapi-production-grade).'
argument-hint: 'Describe the problem, language, performance requirements, security constraints, and expected architecture.'
user-invocable: true
disable-model-invocation: false
---

# Production-Grade Engineering Workflow

## When to Use
- Implement or review production-ready code.
- Design algorithms and data structures with explicit complexity goals.
- Improve code quality, maintainability, testability, and security.
- Apply Microsoft engineering practices and OWASP-aligned safeguards.

## Core Objective
Produce software that is correct, secure, efficient, readable, and maintainable under real-world production conditions.

## Workflow

### 1. Clarify the requirement and constraints
Start by identifying:
1. The functional goal and expected behavior.
2. Required performance characteristics, including time and space constraints.
3. Security, privacy, and compliance expectations.
4. Applicable language, platform, and team standards.
5. Expected extensibility and maintenance burden.

Decision point:
- If the task is algorithmic or data-heavy, prioritize correctness and complexity analysis before implementation.
- If the task is a service or API, prioritize reliability, security, and testability.

### 2. Choose the right algorithmic approach
Before coding, decide whether the solution needs:
- A simple traversal or transformation.
- A more efficient search, sorting, graph, or dynamic programming approach.
- A data structure that reduces complexity, such as hash maps, heaps, queues, trees, or tries.

Apply these rules:
- Prefer the simplest correct approach that meets constraints.
- Analyze time complexity and space complexity explicitly.
- Avoid unnecessary nesting, repeated scans, or hidden exponential behavior.

Decision point:
- If the problem has strict performance limits, choose a structure or algorithm that reduces runtime from quadratic to linearithmic or better when possible.
- If the data is small or performance is not critical, prefer clarity and maintainability.

### 3. Keep code structure simple and maintainable
Write code that is easy to read and verify:
- Use small functions with a single responsibility.
- Keep cyclomatic complexity low by avoiding deeply nested conditionals and long branching chains.
- Prefer early returns and clear abstractions over clever tricks.
- Use meaningful names, consistent formatting, and limited duplication.

Good practice:
- If a method grows too complex, split it into smaller helpers.
- If a block contains many branches, consider a strategy or policy object rather than a large conditional tree.

### 4. Apply design patterns only when they solve a real problem
Use patterns when they improve clarity or flexibility, not as decoration.

Common cases:
- Factory or builder for object creation complexity.
- Strategy for interchangeable behaviors.
- Repository or adapter for external dependencies.
- Singleton only when truly justified and safe in the runtime environment.

Decision point:
- If the requirement is simple and stable, avoid adding pattern overhead.
- If the requirement involves variation, extensibility, or multiple implementations, apply the appropriate pattern.

### 5. Follow Microsoft and secure-by-default engineering practices
Adopt the following quality baseline:
- Write readable, maintainable, and testable code.
- Use clear exception handling and avoid swallowing failures silently.
- Keep secrets out of source code and use secure configuration practices.
- Validate all external input and limit trust boundaries.
- Prefer immutable data and explicit state transitions where possible.
- Use logging and diagnostics that help operations without exposing sensitive data.

Security guidance:
- Follow OWASP Top 10 principles for input validation, authentication, authorization, injection prevention, and secure defaults.
- Avoid unsafe deserialization, weak randomness, and hard-coded credentials.
- Sanitize outputs that may be rendered in user interfaces or logs.

### 6. Ensure performance and complexity discipline
Before finalizing, verify:
1. The chosen algorithm satisfies the expected constraints.
2. Time complexity is documented or reasoned about clearly.
3. Space complexity is acceptable for the expected input size.
4. There are no obvious hotspots or unnecessary repeated work.

Decision point:
- If complexity is borderline, profile or benchmark the hot path before optimizing.
- If complexity is clearly poor, revisit the data structure or algorithm rather than patching around it.

### 7. Write tests that prove the behavior
Use tests to confirm:
- Correctness on normal and edge cases.
- Failure handling and invalid inputs.
- Performance-sensitive scenarios where relevant.
- Security-related boundaries such as input validation and authorization.

Recommended coverage:
- Unit tests for core logic.
- Integration tests for external dependencies.
- Boundary tests for performance-critical paths.

### 8. Review for production readiness
Before completion, check:
- Code is understandable to another engineer.
- Complexity and algorithm choices are justified.
- Security requirements are satisfied.
- Error handling is explicit and safe.
- Tests exist for major behaviors and regressions.

## Decision Guide

### Use algorithmic rigor when
- The task involves search, sorting, traversal, optimization, or large input sizes.
- Time or space constraints are explicit or critical.

### Use low-complexity design when
- The solution contains many branches, nested conditions, or repeated logic.
- Maintainability and readability matter more than cleverness.

### Use design patterns when
- Variability, extensibility, or multiple implementation strategies are part of the requirement.
- The code would otherwise become hard to evolve safely.

### Use OWASP-aligned security practices when
- The code handles user input, secrets, network traffic, auth, or untrusted data.
- The software is exposed to external users or systems.

## Anti-Patterns to Avoid
- Choosing a data structure or algorithm without checking the input-size and complexity constraints.
- Deep nesting and long branch chains instead of early returns and small helpers.
- Applying design patterns for simple, stable requirements (pattern overhead with no payoff).
- Trusting external input without validation, or building SQL/commands via string concatenation.
- Swallowing exceptions, weak randomness for security, or hard-coded secrets.
- Declaring code correct without tests for edge cases and failure paths.

## Quality Criteria
A high-quality solution should:
- Be correct and robust under expected and edge-case inputs.
- Use data structures and algorithms that match the problem constraints.
- Keep cyclomatic complexity low and logic easy to follow.
- Apply OWASP best practices and secure-by-default design.
- Use design patterns only where they genuinely improve maintainability.
- Be testable, reviewable, and ready for production use.

## Output Expectations
When used, this skill should help produce:
- A production-grade implementation plan.
- A complexity-aware algorithm and data structure recommendation.
- A secure, low-complexity code design.
- A review checklist for code quality and maintainability.

## Example Prompts to Try
- Implement a production-grade solution for this algorithmic problem with explicit time complexity analysis.
- Refactor this module to reduce cyclomatic complexity and improve maintainability.
- Review this code for OWASP security best practices and Microsoft engineering standards.
- Design a solution using the right data structures and patterns for the given requirement.

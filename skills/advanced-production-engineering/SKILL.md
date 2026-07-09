---
name: advanced-production-engineering
description: 'Senior-level engineering standard for building or refactoring complete, production-grade software with clean architecture, modularity, extensibility, TDD with at least 80% coverage, algorithmic rigor, low complexity, and OWASP-aligned security. USE WHEN: build a feature to senior/production standard, produce an end-to-end implementation plan, architect a maintainable module, apply TDD plus coverage gates, or combine quality, security, performance, and testing in one workflow. DO NOT USE FOR: a single focused algorithm, complexity, or security review with no architecture or TDD scope (use production-grade-engineering); FastAPI-specific services (use fastapi-production-grade).'
argument-hint: 'Describe the problem, language, performance constraints, architecture needs, test framework, and security or compliance requirements.'
user-invocable: true
disable-model-invocation: false
---

# Advanced Production Engineering Standard

## When to Use
- Build or refactor software to senior-level production standards.
- Design code that is modular, extensible, readable, and high-performance.
- Apply test-driven development with strong quality gates and minimum 80% coverage.
- Enforce clean architecture, algorithmic discipline, security best practices, and maintainability.

## Core Objective
Produce software that is correct, secure, efficient, testable, modular, and easy to evolve in production environments.

## Engineering Principles

### 1. Start with clear requirements and constraints
Identify:
1. The business or technical goal.
2. Required performance, scalability, and reliability limits.
3. Security, privacy, and compliance requirements.
4. The target language, runtime, and platform constraints.
5. Expected maintainability, extensibility, and team collaboration needs.

Decision point:
- If the task is algorithmic or data-heavy, analyze complexity and data structure choices first.
- If the task is service-oriented, emphasize architecture, validation, testing, and operational readiness.

### 2. Design for clean architecture and modularity
Structure the solution so each component has one responsibility:
- Separate domain logic, infrastructure, validation, and orchestration.
- Keep interfaces small, explicit, and stable.
- Avoid putting business logic directly into transport or framework-specific layers.
- Prefer composable modules over monolithic functions.

Rules:
- Write small, focused functions and classes.
- Make dependencies explicit and injectable where appropriate.
- Favor readability and maintainability over clever shortcuts.

### 3. Use algorithmic rigor and performance discipline
Before implementation, choose the appropriate approach:
- Use the simplest correct algorithm that satisfies the constraints.
- Prefer efficient data structures such as hash maps, heaps, queues, trees, or sets when they reduce complexity.
- Analyze time and space complexity for critical paths.

Decision point:
- If constraints are strict or input sizes are large, optimize the algorithmic design before coding.
- If the problem is small or not performance-sensitive, prioritize clarity and maintainability.

### 4. Keep code low in complexity and high in clarity
Apply senior coding standards:
- Minimize deep nesting and long conditional chains.
- Use early returns and small helper functions to reduce cyclomatic complexity.
- Keep methods and classes focused, readable, and easy to test.
- Avoid duplication; extract reusable logic when it improves clarity and reuse.

Good practice:
- If a function becomes difficult to explain, split it into smaller pieces.
- If a branch tree grows too large, convert it into a strategy, policy, or factory-based design.

### 5. Follow test-driven development as the default path
Use TDD for production-grade work:
1. Write the smallest failing test that describes the expected behavior.
2. Implement the minimum code required to make it pass.
3. Refactor safely with the test suite as protection.
4. Expand tests for edge cases, failures, and integration behavior.

Coverage expectation:
- Maintain at least 80% code coverage for critical code paths.
- Prioritize meaningful tests over superficial coverage numbers.

Decision point:
- If a component is high-risk or business-critical, require broader and more explicit test coverage.
- If a pathway is trivial or dead code, remove it instead of padding it with tests.

### 6. Apply OWASP and secure-by-default practices
Follow secure engineering rules:
- Validate and sanitize all input.
- Avoid hard-coded credentials, unsafe deserialization, weak randomness, and insecure defaults.
- Handle secrets via secure configuration and secret stores.
- Use least-privilege access, proper authorization, and secure transport.
- Log safely without exposing sensitive information.

Decision point:
- If the software interacts with external users, APIs, or data, apply stricter input validation and authorization checks.
- If the system deals with regulated or sensitive data, add stronger audit, control, and encryption practices.

### 7. Use design patterns only where they solve real problems
Apply patterns when they improve flexibility, extensibility, or maintainability:
- Factory or builder for complex object creation.
- Strategy for interchangeable behaviors.
- Repository or adapter for external systems.
- Dependency injection for testability and dependency management.

Avoid pattern overuse when the requirement is simple and stable.

### 8. Build for extensibility and long-term maintainability
Design the codebase so future changes are low-risk:
- Use well-defined boundaries between layers.
- Prefer configuration over hard-coded assumptions.
- Make core behavior easy to extend with minimal disruption.
- Keep docs, naming, and interfaces consistent across the codebase.

### 9. Verify production readiness before completion
Before considering the work done, confirm:
- The implementation meets the requirements.
- Tests pass and coverage is at or above the target.
- Complexity and performance choices are appropriate.
- Security requirements are satisfied.
- The solution is readable, modular, and easy to review.

## Anti-Patterns to Avoid
- Claiming completion without running tests and citing fresh pass/coverage output.
- Padding coverage with assertion-free or mock-only tests instead of testing real behavior.
- Adding speculative abstractions, patterns, or config for needs that do not exist yet.
- Catching and swallowing exceptions, or logging secrets and sensitive data.
- Optimizing before measuring, or shipping unanalyzed quadratic/exponential hot paths.
- Large multi-responsibility functions with deep nesting and unclear naming.

## Senior Engineering Checklist
- Clean separation of concerns
- Low cyclomatic complexity
- Efficient data structures and algorithms
- Test-driven development discipline
- At least 80% coverage for critical paths
- OWASP-aligned secure defaults
- Modular, extensible, and maintainable design
- Clear naming, documentation, and review friendliness

## Output Expectations
When used, this skill should help produce:
- A production-grade implementation plan.
- A high-performance, modular, and extensible design.
- A TDD-based development and validation approach.
- A quality checklist for security, maintainability, and coverage.

## Example Prompts to Try
- Build this feature using senior production engineering standards with TDD and minimum 80% coverage.
- Refactor this module to be modular, low-complexity, and performance-aware.
- Review this code for clean architecture, security, and extensibility.
- Design a scalable solution using the right algorithms, patterns, and tests.

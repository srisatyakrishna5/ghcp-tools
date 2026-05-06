---
description: "Testing standards enforced by the test engineer agent"
applyTo: "**/*.test.*,**/*.spec.*,**/test_*,**/*_test.*,**/tests/**"
---

# Testing Standards

## Coverage Target

- Minimum **80% line coverage** on all production code
- Critical paths (auth, payments, data mutations): **90%+ coverage**
- Exclude generated code, type definitions, and configuration from coverage metrics

## Test Structure (AAA Pattern)

```
Arrange → set up preconditions and inputs
Act     → invoke the behavior under test
Assert  → verify expected outcomes
```

## Naming Convention

- Test names describe the scenario: `should_return_404_when_user_not_found`
- Group tests by unit under test, then by behavior
- Use descriptive `describe`/`context` blocks for readability

## Unit Test Principles

1. **Isolated**: No shared mutable state between tests. Each test sets up its own context.
2. **Deterministic**: Same result every run. No reliance on time, network, or filesystem.
3. **Fast**: Unit tests complete in milliseconds. Mock external dependencies.
4. **Focused**: One logical assertion per test (multiple physical assertions are acceptable if testing one behavior).
5. **Readable**: Tests serve as documentation. Prefer clarity over cleverness.

## Mocking Guidelines

- Mock at boundaries (I/O, network, database, third-party APIs)
- Use dependency injection to enable testability
- Prefer fakes over mocks for complex interactions
- Verify interactions only when the interaction itself is the requirement

## Test Categories

| Category | Scope | Speed | External Deps |
|----------|-------|-------|---------------|
| Unit | Single function/class | < 100ms | None (mocked) |
| Integration | Module boundaries | < 5s | May use test containers |
| E2E | Full user flow | < 30s | Real services |

## What to Test

- Happy path (expected inputs → expected outputs)
- Edge cases (empty inputs, boundary values, max lengths)
- Error paths (invalid inputs, service failures, timeouts)
- State transitions (before/after mutations)
- Security-relevant paths (auth, authorization, input validation)

## What NOT to Test

- Framework internals or third-party library behavior
- Trivial getters/setters with no logic
- Private implementation details (test through public API)
- Generated code

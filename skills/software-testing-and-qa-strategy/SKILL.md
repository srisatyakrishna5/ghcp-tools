---
name: software-testing-and-qa-strategy
description: 'Design a complete testing and QA strategy across unit, integration, end-to-end, contract, performance, and security testing, with coverage goals and CI integration. USE WHEN: plan a test strategy, choose test types and the test pyramid, design test cases and data, set coverage targets, reduce flaky tests, or wire testing into CI. DO NOT USE FOR: reviewing a specific diff (use code-review-and-quality-gates); building the production code itself (use advanced-production-engineering); AI model evaluation (use ai-evaluation-and-benchmarking).'
argument-hint: 'Describe the system under test, the languages and frameworks, risk areas, existing coverage, and CI environment.'
user-invocable: true
disable-model-invocation: false
---

# Software Testing and QA Strategy

## When to Use
- Design a testing strategy for a service, app, or feature.
- Choose the right mix of test types and balance the test pyramid.
- Define test cases, test data, and coverage goals.
- Stabilize flaky tests and integrate testing into CI/CD.

## Core Objective
Build confidence in correctness and prevent regressions with a fast, reliable, and maintainable test suite that matches the system's risk profile.

## Workflow

### 1. Assess risk and current coverage
- Identify high-risk areas: money, auth, data integrity, public contracts.
- Map existing coverage and gaps.
- Define quality goals: regression safety, release confidence, speed.

### 2. Shape the test pyramid
Balance test types by cost and value:
- Many fast unit tests for logic and edge cases.
- Fewer integration tests for boundaries (DB, queues, external services).
- A small set of end-to-end tests for critical user journeys.
- Contract tests for service and API stability.

Decision point:
- If e2e tests are slow and flaky, push coverage down to integration and unit levels.
- If services interact heavily, invest in contract tests.

### 3. Design effective test cases
- Cover happy paths, edge cases, boundaries, and failure modes.
- Test behavior and observable outcomes, not implementation details.
- Use equivalence partitioning and boundary-value analysis.
- Include negative tests, invalid input, and error handling.

### 4. Manage test data and environments
- Use deterministic, isolated test data; avoid shared mutable state.
- Prefer fixtures, factories, and builders over copy-paste data.
- Use realistic data for integration and performance tests.
- Reset state between tests to ensure independence.

### 5. Add non-functional testing where it matters
- Performance and load tests for latency- and throughput-critical paths.
- Security tests for input validation, authz, and OWASP risks.
- Accessibility and compatibility tests for user-facing apps.
- Resilience tests (timeouts, retries, failure injection) for distributed systems.

### 6. Integrate into CI and keep it healthy
- Run fast tests on every commit; gate merges on green.
- Run slower suites on a schedule or pre-release.
- Track coverage and flaky-test rate; quarantine and fix flakes.
- Make failures actionable with clear messages and fast feedback.

## Anti-Patterns to Avoid
- Inverted pyramid: many slow e2e tests, few unit tests.
- Testing implementation details so refactors break tests unnecessarily.
- Asserting on mocks instead of real behavior and outcomes.
- Adding production-only hooks or methods just to make code testable.
- Chasing a coverage percentage with shallow, assertion-light tests.
- Tolerating flaky tests, which erodes trust in the whole suite.
- Shared, order-dependent test state causing intermittent failures.

## Decision Guide

### Prioritize unit tests when
- Logic is complex, with many branches and edge cases.

### Prioritize integration tests when
- Correctness depends on real boundaries: DB, queues, external APIs.

### Prioritize end-to-end tests when
- A few critical user journeys must always work.

### Add performance or security tests when
- Latency, throughput, or untrusted input is a real risk.

## Quality Criteria
A strong test strategy should:
- Match coverage to risk, not chase a single number.
- Be fast, deterministic, and isolated.
- Test real behavior and fail for real reasons.
- Cover failure paths, not just happy paths.
- Integrate cleanly into CI with actionable feedback.

## Output Expectations
When invoked, this skill should help produce:
- A layered test strategy and pyramid plan.
- Concrete test cases and test-data approach.
- A non-functional testing plan where warranted.
- A CI integration and flaky-test management plan.

## Example Prompts to Try
- Design a test strategy for this payment service with coverage goals.
- Convert these slow e2e tests into a healthier test pyramid.
- Write test cases covering edge cases and failure paths for this module.
- Plan performance and security testing for this public API.

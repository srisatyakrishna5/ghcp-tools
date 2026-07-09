---
name: code-review-and-quality-gates
description: 'Run rigorous, constructive code reviews and define merge quality gates: correctness, readability, security, performance, tests, and maintainability. USE WHEN: review a pull request or diff, give actionable review feedback, define PR or merge checklists, set CI quality gates, or assess change risk before merge. DO NOT USE FOR: authoring new features from scratch (use production-grade-engineering or advanced-production-engineering); test strategy design (use software-testing-and-qa-strategy).'
argument-hint: 'Provide the diff or PR, the change intent, the language, and any risk or compliance concerns.'
user-invocable: true
disable-model-invocation: false
---

# Code Review and Quality Gates

## When to Use
- Review a pull request, diff, or proposed change.
- Provide actionable, prioritized feedback to an author.
- Define PR checklists and CI merge quality gates.
- Assess the risk of a change before approving it.

## Core Objective
Improve change quality and reduce risk through focused, constructive review and consistent, enforceable quality gates.

## Workflow

### 1. Understand intent before reading code
- Read the description, linked issue, and acceptance criteria.
- Confirm the change scope matches the stated intent.
- Note risk level: data migrations, auth, payments, and public APIs are high risk.

### 2. Review correctness and behavior
- Verify the logic matches requirements and handles edge cases.
- Check error handling, null/empty/boundary cases, and concurrency.
- Confirm backward compatibility and API/contract stability.
- Look for off-by-one, race conditions, and incorrect assumptions.

### 3. Review quality and maintainability
- Readability: clear names, small functions, low nesting and complexity.
- Structure: separation of concerns, no needless duplication or dead code.
- Consistency with existing patterns and conventions.
- Avoid scope creep and unrelated changes bundled in.

### 4. Review security and data handling
- Validate and sanitize input; avoid injection and unsafe deserialization.
- No hard-coded secrets; correct authn/authz checks.
- Safe logging without sensitive data; least-privilege access.
- Dependency changes reviewed for known vulnerabilities.

### 5. Review tests and performance
- New behavior is covered by meaningful tests, including failure paths.
- Tests assert real behavior, not just mocks.
- No obvious performance regressions; hot paths reasoned about.
- Migrations and rollouts are safe and reversible.

### 6. Deliver actionable feedback
- Categorize comments: blocking, recommended, and nit/optional.
- Explain the why and suggest a concrete fix.
- Acknowledge good work; keep tone respectful and specific.
- Approve only when blocking issues are resolved.

## Anti-Patterns to Avoid
- Rubber-stamp approvals without understanding the change.
- Style-only nitpicking while missing correctness or security issues.
- Vague feedback ("this is wrong") with no reason or suggested fix.
- Blocking on personal preference rather than standards or risk.
- Approving changes with no tests for new behavior.
- Letting unrelated refactors ride along in a focused PR.

## Decision Guide

### Block the merge when
- There are correctness, security, or data-integrity defects.
- New behavior lacks meaningful test coverage.
- The change is unsafe to roll back.

### Approve with suggestions when
- Only non-blocking improvements or nits remain.

### Request more context when
- Intent, scope, or risk is unclear from the PR.

## Quality Gates Checklist
- Builds pass and CI is green.
- Tests cover new and changed behavior, including failure paths.
- Static analysis, linting, and security scans pass.
- No secrets, no high/critical vulnerable dependencies.
- Migrations are reversible; rollout/rollback is defined.
- Documentation and changelog updated where relevant.

## Output Expectations
When invoked, this skill should help produce:
- A prioritized review with blocking vs. optional feedback.
- A risk assessment for the change.
- A PR checklist or CI quality-gate definition.

## Example Prompts to Try
- Review this pull request for correctness, security, and test coverage.
- Define merge quality gates for our CI pipeline.
- Assess the risk of this database migration change before approval.
- Turn this diff review into prioritized, actionable feedback.

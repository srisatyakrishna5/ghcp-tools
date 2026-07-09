---
name: product-requirements-and-specs
description: 'Turn ideas and stakeholder input into clear product requirements, user stories, acceptance criteria, and technical specs that drive high-quality delivery. USE WHEN: define scope for a new feature or product, write a PRD or spec, capture user stories and acceptance criteria, clarify ambiguous requirements, or set measurable success metrics before building. DO NOT USE FOR: system architecture and component design (use software-architecture-and-design); writing code (use production-grade-engineering or advanced-production-engineering).'
argument-hint: 'Describe the product idea or feature, the users, the problem, known constraints, and the success metrics.'
user-invocable: true
disable-model-invocation: false
---

# Product Requirements and Specifications

## When to Use
- Translate a rough idea or request into clear, testable requirements.
- Write a product requirements document (PRD), feature spec, or technical design brief.
- Define user stories, acceptance criteria, and measurable success metrics.
- Resolve ambiguity and scope before architecture or implementation begins.

## Core Objective
Produce unambiguous, testable, and prioritized requirements that align stakeholders and give engineers a clear definition of done.

## Workflow

### 1. Frame the problem and users
Capture first:
1. The user or persona and the job they are trying to do.
2. The problem and its impact, with evidence where possible.
3. The desired outcome and how success will be measured.
4. Constraints: timeline, budget, compliance, platform, dependencies.
5. What is explicitly out of scope.

Decision points:
- If the problem is unclear, gather evidence or examples before writing requirements.
- If multiple personas exist, prioritize the primary one and note secondary needs.

### 2. Define scope and priorities
- Separate must-have, should-have, and nice-to-have using a clear method (e.g., MoSCoW).
- Define a minimal valuable slice that can ship and be validated.
- Record assumptions, open questions, and risks explicitly.

### 3. Write user stories and acceptance criteria
For each capability:
- Use the form: as a [user], I want [capability], so that [outcome].
- Add acceptance criteria in given/when/then or checklist form.
- Make each criterion observable and testable, not vague.
- Include negative paths, edge cases, and error handling expectations.

### 4. Specify functional and non-functional requirements
- Functional: inputs, outputs, behaviors, states, and rules.
- Non-functional: performance, scalability, availability, security, privacy, accessibility, and compliance targets.
- Define data requirements, retention, and any regulatory constraints.

### 5. Define success metrics and validation
- Tie each goal to a measurable metric (adoption, latency, error rate, conversion, satisfaction).
- State how the metric will be measured and the target threshold.
- Define how the feature will be validated after launch.

### 6. Confirm shared understanding
Before handing off:
- Review with stakeholders and engineering for feasibility.
- Resolve open questions or mark them as decisions needed.
- Ensure traceability from goal to story to acceptance criteria.

## Anti-Patterns to Avoid
- Vague, untestable requirements ("make it fast", "user-friendly") with no measurable target.
- Specifying a solution or UI before the problem and outcome are agreed.
- Mixing must-haves and nice-to-haves with no prioritization.
- Ignoring edge cases, error paths, and non-functional needs.
- Hidden assumptions and unowned open questions left unresolved.
- Success defined by shipping rather than by a measurable outcome.

## Decision Guide

### Write a full PRD when
- The work is a new product, major feature, or cross-team initiative.
- Multiple stakeholders need alignment and traceability.

### Write a lightweight spec when
- The change is small, well understood, and single-team.
- A few user stories and acceptance criteria are enough.

### Pause and clarify when
- The problem, users, or success metric is unknown or contested.

## Quality Criteria
Strong requirements should be:
- Clear, unambiguous, and testable.
- Prioritized with an identified minimal valuable slice.
- Complete across functional and non-functional needs.
- Traceable from goal to story to acceptance criteria.
- Tied to measurable success metrics and a validation plan.

## Output Expectations
When invoked, this skill should help produce:
- A PRD or feature spec.
- A set of user stories with acceptance criteria.
- A prioritized scope with assumptions, risks, and open questions.
- A success-metrics and validation plan.

## Example Prompts to Try
- Write a PRD for a notifications feature with user stories and acceptance criteria.
- Turn this rough idea into prioritized, testable requirements with success metrics.
- Add edge cases and non-functional requirements to this feature spec.
- Define a minimal valuable slice and validation plan for this initiative.

---
name: observability-and-sre
description: 'Make systems observable and operable: logging, metrics, distributed tracing, SLI/SLO/error budgets, alerting, dashboards, and incident response. USE WHEN: instrument a service, define SLOs and alerts, design dashboards, structure logs and traces, plan on-call and incident response, or run a blameless postmortem. DO NOT USE FOR: container/AKS pipeline setup (use aks-gitlab-secure-cicd); test strategy (use software-testing-and-qa-strategy); architecture design (use software-architecture-and-design).'
argument-hint: 'Describe the service, its criticality, current telemetry, latency/availability targets, and on-call setup.'
user-invocable: true
disable-model-invocation: false
---

# Observability and SRE

## When to Use
- Instrument a service with logs, metrics, and traces.
- Define SLIs, SLOs, and error budgets.
- Design alerts and dashboards that surface real problems.
- Plan on-call, incident response, and postmortems.

## Core Objective
Enable teams to detect, diagnose, and resolve issues quickly while keeping reliability aligned with explicit, measurable targets.

## Workflow

### 1. Define what reliability means
- Identify critical user journeys and their failure impact.
- Choose SLIs that reflect user experience: availability, latency, error rate, freshness.
- Set SLOs with realistic targets and define error budgets.
- Decide how budget burn changes release and operational behavior.

### 2. Instrument the three pillars
- Logs: structured, leveled, with correlation/request IDs; no sensitive data.
- Metrics: RED (rate, errors, duration) for services; USE (utilization, saturation, errors) for resources.
- Traces: distributed tracing across service and dependency boundaries.
- Propagate context so logs, metrics, and traces correlate.

### 3. Design actionable alerting
- Alert on symptoms (SLO burn, user-facing errors), not every cause.
- Make alerts actionable, with clear ownership and runbooks.
- Use multi-window burn-rate alerts to balance speed and noise.
- Eliminate noisy, non-actionable alerts that cause fatigue.

### 4. Build useful dashboards
- Top-level service health: SLOs, RED metrics, error budget.
- Drill-downs for dependencies, saturation, and recent deploys.
- Keep dashboards focused on questions responders actually ask.

### 5. Prepare for incidents
- Define severity levels, roles (incident commander, comms), and escalation.
- Maintain runbooks for common failures and recovery steps.
- Ensure rollback and feature-flag kill switches are ready.
- Practice with game days where reliability is critical.

### 6. Learn from failures
- Run blameless postmortems focused on systems, not individuals.
- Capture timeline, root cause, contributing factors, and action items.
- Track remediation to completion and feed it back into design.

## Anti-Patterns to Avoid
- Logging everything with no structure, levels, or correlation IDs.
- Alerting on causes and noise instead of user-facing symptoms.
- SLOs with no error budget or no consequence when burned.
- Dashboards full of vanity metrics that answer no operational question.
- Logging secrets, tokens, or personal data.
- Blameful postmortems that hide root causes and discourage honesty.
- Runbooks that are missing, stale, or never tested.

## Decision Guide

### Invest heavily in observability when
- The service is user-facing, revenue-critical, or hard to debug.

### Keep it lightweight when
- The service is internal, low-risk, and rarely changing.

### Add distributed tracing when
- Requests cross multiple services and latency is hard to attribute.

### Tighten SLOs when
- Users are sensitive to downtime or latency and the budget is being burned.

## Quality Criteria
A well-observed system should:
- Have SLIs/SLOs tied to user experience with error budgets.
- Provide correlated logs, metrics, and traces.
- Alert on actionable symptoms with runbooks and clear ownership.
- Recover quickly via rehearsed incident response and rollback.
- Improve continuously through blameless postmortems.

## Output Expectations
When invoked, this skill should help produce:
- An instrumentation plan for logs, metrics, and traces.
- SLI/SLO definitions and error-budget policy.
- An alerting and dashboard design.
- An incident response and postmortem process.

## Example Prompts to Try
- Define SLIs, SLOs, and burn-rate alerts for this API.
- Design an observability plan with structured logs, RED metrics, and tracing.
- Create an incident response runbook and severity model for this service.
- Review these alerts and remove noise while keeping coverage.

---
name: software-architecture-and-design
description: 'Design scalable, reliable, and maintainable software architecture: component and data design, API contracts, trade-off analysis, and architecture decision records (ADRs). USE WHEN: design a system or service, choose between monolith, microservices, or event-driven styles, model data and boundaries, plan for scale and resilience, evaluate trade-offs, or write an ADR. DO NOT USE FOR: product requirements (use product-requirements-and-specs); language-level implementation (use production-grade-engineering); container/AKS delivery (use aks-gitlab-secure-cicd).'
argument-hint: 'Describe the system, expected scale and load, latency/availability targets, data needs, integration points, and constraints.'
user-invocable: true
disable-model-invocation: false
---

# Software Architecture and System Design

## When to Use
- Design the architecture for a new system, service, or major feature.
- Choose architectural style, component boundaries, and data ownership.
- Plan for scalability, availability, performance, and resilience.
- Document significant decisions and trade-offs in ADRs.

## Core Objective
Produce an architecture that meets functional and non-functional requirements, is justified by explicit trade-offs, and is maintainable and evolvable.

## Workflow

### 1. Establish drivers and constraints
Capture:
1. Functional scope and key use cases.
2. Non-functional drivers: throughput, latency, availability, consistency, security, cost.
3. Expected scale now and projected growth.
4. Integration points, external dependencies, and data sources.
5. Team, platform, and operational constraints.

Decision point:
- If consistency and transactions dominate, favor strong-consistency designs.
- If scale and decoupling dominate, consider event-driven or partitioned designs.

### 2. Choose an architectural style deliberately
Evaluate options against drivers:
- Modular monolith for simplicity, strong consistency, and small teams.
- Microservices for independent scaling, deployment, and team autonomy.
- Event-driven or streaming for decoupling, async workloads, and high throughput.
- Serverless for spiky, event-triggered, or low-ops workloads.

Avoid choosing a style by trend; justify it against the drivers.

### 3. Define components, boundaries, and contracts
- Identify components, responsibilities, and ownership.
- Define clear interfaces and API contracts (sync/async, request/response shapes, versioning).
- Establish data ownership and avoid shared mutable databases across services.
- Define failure boundaries, timeouts, retries, and idempotency.

### 4. Design the data layer
- Choose storage per access pattern: relational, document, key-value, search, vector, or analytics.
- Model for the dominant queries; plan partitioning and indexing.
- Define consistency model, caching strategy, and data lifecycle.
- Plan migrations, schema evolution, and backfills.

### 5. Plan for scale, resilience, and security
- Identify bottlenecks and scaling strategy (vertical, horizontal, partitioning).
- Add redundancy, health checks, graceful degradation, and backpressure.
- Design for failure: retries with backoff, circuit breakers, and timeouts.
- Apply least privilege, secure transport, secrets management, and threat modeling.

### 6. Record decisions and trade-offs
- Write ADRs capturing context, options considered, decision, and consequences.
- Make trade-offs explicit (e.g., consistency vs. availability, cost vs. latency).
- Diagram the system (context, container, component) at an appropriate level.

## Anti-Patterns to Avoid
- Choosing microservices or a trendy style without scale or autonomy drivers.
- Distributed monolith: services that must deploy together and share a database.
- Designing for hypothetical scale far beyond realistic needs (premature complexity).
- Undefined failure handling: no timeouts, retries, idempotency, or degradation plan.
- Shared mutable data stores that couple services and erase boundaries.
- Decisions with no recorded rationale, leaving trade-offs invisible to future teams.

## Decision Guide

### Use a modular monolith when
- The team is small, the domain is cohesive, and strong consistency matters.

### Use microservices when
- Components need independent scaling, deployment, or team ownership, and you can fund the operational overhead.

### Use event-driven design when
- Workloads are async, producers and consumers should be decoupled, or throughput is high.

### Write an ADR when
- A decision is hard to reverse, affects multiple teams, or trades off key qualities.

## Quality Criteria
A strong architecture should:
- Satisfy functional and non-functional drivers.
- Have clear boundaries, contracts, and data ownership.
- Handle failure, scale, and security by design.
- Make trade-offs explicit and recorded.
- Be understandable via diagrams and ADRs, and evolvable over time.

## Output Expectations
When invoked, this skill should help produce:
- An architecture design with components, boundaries, and contracts.
- A data and scaling strategy.
- A resilience and security plan.
- ADRs and architecture diagrams.

## Example Prompts to Try
- Design the architecture for a high-throughput order-processing system with ADRs.
- Compare modular monolith vs. microservices for this workload and recommend one.
- Design the data layer and scaling strategy for this read-heavy service.
- Write an ADR for choosing event-driven processing over synchronous calls.

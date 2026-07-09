---
name: fastapi-production-grade
description: 'Design and implement production-grade FastAPI applications in Python: API architecture, async patterns, Pydantic validation, dependency injection, security, testing, observability, deployment, and performance tuning. USE WHEN: build or refactor a FastAPI service, design REST endpoints or routers, add JWT or OAuth2 auth, structure a FastAPI project, or test and deploy a FastAPI API. DO NOT USE FOR: general non-FastAPI code quality and algorithms (use production-grade-engineering); RAG or agent design (use ai-agent-rag-and-prompt-design); container or AKS CI/CD (use aks-gitlab-secure-cicd).'
argument-hint: 'Describe the service goals, data model, auth needs, deployment target, and performance constraints.'
user-invocable: true
disable-model-invocation: false
---

# Production-Grade FastAPI Development

## When to Use
- Build or refactor Python REST APIs with FastAPI.
- Design reliable, secure, and scalable API services.
- Improve validation, dependency injection, async I/O, testing, or deployment readiness.
- Prepare FastAPI apps for production environments, CI/CD, and monitoring.

## Core Objective
Create FastAPI applications that are maintainable, secure, observable, testable, and performant under real production load.

## Workflow

### 1. Define the service contract
Start by clarifying:
1. The business capability the API must provide.
2. The expected request/response schemas.
3. Authentication, authorization, and data sensitivity requirements.
4. Performance targets such as latency, throughput, and concurrency.
5. Deployment target, including containers, serverless, or VM hosting.

Decision point:
- If the API is public or customer-facing, prioritize authentication, rate limiting, input validation, and audit logging.
- If the API is internal or low-latency, focus on reliability, observability, and connection pooling.

### 2. Set up a production-ready project structure
Use a clean layout that separates concerns:
- `app/main.py` for app creation and router inclusion.
- `app/api/` for endpoint modules.
- `app/core/` for settings, logging, security, exceptions, and middleware.
- `app/services/` for domain logic.
- `app/models/` and `app/schemas/` for data and contract validation.
- `app/db/` for database access or session management.
- `tests/` for unit, integration, and API tests.

Recommended practices:
- Use environment-based configuration with Pydantic settings.
- Keep startup logic explicit and dependency-based.
- Avoid business logic inside route handlers.

### 3. Design models and validation carefully
Use Pydantic models for request and response contracts.

Best practices:
- Use strict types, enums, and constrained fields.
- Separate input DTOs from output DTOs when needed.
- Validate boundaries, file sizes, pagination, and IDs early.
- Use aliases, examples, and descriptions for API documentation quality.

Decision point:
- If the model is used across layers, keep it stable and version-aware.
- If the payload is large or complex, use nested models and clear field constraints.

### 4. Use FastAPI features for maintainability
Apply the key FastAPI building blocks:
- Dependency injection for shared logic and database sessions.
- APIRouter for modular endpoint organization.
- Background tasks or queue integration for non-blocking work.
- Response models and status codes for clear contracts.
- Query parameters and path parameters with validation.

Design rules:
- Keep endpoints thin and orchestration-focused.
- Centralize repeated logic through dependencies and helpers.
- Use consistent error handling with domain-specific exceptions.

### 5. Choose async patterns correctly
FastAPI is built on async Python, but not every workload should be async.

Use async when:
- The code performs I/O bound work such as database calls, HTTP requests, or file access.
- The service handles many concurrent requests.

Use sync code when:
- The operation is CPU-bound and not suitable for event-loop concurrency.
- The library does not support async usage well.

Decision point:
- If using PostgreSQL, prefer async drivers and connection pooling for higher throughput.
- If the workload is simple and CPU-bound, keep the implementation straightforward and benchmark before changing to async.

### 6. Build security into the API from the start
Production-grade FastAPI APIs should include:
- Authentication and authorization using OAuth2, JWT, or managed identity where appropriate.
- Input validation and output sanitization.
- CORS and trusted host configuration for web exposure.
- Rate limiting or abuse protection for public endpoints.
- Secret handling with environment variables or secret stores.
- Dependency-aware access checks for sensitive resources.

Decision point:
- If the service handles sensitive or regulated data, require stronger identity checks, audit trails, and encryption at rest/in transit.

### 7. Add observability and reliability
Implement:
- Structured logging with request IDs and correlation context.
- Metrics for latency, error rate, and throughput.
- Health checks and readiness/liveness endpoints.
- Exception handling with consistent error responses.
- Tracing support for downstream calls and database operations.

Decision point:
- If the service is critical, add dashboards, alerts, and retry policies for external dependencies.
- If the service is internal, keep the observability surface minimal but reliable.

### 8. Test the API as a real system
Use a layered test approach:
- Unit tests for service logic and validation rules.
- Integration tests for database interactions and dependencies.
- API tests using `TestClient` for request/response behavior.
- Contract tests for schema stability.

Quality checks:
- Validate success and failure paths.
- Cover auth, pagination, validation errors, and edge cases.
- Add performance or load tests for critical endpoints.

### 9. Prepare for deployment and operations
Before release, confirm:
1. Environment variables and secrets are externalized.
2. The app starts cleanly with production settings.
3. Logging, metrics, and health endpoints are enabled.
4. Database migrations or startup initialization are automated.
5. The container image is small and secure.
6. CI/CD runs tests, linting, and security checks.

Decision point:
- If the service runs in containers, use multi-stage builds, non-root users, and dependency pinning.
- If the service runs serverless, minimize cold starts and keep dependencies lean.

## Anti-Patterns to Avoid
- Putting business logic inside route handlers instead of services and dependencies.
- Using `async def` around blocking, CPU-bound, or sync-only library calls (blocks the event loop).
- Sharing one Pydantic model for input and output, or skipping field constraints and validation.
- Returning raw ORM objects or leaking internal fields instead of explicit response models.
- Hard-coding secrets or config instead of Pydantic settings and secret stores.
- Missing health checks, structured logging, correlation IDs, and consistent error responses.
- Testing only happy paths and skipping auth, validation-error, and pagination cases.

## Decision Guide
- You need a modern Python API with automatic docs, type safety, and good developer ergonomics.
- The service is HTTP-based and benefits from validation and dependency injection.

### Use async database or I/O layers when
- The API handles many parallel requests or external network calls.
- Throughput and responsiveness are more important than simple synchronous code.

### Use Pydantic models heavily when
- The API contract must be precise and self-documenting.
- You need strong validation, serialization, and schema generation.

### Use dependency injection when
- The same logic appears in many endpoints.
- You want cleaner testing, shared session handling, and modular design.

## Quality Criteria
A production-grade FastAPI service should:
- Validate and document inputs and outputs clearly.
- Handle errors consistently and safely.
- Use async patterns only where they improve real performance.
- Keep endpoint logic thin and maintainable.
- Be observable, testable, and secure by default.
- Deploy predictably in CI/CD and production environments.

## Output Expectations
When this skill is used, it should help produce one of the following:
- A production-ready FastAPI architecture plan.
- A secure and scalable API implementation guide.
- A testing and observability checklist for a FastAPI service.
- A deployment-ready project structure and best-practice review.

## Example Prompts to Try
- Design a production-grade FastAPI service for user management with JWT auth.
- Refactor this FastAPI app to add dependency injection, validation, and tests.
- Improve the performance and observability of a FastAPI API with async database access.
- Create a secure FastAPI project structure for containerized deployment.

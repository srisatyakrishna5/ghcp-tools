---
name: fastapi-runtime
description: "Runtime guidance for common FastAPI work. Use for routes, dependencies, request and response models, middleware, and tests. Prefer this over the full FastAPI reference for routine tasks."
applyTo: "**/main.py,**/app.py,**/dependencies.py,**/exceptions.py,**/routers/**/*.py,**/routes/**/*.py,**/middleware/**/*.py,**/*api*.py"
---

# FastAPI Runtime

Use this skill for routine FastAPI work. Load the full `fastapi-patterns` reference only when this card is insufficient.

## Use For

* Routes and request handling
* Dependency injection
* Pydantic request and response models
* Exception handlers and middleware
* Endpoint-focused testing

## Core Rules

* Keep router, service, and repository concerns separate
* Validate at the API boundary with typed models
* Use dependency injection for external collaborators
* Use async only for real I/O work
* Keep handlers thin and move business logic into services

## Preferred Layout

```text
src/
  main.py
  dependencies.py
  exceptions.py
  routers/
  services/
  repositories/
  models/
```

## Minimal Checklist

* Inputs and outputs are typed
* Errors are mapped consistently
* Side effects live outside the router
* Tests cover the changed endpoint behavior

## Escalate to Full Reference When

* You need advanced middleware chains
* You need websockets or background tasks
* You are designing app startup or lifespan orchestration
* You need deeper auth or project-structure guidance
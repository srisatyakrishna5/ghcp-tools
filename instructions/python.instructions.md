---
description: 'Python coding standards for this workspace. Use when writing or refactoring Python (.py) code: typing, structure, error handling, security, and testing conventions.'
name: Python Standards
applyTo: "**/*.py"
---
# Python Standards

When writing Python in this workspace, apply these on top of the relevant skill
(`production-grade-engineering`, `advanced-production-engineering`, or `fastapi-production-grade`).

## Style & Structure
- Target Python 3.11+. Follow PEP 8; format with `black` and lint with `ruff`.
- Use full type hints on public functions and class attributes. Prefer `pydantic`
  models or `dataclasses` over loose dicts for structured data.
- Keep functions small and single-purpose; keep cyclomatic complexity low.
- Use explicit imports; no wildcard `from x import *`.

## Error Handling
- Catch specific exceptions, never bare `except:`. Re-raise with context where useful.
- Validate inputs at boundaries (API handlers, file/DB I/O); fail fast with clear messages.
- Use context managers (`with`) for files, locks, sessions, and connections.

## Security (OWASP-aligned)
- Never build SQL/shell/HTML by string concatenation; use parameterized queries and safe APIs.
- Never hardcode secrets; read from environment or a secret store.
- Validate and sanitize all external input. Avoid `eval`/`exec`/`pickle` on untrusted data.

## Testing
- Write `pytest` tests alongside code. Cover happy path, edges, and failure modes.
- Prefer dependency injection to enable mocking; avoid hidden global state.
- Keep tests deterministic and fast; isolate I/O behind interfaces.

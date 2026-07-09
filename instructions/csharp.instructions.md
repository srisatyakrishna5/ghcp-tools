---
description: 'C# / .NET coding standards for this workspace. Use when writing or refactoring .cs code: nullability, async, error handling, security, and testing conventions.'
name: C# / .NET Standards
applyTo: "**/*.cs"
---
# C# / .NET Standards

Apply these on top of the relevant skill (`production-grade-engineering` or
`advanced-production-engineering`). Target modern .NET (8+).

## Style & Structure
- Enable nullable reference types (`<Nullable>enable</Nullable>`) and treat warnings as errors.
- Follow standard C# conventions: PascalCase for types/methods, camelCase for locals/params.
- Prefer `readonly`/immutability, `record` types for data, and expression-bodied members where clear.
- Keep methods small and single-purpose; keep cyclomatic complexity low.
- Use dependency injection; avoid static mutable state and service locators.

## Async & Errors
- Use `async`/`await` end-to-end; never block with `.Result`/`.Wait()`. Pass `CancellationToken`.
- Catch specific exceptions; don't swallow them. Use `using`/`await using` for `IDisposable`.
- Validate inputs at boundaries (controllers, handlers, I/O) and fail fast with clear messages.

## Security (OWASP-aligned)
- Use parameterized queries / an ORM; never concatenate SQL. Encode output to prevent XSS.
- Never hardcode secrets; use configuration providers, Key Vault, or managed identity.
- Validate and sanitize all external input; avoid insecure deserialization.

## Testing
- Write xUnit (or NUnit) tests alongside code. Cover happy path, edges, and failures.
- Mock dependencies via interfaces; keep tests deterministic and isolated from external I/O.

---
description: 'TypeScript/JavaScript coding standards for this workspace. Use when writing or refactoring .ts/.tsx/.js/.jsx code: typing, async, error handling, security, and testing conventions.'
name: TypeScript & JavaScript Standards
applyTo: "**/*.ts, **/*.tsx, **/*.js, **/*.jsx"
---
# TypeScript & JavaScript Standards

Apply these on top of the relevant skill (`production-grade-engineering` or
`advanced-production-engineering`). Prefer TypeScript over plain JavaScript for new code.

## Style & Structure
- Enable `strict` mode in `tsconfig`. Avoid `any`; prefer precise types, generics, and `unknown`
  at boundaries with narrowing.
- Use `const`/`let` (never `var`). Prefer pure functions and small modules.
- Format with Prettier and lint with ESLint; fix warnings rather than suppressing them.
- Model data with explicit `interface`/`type`; validate external input with a schema (e.g. `zod`).

## Async & Errors
- Use `async/await`; always handle rejected promises. Don't leave floating promises.
- Throw `Error` (or subclasses) with messages; never throw strings.
- Validate inputs at boundaries (HTTP handlers, IPC, file/DB I/O) and fail fast.

## Security (OWASP-aligned)
- Never concatenate untrusted input into SQL, shell, or HTML; use parameterized queries
  and safe DOM APIs. Avoid `eval` and `new Function` on untrusted data.
- Never hardcode secrets; read from environment or a secret store.
- Sanitize/escape output to prevent XSS; set secure headers on servers.

## Testing
- Write tests with Jest or Vitest alongside code. Cover happy path, edges, and failures.
- Keep tests deterministic; mock network and time. Avoid shared mutable state between tests.

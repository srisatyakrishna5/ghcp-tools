---
description: "Shared coding standards enforced across all engineering agents — MANDATORY for all code generation and review"
applyTo: "**/*.ts,**/*.tsx,**/*.js,**/*.jsx,**/*.py,**/*.cs,**/*.java,**/*.go,**/*.rs"
---

# Coding Standards

> **Enforcement level: MANDATORY.** These rules are not suggestions. Every agent that writes, modifies, or reviews code MUST apply these standards. Violations must be caught in code review and fixed before delivery.

## SOLID Principles

- **Single Responsibility**: Each class/module has one reason to change. Extract concerns into dedicated units.
- **Open/Closed**: Design modules open for extension, closed for modification. Use abstractions, strategy patterns, or composition.
- **Liskov Substitution**: Subtypes must be substitutable for their base types without altering correctness.
- **Interface Segregation**: Prefer many small, focused interfaces over one large general-purpose interface.
- **Dependency Inversion**: Depend on abstractions, not concretions. Inject dependencies; never instantiate collaborators internally.

## Design Patterns

Apply patterns only when they solve a real problem. Prefer simplicity.

- **Creational**: Factory Method, Builder (for complex object construction), Singleton (only for true global state)
- **Structural**: Adapter, Decorator, Composite (for tree structures), Facade (to simplify subsystems)
- **Behavioral**: Strategy, Observer, Command, Chain of Responsibility

## Clean Code Principles

1. **Naming**: Use intention-revealing names. Avoid abbreviations. Classes = nouns, methods = verbs.
2. **Functions**: Keep functions small (< 20 lines preferred). Single level of abstraction per function.
3. **DRY**: Eliminate duplication. Extract shared logic into well-named helpers.
4. **YAGNI**: Do not build what is not needed today.
5. **Boy Scout Rule**: Leave code cleaner than you found it.
6. **Fail Fast**: Validate inputs at boundaries. Throw meaningful errors early.
7. **Immutability**: Prefer immutable data structures. Minimize mutable state.

## Complexity Management

- Cyclomatic complexity per function: target ≤ 10
- Cognitive complexity per function: target ≤ 15
- Maximum nesting depth: 3 levels
- Maximum parameters per function: 4 (use options objects for more)
- Maximum file length: 300 lines (split if exceeded)

## Error Handling

- Use typed/custom exceptions with contextual messages
- Never swallow exceptions silently
- Log at appropriate levels (error for failures, warn for recoverable issues, info for operations)
- Return meaningful error responses at API boundaries

## Security (OWASP Top 10 Awareness)

- Validate and sanitize all external inputs
- Use parameterized queries (never string concatenation for SQL)
- Apply principle of least privilege
- Never log secrets, tokens, or PII
- Use constant-time comparison for sensitive values

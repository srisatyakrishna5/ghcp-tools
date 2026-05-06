# GHCP Instructions, Skills & Agents

A curated collection of GitHub Copilot customization files that transform generic AI assistance into a precision engineering partner. These files encode team standards, domain expertise, and role-specific personas so that Copilot produces production-ready output aligned with your conventions — automatically.

## Repository Structure

```
├── agents/                          # Role-based AI personas
│   ├── architect.agent.md           # System design & architecture decisions
│   ├── code-reviewer.agent.md      # Quality gates & standards enforcement
│   ├── developer.agent.md          # Production-grade implementation
│   ├── devops-engineer.agent.md    # Docker, CI/CD, deployment
│   ├── documentation-engineer.agent.md  # Docs, docstrings, README
│   ├── prompt-engineer.agent.md    # LLM prompt optimization
│   ├── tech-lead.agent.md          # Team orchestrator & parallel execution
│   └── test-engineer.agent.md      # Automated testing & coverage
├── instructions/                    # Always-active coding rules
│   ├── coding-standards.instructions.md    # SOLID, clean code, complexity limits
│   ├── docker-standards.instructions.md    # Multi-stage builds, security hardening
│   ├── parallel-execution.instructions.md  # Automatic parallelization strategy
│   └── testing-standards.instructions.md   # Coverage targets, AAA pattern, mocking
├── skills/                          # Domain-specific knowledge
│   ├── agentic-ai-patterns/        # Multi-agent design, RAG, tool use, orchestration
│   ├── fastapi-patterns/           # Project structure, DI, Pydantic, middleware
│   ├── mongodb-patterns/           # Document modeling, aggregation, indexing
│   └── postgres-patterns/          # Schema design, query optimization, migrations
```

## How It Works

### Instructions

Declarative rules that apply automatically based on file patterns. They enforce non-negotiable standards without requiring explicit prompts.

| File | Scope | What It Enforces |
|------|-------|-----------------|
| `coding-standards` | All source code | SOLID principles, naming conventions, complexity ≤ 10, functions < 20 lines, max 4 params |
| `testing-standards` | Test files | 80% coverage minimum, AAA structure, isolation, determinism |
| `docker-standards` | Dockerfiles & Compose | Multi-stage builds, non-root user, health checks, < 100MB images |
| `parallel-execution` | All workflows | Automatic parallelization of independent tasks across agents |

### Skills

Deep, curated knowledge documents that provide the *correct* patterns for specific technologies — replacing the noisy, often-outdated patterns from general training data.

| Skill | Key Patterns |
|-------|-------------|
| **Agentic AI** | Complexity spectrum, augmented LLM architecture, reflection/planning/tool-use patterns, multi-agent orchestration, memory systems, RAG pipelines |
| **FastAPI** | Application factory, dependency injection, router organization, Pydantic request/response models, middleware stack, background tasks |
| **MongoDB** | Embed vs. reference decision matrix, subset pattern, polymorphic pattern, bucket pattern, aggregation pipelines, Motor async driver |
| **PostgreSQL** | Naming conventions, standard column sets, indexing strategies, migration patterns, connection pooling, SQLAlchemy/asyncpg |

### Agents

Persona-driven specialists that approach problems from a specific engineering role's perspective. The Tech Lead orchestrates the team and automatically parallelizes independent work.

| Agent | Role | Key Capability |
|-------|------|---------------|
| **Tech Lead** | Orchestrator | Decomposes work, delegates to specialists, runs independent tasks in parallel |
| **Architect** | System Designer | Trade-off analysis, ADRs, module boundaries, API contracts |
| **Developer** | Implementer | Clean code, SOLID compliance, production-grade implementation |
| **Test Engineer** | Quality Assurer | Coverage strategies, edge case identification, test isolation |
| **Code Reviewer** | Quality Gate | Severity-graded findings (critical → suggestion), security review |
| **DevOps Engineer** | Infrastructure | Optimized Docker builds, CI/CD pipelines, deployment configs |
| **Documentation Engineer** | Knowledge Capture | Docstrings, README, API docs, architecture docs |
| **Prompt Engineer** | AI Optimizer | Deterministic prompts, token reduction, output format control |

## Installation: Hosting in Your Repository

GitHub Copilot automatically discovers agents, instructions, and skills when they are placed inside the `.github/` folder at the root of your code repository. No configuration, no plugin installs — just the correct folder structure.

### Required Folder Structure

```
your-repo/
├── .github/
│   ├── agents/
│   │   ├── architect.agent.md
│   │   ├── code-reviewer.agent.md
│   │   ├── developer.agent.md
│   │   ├── devops-engineer.agent.md
│   │   ├── documentation-engineer.agent.md
│   │   ├── prompt-engineer.agent.md
│   │   ├── tech-lead.agent.md
│   │   └── test-engineer.agent.md
│   ├── instructions/
│   │   ├── coding-standards.instructions.md
│   │   ├── docker-standards.instructions.md
│   │   ├── parallel-execution.instructions.md
│   │   └── testing-standards.instructions.md
│   └── skills/
│       ├── agentic-ai-patterns/
│       │   └── SKILL.md
│       ├── fastapi-patterns/
│       │   └── SKILL.md
│       ├── mongodb-patterns/
│       │   └── SKILL.md
│       └── postgres-patterns/
│           └── SKILL.md
├── src/
└── ...
```

### How to Set Up

1. Create a `.github/` folder at the root of your repository (if it doesn't already exist).
2. Copy the `agents/` folder into `.github/agents/`. Each file must have the `.agent.md` extension. Copilot will detect them and make them available as invocable agents in chat (e.g., `@developer`, `@tech-lead`).
3. Copy the `instructions/` folder into `.github/instructions/`. Each file must have the `.instructions.md` extension. Copilot loads these automatically based on the `applyTo` glob pattern in the file's YAML frontmatter — no manual invocation needed.
4. Copy the `skills/` folder into `.github/skills/`. Each skill lives in its own subfolder and the file must be named `SKILL.md`. Copilot loads them on demand when it detects relevant technology context matching the skill's description or `applyTo` pattern.
5. Commit and push. Every developer who clones the repository automatically gets these customizations — no local setup required.

### Key Points

- The `.github/` folder must be at the repository root — not nested inside `src/` or any other directory.
- Instructions with an `applyTo` pattern (e.g., `**/*.py`) activate only when Copilot is working on files matching that pattern.
- Agents become available in GitHub Copilot Chat and can be invoked by their filename prefix (without the `.agent.md` suffix).
- Changes to these files take effect immediately after saving — no restart or rebuild required.
- This works across all team members — one setup benefits everyone who uses the repository.

## Getting Started

1. **Fork or clone** this repository and copy the `.github/` folder into your project root
2. **Instructions activate automatically** based on `applyTo` file patterns — no manual invocation needed
3. **Invoke agents** by referencing them in Copilot Chat (e.g., `@tech-lead implement a user service`)
4. **Skills load on demand** when Copilot detects relevant technology context

## Parallel Execution

The Tech Lead agent and the `parallel-execution` instruction enforce automatic parallelism:

- Independent modules are implemented simultaneously
- Tests, docs, and DevOps configs run in parallel after implementation
- Only true data dependencies (architecture → code → review) are serialized
- No explicit user request needed — parallelization is the default behavior

## Customization

- Add new skills by creating a folder under `skills/` with a `SKILL.md` file
- Add new instructions by creating `.instructions.md` files with `applyTo` patterns
- Add new agents by creating `.agent.md` files with role descriptions and workflows
- Modify complexity thresholds, coverage targets, or conventions to match your team's standards

---
description: "Docker and containerization standards for multi-stage builds — MANDATORY for all container work"
applyTo: "**/Dockerfile,**/Dockerfile.*,**/docker-compose*.yml,**/docker-compose*.yaml"
---

# Docker Standards

> **Enforcement level: MANDATORY.** These rules are not suggestions. Every agent that creates or modifies Dockerfiles and docker-compose configs MUST apply these standards. Violations must be caught in review and fixed before delivery.

## Multi-Stage Build Pattern

All production Dockerfiles MUST use multi-stage builds to minimize image size and attack surface.

### Stage Naming Convention

```dockerfile
FROM <base> AS deps        # dependency installation
FROM <base> AS build       # compilation/transpilation
FROM <base> AS test        # run tests (optional, for CI)
FROM <base> AS production  # final minimal runtime image
```

### Principles

1. **Minimal final image**: Use distroless, alpine, or slim variants for production stage
2. **Layer caching**: Order instructions from least-frequently-changed to most-frequently-changed
3. **No dev dependencies in production**: Only copy runtime artifacts to final stage
4. **Non-root user**: Always run as non-root in production stage
5. **Health checks**: Include HEALTHCHECK instruction for orchestrator awareness
6. **.dockerignore**: Always include to exclude node_modules, .git, test files, docs

### Node.js Template

```dockerfile
# Stage 1: Dependencies
FROM node:20-alpine AS deps
WORKDIR /app
COPY package.json pnpm-lock.yaml ./
RUN corepack enable && pnpm install --frozen-lockfile

# Stage 2: Build
FROM node:20-alpine AS build
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .
RUN pnpm build

# Stage 3: Production
FROM node:20-alpine AS production
RUN addgroup -g 1001 -S appgroup && adduser -S appuser -u 1001 -G appgroup
WORKDIR /app
COPY --from=build /app/dist ./dist
COPY --from=deps /app/node_modules ./node_modules
COPY package.json ./
USER appuser
EXPOSE 3000
HEALTHCHECK --interval=30s --timeout=3s CMD wget -qO- http://localhost:3000/health || exit 1
CMD ["node", "dist/index.js"]
```

### Python Template

```dockerfile
# Stage 1: Build
FROM python:3.12-slim AS build
WORKDIR /app
COPY pyproject.toml uv.lock ./
RUN pip install uv && uv sync --frozen --no-dev

# Stage 2: Production
FROM python:3.12-slim AS production
RUN groupadd -r appgroup && useradd -r -g appgroup appuser
WORKDIR /app
COPY --from=build /app/.venv ./.venv
COPY src/ ./src/
ENV PATH="/app/.venv/bin:$PATH"
USER appuser
EXPOSE 8000
HEALTHCHECK --interval=30s --timeout=3s CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8000/health')" || exit 1
CMD ["python", "-m", "uvicorn", "src.main:app", "--host", "0.0.0.0", "--port", "8000"]
```

### Security Hardening

- Pin base image digests for reproducibility in CI
- Scan images with `trivy` or `grype` before publishing
- Never copy secrets into image layers (use runtime env vars or mounted secrets)
- Remove package managers and shells in distroless images
- Set `LABEL` metadata (maintainer, version, description)

### Optimization

- Combine RUN commands to reduce layers
- Use `--mount=type=cache` for package manager caches
- Target < 100MB for service images where possible
- Use `.dockerignore` aggressively

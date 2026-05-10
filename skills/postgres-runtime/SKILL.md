---
name: postgres-runtime
description: "Runtime guidance for common PostgreSQL work. Use for schema updates, queries, repositories, and migrations. Prefer this over the full PostgreSQL reference for routine tasks."
applyTo: "**/*.sql,**/alembic/**/*.py,**/migrations/**/*.py,**/*repo*.py,**/*repository*.py,**/*query*.py,**/*db*.py"
---

# PostgreSQL Runtime

Use this skill for routine PostgreSQL work. Load the full `postgres-patterns` reference only when this card is insufficient.

## Use For

* Schema design and migrations
* Query and repository code
* Indexing decisions for known access patterns
* SQLAlchemy or asyncpg integration

## Core Rules

* Prefer simple schemas and explicit constraints
* Index only proven query paths
* Use parameterized queries only
* Keep transactions short and explicit
* Separate migration logic from application logic

## Minimal Checklist

* Naming is consistent
* Query paths match indexes
* Error handling is explicit at the boundary
* Migrations are reversible when practical

## Escalate to Full Reference When

* You need advanced indexing strategies
* You are evaluating partitioning or pooling trade-offs
* You need ORM-specific modeling guidance
* You are tuning complex queries or migrations
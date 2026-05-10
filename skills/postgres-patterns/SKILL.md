---
name: postgres-patterns
description: "Reference guide for PostgreSQL database patterns including schema design, query optimization, indexing strategies, migrations, connection pooling, and SQLAlchemy or asyncpg usage. Prefer postgres-runtime for routine work."
---

# PostgreSQL Patterns

> Reference skill. Prefer `#file:skills/postgres-runtime/SKILL.md` for routine work. Load this full reference only when you need detailed schema, indexing, migration, or ORM guidance.

## Schema Design Principles

### Naming Conventions
- Tables: `snake_case`, plural nouns (`users`, `order_items`)
- Columns: `snake_case`, descriptive (`created_at`, `is_active`)
- Primary keys: `id` (UUID preferred for distributed systems, BIGSERIAL for simplicity)
- Foreign keys: `{referenced_table_singular}_id` (e.g., `user_id`)
- Indexes: `ix_{table}_{columns}` (e.g., `ix_users_email`)
- Unique constraints: `uq_{table}_{columns}`
- Check constraints: `ck_{table}_{description}`

### Standard Column Set

Every table should include:

```sql
CREATE TABLE {table_name} (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    -- domain columns here
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at TIMESTAMPTZ  -- soft delete (NULL = active)
);
```

### Data Types

| Use Case | Type | Rationale |
|----------|------|-----------|
| Identifiers | `UUID` | Globally unique, no sequence contention |
| Timestamps | `TIMESTAMPTZ` | Always store with timezone |
| Money | `NUMERIC(19, 4)` | Exact decimal arithmetic |
| Status/enum | `TEXT` with CHECK | Flexible, no DDL for new values |
| JSON data | `JSONB` | Indexable, compressed |
| Short text | `VARCHAR(n)` | Enforce max length at DB level |
| Long text | `TEXT` | Unbounded text |
| Boolean | `BOOLEAN` | NOT NULL with default |
| IP address | `INET` | Native type with operators |

## Indexing Strategy

### When to Create Indexes

```sql
-- Columns in WHERE clauses (high selectivity)
CREATE INDEX ix_users_email ON users (email);

-- Foreign key columns (JOIN performance)
CREATE INDEX ix_orders_user_id ON orders (user_id);

-- Columns in ORDER BY
CREATE INDEX ix_orders_created_at ON orders (created_at DESC);

-- Composite for multi-column queries (order matters!)
CREATE INDEX ix_orders_user_status ON orders (user_id, status);

-- Partial index for filtered queries
CREATE INDEX ix_orders_active ON orders (created_at)
WHERE deleted_at IS NULL;

-- GIN index for JSONB containment queries
CREATE INDEX ix_users_metadata ON users USING GIN (metadata);

-- GIN index for full-text search
CREATE INDEX ix_articles_search ON articles USING GIN (to_tsvector('english', title || ' ' || body));
```

### Index Anti-Patterns

- Do NOT index low-cardinality columns alone (`is_active`, `status` with few values)
- Do NOT create indexes on every column "just in case"
- Do NOT use indexes on small tables (< 1000 rows)
- Do NOT forget: indexes slow down writes

### Covering Indexes (Index-Only Scans)

```sql
-- Include columns to avoid table heap lookup
CREATE INDEX ix_orders_user_summary ON orders (user_id)
INCLUDE (status, total_amount, created_at);
```

## Query Optimization

### EXPLAIN ANALYZE Workflow

```sql
EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
SELECT * FROM orders WHERE user_id = $1 AND status = 'active';
```

Look for:
- `Seq Scan` on large tables → needs index
- `Nested Loop` with large outer set → consider `Hash Join`
- `Sort` without index → add index on ORDER BY columns
- High `Buffers: shared read` → data not in cache

### Common Query Patterns

```sql
-- Pagination (keyset/cursor-based — preferred over OFFSET)
SELECT id, name, created_at
FROM users
WHERE created_at < $1  -- cursor from previous page
ORDER BY created_at DESC
LIMIT 20;

-- Batch upsert
INSERT INTO metrics (key, value, recorded_at)
VALUES (unnest($1::text[]), unnest($2::numeric[]), unnest($3::timestamptz[]))
ON CONFLICT (key, recorded_at)
DO UPDATE SET value = EXCLUDED.value;

-- Aggregate with window function
SELECT
    user_id,
    amount,
    SUM(amount) OVER (PARTITION BY user_id ORDER BY created_at) AS running_total
FROM transactions;

-- Recursive CTE (tree/hierarchy traversal)
WITH RECURSIVE org_tree AS (
    SELECT id, name, parent_id, 0 AS depth
    FROM departments
    WHERE parent_id IS NULL
    UNION ALL
    SELECT d.id, d.name, d.parent_id, t.depth + 1
    FROM departments d
    JOIN org_tree t ON d.parent_id = t.id
)
SELECT * FROM org_tree;
```

### Avoid These Anti-Patterns

- `SELECT *` — always list needed columns
- `OFFSET` for deep pagination — use keyset pagination
- Implicit casting in WHERE (`WHERE id = '123'` when `id` is int)
- `NOT IN (subquery)` — use `NOT EXISTS` instead
- Functions on indexed columns in WHERE (`WHERE LOWER(email) = ...`) — use expression index

## Connection Pooling

### asyncpg Pool Configuration

```python
import asyncpg

async def create_db_pool(database_url: str) -> asyncpg.Pool:
    """Create connection pool with production-ready settings."""
    return await asyncpg.create_pool(
        database_url,
        min_size=5,           # Minimum idle connections
        max_size=20,          # Maximum connections
        max_inactive_connection_lifetime=300,  # Close idle after 5 min
        command_timeout=30,   # Query timeout
        statement_cache_size=100,  # Prepared statement cache
    )
```

### SQLAlchemy Async Engine

```python
from sqlalchemy.ext.asyncio import create_async_engine, async_sessionmaker, AsyncSession

engine = create_async_engine(
    "postgresql+asyncpg://user:pass@host/db",
    pool_size=20,
    max_overflow=10,
    pool_pre_ping=True,        # Verify connections before use
    pool_recycle=3600,         # Recycle connections hourly
    echo=False,                # Set True for SQL debugging
)

AsyncSessionLocal = async_sessionmaker(
    engine,
    class_=AsyncSession,
    expire_on_commit=False,
)


async def get_session() -> AsyncSession:
    """Dependency that yields a session and handles rollback."""
    async with AsyncSessionLocal() as session:
        try:
            yield session
            await session.commit()
        except Exception:
            await session.rollback()
            raise
```

## SQLAlchemy Models (Declarative)

```python
from datetime import datetime
from uuid import uuid4
from sqlalchemy import String, Boolean, DateTime, func
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import DeclarativeBase, Mapped, mapped_column, relationship


class Base(DeclarativeBase):
    """Shared base for all models."""
    pass


class TimestampMixin:
    """Mixin adding created_at and updated_at columns."""

    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), onupdate=func.now(), nullable=False
    )


class SoftDeleteMixin:
    """Mixin for soft delete pattern."""

    deleted_at: Mapped[datetime | None] = mapped_column(
        DateTime(timezone=True), nullable=True, default=None
    )

    @property
    def is_deleted(self) -> bool:
        return self.deleted_at is not None


class User(Base, TimestampMixin, SoftDeleteMixin):
    """User account model."""

    __tablename__ = "users"

    id: Mapped[str] = mapped_column(
        UUID(as_uuid=False), primary_key=True, default=lambda: str(uuid4())
    )
    email: Mapped[str] = mapped_column(String(255), unique=True, nullable=False, index=True)
    name: Mapped[str] = mapped_column(String(100), nullable=False)
    is_active: Mapped[bool] = mapped_column(Boolean, default=True, nullable=False)

    # Relationships
    orders: Mapped[list["Order"]] = relationship(back_populates="user", lazy="selectin")
```

## Repository Pattern

```python
from sqlalchemy import select, and_
from sqlalchemy.ext.asyncio import AsyncSession
from src.models.db import User


class UserRepository:
    """Data access layer for users."""

    def __init__(self, session: AsyncSession) -> None:
        self._session = session

    async def find_by_id(self, user_id: str) -> User | None:
        """Find active user by ID."""
        stmt = select(User).where(
            and_(User.id == user_id, User.deleted_at.is_(None))
        )
        result = await self._session.execute(stmt)
        return result.scalar_one_or_none()

    async def find_by_email(self, email: str) -> User | None:
        """Find active user by email."""
        stmt = select(User).where(
            and_(User.email == email, User.deleted_at.is_(None))
        )
        result = await self._session.execute(stmt)
        return result.scalar_one_or_none()

    async def create(self, data: dict) -> User:
        """Insert a new user."""
        user = User(**data)
        self._session.add(user)
        await self._session.flush()  # Get ID without committing
        return user

    async def soft_delete(self, user_id: str) -> bool:
        """Soft delete a user by setting deleted_at."""
        user = await self.find_by_id(user_id)
        if not user:
            return False
        user.deleted_at = func.now()
        return True
```

## Migration Strategy (Alembic)

### Setup
```bash
alembic init migrations
```

### Migration Best Practices

1. **One concern per migration** — Don't mix schema changes with data migrations
2. **Always include downgrade** — Rollback must be possible
3. **Non-blocking migrations** — Use `CONCURRENTLY` for index creation on large tables
4. **Backward compatible** — New columns must be nullable or have defaults
5. **Test migrations** — Run upgrade + downgrade in CI

```python
# migrations/versions/001_add_users_table.py
"""Create users table."""

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects.postgresql import UUID

revision = "001"
down_revision = None


def upgrade() -> None:
    op.create_table(
        "users",
        sa.Column("id", UUID(as_uuid=False), primary_key=True),
        sa.Column("email", sa.String(255), nullable=False),
        sa.Column("name", sa.String(100), nullable=False),
        sa.Column("is_active", sa.Boolean(), nullable=False, server_default="true"),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.func.now()),
        sa.Column("updated_at", sa.DateTime(timezone=True), server_default=sa.func.now()),
        sa.Column("deleted_at", sa.DateTime(timezone=True), nullable=True),
    )
    op.create_index("ix_users_email", "users", ["email"], unique=True)


def downgrade() -> None:
    op.drop_index("ix_users_email")
    op.drop_table("users")
```

### Zero-Downtime Migration Pattern

```sql
-- Step 1: Add nullable column (non-blocking)
ALTER TABLE users ADD COLUMN phone VARCHAR(20);

-- Step 2: Backfill in batches (separate migration or script)
UPDATE users SET phone = 'unknown' WHERE phone IS NULL AND id BETWEEN $1 AND $2;

-- Step 3: Add constraint (after backfill complete)
ALTER TABLE users ALTER COLUMN phone SET NOT NULL;
ALTER TABLE users ALTER COLUMN phone SET DEFAULT 'unknown';
```

## Performance Tuning

### Key `postgresql.conf` Settings (Production)

```ini
# Memory
shared_buffers = '25% of RAM'         # e.g., 4GB for 16GB server
effective_cache_size = '75% of RAM'   # OS + shared_buffers cache estimate
work_mem = '64MB'                     # Per-operation sort/hash memory
maintenance_work_mem = '512MB'        # VACUUM, CREATE INDEX

# WAL
wal_buffers = '64MB'
checkpoint_completion_target = 0.9
max_wal_size = '2GB'

# Query Planning
random_page_cost = 1.1               # SSD storage
effective_io_concurrency = 200       # SSD storage
default_statistics_target = 100

# Connections
max_connections = 200                # Use pgbouncer for > 200 clients
```

### Monitoring Queries

```sql
-- Slow queries (requires pg_stat_statements)
SELECT query, calls, mean_exec_time, total_exec_time
FROM pg_stat_statements
ORDER BY mean_exec_time DESC
LIMIT 20;

-- Index usage
SELECT relname, indexrelname, idx_scan, idx_tup_read
FROM pg_stat_user_indexes
ORDER BY idx_scan ASC;  -- Low scans = potentially unused index

-- Table bloat estimate
SELECT relname, n_dead_tup, last_autovacuum
FROM pg_stat_user_tables
ORDER BY n_dead_tup DESC;

-- Active locks
SELECT pid, relation::regclass, mode, granted
FROM pg_locks
WHERE NOT granted;
```

## Key Conventions

1. **Always use parameterized queries** — Never string-concatenate user input into SQL
2. **Use transactions explicitly** — Wrap multi-statement operations in transactions
3. **Prefer keyset pagination** — Avoid OFFSET for large datasets
4. **Index foreign keys** — Every FK column gets an index
5. **TIMESTAMPTZ everywhere** — Never use `TIMESTAMP` without timezone
6. **UUID for distributed IDs** — Avoid integer sequences in microservices
7. **Soft delete by default** — Use `deleted_at` column, filter in queries
8. **Connection pooling mandatory** — Never connect directly from app to PostgreSQL in production

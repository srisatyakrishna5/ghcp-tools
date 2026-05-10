---
name: fastapi-patterns
description: "Reference guide for advanced FastAPI application patterns including dependency injection, Pydantic models, middleware, authentication, and project structure. Prefer fastapi-runtime for routine work."
---

# FastAPI Patterns

> Reference skill. Prefer `#file:skills/fastapi-runtime/SKILL.md` for routine work. Load this full reference only when you need deeper patterns, larger examples, or advanced framework features.

## Project Structure

```
src/
├── main.py                 # Application factory, lifespan events
├── config.py               # Settings via pydantic-settings
├── dependencies.py         # Shared dependency providers
├── exceptions.py           # Custom exception classes + handlers
├── middleware/
│   ├── __init__.py
│   ├── correlation_id.py   # Request correlation tracking
│   ├── logging.py          # Structured request/response logging
│   └── timing.py           # Response time headers
├── models/
│   ├── __init__.py
│   ├── base.py             # Shared base models
│   ├── requests.py         # Request body schemas
│   └── responses.py        # Response envelope schemas
├── routers/
│   ├── __init__.py
│   ├── health.py           # Health/readiness endpoints
│   └── v1/
│       ├── __init__.py
│       └── {domain}.py     # Domain-specific routes
├── services/
│   ├── __init__.py
│   └── {domain}_service.py # Business logic layer
├── repositories/
│   ├── __init__.py
│   └── {domain}_repo.py    # Data access layer
└── utils/
    ├── __init__.py
    └── pagination.py       # Shared utilities
```

## Application Factory Pattern

```python
from contextlib import asynccontextmanager
from fastapi import FastAPI
from src.config import get_settings
from src.routers import health, v1
from src.middleware.correlation_id import CorrelationIdMiddleware
from src.middleware.logging import LoggingMiddleware
from src.exceptions import register_exception_handlers


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Manage application startup and shutdown resources."""
    # Startup: initialize pools, connections, caches
    settings = get_settings()
    app.state.db_pool = await create_db_pool(settings.database_url)
    yield
    # Shutdown: clean up resources
    await app.state.db_pool.close()


def create_app() -> FastAPI:
    """Application factory for FastAPI."""
    settings = get_settings()

    app = FastAPI(
        title=settings.app_name,
        version=settings.app_version,
        docs_url="/docs" if settings.debug else None,
        redoc_url=None,
        lifespan=lifespan,
    )

    # Middleware (order matters — outermost first)
    app.add_middleware(CorrelationIdMiddleware)
    app.add_middleware(LoggingMiddleware)

    # Exception handlers
    register_exception_handlers(app)

    # Routers
    app.include_router(health.router)
    app.include_router(v1.router, prefix="/api/v1")

    return app
```

## Configuration with pydantic-settings

```python
from functools import lru_cache
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """Application settings loaded from environment variables."""

    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        case_sensitive=False,
    )

    app_name: str = "MyService"
    app_version: str = "0.1.0"
    debug: bool = False

    # Database
    database_url: str
    db_pool_min_size: int = 5
    db_pool_max_size: int = 20

    # Auth
    jwt_secret: str
    jwt_algorithm: str = "HS256"
    jwt_expiry_minutes: int = 30


@lru_cache
def get_settings() -> Settings:
    """Cached settings instance (singleton per process)."""
    return Settings()
```

## Dependency Injection

```python
from typing import Annotated
from fastapi import Depends, Request
from src.config import Settings, get_settings
from src.repositories.user_repo import UserRepository
from src.services.user_service import UserService


# Settings dependency
SettingsDep = Annotated[Settings, Depends(get_settings)]


# Database session dependency
async def get_db_session(request: Request):
    """Yield a database session from the connection pool."""
    async with request.app.state.db_pool.acquire() as conn:
        yield conn


DbSessionDep = Annotated[AsyncSession, Depends(get_db_session)]


# Repository dependency (depends on session)
async def get_user_repository(session: DbSessionDep) -> UserRepository:
    """Provide UserRepository with injected session."""
    return UserRepository(session)


UserRepoDep = Annotated[UserRepository, Depends(get_user_repository)]


# Service dependency (depends on repository)
async def get_user_service(repo: UserRepoDep) -> UserService:
    """Provide UserService with injected repository."""
    return UserService(repo)


UserServiceDep = Annotated[UserService, Depends(get_user_service)]
```

## Pydantic Models

### Request/Response Patterns

```python
from datetime import datetime
from pydantic import BaseModel, Field, ConfigDict


# Base with shared config
class AppBaseModel(BaseModel):
    """Base model with shared configuration."""

    model_config = ConfigDict(
        from_attributes=True,       # Enable ORM mode
        str_strip_whitespace=True,  # Strip leading/trailing whitespace
        frozen=False,               # Mutable by default
    )


# Request models — validate inputs
class CreateUserRequest(AppBaseModel):
    """Request body for user creation."""

    email: str = Field(..., pattern=r"^[\w\.-]+@[\w\.-]+\.\w+$", max_length=255)
    name: str = Field(..., min_length=1, max_length=100)
    role: str = Field(default="viewer", pattern=r"^(admin|editor|viewer)$")


# Response models — control output shape
class UserResponse(AppBaseModel):
    """Public user representation."""

    id: str
    email: str
    name: str
    role: str
    created_at: datetime


# Envelope pattern for consistent API responses
class ApiResponse[T](AppBaseModel):
    """Standard API response wrapper."""

    data: T
    meta: dict | None = None


class PaginatedResponse[T](AppBaseModel):
    """Paginated list response."""

    data: list[T]
    total: int
    page: int
    page_size: int
    has_next: bool
```

## Router Pattern

```python
from fastapi import APIRouter, HTTPException, status
from src.dependencies import UserServiceDep
from src.models.requests import CreateUserRequest
from src.models.responses import ApiResponse, UserResponse

router = APIRouter(prefix="/users", tags=["users"])


@router.post(
    "/",
    response_model=ApiResponse[UserResponse],
    status_code=status.HTTP_201_CREATED,
    summary="Create a new user",
)
async def create_user(
    body: CreateUserRequest,
    service: UserServiceDep,
) -> ApiResponse[UserResponse]:
    """Create a new user account.

    Raises:
        HTTPException(409): If email already exists.
    """
    user = await service.create_user(body)
    return ApiResponse(data=UserResponse.model_validate(user))


@router.get(
    "/{user_id}",
    response_model=ApiResponse[UserResponse],
    summary="Get user by ID",
)
async def get_user(
    user_id: str,
    service: UserServiceDep,
) -> ApiResponse[UserResponse]:
    """Retrieve a user by their unique identifier."""
    user = await service.get_by_id(user_id)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"User {user_id} not found",
        )
    return ApiResponse(data=UserResponse.model_validate(user))
```

## Service Layer Pattern

```python
from src.models.requests import CreateUserRequest
from src.repositories.user_repo import UserRepository
from src.exceptions import ConflictError


class UserService:
    """Business logic for user operations."""

    def __init__(self, repository: UserRepository) -> None:
        self._repo = repository

    async def create_user(self, data: CreateUserRequest):
        """Create a user after validating business rules."""
        existing = await self._repo.find_by_email(data.email)
        if existing:
            raise ConflictError(f"Email {data.email} is already registered")

        return await self._repo.create(data.model_dump())

    async def get_by_id(self, user_id: str):
        """Retrieve user by ID."""
        return await self._repo.find_by_id(user_id)
```

## Exception Handling

```python
from fastapi import FastAPI, Request, status
from fastapi.responses import JSONResponse


class AppError(Exception):
    """Base application error."""

    def __init__(self, message: str, status_code: int = 500):
        self.message = message
        self.status_code = status_code
        super().__init__(message)


class NotFoundError(AppError):
    def __init__(self, message: str = "Resource not found"):
        super().__init__(message, status_code=404)


class ConflictError(AppError):
    def __init__(self, message: str = "Resource conflict"):
        super().__init__(message, status_code=409)


class ValidationError(AppError):
    def __init__(self, message: str = "Validation failed"):
        super().__init__(message, status_code=422)


def register_exception_handlers(app: FastAPI) -> None:
    """Register global exception handlers."""

    @app.exception_handler(AppError)
    async def app_error_handler(request: Request, exc: AppError) -> JSONResponse:
        return JSONResponse(
            status_code=exc.status_code,
            content={"error": {"message": exc.message, "type": type(exc).__name__}},
        )

    @app.exception_handler(Exception)
    async def unhandled_error_handler(request: Request, exc: Exception) -> JSONResponse:
        # Log the full traceback internally; return generic message
        import logging
        logging.exception("Unhandled exception")
        return JSONResponse(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            content={"error": {"message": "Internal server error", "type": "ServerError"}},
        )
```

## Authentication Pattern

```python
from typing import Annotated
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
import jwt
from src.config import get_settings

security = HTTPBearer()


async def get_current_user(
    credentials: Annotated[HTTPAuthorizationCredentials, Depends(security)],
) -> dict:
    """Decode and validate JWT token, return user claims."""
    settings = get_settings()
    try:
        payload = jwt.decode(
            credentials.credentials,
            settings.jwt_secret,
            algorithms=[settings.jwt_algorithm],
        )
        return payload
    except jwt.ExpiredSignatureError:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Token expired")
    except jwt.InvalidTokenError:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid token")


CurrentUserDep = Annotated[dict, Depends(get_current_user)]


def require_role(*roles: str):
    """Factory for role-based access control dependency."""
    async def check_role(user: CurrentUserDep) -> dict:
        if user.get("role") not in roles:
            raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Insufficient permissions")
        return user
    return Depends(check_role)
```

## Background Tasks

```python
from fastapi import BackgroundTasks

@router.post("/users/{user_id}/welcome")
async def send_welcome(
    user_id: str,
    background_tasks: BackgroundTasks,
    service: UserServiceDep,
):
    """Trigger welcome email asynchronously."""
    user = await service.get_by_id(user_id)
    background_tasks.add_task(send_welcome_email, user.email, user.name)
    return {"status": "queued"}
```

## Testing FastAPI Applications

```python
import pytest
from httpx import AsyncClient, ASGITransport
from src.main import create_app


@pytest.fixture
async def client():
    """Async test client with app lifespan."""
    app = create_app()
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as ac:
        yield ac


@pytest.mark.anyio
async def test_create_user_returns_201(client: AsyncClient):
    response = await client.post("/api/v1/users/", json={
        "email": "test@example.com",
        "name": "Test User",
    })
    assert response.status_code == 201
    assert response.json()["data"]["email"] == "test@example.com"


@pytest.mark.anyio
async def test_get_nonexistent_user_returns_404(client: AsyncClient):
    response = await client.get("/api/v1/users/nonexistent-id")
    assert response.status_code == 404
```

## Health Check Endpoint

```python
from fastapi import APIRouter, Request

router = APIRouter(tags=["health"])


@router.get("/health")
async def health():
    """Liveness probe — always returns 200 if process is running."""
    return {"status": "healthy"}


@router.get("/ready")
async def readiness(request: Request):
    """Readiness probe — verifies dependencies are reachable."""
    try:
        async with request.app.state.db_pool.acquire() as conn:
            await conn.execute("SELECT 1")
        return {"status": "ready"}
    except Exception:
        return JSONResponse(status_code=503, content={"status": "not ready"})
```

## Key Conventions

1. **Always use async** — All route handlers and service methods are `async`
2. **Type everything** — Use `Annotated` dependencies and typed return values
3. **Validate at the edge** — Pydantic models validate all inputs at router level
4. **Thin routes** — Routes orchestrate; business logic lives in services
5. **Repository pattern** — Data access abstracted behind repository interfaces
6. **No global state** — Use `app.state` or dependency injection for shared resources
7. **Structured errors** — Custom exceptions with consistent JSON error envelope

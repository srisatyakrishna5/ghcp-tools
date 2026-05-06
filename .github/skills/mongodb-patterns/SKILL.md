---
name: mongodb-patterns
description: "MongoDB patterns including schema design, aggregation pipelines, indexing, Motor async driver, document modeling, and ODM usage with Beanie/MongoEngine. WHEN: MongoDB schema, document modeling, aggregation pipeline, MongoDB indexes, Motor async, Beanie ODM, MongoEngine, MongoDB queries, embedded vs referenced, MongoDB performance."
applyTo: "**/*.py,**/*.ts,**/*.js"
---

# MongoDB Patterns

## Document Modeling Principles

### Embedding vs Referencing Decision Matrix

| Factor | Embed | Reference |
|--------|-------|-----------|
| Read together? | Always read together → embed | Read independently → reference |
| Update frequency | Rarely changes → embed | Frequently changes → reference |
| Document size | Stays under 16MB → embed | Could grow unbounded → reference |
| Cardinality | 1:few (< 100) → embed | 1:many or many:many → reference |
| Atomicity needed? | Must be atomic → embed | Eventual consistency OK → reference |
| Duplication acceptable? | Small, stable data → embed | Large, volatile data → reference |

### The Hybrid Approach (Subset Pattern)

```python
# Store frequently-accessed subset embedded, full data referenced
{
    "_id": ObjectId("..."),
    "title": "Product Name",
    "price": 29.99,
    # Embedded: top 3 recent reviews for display
    "recent_reviews": [
        {"user": "alice", "rating": 5, "text": "Great!", "date": "2024-01-15"},
        {"user": "bob", "rating": 4, "text": "Good value", "date": "2024-01-14"},
    ],
    "review_count": 142,
    # Full reviews in separate collection
}
```

## Schema Design Patterns

### 1. Polymorphic Pattern (Single Collection, Multiple Shapes)

```python
# events collection — different event types share base fields
{
    "_id": ObjectId("..."),
    "type": "page_view",
    "timestamp": ISODate("2024-01-15T10:30:00Z"),
    "user_id": "user_123",
    "url": "/products/widget",
    "referrer": "https://google.com"
}

{
    "_id": ObjectId("..."),
    "type": "purchase",
    "timestamp": ISODate("2024-01-15T10:35:00Z"),
    "user_id": "user_123",
    "items": [{"sku": "WDG-001", "qty": 2, "price": 29.99}],
    "total": 59.98
}
```

### 2. Bucket Pattern (Time Series)

```python
# sensor_readings — group readings by hour
{
    "_id": ObjectId("..."),
    "sensor_id": "temp_001",
    "bucket_start": ISODate("2024-01-15T10:00:00Z"),
    "bucket_end": ISODate("2024-01-15T11:00:00Z"),
    "count": 60,
    "readings": [
        {"ts": ISODate("2024-01-15T10:00:00Z"), "value": 22.5},
        {"ts": ISODate("2024-01-15T10:01:00Z"), "value": 22.6},
        # ... up to 60 per bucket
    ],
    "summary": {"min": 22.1, "max": 23.4, "avg": 22.7}
}
```

### 3. Attribute Pattern (Dynamic Fields)

```python
# products with variable attributes
{
    "_id": ObjectId("..."),
    "name": "Running Shoe",
    "category": "footwear",
    "attributes": [
        {"key": "color", "value": "blue"},
        {"key": "size", "value": "10"},
        {"key": "weight_grams", "value": 280},
        {"key": "waterproof", "value": True},
    ]
}
# Index: {"attributes.key": 1, "attributes.value": 1}
```

### 4. Outlier Pattern (Handle Exceptions)

```python
# Most users have < 50 followers (embed), celebrities have millions (overflow)
{
    "_id": "user_regular",
    "name": "Alice",
    "followers": ["bob", "charlie", "dave"],
    "has_overflow": False
}

{
    "_id": "user_celebrity",
    "name": "Famous Person",
    "followers": ["user1", "user2", ...],  # First 1000
    "has_overflow": True  # Signal to check overflow collection
}

# followers_overflow collection for outliers
{"user_id": "user_celebrity", "followers_batch": 2, "followers": [...]}
```

## Indexing Strategy

### Index Types and When to Use

```python
# Single field — most common queries
db.users.create_index("email", unique=True)

# Compound — multi-field queries (order matches query pattern)
db.orders.create_index([("user_id", 1), ("created_at", -1)])

# Multikey — array fields (automatic)
db.articles.create_index("tags")  # Works with tags: ["python", "mongodb"]

# Text — full-text search
db.articles.create_index([("title", "text"), ("body", "text")])

# TTL — auto-expire documents
db.sessions.create_index("expires_at", expireAfterSeconds=0)

# Partial — index subset of documents
db.orders.create_index(
    "created_at",
    partialFilterExpression={"status": "active"}
)

# Wildcard — dynamic/unpredictable field names
db.events.create_index({"metadata.$**": 1})
```

### Index Rules

1. **ESR Rule**: Equality → Sort → Range (order compound index fields this way)
2. **Covered queries**: Include all projected fields in index to avoid document fetch
3. **Selectivity first**: Most selective field goes first in compound index
4. **Max 1 multikey per compound**: Only one array field per compound index
5. **Index intersection**: MongoDB can combine multiple single-field indexes (but compound is faster)

### Check Index Usage

```javascript
// Identify unused indexes
db.collection.aggregate([
    { $indexStats: {} },
    { $match: { "accesses.ops": { $lt: 10 } } }
])

// Explain query plan
db.users.find({ email: "test@example.com" }).explain("executionStats")
```

## Aggregation Pipelines

### Common Pipeline Patterns

```python
# Group and compute statistics
pipeline = [
    {"$match": {"status": "completed", "created_at": {"$gte": start_date}}},
    {"$group": {
        "_id": "$category",
        "total_revenue": {"$sum": "$total"},
        "order_count": {"$sum": 1},
        "avg_order_value": {"$avg": "$total"},
    }},
    {"$sort": {"total_revenue": -1}},
    {"$limit": 10},
]

# Lookup (JOIN equivalent)
pipeline = [
    {"$match": {"user_id": user_id}},
    {"$lookup": {
        "from": "products",
        "localField": "product_id",
        "foreignField": "_id",
        "as": "product",
    }},
    {"$unwind": "$product"},
    {"$project": {
        "order_date": 1,
        "quantity": 1,
        "product_name": "$product.name",
        "unit_price": "$product.price",
        "total": {"$multiply": ["$quantity", "$product.price"]},
    }},
]

# Faceted search (multiple aggregations in one pass)
pipeline = [
    {"$match": {"$text": {"$search": query}}},
    {"$facet": {
        "results": [
            {"$skip": (page - 1) * page_size},
            {"$limit": page_size},
        ],
        "total_count": [{"$count": "count"}],
        "categories": [
            {"$group": {"_id": "$category", "count": {"$sum": 1}}},
            {"$sort": {"count": -1}},
        ],
    }},
]
```

### Pipeline Performance Tips

- Put `$match` and `$limit` as early as possible
- Use `$project` early to reduce document size through pipeline
- Avoid `$unwind` on large arrays when possible
- Use `allowDiskUse=True` for large datasets exceeding 100MB memory limit
- Create indexes that support `$match` and `$sort` stages

## Motor (Async Python Driver)

### Connection Setup

```python
from motor.motor_asyncio import AsyncIOMotorClient
from pymongo import ReadPreference


def create_mongo_client(connection_string: str) -> AsyncIOMotorClient:
    """Create Motor client with production settings."""
    return AsyncIOMotorClient(
        connection_string,
        maxPoolSize=50,
        minPoolSize=10,
        maxIdleTimeMS=300_000,          # Close idle connections after 5 min
        serverSelectionTimeoutMS=5_000,  # Fail fast if no server
        connectTimeoutMS=10_000,
        socketTimeoutMS=30_000,
        retryWrites=True,
        retryReads=True,
        readPreference=ReadPreference.SECONDARY_PREFERRED,  # Read from secondaries
    )


# Usage in FastAPI lifespan
@asynccontextmanager
async def lifespan(app: FastAPI):
    app.state.mongo = create_mongo_client(settings.mongodb_url)
    app.state.db = app.state.mongo[settings.mongodb_database]
    yield
    app.state.mongo.close()
```

### CRUD Operations with Motor

```python
from motor.motor_asyncio import AsyncIOMotorCollection
from bson import ObjectId


class OrderRepository:
    """Data access for orders collection."""

    def __init__(self, collection: AsyncIOMotorCollection) -> None:
        self._collection = collection

    async def find_by_id(self, order_id: str) -> dict | None:
        """Find order by ID."""
        return await self._collection.find_one(
            {"_id": ObjectId(order_id), "deleted_at": None}
        )

    async def find_by_user(
        self, user_id: str, *, page: int = 1, page_size: int = 20
    ) -> list[dict]:
        """Find orders for a user with cursor-based pagination."""
        cursor = self._collection.find(
            {"user_id": user_id, "deleted_at": None}
        ).sort("created_at", -1).skip((page - 1) * page_size).limit(page_size)
        return await cursor.to_list(length=page_size)

    async def create(self, data: dict) -> str:
        """Insert a new order, return its ID."""
        data["created_at"] = datetime.utcnow()
        data["updated_at"] = datetime.utcnow()
        result = await self._collection.insert_one(data)
        return str(result.inserted_id)

    async def update(self, order_id: str, updates: dict) -> bool:
        """Update order fields."""
        result = await self._collection.update_one(
            {"_id": ObjectId(order_id)},
            {"$set": {**updates, "updated_at": datetime.utcnow()}}
        )
        return result.modified_count > 0

    async def soft_delete(self, order_id: str) -> bool:
        """Soft delete by setting deleted_at."""
        result = await self._collection.update_one(
            {"_id": ObjectId(order_id)},
            {"$set": {"deleted_at": datetime.utcnow()}}
        )
        return result.modified_count > 0
```

## Beanie ODM (Recommended for FastAPI)

```python
from beanie import Document, Indexed, init_beanie
from pydantic import Field
from datetime import datetime


class User(Document):
    """User document model."""

    email: Indexed(str, unique=True)
    name: str = Field(max_length=100)
    role: str = Field(default="viewer")
    is_active: bool = True
    metadata: dict = Field(default_factory=dict)
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)
    deleted_at: datetime | None = None

    class Settings:
        name = "users"  # Collection name
        indexes = [
            [("role", 1), ("created_at", -1)],  # Compound index
        ]

    class Config:
        json_schema_extra = {
            "example": {
                "email": "user@example.com",
                "name": "John Doe",
                "role": "editor",
            }
        }


# Initialize Beanie with document models
async def init_db(mongo_client, database_name: str):
    await init_beanie(
        database=mongo_client[database_name],
        document_models=[User],
    )


# Repository using Beanie
class UserRepository:
    async def find_by_email(self, email: str) -> User | None:
        return await User.find_one(
            User.email == email,
            User.deleted_at == None,
        )

    async def find_active(self, page: int, size: int) -> list[User]:
        return await User.find(
            User.deleted_at == None,
            User.is_active == True,
        ).sort(-User.created_at).skip((page - 1) * size).limit(size).to_list()

    async def create(self, user: User) -> User:
        return await user.insert()

    async def update_fields(self, user_id: str, updates: dict) -> None:
        await User.find_one(User.id == user_id).update(
            {"$set": {**updates, "updated_at": datetime.utcnow()}}
        )
```

## Transaction Patterns

```python
async def transfer_funds(
    db: AsyncIOMotorDatabase,
    from_account_id: str,
    to_account_id: str,
    amount: float,
) -> bool:
    """Atomic fund transfer using multi-document transaction."""
    async with await db.client.start_session() as session:
        async with session.start_transaction():
            accounts = db["accounts"]

            # Debit source
            result = await accounts.update_one(
                {"_id": ObjectId(from_account_id), "balance": {"$gte": amount}},
                {"$inc": {"balance": -amount}},
                session=session,
            )
            if result.modified_count == 0:
                await session.abort_transaction()
                return False

            # Credit destination
            await accounts.update_one(
                {"_id": ObjectId(to_account_id)},
                {"$inc": {"balance": amount}},
                session=session,
            )

            # Record transaction
            await db["transactions"].insert_one(
                {
                    "from": from_account_id,
                    "to": to_account_id,
                    "amount": amount,
                    "timestamp": datetime.utcnow(),
                },
                session=session,
            )

            return True
```

## Change Streams (Real-Time)

```python
async def watch_orders(collection: AsyncIOMotorCollection):
    """Watch for new orders in real-time."""
    pipeline = [
        {"$match": {"operationType": {"$in": ["insert", "update"]}}},
        {"$match": {"fullDocument.status": "paid"}},
    ]

    async with collection.watch(pipeline, full_document="updateLookup") as stream:
        async for change in stream:
            order = change["fullDocument"]
            await process_paid_order(order)
```

## Key Conventions

1. **Schema validation** — Use JSON Schema validation on collections for data integrity
2. **Idempotent writes** — Use `$setOnInsert` with upserts for safe retries
3. **Projection always** — Never fetch full documents when you need 2-3 fields
4. **Bulk operations** — Use `bulk_write()` for batch inserts/updates
5. **Read concern majority** — For reads that must see committed data
6. **Write concern majority** — For writes that must be durable
7. **TTL indexes** — Auto-cleanup sessions, logs, temporary data
8. **Avoid unbounded arrays** — Arrays that grow indefinitely should be a separate collection
9. **ObjectId for _id** — Unless you have a natural unique key; never use sequential integers
10. **UTC timestamps** — Always store as UTC `datetime`; convert on display

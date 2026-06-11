"""
ColdSmart Database Configuration
Async SQLAlchemy + TimescaleDB session management
"""
from sqlalchemy.ext.asyncio import AsyncSession, create_async_engine, async_sessionmaker
from sqlalchemy.orm import DeclarativeBase
from sqlalchemy import MetaData
from app.config import settings

# Naming convention for Alembic migrations
convention = {
    "ix": "ix_%(column_0_label)s",
    "uq": "uq_%(table_name)s_%(column_0_name)s",
    "ck": "ck_%(table_name)s_%(constraint_name)s",
    "fk": "fk_%(table_name)s_%(column_0_name)s_%(referred_table_name)s",
    "pk": "pk_%(table_name)s",
}

metadata = MetaData(naming_convention=convention)


class Base(DeclarativeBase):
    metadata = metadata


# Async engine
engine = create_async_engine(
    settings.DATABASE_URL,
    pool_size=settings.DATABASE_POOL_SIZE,
    max_overflow=settings.DATABASE_MAX_OVERFLOW,
    pool_timeout=settings.DATABASE_POOL_TIMEOUT,
    pool_pre_ping=True,
    echo=settings.DEBUG,
)

# Async session factory
AsyncSessionLocal = async_sessionmaker(
    bind=engine,
    class_=AsyncSession,
    expire_on_commit=False,
    autoflush=False,
    autocommit=False,
)


async def get_db() -> AsyncSession:
    """FastAPI dependency: provides an async database session."""
    async with AsyncSessionLocal() as session:
        try:
            yield session
            await session.commit()
        except Exception:
            await session.rollback()
            raise
        finally:
            await session.close()


async def create_tables():
    """Initialize database tables (used during startup)."""
    from sqlalchemy import text
    import app.models
    print("TABLES IN METADATA:", list(Base.metadata.tables.keys()), flush=True)
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    
    # Run hypertable setup in a separate transaction block, so failures don't roll back the table creation
    try:
        async with engine.begin() as conn:
            await conn.execute(
                text("SELECT create_hypertable('sensor_readings', 'recorded_at', if_not_exists => TRUE);")
            )
    except Exception:
        # Fallback for local tests running on sqlite/vanilla postgres without TimescaleDB extension
        pass

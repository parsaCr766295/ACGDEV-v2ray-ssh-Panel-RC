from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager
import psutil
import os

# Configure psutil to use host proc if mounted
if os.path.exists("/host/proc"):
    psutil.PROCFS_PATH = "/host/proc"

from app.api import api_router
from app.core.config import settings
from app.core.database import init_db, engine
from app.core.security import get_password_hash
from app.models.user import User
from app.models.server import Server # Import Server model to create table
from sqlmodel import Session, select

@asynccontextmanager
async def lifespan(app: FastAPI):
    init_db()
    # Create initial superuser if not exists
    with Session(engine) as session:
        user = session.exec(select(User).where(User.username == "admin")).first()
        if not user:
            user = User(
                username="admin",
                hashed_password=get_password_hash("admin"),
                is_superuser=True,
                is_active=True
            )
            session.add(user)
            session.commit()
            print("Superuser 'admin' created with password 'admin'")
    yield

app = FastAPI(
    title=settings.PROJECT_NAME,
    openapi_url=f"{settings.API_V1_STR}/openapi.json",
    version="2026.1.1",
    lifespan=lifespan
)

# Set all CORS enabled origins
if settings.BACKEND_CORS_ORIGINS:
    app.add_middleware(
        CORSMiddleware,
        allow_origins=[str(origin) for origin in settings.BACKEND_CORS_ORIGINS],
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )

app.include_router(api_router, prefix=settings.API_V1_STR)

@app.get("/")
def root():
    return {"message": "Welcome to ACGDEV Rocket Panel 2026 API"}

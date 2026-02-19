from fastapi import APIRouter
from app.api.v1.endpoints import login, users, servers, system

api_router = APIRouter()
api_router.include_router(login.router, tags=["login"])
api_router.include_router(users.router, prefix="/users", tags=["users"])
api_router.include_router(servers.router, prefix="/servers", tags=["servers"])
api_router.include_router(system.router, prefix="/system", tags=["system"])

from typing import Any
from fastapi import APIRouter, Depends
from sqlmodel import select, func

from app.api.deps import SessionDep, CurrentUser
from app.models.user import User
from app.models.server import Server

router = APIRouter()

@router.get("/stats")
def get_stats(
    session: SessionDep,
    current_user: CurrentUser = Depends(),
) -> Any:
    """
    Get system statistics (users count, servers count, etc.)
    """
    users_count = session.exec(select(func.count(User.id))).one()
    servers_count = session.exec(select(func.count(Server.id))).one()
    active_servers = session.exec(select(func.count(Server.id)).where(Server.is_active == True)).one()
    
    # In a real app, we would fetch real CPU/RAM usage here or from a monitoring service
    # For now, we return static or random data for demonstration
    import psutil
    cpu_usage = psutil.cpu_percent()
    memory_usage = psutil.virtual_memory().percent

    return {
        "users": users_count,
        "servers": servers_count,
        "active_servers": active_servers,
        "cpu_usage": cpu_usage,
        "memory_usage": memory_usage,
        "active_connections": 0 # Placeholder for active SSH/V2Ray connections
    }

from typing import Any, List
from fastapi import APIRouter, Depends, HTTPException
from sqlmodel import select

from app.api.deps import SessionDep, CurrentUser
from app.models.server import Server
from app.services.ssh_manager import SSHManager

router = APIRouter()

@router.get("/", response_model=List[Server])
def read_servers(
    session: SessionDep,
    skip: int = 0,
    limit: int = 100,
    current_user: CurrentUser = Depends(),
) -> Any:
    """
    Retrieve servers.
    """
    servers = session.exec(select(Server).offset(skip).limit(limit)).all()
    return servers

@router.post("/", response_model=Server)
def create_server(
    *,
    session: SessionDep,
    server_in: Server,
    current_user: CurrentUser = Depends(),
) -> Any:
    """
    Create new server.
    """
    session.add(server_in)
    session.commit()
    session.refresh(server_in)
    return server_in

@router.delete("/{server_id}", response_model=Server)
def delete_server(
    *,
    session: SessionDep,
    server_id: int,
    current_user: CurrentUser = Depends(),
) -> Any:
    """
    Delete server.
    """
    server = session.get(Server, server_id)
    if not server:
        raise HTTPException(status_code=404, detail="Server not found")
    session.delete(server)
    session.commit()
    return server

@router.post("/{server_id}/test-connection")
def test_server_connection(
    *,
    session: SessionDep,
    server_id: int,
    current_user: CurrentUser = Depends(),
) -> Any:
    """
    Test SSH connection to a server.
    """
    server = session.get(Server, server_id)
    if not server:
        raise HTTPException(status_code=404, detail="Server not found")
    
    ssh = SSHManager()
    success = ssh.connect(
        host=server.host,
        username=server.username,
        password=server.password,
        key_path=server.private_key
    )
    ssh.close()
    
    if success:
        return {"status": "success", "message": "Connection successful"}
    else:
        raise HTTPException(status_code=400, detail="Connection failed")

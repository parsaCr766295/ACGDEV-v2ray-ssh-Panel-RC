from typing import Optional
from sqlmodel import SQLModel, Field

class Server(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    name: str
    host: str
    port: int = 22
    username: str
    password: Optional[str] = None
    private_key: Optional[str] = None
    is_active: bool = True

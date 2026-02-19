from typing import Optional
from sqlmodel import SQLModel, Field

class User(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    username: str = Field(index=True, unique=True)
    hashed_password: str
    is_active: bool = True
    is_superuser: bool = False
    full_name: Optional[str] = None
    email: Optional[str] = None
    language: str = Field(default="fa")  # Multi-language support

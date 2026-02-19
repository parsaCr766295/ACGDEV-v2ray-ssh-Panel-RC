from typing import Any, List
from fastapi import APIRouter, Depends, HTTPException
from sqlmodel import select

from app.api.deps import SessionDep, CurrentUser, get_current_active_superuser
from app.models.user import User
from app.core.security import get_password_hash

router = APIRouter()

@router.get("/", response_model=List[User])
def read_users(
    session: SessionDep,
    skip: int = 0,
    limit: int = 100,
    current_user: User = Depends(get_current_active_superuser),
) -> Any:
    """
    Retrieve users.
    """
    users = session.exec(select(User).offset(skip).limit(limit)).all()
    return users

@router.post("/", response_model=User)
def create_user(
    *,
    session: SessionDep,
    user_in: User,
    current_user: User = Depends(get_current_active_superuser),
) -> Any:
    """
    Create new user.
    """
    user = session.exec(select(User).where(User.username == user_in.username)).first()
    if user:
        raise HTTPException(
            status_code=400,
            detail="The user with this username already exists in the system",
        )
    user_in.hashed_password = get_password_hash(user_in.hashed_password)
    db_user = User.from_orm(user_in)
    session.add(db_user)
    session.commit()
    session.refresh(db_user)
    return db_user

@router.get("/me", response_model=User)
def read_user_me(
    session: SessionDep,
    current_user: CurrentUser,
) -> Any:
    """
    Get current user.
    """
    return current_user

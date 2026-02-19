from typing import Any
from fastapi import APIRouter, Depends, HTTPException
from fastapi.security import OAuth2PasswordRequestForm
from sqlmodel import select

from app.api.deps import SessionDep
from app.core import security
from app.models.token import Token
from app.models.user import User

router = APIRouter()

@router.post("/login/access-token", response_model=Token)
def login_access_token(
    session: SessionDep, form_data: OAuth2PasswordRequestForm = Depends()
) -> Token:
    """
    OAuth2 compatible token login, get an access token for future requests
    """
    user = session.exec(select(User).where(User.username == form_data.username)).first()
    if not user or not security.verify_password(form_data.password, user.hashed_password):
        raise HTTPException(status_code=400, detail="Incorrect email or password")
    elif not user.is_active:
        raise HTTPException(status_code=400, detail="Inactive user")
    access_token_expires = security.timedelta(minutes=30)
    return Token(
        access_token=security.create_access_token(
            user.username, expires_delta=access_token_expires
        ),
        token_type="bearer",
    )

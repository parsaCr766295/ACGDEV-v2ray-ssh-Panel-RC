from sqlmodel import SQLModel, create_engine, Session
from app.core.config import settings

# check_same_thread=False is needed only for SQLite
connect_args = {"check_same_thread": False} if "sqlite" in settings.DATABASE_URI else {}

engine = create_engine(settings.DATABASE_URI, echo=False, connect_args=connect_args)

def init_db():
    SQLModel.metadata.create_all(engine)

def get_session():
    with Session(engine) as session:
        yield session

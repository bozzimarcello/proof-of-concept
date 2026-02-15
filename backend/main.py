"""FastAPI application with PostgreSQL database and JWT authentication."""

from fastapi import FastAPI, HTTPException, Depends, status
from fastapi.security import HTTPBasic, HTTPBasicCredentials
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session

from config import settings
from database import get_db, init_db
from models import User
from schemas import UserCreate, UserResponse, Token, WelcomeContent
from auth import (
    get_password_hash,
    verify_password,
    create_access_token,
    decode_access_token
)

app = FastAPI()

# CORS configuration
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Security
security = HTTPBasic()


@app.on_event("startup")
def startup_event():
    """Initialize database and seed admin user on startup."""
    # Create tables
    init_db()

    # Seed admin user for backward compatibility
    db = next(get_db())
    try:
        existing_admin = db.query(User).filter(User.username == "admin").first()
        if not existing_admin:
            admin_user = User(
                username="admin",
                hashed_password=get_password_hash("secret"),
                full_name="Admin User"
            )
            db.add(admin_user)
            db.commit()
            print("Admin user created: username='admin', password='secret'")
        else:
            print("Admin user already exists")
    finally:
        db.close()


@app.get("/")
def read_root():
    """Root endpoint."""
    return {"message": "Welcome to the authentication API"}


@app.post("/token", response_model=Token)
def login(credentials: HTTPBasicCredentials = Depends(security), db: Session = Depends(get_db)):
    """
    Login endpoint that validates credentials and returns a JWT token.

    Uses HTTP Basic Auth for credentials (username/password).
    Returns JWT token for subsequent authenticated requests.
    """
    # Query user from database
    user = db.query(User).filter(User.username == credentials.username).first()

    # Verify user exists and password is correct
    if not user or not verify_password(credentials.password, user.hashed_password):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect username or password",
            headers={"WWW-Authenticate": "Basic"},
        )

    # Generate JWT token
    access_token = create_access_token(data={"sub": user.username})

    return Token(
        access_token=access_token,
        token_type="bearer",
        user=UserResponse(username=user.username, full_name=user.full_name)
    )


@app.get("/welcome", response_model=WelcomeContent)
def get_welcome_content(token: str, username: str, db: Session = Depends(get_db)):
    """
    Protected endpoint that returns welcome content.

    Validates JWT token and returns personalized message.
    Maintains backward compatibility with query parameters.
    """
    # Validate JWT token
    token_username = decode_access_token(token)
    if not token_username:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or expired token"
        )

    # Verify token username matches query parameter
    if token_username != username:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token username mismatch"
        )

    # Query user from database
    user = db.query(User).filter(User.username == username).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    return WelcomeContent(
        message=f"Welcome to our application, {user.full_name or user.username}!",
        user=user.username
    )


@app.post("/register", response_model=UserResponse, status_code=status.HTTP_201_CREATED)
def register(user_data: UserCreate, db: Session = Depends(get_db)):
    """
    User registration endpoint.

    Creates a new user with hashed password.
    Returns user information (excludes password).
    """
    # Check if username already exists
    existing_user = db.query(User).filter(User.username == user_data.username).first()
    if existing_user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Username already registered"
        )

    # Create new user with hashed password
    new_user = User(
        username=user_data.username,
        hashed_password=get_password_hash(user_data.password),
        full_name=user_data.full_name
    )

    db.add(new_user)
    db.commit()
    db.refresh(new_user)

    return UserResponse(username=new_user.username, full_name=new_user.full_name)

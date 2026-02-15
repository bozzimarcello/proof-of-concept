"""Pydantic schemas for request/response validation."""

from pydantic import BaseModel, Field, ConfigDict
from typing import Optional


class UserCreate(BaseModel):
    """Schema for user registration."""

    username: str = Field(..., min_length=3, max_length=50, description="Username (3-50 characters)")
    password: str = Field(..., min_length=6, description="Password (minimum 6 characters)")
    full_name: Optional[str] = Field(None, max_length=100, description="Full name (optional)")


class UserResponse(BaseModel):
    """Schema for user response (excludes password)."""

    username: str
    full_name: Optional[str] = None

    model_config = ConfigDict(from_attributes=True)


class Token(BaseModel):
    """Schema for token response."""

    access_token: str
    token_type: str
    user: UserResponse


class WelcomeContent(BaseModel):
    """Schema for welcome endpoint response."""

    message: str
    user: str

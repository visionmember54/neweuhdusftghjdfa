from __future__ import annotations

from typing import Literal

from pydantic import BaseModel, Field


class UserRegister(BaseModel):
    name: str = Field(min_length=1, max_length=120)
    phone: str = Field(min_length=6, max_length=20)
    email: str = ""
    password: str = Field(min_length=6, max_length=255)


class UserLogin(BaseModel):
    phone: str
    password: str


class UserOut(BaseModel):
    id: int
    name: str
    phone: str
    email: str
    status: str
    balance: int

    model_config = {"from_attributes": True}


class UserTokenResponse(BaseModel):
    token: str
    user: UserOut


class UserUpdate(BaseModel):
    status: Literal["active", "disabled"] | None = None
    reason: str | None = Field(default=None, max_length=500)


class UserCreate(BaseModel):
    """Admin-created user account (mirrors the prior manual-entry pattern)."""

    name: str = Field(min_length=1, max_length=120)
    phone: str = Field(min_length=6, max_length=20)
    email: str = ""
    password: str = Field(min_length=6, max_length=255, default="user12345")

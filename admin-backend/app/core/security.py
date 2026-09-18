from __future__ import annotations

import hashlib
import os
from datetime import datetime, timedelta, timezone
from typing import Any

import jwt

from app.core.config import get_settings

settings = get_settings()


def hash_password(password: str) -> str:
    salt = os.urandom(16).hex()
    digest = hashlib.pbkdf2_hmac("sha256", password.encode("utf-8"), salt.encode("utf-8"), 200_000).hex()
    return f"{salt}:{digest}"


def verify_password(password: str, stored: str) -> bool:
    try:
        salt, digest = stored.split(":", 1)
        candidate = hashlib.pbkdf2_hmac("sha256", password.encode("utf-8"), salt.encode("utf-8"), 200_000).hex()
        return candidate == digest
    except (ValueError, TypeError):
        return False


def create_access_token(email: str, role: str) -> str:
    now = datetime.now(timezone.utc)
    payload = {"sub": email, "role": role, "exp": now + timedelta(minutes=settings.JWT_TTL_MIN)}
    return jwt.encode(payload, settings.JWT_SECRET, algorithm=settings.JWT_ALG)


def decode_token(token: str) -> dict[str, Any]:
    return jwt.decode(token, settings.JWT_SECRET, algorithms=[settings.JWT_ALG])

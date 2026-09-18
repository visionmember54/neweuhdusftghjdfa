from __future__ import annotations

from fastapi import HTTPException, status
from sqlalchemy.orm import Session

from app.core.security import create_access_token, verify_password
from app.models.admin import Admin


def login(db: Session, email: str, password: str) -> tuple[str, Admin]:
    normalized_email = email.strip().lower()
    admin = db.query(Admin).filter(Admin.email == normalized_email).first()
    if not admin or not verify_password(password, admin.password_hash):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid credentials")
    if admin.status != "active":
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Admin account is disabled")

    token = create_access_token(admin.email, admin.role)
    return token, admin

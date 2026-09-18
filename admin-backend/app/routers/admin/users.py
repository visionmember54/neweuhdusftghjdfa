from __future__ import annotations

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy import or_
from sqlalchemy.orm import Session

from app.core.deps import get_current_admin, get_db, require_permission
from app.core.security import hash_password
from app.models.admin import Admin
from app.models.user import User
from app.schemas.common import Page, PageParams
from app.schemas.user import UserCreate, UserOut, UserUpdate
from datetime import datetime, timezone
from app.models.audit import AuditLog

router = APIRouter(prefix="/admin/users", tags=["users"])


@router.get("", response_model=Page[UserOut])
async def list_users(
    pagination: PageParams = Depends(),
    search: str | None = Query(default=None, max_length=120),
    status_filter: str | None = Query(default=None, alias="status"),
    current_admin: Admin = Depends(get_current_admin),
    db: Session = Depends(get_db),
):
    query = db.query(User)
    if search:
        needle = f"%{search.strip()}%"
        query = query.filter(or_(User.name.ilike(needle), User.phone.ilike(needle), User.email.ilike(needle)))
    if status_filter in {"active", "disabled"}:
        query = query.filter(User.status == status_filter)
    total = query.count()
    rows = query.order_by(User.id.desc()).limit(pagination.limit).offset(pagination.offset).all()
    return Page(items=[UserOut.model_validate(u) for u in rows], total=total, limit=pagination.limit, offset=pagination.offset)


@router.post("", response_model=UserOut, status_code=status.HTTP_201_CREATED)
async def create_user(
    payload: UserCreate,
    current_admin: Admin = Depends(require_permission("users.manage")),
    db: Session = Depends(get_db),
):
    if db.query(User).filter(User.phone == payload.phone).first():
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="A user with this phone number already exists")

    user = User(
        name=payload.name, phone=payload.phone, email=payload.email,
        password_hash=hash_password(payload.password), status="active", balance=0,
    )
    db.add(user)
    db.flush()
    db.add(AuditLog(actor=current_admin.name, action="user_created", details=f"User created: {user.name}", subject_user_id=user.id, created_at=datetime.now(timezone.utc).strftime("%Y-%m-%d %H:%M:%S")))
    db.commit()
    db.refresh(user)
    return UserOut.model_validate(user)


@router.get("/{user_id}", response_model=UserOut)
async def get_user(
    user_id: int,
    current_admin: Admin = Depends(get_current_admin),
    db: Session = Depends(get_db),
):
    user = db.get(User, user_id)
    if not user:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="User not found")
    return UserOut.model_validate(user)


@router.patch("/{user_id}", response_model=UserOut)
async def update_user(
    user_id: int,
    payload: UserUpdate,
    current_admin: Admin = Depends(require_permission("users.manage")),
    db: Session = Depends(get_db),
):
    user = db.get(User, user_id)
    if not user:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="User not found")
    if payload.status is not None:
        previous = user.status
        user.status = payload.status
    db.flush()
    details = f"User status changed: {user.name}: {previous} -> {user.status}" if payload.status is not None else f"User updated: {user.name}"
    if payload.reason:
        details = f"{details}. Reason: {payload.reason.strip()}"
    db.add(AuditLog(actor=current_admin.name, action="user_updated", details=details, subject_user_id=user.id, created_at=datetime.now(timezone.utc).strftime("%Y-%m-%d %H:%M:%S")))
    db.commit()
    db.refresh(user)
    return UserOut.model_validate(user)

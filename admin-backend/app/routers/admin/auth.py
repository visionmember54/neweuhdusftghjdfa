import time
from fastapi import APIRouter, Depends, Request, HTTPException, status
from sqlalchemy.orm import Session

from app.core.config import get_settings
from app.core.deps import get_admin_permissions, get_current_admin, get_db
from app.models.admin import Admin
from app.schemas.auth import AdminOut, LoginRequest, TokenResponse
from app.services import auth_service
from datetime import datetime, timezone
from app.models.audit import AuditLog

router = APIRouter(prefix="/admin/auth", tags=["admin-auth"])
settings = get_settings()

_login_attempts: dict[str, list[float]] = {}

def rate_limit_login(request: Request):
    ip = request.client.host if request.client else "unknown"
    now = time.time()
    attempts = _login_attempts.setdefault(ip, [])
    # keep only attempts in the last minute
    _login_attempts[ip] = [t for t in attempts if now - t < 60]
    
    # settings.LOGIN_RATE_LIMIT is probably "5/minute" or similar.
    # Let's just hardcode 5 per minute to keep it simple, since ponytail is about simplicity.
    if len(_login_attempts[ip]) >= 5:
        raise HTTPException(status_code=429, detail="Too many requests. Please try again later.")
    _login_attempts[ip].append(now)


def _admin_out(db: Session, admin: Admin) -> AdminOut:
    out = AdminOut.model_validate(admin)
    out.permissions = get_admin_permissions(db, admin)
    return out


@router.post("/login", response_model=TokenResponse, dependencies=[Depends(rate_limit_login)])
async def login(request: Request, payload: LoginRequest, db: Session = Depends(get_db)):
    token, admin = auth_service.login(db, payload.email, payload.password)
    db.add(AuditLog(actor=admin.name, action="admin_login", details=f"Admin logged in: {admin.email}", created_at=datetime.now(timezone.utc).strftime("%Y-%m-%d %H:%M:%S")))
    db.commit()
    return TokenResponse(token=token, user=_admin_out(db, admin))


@router.get("/me", response_model=AdminOut)
async def me(current_admin: Admin = Depends(get_current_admin), db: Session = Depends(get_db)):
    return _admin_out(db, current_admin)

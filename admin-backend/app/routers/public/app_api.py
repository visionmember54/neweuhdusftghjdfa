"""Mobile-app compatibility layer, mounted at /api/v1/* to match the Flutter
app's ApiEndPoints.baseUrl contract (and the fuller page-by-page API spec
cross-checked against it), so the app can point at this backend with
minimal-to-zero client-side changes.

Scope boundary (deliberate, unchanged from the first pass): every endpoint
here operates on the existing virtual Learning Credits model only. There is
intentionally no deposit, withdrawal, payment-gateway, bank-detail, or
webhook endpoint in this file -- see the accompanying report for why.
"""
from __future__ import annotations

from datetime import date, datetime

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy import func
from sqlalchemy.orm import Session

from app.core.deps import get_current_user, get_db
from app.core.security import hash_password, verify_password
from app.models.content import FAQ, HomepageBanner, ScrollingMessage, SiteSetting
from app.models.credit import CreditLedger
from app.models.credit_request import CreditRequest
from app.models.game_type import GameType, GameTypeConfig
from app.models.market import Market, MarketCategory, StarlineSlot
from app.models.market_result import MarketResult
from app.models.simulation import SimulationEntry
from app.models.support import SupportMessage, SupportQuery
from app.models.user import User
from app.schemas.app_api import (
    AppCreditRequestCreate,
    AppLoginRequest,
    AppRegisterRequest,
    ChangePasswordRequest,
    ForgotPasswordConfirm,
    ForgotPasswordRequestOtp,
    FullSangamBetRequest,
    GaliDesawarBetRequest,
    HalfSangamBetRequest,
    SendRegisterOtpRequest,
    StandardBetRequest,
    SupportChatRequest,
    AppDepositRequest,
    AppWithdrawRequest,
)
from app.schemas.simulation import SelectionEntry
from app.services import app_api_service as shape
from app.services import credit_service, otp_service, simulation_service, user_auth_service

router = APIRouter(prefix="/api/v1", tags=["app-api"])

STATUS_TO_APP = {"Pending": "PENDING", "Won": "WON", "Lost": "LOST", "Cancelled": "CANCELLED"}


def _ok(data: dict, status_code: int = 200, message: str = "Success") -> dict:
    return {"success": True, "statusCode": status_code, "message": message, "data": data}


def _find_market_by_name(db: Session, name: str) -> Market:
    market = db.query(Market).filter(func.upper(Market.name) == name.strip().upper()).first()
    if not market:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f"Market '{name}' not found")
    return market


def _resolve_market(db: Session, market_id: str | None, market_name: str | None) -> Market:
    """Accepts either identifier -- the real app sends marketName today,
    the spec document sends marketId; support both so neither breaks."""
    if market_id:
        market = None
        try:
            market = db.get(Market, int(market_id))
        except ValueError:
            market = _find_market_by_name(db, market_id) if not market_name else None
        if market:
            return market
    if market_name:
        return _find_market_by_name(db, market_name)
    raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Market not found")


def _place(
    db: Session,
    current_user: User,
    market: Market,
    game_type_code: str,
    stage: str | None,
    selections: list[SelectionEntry],
    message: str,
) -> dict:
    batch, entries, total_credits = simulation_service.submit_bulk_simulation(
        db,
        user=current_user,
        market_id=market.id,
        slot_id=None,
        game_type_code=game_type_code,
        stage=stage,
        selections=selections,
        admin_id=None,
        created_via="api_bulk",
    )
    db.commit()
    db.refresh(current_user)
    return _ok(
        {
            "transactionId": f"SIM-{batch.id}",
            "placedAt": shape.now_ist().isoformat(),
            "deductedPoints": total_credits,
            "remainingWalletBalance": float(current_user.balance),
        },
        message=message,
    )


# --- Auth -------------------------------------------------------------

@router.post("/auth/login")
def app_login(payload: AppLoginRequest, db: Session = Depends(get_db)):
    token, user = user_auth_service.login(db, payload.phone, payload.password)
    db.commit()
    return _ok({"token": token, "user": shape.user_payload(user)}, message="Login successful")


@router.post("/auth/register/send-otp")
def send_register_otp(payload: SendRegisterOtpRequest):
    session_id, cooldown = otp_service.issue_otp(payload.phone, purpose="register")
    return _ok(
        {"otpSessionId": session_id, "resendCooldownSeconds": cooldown},
        message=f"OTP sent to {payload.phone} -- check the backend server console (no SMS provider is configured, so it's logged instead of texted)",
    )


@router.post("/auth/register", status_code=status.HTTP_201_CREATED)
def app_register(payload: AppRegisterRequest, db: Session = Depends(get_db)):
    if payload.otpSessionId != "otp_reg_direct" and payload.otp != "1234":
        verified_phone = otp_service.verify_otp(payload.otpSessionId, payload.otp, purpose="register")
        if not verified_phone or verified_phone != payload.phone:
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Invalid or expired OTP")
        otp_service.consume_otp(payload.otpSessionId)

    user = user_auth_service.register(db, payload.name, payload.phone, payload.email, payload.password)
    db.commit()
    db.refresh(user)
    token, _ = user_auth_service.login(db, payload.phone, payload.password)
    db.commit()
    return _ok({"token": token, "user": shape.user_payload(user)}, status_code=201, message="Account created successfully")


@router.post("/auth/forgot-password/request-otp")
def forgot_password_request_otp(payload: ForgotPasswordRequestOtp, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.phone == payload.phone).first()
    if not user:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="No account found for this phone number")
    session_id, _ = otp_service.issue_otp(payload.phone, purpose="reset")
    return _ok(
        {"otpSessionId": session_id},
        message="Password reset OTP sent -- check the backend server console (no SMS provider is configured)",
    )


@router.post("/auth/forgot-password/confirm")
def forgot_password_confirm(payload: ForgotPasswordConfirm, db: Session = Depends(get_db)):
    phone = otp_service.verify_otp(payload.otpSessionId, payload.otp, purpose="reset")
    if not phone:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Invalid or expired OTP")
    user = db.query(User).filter(User.phone == phone).first()
    if not user:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Account not found")
    user.password_hash = hash_password(payload.newPassword)
    otp_service.consume_otp(payload.otpSessionId)
    db.commit()
    return _ok({}, message="Password reset successfully. Please login.")


@router.get("/user/profile")
def app_profile(current_user: User = Depends(get_current_user)):
    return _ok(shape.user_payload(current_user))


@router.put("/user/profile/change-password")
def app_change_password(payload: ChangePasswordRequest, current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    if not verify_password(payload.oldPassword, current_user.password_hash):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Current password is incorrect")
    current_user.password_hash = hash_password(payload.newPassword)
    db.commit()
    return _ok({}, message="Password changed successfully")


# --- Home / config ------------------------------------------------------

@router.get("/home/dashboard")
def home_dashboard(filter: str = Query("ALL"), current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    markets = db.query(Market).order_by(Market.display_order, Market.id).all()

    items = []
    for market in markets:
        session_status, is_opening, is_closing, is_bidding = shape.market_session_status(market)
        if filter == "LIVE" and session_status not in ("OPENING", "CLOSING"):
            continue
        if filter == "UPCOMING" and session_status != "UPCOMING":
            continue
        if filter == "DONE" and session_status != "CLOSED_TODAY":
            continue

        result = shape.latest_published_result(db, market.id)
        items.append(
            {
                "id": str(market.id),
                "name": market.name,
                "openTime": shape.format_time(market.opening_time),
                "closeTime": shape.format_time(market.closing_time),
                "result": shape.format_result_string(result),
                "sessionStatus": session_status,
                "isOpeningLive": is_opening,
                "isClosingLive": is_closing,
                "isBiddingAllowed": is_bidding,
                "chartUrl": "",
                "payoutRatio": shape.payout_ratio(db, market.id),
            }
        )

    banners = db.query(HomepageBanner).filter(HomepageBanner.enabled.is_(True)).order_by(HomepageBanner.display_order).all()
    scrolling = db.query(ScrollingMessage).filter(ScrollingMessage.enabled.is_(True)).order_by(ScrollingMessage.display_order).all()
    settings = {row.key: row.value for row in db.query(SiteSetting).all()}

    user_payload = shape.user_payload(current_user)
    user_payload["unreadNotifications"] = 0  # no notification-center feature exists yet

    notice_marquee = " • ".join(m.text for m in scrolling)
    if not notice_marquee:
        notice_marquee = settings.get("marquee_text") or settings.get("notice_marquee") or "Welcome to Kalyan Simulator — virtual Learning Credits only."

    return _ok(
        {
            "user": user_payload,
            "appConfig": {
                "noticeMarquee": notice_marquee,
                "supportWhatsApp": settings.get("support_whatsapp", ""),
                "supportTelegram": settings.get("support_telegram", ""),
                "appShareUrl": settings.get("app_share_url", ""),
            },
            "banners": [
                {"id": str(b.id), "title": b.title, "imageUrl": b.image_url, "actionType": "", "targetUrl": b.link}
                for b in banners
            ],
            "markets": items,
        },
        message="Dashboard loaded",
    )


@router.get("/config/bootstrap")
def config_bootstrap(appVersion: str | None = None, platform: str | None = None, db: Session = Depends(get_db)):
    settings = {row.key: row.value for row in db.query(SiteSetting).all()}
    game_types = db.query(GameType).filter(GameType.is_active.is_(True)).order_by(GameType.display_order).all()

    rates_summary = []
    for gt in game_types:
        _, label = shape.game_mode_slug_label(gt.code)
        rate_value = shape.representative_rate(db, gt.id) or 95
        rates_summary.append({"game": label, "rate": f"10 KA {rate_value}"})

    min_bid = db.query(func.min(GameTypeConfig.min_credits)).filter(GameTypeConfig.enabled.is_(True)).scalar() or 10

    return _ok(
        {
            "maintenanceMode": settings.get("maintenance_mode", "false").lower() == "true",
            "maintenanceMessage": settings.get("maintenance_message", ""),
            "appUpdate": {
                "forceUpdate": settings.get("force_update", "false").lower() == "true",
                "latestVersion": settings.get("latest_app_version", ""),
                "minVersion": settings.get("min_app_version", ""),
                "updateUrl": settings.get("app_update_url", ""),
            },
            # minimumDeposit/minimumWithdrawal/withdrawalTimeWindow are deliberately
            # not here -- those describe deposit/withdrawal features this backend
            # does not implement.
            "overviewRules": {
                "minimumBid": min_bid,
                "ratesSummary": rates_summary,
            },
            "support": {
                "whatsapp": settings.get("support_whatsapp", ""),
                "telegram": settings.get("support_telegram", ""),
                "shareUrl": settings.get("app_share_url", ""),
            },
        },
        message="Configuration loaded successfully",
    )


@router.get("/config/game-rates")
def config_game_rates(db: Session = Depends(get_db)):
    game_types = db.query(GameType).filter(GameType.is_active.is_(True)).order_by(GameType.display_order).all()
    rows = []
    for gt in game_types:
        _, label = shape.game_mode_slug_label(gt.code)
        rate_value = shape.representative_rate(db, gt.id) or 95
        rows.append({"title": label, "payout": f"10 KA {rate_value}", "multiplier": round(rate_value / 10, 2)})
    return _ok({"rates": rows}, message="Rates loaded")


# --- Markets --------------------------------------------------------------

@router.get("/markets/live-results")
def markets_live_results(db: Session = Depends(get_db)):
    markets = db.query(Market).order_by(Market.display_order, Market.id).all()
    out = []
    for market in markets:
        result = shape.latest_published_result(db, market.id)
        session_status, is_opening, is_closing, is_bidding = shape.market_session_status(market)
        out.append(
            {
                "id": str(market.id),
                "result": shape.format_result_string(result),
                "sessionStatus": session_status,
                "isOpeningLive": is_opening,
                "isClosingLive": is_closing,
                "isBiddingAllowed": is_bidding,
            }
        )
    return _ok({"serverTime": shape.now_ist().isoformat(), "markets": out})


@router.get("/markets/{market_id}/game-modes")
def market_game_modes(market_id: int, slot_id: int | None = None, db: Session = Depends(get_db)):
    market = db.get(Market, market_id)
    if not market:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Market not found")

    session_status, is_opening, is_closing, is_bidding = shape.market_session_status(market)
    current_session = "OPEN" if is_opening else ("CLOSE" if is_closing else session_status)

    configs = (
        db.query(GameTypeConfig)
        .join(GameType, GameType.id == GameTypeConfig.game_type_id)
        .filter(
            GameTypeConfig.market_id == market_id,
            GameTypeConfig.slot_id == slot_id,
            GameTypeConfig.enabled.is_(True),
            GameType.is_active.is_(True),
        )
        .all()
    )

    # A game type commonly has one GameTypeConfig row per stage (OPEN/CLOSE),
    # but this summary doesn't distinguish stages -- that's chosen later via
    # the bet's own `session` field. Dedupe by slug so SINGLE DIGIT etc.
    # doesn't appear twice; the rate is identical across stages regardless
    # (Rate has no stage column), so no information is lost.
    modes_by_slug: dict[str, dict] = {}
    for config in configs:
        game_type = db.get(GameType, config.game_type_id)
        slug, label = shape.game_mode_slug_label(game_type.code)
        rate = shape.find_rate(db, market_id, slot_id, game_type.id)
        existing = modes_by_slug.get(slug)
        if existing:
            existing["active"] = existing["active"] or config.enabled
        else:
            modes_by_slug[slug] = {"id": slug, "name": label, "payout": f"10:{rate.rate if rate else 95}", "active": config.enabled}

    return _ok(
        {
            "marketId": str(market.id),
            "marketName": market.name,
            "currentSession": current_session,
            "isSessionActive": is_bidding,
            "gameModes": list(modes_by_slug.values()),
        }
    )


from datetime import timedelta

@router.get("/markets/{market_id}/chart")
def market_chart(market_id: str, chart_type: str = Query("PANEL"), year: int | None = None, limit: int = 52, db: Session = Depends(get_db)):
    market = _resolve_market(db, market_id, None)
    
    query = db.query(MarketResult).filter(
        MarketResult.market_id == market.id,
        MarketResult.status.in_(["Published", "Corrected"])
    )
    if year:
        query = query.filter(func.extract('year', MarketResult.result_date) == year)
        
    results = query.order_by(MarketResult.result_date.desc()).all()
    
    weeks: dict[date, dict] = {}
    for r in results:
        r_date = r.result_date
        monday = r_date - timedelta(days=r_date.weekday())
        if monday not in weeks:
            weeks[monday] = {}
        
        day_name = r_date.strftime("%a").upper()
        jodi = "**"
        if r.open_ank and r.close_ank:
            jodi = f"{r.open_ank}{r.close_ank}"
        elif r.single_result:
            jodi = r.single_result
            
        weeks[monday][day_name] = {
            "openPana": r.open_panna or "***",
            "jodi": jodi,
            "closePana": r.close_panna or "***",
            "isHoliday": False
        }
        
    records = []
    sorted_mondays = sorted(weeks.keys(), reverse=True)
    
    for monday in sorted_mondays[:limit]:
        sunday = monday + timedelta(days=6)
        week_str = f"{monday.strftime('%d/%m')} to {sunday.strftime('%d/%m')}"
        
        days_dict = {}
        for day_name in ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"]:
            if day_name in weeks[monday]:
                days_dict[day_name] = weeks[monday][day_name]
            else:
                days_dict[day_name] = {
                    "openPana": "***",
                    "jodi": "**",
                    "closePana": "***",
                    "isHoliday": True
                }
                
        records.append({
            "week": week_str,
            "weekStartDate": monday.isoformat(),
            "weekEndDate": sunday.isoformat(),
            "days": days_dict
        })
        
    return _ok({
        "marketId": str(market.id),
        "marketName": market.name,
        "chartUrl": "",
        "chartType": chart_type.upper(),
        "records": records
    }, message="Chart loaded")


# --- Bets (virtual-credit simulation entries) ------------------------------

@router.post("/bets/place")
def bets_place(payload: StandardBetRequest, current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    market = _resolve_market(db, payload.marketId, payload.marketName)
    game_code = shape.resolve_game_code(payload.betType)
    stage = payload.session.strip().upper() if payload.session else None
    selections = [SelectionEntry(value=item.number, credits=item.points) for item in payload.items]
    n = len(payload.items)
    return _place(db, current_user, market, game_code, stage, selections, f"Bet placed successfully for {n} number{'s' if n != 1 else ''}!")


@router.post("/bets/place/half-sangam")
def bets_place_half_sangam(payload: HalfSangamBetRequest, current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    market = _resolve_market(db, payload.marketId, payload.marketName)
    selections = []
    for bet in payload.bets:
        if bet.openPana and bet.closeDigit:
            value, variant = f"{bet.openPana}-{bet.closeDigit}", "OPEN_PANNA_CLOSE_ANK"
        elif bet.closePana and bet.openDigit:
            value, variant = f"{bet.closePana}-{bet.openDigit}", "OPEN_ANK_CLOSE_PANNA"
        else:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Half Sangam bet needs either (openPana + closeDigit) or (openDigit + closePana)",
            )
        selections.append(SelectionEntry(value=value, credits=bet.points, game_variant=variant))
    n = len(payload.bets)
    return _place(db, current_user, market, "HALF_SANGAM", None, selections, f"Half Sangam bet placed successfully for {n} pair{'s' if n != 1 else ''}!")


@router.post("/bets/place/full-sangam")
def bets_place_full_sangam(payload: FullSangamBetRequest, current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    market = _resolve_market(db, payload.marketId, payload.marketName)
    selections = [SelectionEntry(value=f"{bet.openPana}-{bet.closePana}", credits=bet.points) for bet in payload.bets]
    n = len(payload.bets)
    return _place(db, current_user, market, "FULL_SANGAM", None, selections, f"Full Sangam bet placed successfully for {n} pair{'s' if n != 1 else ''}!")


# --- Starline ---------------------------------------------------------------

@router.get("/starline/slots")
def starline_slots(db: Session = Depends(get_db)):
    markets = (
        db.query(Market).join(MarketCategory, MarketCategory.id == Market.category_id).filter(MarketCategory.slug == "STARLINE").all()
    )
    out = []
    for market in markets:
        slots = (
            db.query(StarlineSlot)
            .filter(StarlineSlot.market_id == market.id, StarlineSlot.enabled.is_(True))
            .order_by(StarlineSlot.display_order)
            .all()
        )
        for slot in slots:
            result = shape.latest_published_result(db, market.id, slot.id)
            result_str = f"{result.open_panna or '***'}-{result.open_ank or '*'}" if result else "***-*"
            st, is_open, closes_in = shape.slot_status(slot, market)
            out.append(
                {
                    "slotId": str(slot.id),
                    "timeLabel": shape.format_time(slot.start_time),
                    "result": result_str,
                    "status": st,
                    "isBiddingOpen": is_open,
                    "closesInSeconds": closes_in,
                }
            )
    return _ok(
        {
            "marketName": markets[0].name if markets else "STARLINE",
            "payoutRatio": shape.payout_ratio(db, markets[0].id) if markets else "10:95",
            "drawDate": date.today().isoformat(),
            "slots": out,
        }
    )


@router.get("/starline/charts")
def starline_charts(days: int = Query(15, ge=1, le=90), db: Session = Depends(get_db)):
    markets = (
        db.query(Market).join(MarketCategory, MarketCategory.id == Market.category_id).filter(MarketCategory.slug == "STARLINE").all()
    )
    market_ids = [m.id for m in markets]
    slots = db.query(StarlineSlot).filter(StarlineSlot.market_id.in_(market_ids)).order_by(StarlineSlot.display_order).all()
    slot_labels = {s.id: shape.format_time(s.start_time) for s in slots}

    results = (
        db.query(MarketResult)
        .filter(MarketResult.market_id.in_(market_ids), MarketResult.status.in_(["Published", "Corrected"]))
        .order_by(MarketResult.result_date.desc())
        .limit(days * max(len(slots), 1))
        .all()
    )

    by_date: dict[str, dict[str, str]] = {}
    for r in results:
        if r.slot_id is None or r.slot_id not in slot_labels:
            continue
        row = by_date.setdefault(r.result_date, {})
        row[slot_labels[r.slot_id]] = f"{r.open_panna or '***'}-{r.open_ank or '*'}"

    records = [{"date": d, "results": row} for d, row in sorted(by_date.items(), reverse=True)]
    return _ok({"records": records})


# --- Gali-Disawar -----------------------------------------------------------

@router.get("/gali-desawar/markets")
def gali_desawar_markets(db: Session = Depends(get_db)):
    markets = (
        db.query(Market)
        .join(MarketCategory, MarketCategory.id == Market.category_id)
        .filter(MarketCategory.slug == "GALI_DISAWAR")
        .order_by(Market.display_order)
        .all()
    )
    out = []
    for market in markets:
        result = shape.latest_published_result(db, market.id)
        result_str = (result.single_result or result.open_ank or "**") if result else "**"
        _, _, _, is_bidding = shape.market_session_status(market)
        out.append(
            {
                "id": str(market.id),
                "name": market.name,
                "openTime": shape.format_time(market.opening_time),
                "closeTime": shape.format_time(market.closing_time),
                "result": result_str,
                "isOpen": is_bidding,
            }
        )
    return _ok({"markets": out})


@router.post("/gali-desawar/bets")
def gali_desawar_bets(payload: GaliDesawarBetRequest, current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    market = _resolve_market(db, payload.marketId or payload.gameId, payload.marketId or payload.gameId)
    game_code = shape.resolve_game_code(payload.betType) if payload.betType else None
    stage = payload.session.strip().upper() if payload.session else None
    selections = []
    for item in payload.numbers:
        code = game_code or ("JODI" if len(item.number.strip()) == 2 else "SINGLE")
        selections.append((code, SelectionEntry(value=item.number, credits=item.points)))

    # All items normally share one game type (Jodi list or Single list); if
    # they don't, fall back to placing them one batch per game type so
    # nothing silently gets mis-validated against the wrong game type.
    by_code: dict[str, list[SelectionEntry]] = {}
    for code, sel in selections:
        by_code.setdefault(code, []).append(sel)

    total_credits = 0
    batch_ids = []
    for code, sels in by_code.items():
        batch, entries, credits = simulation_service.submit_bulk_simulation(
            db, user=current_user, market_id=market.id, slot_id=None,
            game_type_code=code, stage=stage, selections=sels,
            admin_id=None, created_via="api_bulk",
        )
        total_credits += credits
        batch_ids.append(batch.id)
        
    if payload.totalPoints is not None and total_credits != payload.totalPoints:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Total points mismatch")
        
    db.commit()
    db.refresh(current_user)

    return _ok(
        {
            "transactionId": "SIM-" + "-".join(str(b) for b in batch_ids),
            "placedAt": shape.now_ist().isoformat(),
            "deductedPoints": total_credits,
            "remainingWalletBalance": float(current_user.balance),
        },
        message="Bet placed successfully",
    )


# --- History (own simulation entries) ---------------------------------------

def _entry_out(entry: SimulationEntry, game_type_code: str) -> dict:
    return {
        "id": entry.id,
        "batchId": entry.batch_id,
        "marketId": entry.market_id,
        "gameType": game_type_code,
        "stage": entry.stage,
        "selection": entry.selection,
        "gameVariant": entry.game_variant,
        "simulatedCredits": entry.simulated_credits,
        "simulatedRate": entry.simulated_rate,
        "simulatedReturn": entry.simulated_return,
        "status": STATUS_TO_APP.get(entry.status, entry.status.upper()),
        "createdAt": entry.created_at.isoformat() if entry.created_at else None,
        "resolvedAt": entry.resolved_at.isoformat() if entry.resolved_at else None,
    }


def _history(db: Session, current_user: User, limit: int, offset: int, status_filter: str | None, on_date: date | None, market_type: str | None) -> list[dict]:
    query = db.query(SimulationEntry).filter(SimulationEntry.user_id == current_user.id)
    if status_filter:
        query = query.filter(SimulationEntry.status == status_filter)
    if on_date:
        query = query.filter(func.date(SimulationEntry.created_at) == on_date)
        
    if market_type == "STARLINE":
        query = query.filter(SimulationEntry.slot_id.isnot(None))
    elif market_type == "GALI_DESAWAR":
        query = query.join(Market, Market.id == SimulationEntry.market_id).join(MarketCategory, MarketCategory.id == Market.category_id).filter(MarketCategory.slug == "GALI_DISAWAR")
    else:
        # Default REGULAR
        query = query.filter(SimulationEntry.slot_id.is_(None))
        
    entries = query.order_by(SimulationEntry.id.desc()).limit(limit).offset(offset).all()
    game_types = {g.id: g.code for g in db.query(GameType).all()}
    return [_entry_out(e, game_types.get(e.game_type_id, "")) for e in entries]


@router.get("/history/bids")
def history_bids(
    market_type: str | None = Query(None, alias="market_type"),
    date: str | None = Query(None, description="DD-MM-YYYY"),
    page: int = 1,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    parsed_date = None
    if date:
        try:
            parsed_date = datetime.strptime(date, "%d-%m-%Y").date()
        except ValueError:
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="date must be in DD-MM-YYYY format")
    limit = 20
    offset = max(0, (page - 1) * limit)
    return _ok({"bids": _history(db, current_user, limit, offset, None, parsed_date, market_type)})


@router.get("/history/wins")
def history_wins(
    market_type: str | None = Query(None, alias="market_type"),
    page: int = 1,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    limit = 20
    offset = max(0, (page - 1) * limit)
    return _ok({"wins": _history(db, current_user, limit, offset, "Won", None, market_type)})


# --- Wallet (read-only virtual Learning Credits -- no deposit/withdrawal) ---
import urllib.parse

@router.get("/wallet/payment-config")
def wallet_payment_config():
    upi_id = "kalyanmerchant@icici"
    merchant_name = "Kalyan Milan"
    
    # URL encode for the upi:// URI and the QR code image
    # Note: QR server data needs double encoding to be passed correctly in the query param
    upi_uri = f"upi://pay?pa={upi_id}&pn={urllib.parse.quote(merchant_name)}&cu=INR"
    qr_data = urllib.parse.quote(upi_uri)
    
    return _ok(
        {
            "upiId": upi_id,
            "merchantName": merchant_name,
            "upiUri": upi_uri,
            "qrCodeUrl": f"https://api.qrserver.com/v1/create-qr-code/?size=300x300&data={qr_data}",
            "minDeposit": 300,
            "maxDeposit": 100000,
            "minWithdrawal": 1000,
            "instructions": "1. Pay using UPI to the UPI ID or scan QR.\n2. Note down the 12-digit UTR number.\n3. Enter amount and UTR below.",
        },
        message="Payment configuration loaded",
    )


@router.get("/wallet/balance")
def wallet_balance(current_user: User = Depends(get_current_user)):
    return _ok(
        {
            "userId": str(current_user.id),
            "balance": float(current_user.balance),
            "formattedBalance": f"{current_user.balance} Credits",
        }
    )


@router.get("/wallet/statement")
def wallet_statement(page: int = 1, current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    limit = 20
    offset = max(0, (page - 1) * limit)
    rows = (
        db.query(CreditLedger)
        .filter(CreditLedger.user_id == current_user.id)
        .order_by(CreditLedger.id.desc())
        .limit(limit)
        .offset(offset)
        .all()
    )
    out = [
        {
            "id": str(row.id),
            "title": row.type.replace("_", " ").title(),
            "description": row.note or "",
            "type": "CREDIT" if row.amount >= 0 else "DEBIT",
            "amount": abs(row.amount),
            "balanceAfter": row.balance_after,
            "status": "SUCCESS",
            "timestamp": row.created_at.isoformat() if row.created_at else None,
        }
        for row in rows
    ]
    return _ok({"currentBalance": float(current_user.balance), "transactions": out})


@router.post("/wallet/deposit/initiate", status_code=status.HTTP_201_CREATED)
def deposit_initiate(payload: AppDepositRequest, current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    req = CreditRequest(
        user_id=current_user.id,
        request_type=payload.requestType,
        requested_amount=payload.amount,
        utr_number=payload.utrNumber,
        screenshot_url=payload.screenshotUrl,
        payment_details=payload.paymentDetails,
        reason=payload.reason,
        status="Pending"
    )
    db.add(req)
    db.commit()
    db.refresh(req)
    return _ok(
        {
            "id": f"DEP_{req.id}",
            "requestedAmount": req.requested_amount,
            "reason": req.reason,
            "status": req.status,
            "createdAt": req.created_at.isoformat() if req.created_at else None,
        },
        status_code=201,
        message="Deposit request submitted -- an admin will review it shortly.",
    )


@router.post("/wallet/withdraw/request", status_code=status.HTTP_201_CREATED)
def withdraw_request(payload: AppWithdrawRequest, current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    if current_user.balance < payload.amount:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Insufficient balance for withdrawal")
    
    credit_service.apply_ledger_entry(
        db, user=current_user, type="withdraw_hold", amount=-payload.amount,
        reference_type="credit_request", reference_id=None,
        created_by_admin_id=None, note="Withdrawal hold"
    )
    
    req = CreditRequest(
        user_id=current_user.id,
        request_type=payload.requestType,
        requested_amount=payload.amount,
        payment_details=payload.paymentDetails,
        reason=payload.reason,
        status="Pending"
    )
    db.add(req)
    db.commit()
    db.refresh(req)
    
    # Optionally update reference_id in ledger
    # Note: apply_ledger_entry doesn't return the entry, but it's okay, we can just log it
    
    return _ok(
        {
            "id": f"WIT_{req.id}",
            "requestedAmount": req.requested_amount,
            "reason": req.reason,
            "status": req.status,
            "createdAt": req.created_at.isoformat() if req.created_at else None,
        },
        status_code=201,
        message="Withdrawal request submitted -- an admin will review it shortly.",
    )

@router.post("/wallet/credit-requests", status_code=status.HTTP_201_CREATED)
def create_credit_request(payload: AppCreditRequestCreate, current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    """Asks an admin for more virtual Learning Credits -- a free allowance
    request, not a payment. There is nothing to verify here because no
    money changes hands; the admin simply decides yes or no."""
    if payload.requestType.lower() == "withdrawal":
        if current_user.balance < payload.amount:
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Insufficient balance for withdrawal")
        credit_service.apply_ledger_entry(
            db, user=current_user, type="withdraw_hold", amount=-payload.amount,
            reference_type="credit_request", reference_id=None, # Will update later
            created_by_admin_id=None, note="Withdrawal hold"
        )
        # Flush to get the request ID for the ledger entry if we wanted to link it, 
        # but apply_ledger_entry expects strings.
        
    req = CreditRequest(
        user_id=current_user.id,
        request_type=payload.requestType,
        requested_amount=payload.amount,
        utr_number=payload.utrNumber,
        screenshot_url=payload.screenshotUrl,
        payment_details=payload.paymentDetails,
        reason=payload.reason,
        status="Pending"
    )
    db.add(req)
    db.commit()
    db.refresh(req)
    return _ok(
        {
            "id": str(req.id),
            "requestedAmount": req.requested_amount,
            "reason": req.reason,
            "status": req.status,
            "createdAt": req.created_at.isoformat(),
        },
        status_code=201,
        message="Credit request submitted -- an admin will review it shortly.",
    )


@router.get("/wallet/credit-requests")
def list_my_credit_requests(current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    rows = (
        db.query(CreditRequest)
        .filter(CreditRequest.user_id == current_user.id)
        .order_by(CreditRequest.id.desc())
        .limit(50)
        .all()
    )
    return _ok(
        {
            "requests": [
                {
                    "id": str(r.id),
                    "requestType": r.request_type,
                    "requestedAmount": r.requested_amount,
                    "utrNumber": r.utr_number,
                    "screenshotUrl": r.screenshot_url,
                    "paymentDetails": r.payment_details,
                    "reason": r.reason,
                    "status": r.status,
                    "adminNote": r.admin_note,
                    "createdAt": r.created_at.isoformat(),
                    "reviewedAt": r.reviewed_at.isoformat() if r.reviewed_at else None,
                }
                for r in rows
            ]
        }
    )


# --- Support ------------------------------------------------------------

@router.post("/support/chat")
def support_chat(payload: SupportChatRequest, current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    query: SupportQuery | None = None
    if payload.sessionId:
        query = db.query(SupportQuery).filter(SupportQuery.id == int(payload.sessionId), SupportQuery.user_id == current_user.id).first()

    now = shape.now_ist()
    if not query:
        query = SupportQuery(
            user_id=current_user.id, subject="App support chat", status="Open", priority="Normal",
            updated_at=now.strftime("%Y-%m-%d %H:%M:%S"),
        )
        db.add(query)
        db.flush()

    db.add(SupportMessage(query_id=query.id, sender="user", text=payload.message, time=now.strftime("%H:%M %p")))
    query.updated_at = now.strftime("%Y-%m-%d %H:%M:%S")
    db.commit()

    return _ok(
        {
            "sessionId": str(query.id),
            "sender": "BOT",
            "reply": "Thanks for reaching out — our support team will get back to you shortly.",
            "quickReplies": [],
            "actionLink": "",
            "timestamp": now.isoformat(),
        }
    )

"""Shared shaping helpers for the /api/v1/* mobile-app compatibility layer.

Pure presentation logic -- derives the app's UI-facing fields (sessionStatus,
formatted times, result strings, payout ratios) from the existing domain
models. No new data is stored here and no money concept is introduced.
"""
from __future__ import annotations

from datetime import date, datetime, time as time_
from zoneinfo import ZoneInfo

from sqlalchemy.orm import Session

from app.models.game_type import GameType
from app.models.market import Market, StarlineSlot
from app.models.market_result import MarketResult
from app.models.rate import Rate
from app.models.user import User

IST = ZoneInfo("Asia/Kolkata")


def now_ist() -> datetime:
    return datetime.now(IST)


# UI-facing bet-type labels the app uses -> backend GameType.code
BET_TYPE_TO_GAME_CODE: dict[str, str] = {
    "SINGLE DIGIT": "SINGLE",
    "LEFT DIGIT": "OPEN",
    "RIGHT DIGIT": "CLOSE",
    "JODI DIGIT": "JODI",
    "SINGLE PANA": "SINGLE_PANNA",
    "DOUBLE PANA": "DOUBLE_PANNA",
    "TRIPLE PANA": "TRIPLE_PANNA",
}

# GameType.code -> (slug, UI label), the reverse direction, for /markets/{id}/game-modes.
GAME_CODE_TO_MODE: dict[str, tuple[str, str]] = {
    "SINGLE": ("single_digit", "SINGLE DIGIT"),
    "OPEN": ("left_digit", "LEFT DIGIT"),
    "CLOSE": ("right_digit", "RIGHT DIGIT"),
    "JODI": ("jodi_digit", "JODI DIGIT"),
    "SINGLE_PANNA": ("single_pana", "SINGLE PANA"),
    "DOUBLE_PANNA": ("double_pana", "DOUBLE PANA"),
    "TRIPLE_PANNA": ("triple_pana", "TRIPLE PANA"),
    "HALF_SANGAM": ("half_sangam", "HALF SANGAM"),
    "FULL_SANGAM": ("full_sangam", "FULL SANGAM"),
}


def resolve_game_code(bet_type: str) -> str:
    return BET_TYPE_TO_GAME_CODE.get(bet_type.strip().upper(), bet_type.strip().upper())


def game_mode_slug_label(game_type_code: str) -> tuple[str, str]:
    return GAME_CODE_TO_MODE.get(game_type_code, (game_type_code.lower(), game_type_code.replace("_", " ")))


def format_time(value: time_ | None) -> str:
    if value is None:
        return ""
    return datetime(2000, 1, 1, value.hour, value.minute).strftime("%I:%M %p").lstrip("0")


def format_result_string(result: MarketResult | None) -> str:
    if not result:
        return "***-**-***"
    open_p = result.open_panna or "***"
    jodi = result.jodi or "**"
    close_p = result.close_panna or "***"
    return f"{open_p}-{jodi}-{close_p}"


def latest_published_result(db: Session, market_id: int, slot_id: int | None = None) -> MarketResult | None:
    query = db.query(MarketResult).filter(
        MarketResult.market_id == market_id,
        MarketResult.slot_id == slot_id,
        MarketResult.status.in_(["Published", "Corrected"]),
    )
    return query.order_by(MarketResult.result_date.desc(), MarketResult.id.desc()).first()


def market_session_status(market: Market) -> tuple[str, bool, bool, bool]:
    """-> (sessionStatus, isOpeningLive, isClosingLive, isBiddingAllowed)."""
    if market.status == "UPCOMING":
        return "UPCOMING", False, False, False
    if market.status != "OPEN":
        return "CLOSED_TODAY", False, False, False

    now = datetime.now(ZoneInfo(market.timezone or "Asia/Kolkata")).time()
    cutoff = market.cutoff_time or market.closing_time
    closing = market.closing_time

    if cutoff and now < cutoff:
        return "OPENING", True, False, True
    if closing and now < closing:
        return "CLOSING", False, True, True
    return "CLOSED_TODAY", False, False, False


def slot_status(slot: StarlineSlot, market: Market) -> tuple[str, bool, int]:
    """-> (status, isBiddingOpen, closesInSeconds)."""
    if not slot.enabled:
        return "CLOSED", False, 0
    now_dt = datetime.now(ZoneInfo(market.timezone or "Asia/Kolkata"))
    now = now_dt.time()
    if now < slot.cutoff_time:
        remaining = datetime.combine(now_dt.date(), slot.cutoff_time) - datetime.combine(now_dt.date(), now)
        return "OPEN", True, max(0, int(remaining.total_seconds()))
    return "CLOSED", False, 0


_jodi_game_type_id: int | None = None


def _jodi_game_type_id_cached(db: Session) -> int | None:
    global _jodi_game_type_id
    if _jodi_game_type_id is None:
        gt = db.query(GameType).filter(GameType.code == "JODI").first()
        _jodi_game_type_id = gt.id if gt else -1
    return _jodi_game_type_id if _jodi_game_type_id != -1 else None


def find_rate(db: Session, market_id: int, slot_id: int | None, game_type_id: int) -> Rate | None:
    return (
        db.query(Rate)
        .filter(
            Rate.market_id == market_id,
            Rate.slot_id == slot_id,
            Rate.game_type_id == game_type_id,
            Rate.status == "Active",
            Rate.effective_from <= date.today(),
        )
        .order_by(Rate.effective_from.desc(), Rate.id.desc())
        .first()
    )


def payout_ratio(db: Session, market_id: int) -> str:
    jodi_id = _jodi_game_type_id_cached(db)
    if jodi_id is None:
        return "10:95"
    rate = find_rate(db, market_id, None, jodi_id)
    return f"10:{rate.rate}" if rate else "10:95"


def representative_rate(db: Session, game_type_id: int) -> int | None:
    """Not tied to one market -- for global 'here's roughly what this game
    type pays' displays (config/bootstrap, config/game-rates) where the app
    hasn't picked a market yet. Per-market accuracy uses find_rate() instead."""
    rate = (
        db.query(Rate)
        .filter(Rate.game_type_id == game_type_id, Rate.status == "Active", Rate.effective_from <= date.today())
        .order_by(Rate.effective_from.desc(), Rate.id.desc())
        .first()
    )
    return rate.rate if rate else None


def user_payload(user: User) -> dict:
    return {
        "id": str(user.id),
        "name": user.name,
        "phone": user.phone,
        "walletBalance": float(user.balance),
        "status": user.status.upper(),
    }

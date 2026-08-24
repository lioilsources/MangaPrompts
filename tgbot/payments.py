"""Invoice payload helpers for Telegram Stars payments.

The invoice payload must stay within Telegram's 1–128 byte limit, so keys are
single letters: {"u": user_id, "p": package_id, "n": nonce}.
"""

import json
import uuid

import config


def build_payload(user_id: int, package_id: str) -> str:
    payload = json.dumps(
        {"u": user_id, "p": package_id, "n": uuid.uuid4().hex[:12]},
        separators=(",", ":"),
    )
    if len(payload.encode()) > 128:
        raise ValueError("invoice payload too long")
    return payload


def parse_payload(raw: str) -> tuple[int, str] | None:
    """Returns (user_id, package_id) or None when malformed/unknown."""
    try:
        data = json.loads(raw)
        user_id = int(data["u"])
        package_id = str(data["p"])
    except (json.JSONDecodeError, KeyError, TypeError, ValueError):
        return None
    if package_id not in config.PACKAGES:
        return None
    return user_id, package_id


def validate_pre_checkout(raw_payload: str, payer_id: int, total_amount: int) -> str | None:
    """Returns an error message for answerPreCheckoutQuery, or None when OK."""
    parsed = parse_payload(raw_payload)
    if parsed is None:
        return "Invalid order, please try again from the app."
    user_id, package_id = parsed
    if user_id != payer_id:
        return "This order belongs to a different account."
    if config.PACKAGES[package_id]["stars"] != total_amount:
        return "The order price does not match, please try again."
    return None

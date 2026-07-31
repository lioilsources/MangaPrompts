"""Telegram Mini App initData validation.

Official algorithm (https://core.telegram.org/bots/webapps#validating-data-received-via-the-mini-app):
secret_key = HMAC_SHA256(key="WebAppData", msg=bot_token); the received `hash`
must equal HMAC_SHA256(secret_key, data_check_string) where data_check_string
is the sorted `key=value` pairs (minus `hash`) joined with newlines.
"""

import hashlib
import hmac
import json
import time
from urllib.parse import parse_qsl


class InvalidInitData(ValueError):
    pass


def validate_init_data(init_data: str, bot_token: str, max_age: int = 3600) -> dict:
    """Validates raw initData and returns the parsed `user` object.

    Raises InvalidInitData on any failure (bad signature, stale, malformed).
    """
    if not init_data:
        raise InvalidInitData("empty initData")

    pairs = dict(parse_qsl(init_data, keep_blank_values=True))
    received_hash = pairs.pop("hash", None)
    if not received_hash:
        raise InvalidInitData("missing hash")

    data_check_string = "\n".join(f"{k}={v}" for k, v in sorted(pairs.items()))
    secret_key = hmac.new(b"WebAppData", bot_token.encode(), hashlib.sha256).digest()
    expected = hmac.new(secret_key, data_check_string.encode(), hashlib.sha256).hexdigest()
    if not hmac.compare_digest(expected, received_hash):
        raise InvalidInitData("signature mismatch")

    try:
        auth_date = int(pairs.get("auth_date", "0"))
    except ValueError as e:
        raise InvalidInitData("bad auth_date") from e
    if auth_date <= 0 or time.time() - auth_date > max_age:
        raise InvalidInitData("stale auth_date")

    try:
        user = json.loads(pairs.get("user", "{}"))
    except json.JSONDecodeError as e:
        raise InvalidInitData("bad user payload") from e
    if not isinstance(user, dict) or "id" not in user:
        raise InvalidInitData("missing user id")
    return user

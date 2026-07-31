import hashlib
import hmac
import json
import time
from urllib.parse import urlencode

import pytest

from auth import InvalidInitData, validate_init_data

BOT_TOKEN = "1234567890:TEST_TOKEN_abcdefghijklmnopqrstuvwx"


def make_init_data(bot_token: str = BOT_TOKEN, auth_date: int | None = None, user_id: int = 42) -> str:
    pairs = {
        "auth_date": str(auth_date if auth_date is not None else int(time.time())),
        "query_id": "AAF03QwAAAAAAPTdDAaBCDEF",
        "user": json.dumps({"id": user_id, "first_name": "Test", "username": "tester"}),
    }
    data_check_string = "\n".join(f"{k}={v}" for k, v in sorted(pairs.items()))
    secret_key = hmac.new(b"WebAppData", bot_token.encode(), hashlib.sha256).digest()
    pairs["hash"] = hmac.new(secret_key, data_check_string.encode(), hashlib.sha256).hexdigest()
    return urlencode(pairs)


def test_valid_init_data_returns_user():
    user = validate_init_data(make_init_data(), BOT_TOKEN)
    assert user["id"] == 42
    assert user["username"] == "tester"


def test_tampered_hash_rejected():
    init_data = make_init_data()
    # flip the last hash character
    tampered = init_data[:-1] + ("0" if init_data[-1] != "0" else "1")
    with pytest.raises(InvalidInitData):
        validate_init_data(tampered, BOT_TOKEN)


def test_wrong_bot_token_rejected():
    with pytest.raises(InvalidInitData):
        validate_init_data(make_init_data(), "other:token")


def test_stale_auth_date_rejected():
    init_data = make_init_data(auth_date=int(time.time()) - 7200)
    with pytest.raises(InvalidInitData):
        validate_init_data(init_data, BOT_TOKEN, max_age=3600)


def test_missing_hash_rejected():
    with pytest.raises(InvalidInitData):
        validate_init_data("auth_date=123&user=%7B%22id%22%3A1%7D", BOT_TOKEN)


def test_empty_rejected():
    with pytest.raises(InvalidInitData):
        validate_init_data("", BOT_TOKEN)

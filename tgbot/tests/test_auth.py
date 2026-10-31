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


# --- AUTH_MODE=app -----------------------------------------------------------

APP_TOKEN = "a" * 40


@pytest.fixture
def app_client(tmp_path, monkeypatch):
    from fastapi.testclient import TestClient

    import app as appmod
    from db import Database

    monkeypatch.setattr(appmod.config, "AUTH_MODE", "app")
    monkeypatch.setattr(appmod.config, "APP_TOKEN", APP_TOKEN)
    monkeypatch.setattr(appmod.config, "BOT_TOKEN", "")
    monkeypatch.setattr(appmod.config, "DEV_TOKEN", "")
    monkeypatch.setattr(appmod.config, "DATA_DIR", tmp_path)
    monkeypatch.setattr(appmod, "bot", None)
    monkeypatch.setattr(appmod, "db", Database(tmp_path / "t.db"))
    return TestClient(appmod.app)


def _app_headers(token=APP_TOKEN, user="ol1n"):
    headers = {"Authorization": f"app {token}"}
    if user is not None:
        headers["X-User"] = user
    return headers


def test_app_mode_accepts_token_and_user(app_client):
    assert app_client.get("/api/me", headers=_app_headers()).status_code == 200


def test_app_mode_without_x_user_is_400(app_client):
    assert app_client.get("/api/me", headers=_app_headers(user=None)).status_code == 400


@pytest.mark.parametrize("user", ["a", "A1", "a b", "x" * 33, "../etc", "é-é"])
def test_app_mode_bad_x_user_is_400(app_client, user):
    headers = {"Authorization": f"app {APP_TOKEN}", "X-User": user.encode("latin-1", "replace")}
    assert app_client.get("/api/me", headers=headers).status_code == 400


def test_app_mode_wrong_token_is_401(app_client):
    assert app_client.get("/api/me", headers=_app_headers("b" * 40)).status_code == 401


def test_app_mode_non_ascii_token_is_401_not_500(app_client):
    headers = {"Authorization": "app ".encode() + "é".encode("latin-1") * 40, "X-User": "ol1n"}
    assert app_client.get("/api/me", headers=headers).status_code == 401


def test_app_mode_refuses_tma_even_correctly_signed_with_the_empty_token(app_client):
    """With no BOT_TOKEN the HMAC key is public; this initData would validate."""
    init_data = make_init_data(bot_token="")
    assert validate_init_data(init_data, "")["id"] == 42
    response = app_client.get("/api/me", headers={"Authorization": f"tma {init_data}"})
    assert response.status_code == 401


def test_telegram_mode_refuses_the_app_scheme(app_client, monkeypatch):
    import config

    monkeypatch.setattr(config, "AUTH_MODE", "telegram")
    assert app_client.get("/api/me", headers=_app_headers()).status_code == 401


def test_app_mode_with_no_token_configured_refuses_an_empty_one(app_client, monkeypatch):
    import config

    monkeypatch.setattr(config, "APP_TOKEN", "")
    assert app_client.get("/api/me", headers=_app_headers("")).status_code == 401


def test_app_user_ids_are_stable_negative_and_distinct():
    from auth import app_user_id

    assert app_user_id("ol1n") == app_user_id("ol1n") < 0
    assert app_user_id("ol1n") != app_user_id("ol2n")
    assert app_user_id("a\n") is None
    assert app_user_id(None) is None


def test_app_mode_lifespan_starts_without_bot_token(app_client):
    with app_client as c:
        assert c.get("/healthz").json() == {"status": "ok", "active_jobs": 0}


def test_app_mode_lifespan_refuses_a_short_token(app_client, monkeypatch):
    import config

    monkeypatch.setattr(config, "APP_TOKEN", "short")
    with pytest.raises(RuntimeError, match="APP_TOKEN"):
        with app_client:
            pass


def test_telegram_mode_lifespan_needs_bot_token(app_client, monkeypatch):
    import config

    monkeypatch.setattr(config, "AUTH_MODE", "telegram")
    with pytest.raises(RuntimeError, match="BOT_TOKEN"):
        with app_client:
            pass


def test_invoice_is_404_without_a_bot(app_client):
    response = app_client.post("/api/invoice", json={"package": "s"}, headers=_app_headers())
    assert response.status_code == 404


def test_bot_is_only_used_for_positive_users():
    """Every `bot.x` in the backend sits behind a user_id check, or in the few
    places that cannot run without a bot."""
    import ast
    from pathlib import Path

    allowed = {"lifespan", "create_invoice", "on_refund"}
    root = Path(__file__).resolve().parent.parent
    for name in ("app.py", "render.py"):
        source = (root / name).read_text()
        tree = ast.parse(source)
        for fn in ast.walk(tree):
            if not isinstance(fn, (ast.FunctionDef, ast.AsyncFunctionDef)) or fn.name in allowed:
                continue
            uses = [
                n for n in ast.walk(fn)
                if isinstance(n, ast.Attribute)
                and (
                    (isinstance(n.value, ast.Name) and n.value.id == "bot")
                    or (isinstance(n.value, ast.Attribute) and n.value.attr == "bot")
                )
            ]
            if uses:
                body = ast.get_source_segment(source, fn)
                assert "user_id > 0" in body or "user_id <= 0" in body, f"{name}:{fn.name}"

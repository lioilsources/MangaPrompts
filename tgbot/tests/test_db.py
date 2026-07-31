import pytest

from db import Database

USER = 111


@pytest.fixture
def db(tmp_path):
    return Database(tmp_path / "test.db")


def test_payment_credits_user(db):
    assert db.add_payment("ch1", USER, stars=100, credits=50, package="m") is True
    assert db.credits(USER) == 50


def test_payment_idempotent(db):
    db.add_payment("ch1", USER, stars=100, credits=50, package="m")
    # Telegram may redeliver the same update — the second insert must be a no-op
    assert db.add_payment("ch1", USER, stars=100, credits=50, package="m") is False
    assert db.credits(USER) == 50


def test_spend_free_first_then_credits(db):
    db.add_payment("ch1", USER, stars=25, credits=2, package="s")
    kinds = [db.spend_generation(USER, free_limit=2)[0] for _ in range(4)]
    assert kinds == ["free", "free", "credit", "credit"]
    assert db.credits(USER) == 0
    assert db.spend_generation(USER, free_limit=2) is None


def test_spend_without_anything(db):
    assert db.spend_generation(USER, free_limit=0) is None


def test_undo_usage_restores_credit(db):
    db.add_payment("ch1", USER, stars=25, credits=1, package="s")
    kind, usage_id = db.spend_generation(USER, free_limit=0)
    assert kind == "credit"
    assert db.credits(USER) == 0
    db.undo_usage(usage_id)
    assert db.credits(USER) == 1
    # undone free spend must also free up the quota again
    kind, usage_id = db.spend_generation(USER, free_limit=1)
    assert kind == "free"
    db.undo_usage(usage_id)
    assert db.free_used_today(USER) == 0


def test_undo_usage_unknown_id_is_noop(db):
    db.undo_usage(99999)


def test_refund_marks_and_claws_back(db):
    db.add_payment("ch1", USER, stars=100, credits=50, package="m")
    assert db.mark_refunded("ch1") is True
    assert db.credits(USER) == 0
    assert db.get_payment("ch1")["status"] == "refunded"
    # second refund of the same charge must be rejected
    assert db.mark_refunded("ch1") is False


def test_refund_floors_at_zero(db):
    db.add_payment("ch1", USER, stars=25, credits=10, package="s")
    for _ in range(4):
        db.spend_generation(USER, free_limit=0)
    assert db.credits(USER) == 6
    db.mark_refunded("ch1")
    assert db.credits(USER) == 0


def test_free_quota_counts_only_free(db):
    db.add_payment("ch1", USER, stars=25, credits=5, package="s")
    db.spend_generation(USER, free_limit=1)   # free
    db.spend_generation(USER, free_limit=1)   # credit
    assert db.free_used_today(USER) == 1

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


# --- video ledger (photo animations) -----------------------------------------

def test_spend_video_free_then_credits(db):
    db.add_payment("chv", USER, stars=20, credits=2, package="v1", video=True)
    kinds = [db.spend_video(USER, free_limit=1)[0] for _ in range(3)]
    assert kinds == ["video_free", "video_credit", "video_credit"]
    assert db.video_credits(USER) == 0
    assert db.spend_video(USER, free_limit=1) is None


def test_video_and_image_ledgers_are_independent(db):
    db.add_payment("chi", USER, stars=25, credits=1, package="s")
    db.add_payment("chv", USER, stars=10, credits=1, package="v1", video=True)
    # spending a video credit must not touch image credits, and vice versa
    kind, _ = db.spend_video(USER, free_limit=0)
    assert kind == "video_credit"
    assert db.credits(USER) == 1
    kind, _ = db.spend_generation(USER, free_limit=0)
    assert kind == "credit"
    assert db.video_credits(USER) == 0
    # image free quota untouched by the video_free spend
    db.spend_video(USER, free_limit=1)
    assert db.free_used_today(USER) == 0
    assert db.free_used_today(USER, "video_free") == 1


def test_undo_video_usage(db):
    db.add_payment("chv", USER, stars=10, credits=1, package="v1", video=True)
    kind, usage_id = db.spend_video(USER, free_limit=0)
    assert kind == "video_credit"
    assert db.video_credits(USER) == 0
    db.undo_usage(usage_id)
    assert db.video_credits(USER) == 1
    # undone free spend frees the video quota again
    kind, usage_id = db.spend_video(USER, free_limit=1)
    assert kind == "video_free"
    db.undo_usage(usage_id)
    assert db.free_used_today(USER, "video_free") == 0


def test_video_payment_targets_video_credits(db):
    assert db.add_payment("chv", USER, stars=10, credits=1, package="v1", video=True) is True
    assert db.video_credits(USER) == 1
    assert db.credits(USER) == 0
    # idempotent like image payments
    assert db.add_payment("chv", USER, stars=10, credits=1, package="v1", video=True) is False
    assert db.video_credits(USER) == 1


def test_video_refund_claws_back_video_credits(db):
    db.add_payment("chv", USER, stars=10, credits=1, package="v1", video=True)
    db.add_payment("chi", USER, stars=25, credits=10, package="s")
    assert db.mark_refunded("chv", video=True) is True
    assert db.video_credits(USER) == 0
    assert db.credits(USER) == 10


def test_migration_adds_video_credits(tmp_path):
    import sqlite3

    # a database from before the video feature: users without video_credits
    path = tmp_path / "old.db"
    conn = sqlite3.connect(path)
    conn.executescript(
        """
        CREATE TABLE users(
          user_id INTEGER PRIMARY KEY,
          credits INTEGER NOT NULL DEFAULT 0,
          created REAL NOT NULL
        );
        INSERT INTO users VALUES (111, 7, 0);
        """
    )
    conn.commit()
    conn.close()

    db = Database(path)
    assert db.credits(111) == 7          # existing rows survive
    assert db.video_credits(111) == 0    # new column defaults to 0


def test_video_job_roundtrip(db):
    db.video_job_add("j1", "r1", USER, usage_id=5, scene_label="Dance")
    rows = db.video_jobs_pending()
    assert len(rows) == 1
    assert rows[0]["remote_id"] == "r1"
    assert rows[0]["usage_id"] == 5
    assert rows[0]["scene_label"] == "Dance"
    db.video_job_delete("j1")
    assert db.video_jobs_pending() == []


def test_video_job_roundtrip_keeps_the_timeout(db):
    # a watcher re-attached after a restart must keep the deadline the scene
    # was sized for, not fall back to the floor
    db.video_job_add("j1", "r1", USER, usage_id=7, scene_label="Belly dance", timeout=4200.0)
    (row,) = db.video_jobs_pending()
    assert row["remote_id"] == "r1" and row["timeout"] == 4200.0
    db.video_job_delete("j1")
    assert db.video_jobs_pending() == []


def test_video_jobs_table_migrates_to_timeout(db, tmp_path):
    import sqlite3

    # a DB created before the column existed must still open
    path = tmp_path / "old.db"
    conn = sqlite3.connect(path)
    conn.execute(
        "CREATE TABLE video_jobs(job_id TEXT PRIMARY KEY, remote_id TEXT NOT NULL,"
        " user_id INTEGER NOT NULL, usage_id INTEGER NOT NULL,"
        " scene_label TEXT NOT NULL, created REAL NOT NULL)"
    )
    conn.execute("INSERT INTO video_jobs VALUES('old', 'r0', 1, 1, 'Wink', 0)")
    conn.commit()
    conn.close()

    migrated = Database(path)
    (row,) = migrated.video_jobs_pending()
    assert row["timeout"] == 0  # falls back to the configured floor


def test_spend_generations_free_first_then_credits(db):
    db.add_payment("c1", 7, 25, 5, "s")
    ids = db.spend_generations(7, 2, 4)
    assert len(ids) == 4 and len(set(ids)) == 4
    assert db.free_used_today(7) == 2
    assert db.credits(7) == 3


def test_spend_generations_short_spends_nothing(db):
    db.add_payment("c1", 7, 25, 2, "s")
    assert db.spend_generations(7, 1, 4) is None
    assert db.credits(7) == 2
    assert db.free_used_today(7) == 0


def test_spend_generations_refund_each_row(db):
    db.add_payment("c1", 7, 25, 2, "s")
    ids = db.spend_generations(7, 1, 3)
    for usage_id in ids:
        db.undo_usage(usage_id)
    assert db.credits(7) == 2
    assert db.free_used_today(7) == 0


def test_spend_generations_rolls_back_a_failed_insert(db):
    """Fails on the third usage row, after the credits went and two rows were
    written — the whole spend has to disappear."""

    class Flaky:
        def __init__(self, conn):
            self.conn = conn
            self.inserts = 0

        def __enter__(self):
            return self.conn.__enter__()

        def __exit__(self, *exc):
            return self.conn.__exit__(*exc)

        def execute(self, sql, *args):
            if sql.startswith("INSERT INTO usage"):
                self.inserts += 1
                if self.inserts == 3:
                    raise RuntimeError("disk full")
            return self.conn.execute(sql, *args)

    db.add_payment("c1", 7, 25, 5, "s")
    real = db._conn
    db._conn = Flaky(real)
    with pytest.raises(RuntimeError):
        db.spend_generations(7, 0, 4)
    db._conn = real
    assert db.credits(7) == 5
    assert real.execute("SELECT COUNT(*) AS n FROM usage").fetchone()["n"] == 0


def test_spend_generations_rejects_zero(db):
    with pytest.raises(ValueError):
        db.spend_generations(7, 1, 0)

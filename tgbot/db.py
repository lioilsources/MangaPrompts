"""SQLite persistence: users' credit balances, the payments ledger and the
usage log driving the free daily quota.

Single-process service → one shared connection guarded by a threading.Lock;
every write runs inside one transaction (`with self._conn`), so a payment
credit or a generation spend can never half-apply.
"""

import sqlite3
import threading
import time
from pathlib import Path

FREE_WINDOW_SECONDS = 86400


class Database:
    def __init__(self, path: Path):
        path.parent.mkdir(parents=True, exist_ok=True)
        self._conn = sqlite3.connect(str(path), check_same_thread=False)
        self._conn.row_factory = sqlite3.Row
        self._conn.execute("PRAGMA journal_mode=WAL")
        self._lock = threading.Lock()
        self._migrate()

    def _migrate(self) -> None:
        with self._lock, self._conn:
            self._conn.executescript(
                """
                CREATE TABLE IF NOT EXISTS users(
                  user_id INTEGER PRIMARY KEY,
                  credits INTEGER NOT NULL DEFAULT 0,
                  created REAL NOT NULL
                );
                CREATE TABLE IF NOT EXISTS payments(
                  charge_id TEXT PRIMARY KEY,
                  user_id INTEGER NOT NULL,
                  stars INTEGER NOT NULL,
                  credits INTEGER NOT NULL,
                  package TEXT NOT NULL,
                  status TEXT NOT NULL DEFAULT 'paid',
                  ts REAL NOT NULL
                );
                CREATE TABLE IF NOT EXISTS usage(
                  id INTEGER PRIMARY KEY AUTOINCREMENT,
                  user_id INTEGER NOT NULL,
                  kind TEXT NOT NULL,
                  ts REAL NOT NULL
                );
                CREATE INDEX IF NOT EXISTS idx_usage_user_ts ON usage(user_id, ts);
                CREATE INDEX IF NOT EXISTS idx_payments_user ON payments(user_id);
                CREATE TABLE IF NOT EXISTS video_jobs(
                  job_id TEXT PRIMARY KEY,
                  remote_id TEXT NOT NULL,
                  user_id INTEGER NOT NULL,
                  usage_id INTEGER NOT NULL,
                  scene_label TEXT NOT NULL,
                  created REAL NOT NULL
                );
                """
            )
            # SQLite has no ADD COLUMN IF NOT EXISTS; probe before altering.
            cols = {r["name"] for r in self._conn.execute("PRAGMA table_info(users)")}
            if "video_credits" not in cols:
                self._conn.execute(
                    "ALTER TABLE users ADD COLUMN video_credits INTEGER NOT NULL DEFAULT 0"
                )

    def ensure_user(self, user_id: int) -> None:
        with self._lock, self._conn:
            self._conn.execute(
                "INSERT OR IGNORE INTO users(user_id, credits, created) VALUES(?, 0, ?)",
                (user_id, time.time()),
            )

    def credits(self, user_id: int) -> int:
        with self._lock:
            row = self._conn.execute(
                "SELECT credits FROM users WHERE user_id = ?", (user_id,)
            ).fetchone()
        return row["credits"] if row else 0

    def video_credits(self, user_id: int) -> int:
        with self._lock:
            row = self._conn.execute(
                "SELECT video_credits FROM users WHERE user_id = ?", (user_id,)
            ).fetchone()
        return row["video_credits"] if row else 0

    def free_used_today(self, user_id: int, kind: str = "free") -> int:
        since = time.time() - FREE_WINDOW_SECONDS
        with self._lock:
            row = self._conn.execute(
                "SELECT COUNT(*) AS n FROM usage WHERE user_id = ? AND kind = ? AND ts > ?",
                (user_id, kind, since),
            ).fetchone()
        return row["n"]

    def add_payment(
        self, charge_id: str, user_id: int, stars: int, credits: int, package: str,
        video: bool = False,
    ) -> bool:
        """Records a payment and credits the user (image credits, or video
        credits when `video`). Returns False if this charge_id was already
        processed (Telegram may redeliver updates)."""
        column = "video_credits" if video else "credits"
        with self._lock:
            try:
                with self._conn:
                    self._conn.execute(
                        "INSERT INTO payments(charge_id, user_id, stars, credits, package, ts)"
                        " VALUES(?, ?, ?, ?, ?, ?)",
                        (charge_id, user_id, stars, credits, package, time.time()),
                    )
                    self._conn.execute(
                        "INSERT OR IGNORE INTO users(user_id, credits, created) VALUES(?, 0, ?)",
                        (user_id, time.time()),
                    )
                    self._conn.execute(
                        f"UPDATE users SET {column} = {column} + ? WHERE user_id = ?",
                        (credits, user_id),
                    )
            except sqlite3.IntegrityError:
                return False
        return True

    def spend_generation(self, user_id: int, free_limit: int) -> tuple[str, int] | None:
        """Atomically pays for one generation: free quota first, then credits.

        Returns (kind, usage_id) or None when the user has neither."""
        now = time.time()
        with self._lock, self._conn:
            self._conn.execute(
                "INSERT OR IGNORE INTO users(user_id, credits, created) VALUES(?, 0, ?)",
                (user_id, now),
            )
            used = self._conn.execute(
                "SELECT COUNT(*) AS n FROM usage WHERE user_id = ? AND kind = 'free' AND ts > ?",
                (user_id, now - FREE_WINDOW_SECONDS),
            ).fetchone()["n"]
            if used < free_limit:
                kind = "free"
            else:
                cur = self._conn.execute(
                    "UPDATE users SET credits = credits - 1 WHERE user_id = ? AND credits > 0",
                    (user_id,),
                )
                if cur.rowcount == 0:
                    return None
                kind = "credit"
            cur = self._conn.execute(
                "INSERT INTO usage(user_id, kind, ts) VALUES(?, ?, ?)", (user_id, kind, now)
            )
            return kind, cur.lastrowid

    def spend_video(self, user_id: int, free_limit: int) -> tuple[str, int] | None:
        """Atomically pays for one photo animation: free quota first, then
        video credits. Mirror of spend_generation with its own ledger.

        Returns (kind, usage_id) or None when the user has neither."""
        now = time.time()
        with self._lock, self._conn:
            self._conn.execute(
                "INSERT OR IGNORE INTO users(user_id, credits, created) VALUES(?, 0, ?)",
                (user_id, now),
            )
            used = self._conn.execute(
                "SELECT COUNT(*) AS n FROM usage"
                " WHERE user_id = ? AND kind = 'video_free' AND ts > ?",
                (user_id, now - FREE_WINDOW_SECONDS),
            ).fetchone()["n"]
            if used < free_limit:
                kind = "video_free"
            else:
                cur = self._conn.execute(
                    "UPDATE users SET video_credits = video_credits - 1"
                    " WHERE user_id = ? AND video_credits > 0",
                    (user_id,),
                )
                if cur.rowcount == 0:
                    return None
                kind = "video_credit"
            cur = self._conn.execute(
                "INSERT INTO usage(user_id, kind, ts) VALUES(?, ?, ?)", (user_id, kind, now)
            )
            return kind, cur.lastrowid

    def undo_usage(self, usage_id: int) -> None:
        """Reverts a spend when the generation was never queued or failed."""
        with self._lock, self._conn:
            row = self._conn.execute(
                "SELECT user_id, kind FROM usage WHERE id = ?", (usage_id,)
            ).fetchone()
            if row is None:
                return
            self._conn.execute("DELETE FROM usage WHERE id = ?", (usage_id,))
            if row["kind"] == "credit":
                self._conn.execute(
                    "UPDATE users SET credits = credits + 1 WHERE user_id = ?",
                    (row["user_id"],),
                )
            elif row["kind"] == "video_credit":
                self._conn.execute(
                    "UPDATE users SET video_credits = video_credits + 1 WHERE user_id = ?",
                    (row["user_id"],),
                )

    def get_payment(self, charge_id: str) -> sqlite3.Row | None:
        with self._lock:
            return self._conn.execute(
                "SELECT * FROM payments WHERE charge_id = ?", (charge_id,)
            ).fetchone()

    def mark_refunded(self, charge_id: str, video: bool = False) -> bool:
        """Marks a paid payment refunded and claws back its credits (floored
        at zero — the user may have already spent some)."""
        column = "video_credits" if video else "credits"
        with self._lock, self._conn:
            row = self._conn.execute(
                "SELECT user_id, credits, status FROM payments WHERE charge_id = ?",
                (charge_id,),
            ).fetchone()
            if row is None or row["status"] != "paid":
                return False
            self._conn.execute(
                "UPDATE payments SET status = 'refunded' WHERE charge_id = ?", (charge_id,)
            )
            self._conn.execute(
                f"UPDATE users SET {column} = MAX(0, {column} - ?) WHERE user_id = ?",
                (row["credits"], row["user_id"]),
            )
        return True

    # --- video job re-attach (survives bot restarts mid-render) --------------

    def video_job_add(
        self, job_id: str, remote_id: str, user_id: int, usage_id: int, scene_label: str
    ) -> None:
        with self._lock, self._conn:
            self._conn.execute(
                "INSERT OR REPLACE INTO video_jobs"
                "(job_id, remote_id, user_id, usage_id, scene_label, created)"
                " VALUES(?, ?, ?, ?, ?, ?)",
                (job_id, remote_id, user_id, usage_id, scene_label, time.time()),
            )

    def video_job_delete(self, job_id: str) -> None:
        with self._lock, self._conn:
            self._conn.execute("DELETE FROM video_jobs WHERE job_id = ?", (job_id,))

    def video_jobs_pending(self) -> list[sqlite3.Row]:
        with self._lock:
            return self._conn.execute(
                "SELECT * FROM video_jobs ORDER BY created"
            ).fetchall()

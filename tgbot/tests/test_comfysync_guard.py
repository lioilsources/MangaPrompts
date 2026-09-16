"""guard() must not crash when ComfyUI stops answering — round 2 of the hair
bench (2026-09-14) lost 4+ hours and ~350 cells to exactly that: the service
died, `vram_free_gb()` started returning None, and a bare `{after:.1f}` in
one of the guard's own log lines turned that into an unhandled TypeError
that killed the whole run instead of restarting the service."""

import sys
from pathlib import Path

import pytest

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "tools" / "bench"))

import comfysync  # noqa: E402


def make_comfy(monkeypatch, *, free_sequence, rss=None, queue_busy=False, video=False):
    """A Comfy whose network calls are stubbed: `free_sequence` is popped
    from the front on every vram_free_gb() call (last value repeats)."""
    c = comfysync.Comfy()
    seq = list(free_sequence)
    monkeypatch.setattr(c, "vram_free_gb", lambda: seq.pop(0) if len(seq) > 1 else seq[0])
    monkeypatch.setattr(comfysync, "comfy_rss_gb", lambda: rss)
    monkeypatch.setattr(c, "queue_busy", lambda: queue_busy)
    monkeypatch.setattr(c, "free_models", lambda: None)
    monkeypatch.setattr(comfysync, "drop_page_cache", lambda: 0)
    monkeypatch.setattr(comfysync, "video_busy", lambda: video)
    monkeypatch.setattr(comfysync, "comfy_unit_state", lambda: "failed")
    monkeypatch.setattr(comfysync.time, "sleep", lambda s: None)
    return c


def test_unreachable_comfyui_restarts_instead_of_a_silent_noop(monkeypatch):
    c = make_comfy(monkeypatch, free_sequence=[None])
    calls = []
    monkeypatch.setattr(c, "restart", lambda log: calls.append("restart"))
    logs = []
    c.guard(min_free_gb=20, log=logs.append)
    assert calls == ["restart"]
    assert any("not responding" in m for m in logs)


def test_a_none_reading_after_dropping_page_cache_does_not_crash(monkeypatch):
    # First call (free) sees low memory; second call (after the page-cache
    # drop) sees the service already gone — the exact round-2 sequence.
    c = make_comfy(monkeypatch, free_sequence=[5.0, None, None])
    monkeypatch.setattr(c, "restart", lambda log: None)
    logs = []
    c.guard(min_free_gb=20, log=logs.append)  # must not raise
    assert any("?" in m for m in logs)


def test_plenty_free_does_nothing(monkeypatch):
    c = make_comfy(monkeypatch, free_sequence=[30.0])
    monkeypatch.setattr(c, "restart", lambda log: pytest.fail("should not restart"))
    c.guard(min_free_gb=20, log=lambda m: None)


# ── sharing the box with a video render ─────────────────────────────────
# video-api runs chain.py for the whole job; between two beats ComfyUI's
# queue is empty for a second, and that is exactly when the guard looks.

def test_low_memory_under_a_video_render_never_restarts(monkeypatch):
    c = make_comfy(monkeypatch, free_sequence=[5.0], video=True)
    monkeypatch.setattr(c, "restart", lambda log: pytest.fail("restart would kill the render"))
    monkeypatch.setattr(c, "free_models", lambda: pytest.fail("unloading reloads 27 GB per beat"))
    with pytest.raises(comfysync.CellError, match="not restarting"):
        c.guard(min_free_gb=20, log=lambda m: None)


def test_a_leaking_comfyui_is_not_restarted_between_two_beats(monkeypatch):
    c = make_comfy(monkeypatch, free_sequence=[30.0], rss=50.0, queue_busy=False, video=True)
    monkeypatch.setattr(c, "restart", lambda log: pytest.fail("restart between beats"))
    c.guard(min_free_gb=20, log=lambda m: None)


def test_a_silent_comfyui_under_a_video_render_gets_time_first(monkeypatch):
    c = make_comfy(monkeypatch, free_sequence=[None], video=True)
    answers = iter([None, {"devices": []}])  # stalled once, then back
    monkeypatch.setattr(c, "stats", lambda: next(answers))
    monkeypatch.setattr(c, "restart", lambda log: pytest.fail("the render was only loading"))
    c.guard(min_free_gb=20, log=lambda m: None)


def test_a_timed_out_cell_cancels_itself_not_the_running_render(monkeypatch):
    c = comfysync.Comfy()
    posts = []

    class Resp:
        def __init__(self, data):
            self.data = data

        def json(self):
            return self.data

    queue = {"queue_running": [[0, "video-beat", {}]], "queue_pending": [[1, "bench-cell", {}]]}
    monkeypatch.setattr(c.http, "get", lambda url, timeout: Resp(queue))
    monkeypatch.setattr(c.http, "post", lambda url, json=None, timeout=None: posts.append((url, json)))
    c.cancel("bench-cell")
    assert posts == [(f"{c.url}/queue", {"delete": ["bench-cell"]})]
    posts.clear()
    c.cancel("video-beat")  # our own prompt running → interrupt is right
    assert posts == [(f"{c.url}/interrupt", None)]


# ── the box's own day/night switch ──────────────────────────────────────
# rag-schedule.timer stops comfyui.service at 02:00 for the corpus
# enrichment; on 2026-09-16 the guard brought it straight back up.

def test_a_deliberately_stopped_comfyui_is_not_restarted(monkeypatch):
    c = make_comfy(monkeypatch, free_sequence=[None])
    monkeypatch.setattr(comfysync, "comfy_unit_state", lambda: "inactive")
    ran = []
    monkeypatch.setattr(comfysync.subprocess, "run",
                        lambda *a, **k: ran.append(a[0]) or type("R", (), {"stdout": "", "returncode": 0})())
    with pytest.raises(comfysync.CellError, match="inactive"):
        c.guard(min_free_gb=20, log=lambda m: None)
    assert not any("restart" in " ".join(cmd) for cmd in ran)


def test_a_failed_comfyui_is_restarted(monkeypatch):
    c = make_comfy(monkeypatch, free_sequence=[None])
    monkeypatch.setattr(comfysync, "comfy_unit_state", lambda: "failed")
    calls = []
    monkeypatch.setattr(c, "restart", lambda log: calls.append("restart"))
    c.guard(min_free_gb=20, log=lambda m: None)
    assert calls == ["restart"]


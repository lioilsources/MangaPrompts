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


def make_comfy(monkeypatch, *, free_sequence, rss=None, queue_busy=False):
    """A Comfy whose network calls are stubbed: `free_sequence` is popped
    from the front on every vram_free_gb() call (last value repeats)."""
    c = comfysync.Comfy()
    seq = list(free_sequence)
    monkeypatch.setattr(c, "vram_free_gb", lambda: seq.pop(0) if len(seq) > 1 else seq[0])
    monkeypatch.setattr(comfysync, "comfy_rss_gb", lambda: rss)
    monkeypatch.setattr(c, "queue_busy", lambda: queue_busy)
    monkeypatch.setattr(c, "free_models", lambda: None)
    monkeypatch.setattr(comfysync, "drop_page_cache", lambda: 0)
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

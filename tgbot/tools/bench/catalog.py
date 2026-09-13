"""What the bench renders: styles and hairstyles, and the prompts the app
would build for them.

Restyle prompts come straight from `lib/config/restyle_styles.dart` (parsed,
not copied), so a change to the app's medium sentences is measured the next
run. Painter candidates and hairstyle candidates are JSON until they pass the
gate; hair prompts come from the bot's own `hairprompt.py`.
"""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[2]
ASSETS = REPO / "assets" / "comfyui"
RESTYLE_DART = REPO / "lib" / "config" / "restyle_styles.dart"

BASELINE = "__baseline"

sys.path.insert(0, str(HERE.parents[1]))  # tgbot/
import hairprompt  # noqa: E402

HAIR_NEGATIVE = hairprompt.NEGATIVE


def _dart_string(body: str) -> str:
    """Concatenated single-quoted Dart literals → one Python string."""
    parts = re.findall(r"'((?:[^'\\]|\\.)*)'", body)
    return "".join(parts).replace("\\'", "'").replace("$_baseNegative", "{base}")


def _dart_const(src: str, name: str) -> str:
    m = re.search(rf"const {name}\s*=\s*(.*?);", src, re.S)
    if not m:
        raise KeyError(name)
    return _dart_string(m.group(1))


def restyle_catalog() -> dict:
    src = RESTYLE_DART.read_text()
    styles = {}
    for body in re.findall(r"RestyleStyle\((.*?)\n  \),", src, re.S):
        fields = {}
        for key in ("id", "label", "block"):
            m = re.search(rf"{key}:\s*((?:'(?:[^'\\]|\\.)*'\s*)+)", body)
            if m:
                fields[key] = _dart_string(m.group(1))
        m = re.search(r"group:\s*(\w+)", body)
        if m:
            fields["group"] = m.group(1)
        if "id" in fields and "block" in fields:
            styles[fields["id"]] = fields
    base = _dart_const(src, "_baseNegative")
    return {
        "styles": styles,
        "heads": {
            "photo": _dart_const(src, "_photoMedium"),
            "illustration": _dart_const(src, "_illustrationMedium"),
        },
        "negatives": {
            "photo": _dart_const(src, "_photoNegative").replace("{base}", base),
            "illustration": _dart_const(src, "_illustrationNegative").replace("{base}", base),
        },
    }


def painter_candidates() -> dict:
    return {p["id"]: p for p in json.loads((HERE / "candidates" / "painters.json").read_text())}


def restyle_style(style_id: str) -> dict:
    """Registry first, then painter candidates — a candidate is measured under
    the same seed and photo as the registry style it might duplicate."""
    if style_id == BASELINE:
        return {"id": BASELINE, "label": "(no style)", "block": ""}
    reg = restyle_catalog()["styles"]
    if style_id in reg:
        return reg[style_id]
    cands = painter_candidates()
    if style_id in cands:
        c = cands[style_id]
        return {"id": style_id, "label": c.get("artist", style_id), "block": c["block"]}
    raise KeyError(f"unknown restyle style '{style_id}'")


def restyle_prompt(style_id: str, medium: str) -> tuple[str, str]:
    cat = restyle_catalog()
    head = cat["heads"][medium]
    block = restyle_style(style_id)["block"]
    return (f"{head}, {block}" if block else head), cat["negatives"][medium]


def hairstyles() -> dict:
    return {
        h["id"]: h
        for h in json.loads((HERE / "candidates" / "hairstyles.json").read_text())
    }


def hair_prompt(style: dict, colour: str | None, engine: str = "flux") -> str:
    """The prompt the bot would send for this candidate (tgbot/hairprompt.py)."""
    return hairprompt.prompt(style["block"], style["id"], style["shape"], colour, engine)

#!/usr/bin/env python3
"""Contact sheet for a bench run: one self-contained HTML file.

    sheet.py out/hair-r1 [--mask] [--title "Hair round 1"]

Rows are styles, columns are (engine, medium, ckpt, src, seed, sweep). The
checkpoint belongs in the key: a run that renders the same matrix on two
checkpoints into one directory would otherwise collapse both into one column
and silently show only whichever landed last. Thumbnails
are embedded as data URIs so the file can be opened anywhere or published as
an artifact. Numbers under each image come from metrics.json when score.py
has run; the row header carries the auto verdict per engine. The eye decides
— the metrics only sort what to look at first.
"""

from __future__ import annotations

import argparse
import base64
import html
import io
import json
from collections import defaultdict
from pathlib import Path

from PIL import Image

THUMB = 220


def data_uri(path: Path, size: int = THUMB) -> str:
    with Image.open(path) as im:
        im = im.convert("RGB")
        im.thumbnail((size, size * 2))
        buf = io.BytesIO()
        im.save(buf, "JPEG", quality=78)
    return "data:image/jpeg;base64," + base64.b64encode(buf.getvalue()).decode()


def col_key(row: dict) -> tuple:
    return (row["engine"], row.get("medium", ""), row.get("ckpt") or "", row["src"], row["seed"],
            json.dumps(row["sweep"], sort_keys=True))


def col_label(key: tuple, show_ckpt: bool = False) -> str:
    engine, medium, ckpt, src, seed, sweep = key
    # The checkpoint is named only when the sheet holds more than one: in a
    # single-model run it is a constant, and engine already implies it.
    parts = [engine, medium]
    if show_ckpt and ckpt:
        parts.append(Path(ckpt).stem)
    parts += [Path(src).stem, f"s{seed}"]
    if sweep != "{}":
        parts.append(", ".join(f"{k.split('.', 1)[-1]}={v}" for k, v in json.loads(sweep).items()))
    return " · ".join(p for p in parts if p)


def badge(m: dict, task: str) -> str:
    if not m:
        return ""
    if m.get("status") != "done":
        return f'<div class="b bad">{html.escape(str(m.get("status")))}: {html.escape(str(m.get("error") or ""))[:60]}</div>'
    bits = []
    ident = m.get("identity")
    bits.append(f'<span class="{"ok" if ident is not None and ident >= 0.6 else "bad"}">id {ident if ident is not None else "—"}</span>')
    if task == "hair":
        for k, label in (("length_ok", "len"), ("bangs_ok", "fringe"), ("recognised", "clip"), ("colour_ok", "colour")):
            v = m.get(k)
            if v is not None:
                bits.append(f'<span class="{"ok" if v else "bad"}">{label}</span>')
        if m.get("clip_rank") is not None:
            bits.append(f'<span class="dim">#{m["clip_rank"]} ({m.get("clip_rank_src")})</span>')
    elif m.get("reaction") is not None:
        bits.append(f'<span class="dim">react {m["reaction"]}</span>')
    if m.get("faces", 1) != 1:
        bits.append(f'<span class="bad">{m.get("faces")} faces</span>')
    return '<div class="b">' + " ".join(bits) + "</div>"


def build(run: Path, show_mask: bool, title: str) -> str:
    manifest = json.loads((run / "manifest.json").read_text())
    metrics = json.loads((run / "metrics.json").read_text()) if (run / "metrics.json").exists() else {"cells": {}, "summary": {}}
    task = manifest["task"]
    rows: dict[str, dict] = defaultdict(dict)
    cols: set[tuple] = set()
    for key, row in manifest["cells"].items():
        cols.add(col_key(row))
        label = row["style"] + (f"+{row['colour']}" if row.get("colour") else "")
        rows[label][col_key(row)] = (key, row)
    cols_sorted = sorted(cols)
    multi_ckpt = len({c[2] for c in cols_sorted}) > 1
    style_meta = {}
    if task == "hair":
        import catalog

        import haircolours

        style_meta = dict(catalog.hairstyles())
        style_meta[haircolours.KEEP_CUT] = catalog.hair_style(haircolours.KEEP_CUT)
        for key_ in list(rows):
            if "+" in key_:
                st, col = key_.split("+", 1)
                base = style_meta.get(st, {})
                c = haircolours.COLOURS[col]
                style_meta[key_] = {**base, "label": f"{base.get('label', st)} + {c['label']}",
                                    "cs": f"{base.get('cs', '')} · {c['cs']}"}

    srcs_used = sorted({c[3] for c in cols_sorted})
    out = [f"""<title>{html.escape(title)}</title>
<style>
:root {{ --bg:#fafaf7; --fg:#1d1d1b; --dim:#77756f; --ok:#1f7a4d; --bad:#b3261e; --line:#e2e0da; --card:#fff; }}
@media (prefers-color-scheme: dark) {{ :root:not([data-theme="light"]) {{ --bg:#161614; --fg:#ecebe6; --dim:#9a988f; --ok:#6fcf97; --bad:#ff8a80; --line:#2d2c29; --card:#1f1f1c; }} }}
:root[data-theme="dark"] {{ --bg:#161614; --fg:#ecebe6; --dim:#9a988f; --ok:#6fcf97; --bad:#ff8a80; --line:#2d2c29; --card:#1f1f1c; }}
body {{ background:var(--bg); color:var(--fg); font:13px/1.4 system-ui, sans-serif; padding:16px; }}
h1 {{ font-size:20px; margin:0 0 4px; }}
.note {{ color:var(--dim); max-width:70ch; }}
.wrap {{ overflow-x:auto; }}
table {{ border-collapse:collapse; }}
th, td {{ border-bottom:1px solid var(--line); padding:6px; vertical-align:top; text-align:left; }}
th.col {{ font-weight:500; color:var(--dim); font-size:11px; max-width:{THUMB}px; }}
td.style {{ min-width:180px; max-width:240px; position:sticky; left:0; background:var(--bg); }}
img {{ width:{THUMB}px; display:block; border-radius:4px; background:var(--card); }}
.b {{ font-size:11px; margin-top:3px; display:flex; gap:6px; flex-wrap:wrap; }}
.ok {{ color:var(--ok); }} .bad {{ color:var(--bad); }} .dim {{ color:var(--dim); }}
.verdict {{ font-size:11px; margin-top:4px; }}
.srcs {{ display:flex; gap:8px; flex-wrap:wrap; margin:12px 0; }}
.srcs figure {{ margin:0; font-size:11px; color:var(--dim); }}
.srcs img {{ width:120px; }}
</style>
<h1>{html.escape(title)}</h1>
<p class="note">Rows are styles, columns engine · checkpoint · source · seed. Under each image: ArcFace identity to the source
(≥ 0.6 same person) and, for hair, whether the length, fringe and CLIP checks passed; <code>#n (m)</code> is the target
label's CLIP rank on the output (and on the source). Auto verdicts only sort — the look decides.</p>
<div class="srcs">""" + "".join(
        f'<figure><img src="{data_uri(run / manifest["srcs"][s], 120)}" alt="{html.escape(s)}"><figcaption>{html.escape(s)}</figcaption></figure>'
        for s in srcs_used
    ) + "</div><div class='wrap'><table><tr><th></th>" + "".join(
        f'<th class="col">{html.escape(col_label(c, multi_ckpt))}</th>' for c in cols_sorted
    ) + "</tr>"]

    for style in sorted(rows, key=lambda s: (style_meta.get(s, {}).get("group", ""), style_meta.get(s, {}).get("section", ""), s)):
        meta = style_meta.get(style, {})
        verdicts = []
        for skey, s in metrics.get("summary", {}).items():
            st, engine, medium, sweep = skey.split("|", 3)
            if st == style:
                label = engine + (f"/{medium}" if medium else "") + ("" if sweep == "{}" else f" {sweep}")
                reasons = ", ".join(s["reasons"])
                verdicts.append(f'<div class="verdict {"ok" if s["auto"] == "pass" else "bad"}">{html.escape(label)}: {s["auto"]}{(" — " + html.escape(reasons)) if reasons else ""}</div>')
        header = f"<b>{html.escape(meta.get('label', style))}</b>"
        if meta:
            shape = meta["shape"]
            header += f'<div class="dim">{html.escape(meta.get("cs", ""))}<br>{shape["length"]} · fringe {shape["bangs"]}{" · updo" if shape["updo"] else ""}</div>'
        out.append(f'<tr><td class="style">{header}{"".join(verdicts)}</td>')
        for c in cols_sorted:
            if c not in rows[style]:
                out.append("<td></td>")
                continue
            key, row = rows[style][c]
            m = metrics.get("cells", {}).get(key, {})
            cell = ""
            if row["status"] == "done" and (run / row["file"]).exists():
                cell += f'<img loading="lazy" src="{data_uri(run / row["file"])}" alt="">'
                if show_mask and row.get("mask") and (run / row["mask"]).exists():
                    cell += f'<img loading="lazy" src="{data_uri(run / row["mask"], 110)}" style="width:110px;margin-top:4px" alt="mask">'
            cell += badge(m or {"status": row["status"], "error": row.get("error")}, task)
            out.append(f"<td>{cell}</td>")
        out.append("</tr>")
    out.append("</table></div>")
    return "\n".join(out)


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("run")
    ap.add_argument("--mask", action="store_true")
    ap.add_argument("--title")
    ap.add_argument("--out")
    args = ap.parse_args()
    run = Path(args.run)
    target = Path(args.out) if args.out else run / "sheet.html"
    target.write_text(build(run, args.mask, args.title or run.name))
    print(target)


if __name__ == "__main__":
    import sys

    sys.path[:0] = [str(Path(__file__).resolve().parents[1].parent), str(Path(__file__).resolve().parent)]
    main()

#!/usr/bin/env python3
"""Write lib/config/hairstyle_catalog.dart from the gate's verdicts.

    export_catalog.py verdicts.json [--engines kontext] [--ol1nllm /path/to/Ol1nLLM]
                      [--bench out/hair-r2 --colours-bench out/hair-colours-r2]

`verdicts.json` maps hairstyle id → {"verdict": …, "note": …}, where the
verdict is "accept" | "reject" | "retune" for every engine or a map engine →
verdict. Each app gets what was accepted on every engine it runs: Tsumiki runs
HAIR_ENGINE alone (`--engines`, re-export after switching it), Ol1nLLM picks
Kontext or SDXL by preset (`--ol1nllm-engines`). Blocks and shapes come from
candidates/hairstyles.json, so a retuned block is edited there and re-measured,
never patched in Dart.

With `--bench` the accepted styles also get a preview: the bench's own output
for that style on the group's primary portrait (w-long / m-short — the same
synthetic face under every style, so the eye compares hair, nothing else),
cropped around the face box to assets/hair/<id>.jpg in each app. The cell is
the app's engine where it was recognised, else the best-scoring source. With
`--colours-bench` each accepted colour gets a swatch: the hair colour the
bench *measured* on the accepted cells (mean Lab → sRGB), not the target
range — what the model paints, not what the prompt asked for. Full-size
images live on the box; `--list-previews` prints the files to pull first.
"""

import argparse

import json
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[2]
TARGET = REPO / "lib" / "config" / "hairstyle_catalog.dart"


def dart_str(s: str) -> str:
    return "'" + s.replace("\\", "\\\\").replace("'", "\\'").replace("$", "\\$") + "'"


PRIMARY_SRC = {"Women": "w-long.png", "Men": "m-short.png"}
PREVIEW_W, PREVIEW_H = 256, 320


def lab_to_hex(L: float, a: float, b: float) -> str:
    """CIE Lab (D65) → sRGB hex, clipped. Same formula as the lab's arch page."""
    fy = (L + 16) / 116
    fx, fz = fy + a / 500, fy - b / 200

    def f(t):
        return t ** 3 if t ** 3 > 0.008856 else (t - 16 / 116) / 7.787

    X, Y, Z = 0.95047 * f(fx), 1.0 * f(fy), 1.08883 * f(fz)
    r = 3.2406 * X - 1.5372 * Y - 0.4986 * Z
    g = -0.9689 * X + 1.8758 * Y + 0.0415 * Z
    bl = 0.0557 * X - 0.2040 * Y + 1.0570 * Z

    def gam(c):
        c = c * 12.92 if c <= 0.0031308 else 1.055 * c ** (1 / 2.4) - 0.055
        return max(0, min(255, round(c * 255)))

    return "%02X%02X%02X" % (gam(r), gam(g), gam(bl))


def load_bench(d: Path) -> tuple[dict, dict]:
    return (json.loads((d / "manifest.json").read_text())["cells"],
            json.loads((d / "metrics.json").read_text())["cells"])


def preview_cell(bench: tuple[dict, dict], style: dict, engines: list[str]) -> dict | None:
    """The cell shown as the style's preview: recognised on the primary
    portrait if possible, else the best (recognised, identity) among sources."""
    cells, metrics = bench
    primary = PRIMARY_SRC[style["group"]]
    best, best_key = None, None
    for k, c in cells.items():
        if c.get("style") != style["id"] or c.get("engine") not in engines or c.get("status") != "done":
            continue
        m = metrics.get(k, {})
        key = (bool(m.get("recognised")), c["src"] == primary, m.get("identity") or 0.0)
        if best_key is None or key > best_key:
            best, best_key = c, key
    return best


def write_preview(bench_dir: Path, cell: dict, out: Path) -> None:
    """Head crop around the face box, PREVIEW_W×PREVIEW_H JPEG. Room above
    for updos and a fringe, more below for lengths past the chin."""
    from PIL import Image

    x0, y0, x1, y1 = cell["face_box"]
    fh, cx = y1 - y0, (x0 + x1) / 2
    with Image.open(bench_dir / cell["file"]) as im:
        W, H = im.size
        top = max(0, y0 - 1.0 * fh)
        bottom = min(H, y1 + 1.3 * fh)
        h = bottom - top
        w = h * PREVIEW_W / PREVIEW_H
        left = min(max(0, cx - w / 2), W - w)
        crop = im.convert("RGB").crop((round(left), round(top), round(left + w), round(bottom)))
        crop.resize((PREVIEW_W, PREVIEW_H), Image.LANCZOS).save(out, "JPEG", quality=82, optimize=True)


def swatch(bench: tuple[dict, dict], colour_id: str, engines: list[str]) -> str | None:
    """Mean measured hair colour over the cells where the bench read the
    target colour back, as sRGB hex; None when nothing was measured."""
    cells, metrics = bench
    labs = [metrics[k]["hair_lab"] for k, c in cells.items()
            if c.get("colour") == colour_id and c.get("engine") in engines
            and metrics.get(k, {}).get("colour_ok") and metrics[k].get("hair_lab")]
    if not labs:
        return None
    n = len(labs)
    return lab_to_hex(sum(x["L"] for x in labs) / n, sum(x["a"] for x in labs) / n,
                      sum(x["b"] for x in labs) / n)


def accepted(verdicts: dict, key: str, engines: list[str]) -> bool:
    v = verdicts.get(key, {}).get("verdict")
    if isinstance(v, dict):
        return all(v.get(e) == "accept" for e in engines)
    return v == "accept"


def accepted_colours(verdicts: dict, engines: list[str]) -> list[tuple[str, dict]]:
    """Colours are gated like styles, under "colour:<id>" keys in verdicts.json."""
    sys.path.insert(0, str(HERE.parents[1]))
    import haircolours

    return [(cid, c) for cid, c in haircolours.COLOURS.items()
            if accepted(verdicts, f"colour:{cid}", engines)]


def ol1nllm_catalog(styles: list[dict], repo: Path, colours: list[tuple[str, dict]],
                    swatches: dict[str, str] | None = None) -> None:
    """Same survivors for Ol1nLLM's Kadeřník, Czech labels."""
    target = repo / "lib" / "models" / "hairstyle_catalog.dart"
    sections = {"Cuts": "Střihy", "Bangs": "Ofiny", "Texture": "Textura", "Updos": "Účesy nahoru",
                "Short": "Krátké", "Medium": "Střední", "Long": "Dlouhé",
                "Braids": "Copánky"}
    lines = [
        "// GENERATED by MangaPrompts tgbot/tools/bench/export_catalog.py from the",
        "// bench verdicts (MangaPrompts/docs/hair-matrix.md). Do not edit by hand.",
        "",
        # HairShape a spol. potřebují jen účesy — s prázdnou gate by nepoužitý
        # import shodil `flutter analyze` v CI appky
        *(["import 'hair_mask.dart';"] if styles else []),
        "import 'hairstyle_preset.dart';",
        "",
        "const kHairstyles = <HairstylePreset>[",
    ]
    for c in styles:
        sh = c["shape"]
        label = c["cs"][:1].upper() + c["cs"][1:]
        lines += [
            "  HairstylePreset(",
            f"    id: {dart_str(c['id'])},",
            f"    label: {dart_str(label)},",
            f"    group: {'kHairGroupWomen' if c['group'] == 'Women' else 'kHairGroupMen'},",
            f"    section: {dart_str(sections[c['section']])},",
            "    block:",
            f"        {dart_str(c['block'])},",
            f"    shape: HairShape(length: HairLength.{sh['length']}, bangs: HairBangs.{sh['bangs']}, updo: {str(sh['updo']).lower()}),",
            "  ),",
        ]
    lines.append("];")
    lines += ["", "const kHairColours = <HairColourPreset>["]
    for cid, c in colours:
        lines += [
            "  HairColourPreset(",
            f"    id: {dart_str(cid)},",
            f"    label: {dart_str(c['cs'][:1].upper() + c['cs'][1:])},",
            f"    phrase: {dart_str(c['phrase'])},",
            *([f"    swatch: 0xFF{swatches[cid]},"] if swatches and swatches.get(cid) else []),
            "  ),",
        ]
    lines.append("];")
    target.write_text("\n".join(lines) + "\n")
    print(f"{target}: {len(styles)} hairstyles, {len(colours)} colours")


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("verdicts")
    ap.add_argument("--engines", default="kontext", help="Tsumiki's HAIR_ENGINE")
    ap.add_argument("--ol1nllm", type=Path)
    ap.add_argument("--ol1nllm-engines", default="kontext,sdxl")
    ap.add_argument("--bench", type=Path, help="run dir with the styles' images (previews)")
    ap.add_argument("--colours-bench", type=Path, help="run dir with the colours' metrics (swatches)")
    ap.add_argument("--list-previews", action="store_true",
                    help="print the bench images the previews need, then stop")
    args = ap.parse_args()
    verdicts = json.loads(Path(args.verdicts).read_text())
    cands = json.loads((HERE / "candidates" / "hairstyles.json").read_text())

    def split(s: str) -> list[str]:
        return [e.strip() for e in s.split(",") if e.strip()]

    bench = load_bench(args.bench) if args.bench else None
    cbench = load_bench(args.colours_bench) if args.colours_bench else None

    def previews(styles: list[dict], engines: list[str], assets: Path) -> None:
        if not bench:
            return
        assets.mkdir(parents=True, exist_ok=True)
        for c in styles:
            cell = preview_cell(bench, c, engines)
            if cell is None:
                sys.exit(f"{c['id']}: v {args.bench} není žádná buňka pro {engines}")
            write_preview(args.bench, cell, assets / f"{c['id']}.jpg")
        # nothing stale: a style that left the gate leaves its picture too
        keep = {f"{c['id']}.jpg" for c in styles}
        for old in assets.glob("*.jpg"):
            if old.name not in keep:
                old.unlink()

    def swatches(colours: list[tuple[str, dict]], engines: list[str]) -> dict[str, str]:
        return {cid: h for cid, _ in colours if cbench and (h := swatch(cbench, cid, engines))}

    if args.list_previews:
        if not bench:
            sys.exit("--list-previews potřebuje --bench")
        seen = set()
        for engines in (split(args.engines), split(args.ol1nllm_engines) if args.ol1nllm else []):
            if not engines:
                continue
            for c in cands:
                if accepted(verdicts, c["id"], engines):
                    cell = preview_cell(bench, c, engines)
                    if cell and cell["file"] not in seen:
                        seen.add(cell["file"])
                        print(cell["file"])
        return

    if args.ol1nllm:
        engines = split(args.ol1nllm_engines)
        styles = [c for c in cands if accepted(verdicts, c["id"], engines)]
        colours = accepted_colours(verdicts, engines)
        ol1nllm_catalog(styles, args.ol1nllm, colours, swatches(colours, engines))
        previews(styles, engines, args.ol1nllm / "assets" / "hair")
    engines = split(args.engines)
    styles = [c for c in cands if accepted(verdicts, c["id"], engines)]
    colours = accepted_colours(verdicts, engines)
    sw = swatches(colours, engines)
    previews(styles, engines, REPO / "assets" / "hair")
    lines = [
        "// GENERATED by tgbot/tools/bench/export_catalog.py from the bench verdicts",
        "// (docs/hair-matrix.md). Do not edit by hand: change the candidate in",
        "// tgbot/tools/bench/candidates/hairstyles.json, re-measure, re-export.",
        "",
        "import 'hairstyles.dart';",
        "",
        "const kHairstyles = <Hairstyle>[",
    ]
    for c in styles:
        sh = c["shape"]
        lines += [
            "  Hairstyle(",
            f"    id: {dart_str(c['id'])},",
            f"    label: {dart_str(c['label'])},",
            f"    group: {'kHairGroupWomen' if c['group'] == 'Women' else 'kHairGroupMen'},",
            f"    section: {dart_str(c['section'])},",
            "    block:",
            f"        {dart_str(c['block'])},",
            f"    shape: HairShape(length: HairLength.{sh['length']}, bangs: HairBangs.{sh['bangs']}, updo: {str(sh['updo']).lower()}),",
            "  ),",
        ]
    lines.append("];")
    lines += ["", "const kHairColours = <HairColour>["]
    for cid, c in colours:
        lines += [
            "  HairColour(",
            f"    id: {dart_str(cid)},",
            f"    label: {dart_str(c['label'])},",
            f"    group: {dart_str(c['group'])},",
            *([f"    swatch: 0xFF{sw[cid]},"] if sw.get(cid) else []),
            "  ),",
        ]
    lines.append("];")
    TARGET.write_text("\n".join(lines) + "\n")
    print(f"{TARGET}: {len(styles)} of {len(cands)} candidates, {len(colours)} colours "
          f"({'+'.join(engines)})")


if __name__ == "__main__":
    main()

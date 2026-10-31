#!/usr/bin/env python3
"""Write packages/tsumiki_shared/lib/catalogs/hairstyle_catalog.dart from the gate's verdicts.

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
cropped around the face box to packages/tsumiki_shared/assets/hair/<id>.jpg (Tsumiki,
Restyler) and to Ol1nLLM's assets/hair/<id>.jpg. The cell is
the app's engine where it was recognised, else the best-scoring source. With
`--colours-bench` each accepted colour gets a swatch: the hair colour the
bench *measured* on the accepted cells (mean Lab → sRGB), not the target
range — what the model paints, not what the prompt asked for. Full-size
images live on the box; `--list-previews` prints the files to pull first.
"""

import argparse

import json
import re
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[2]
SHARED = REPO / "packages" / "tsumiki_shared"
TARGET = SHARED / "lib" / "catalogs" / "hairstyle_catalog.dart"


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
    """The cell shown as the style's preview.

    **Primární předloha vyhrává nade vším ostatním.** Celý smysl náhledů je,
    že je na každém řádku tatáž tvář, takže oko porovnává jen vlasy; náhled
    z jiné fotky ten smysl ruší — v listu se najednou objeví jiný člověk na
    jiném pozadí. Dřív byl v klíči první `recognised`, takže buňka rozpoznaná
    na *jiné* předloze přebila nerozpoznanou na té primární: `pixie`,
    `half-up` a `space-buns` tím v Tsumiki dostaly blondýnu na modrém, zatímco
    zbytek listu byl brunet na šedém. `recognised` navíc od přegatování
    nerozhoduje ani o katalogu (neprojde na reálných předlohách,
    viz `metric_check.py`), takže nemá co řídit ani náhledy.

    Mezi buňkami téže předlohy rozhoduje identita — tam je to vlastnost
    obrázku, ne nálepky."""
    cells, metrics = bench
    primary = PRIMARY_SRC[style["group"]]
    best, best_key = None, None
    for k, c in cells.items():
        if c.get("style") != style["id"] or c.get("engine") not in engines or c.get("status") != "done":
            continue
        m = metrics.get(k, {})
        key = (c["src"] == primary, m.get("identity") or 0.0)
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


def engines_of(verdicts: dict, key: str, engines: list[str]) -> list[str]:
    """Which of `engines` accepted this entry, in the order given.

    The gate is per engine and the two disagree in *both* directions: Kontext
    keeps platinum blonde platinum where SDXL paints it brown (colour_ok 0%),
    SDXL keeps a lob or a pixie recognisable where Kontext loses it
    (recognised 33%). Demanding every engine threw away 20 measured, passing
    entries — most of the everyday haircuts — so an entry ships as soon as one
    engine accepts it and carries which, and the app runs it there.
    """
    v = verdicts.get(key, {}).get("verdict")
    if not isinstance(v, dict):
        return list(engines) if v == "accept" else []
    return [e for e in engines if v.get(e) == "accept"]


def accepted(verdicts: dict, key: str, engines: list[str]) -> bool:
    return bool(engines_of(verdicts, key, engines))


def accepted_colours(verdicts: dict,
                     engines: list[str]) -> list[tuple[str, dict, list[str]]]:
    """Colours are gated like styles, under "colour:<id>" keys in verdicts.json."""
    sys.path.insert(0, str(HERE.parents[1]))
    import haircolours

    return [(cid, c, es) for cid, c in haircolours.COLOURS.items()
            if (es := engines_of(verdicts, f"colour:{cid}", engines))]


def dart_engines(engines: list[str]) -> str:
    return "[" + ", ".join(f"HairEngine.{e}" for e in engines) + "]"


# ── tasks with a catalog of their own ───────────────────────────────────────
#
#   export_catalog.py --task beard verdicts-beard.json [--bench out/beard-r1]
#   export_catalog.py --task live verdicts-live.json
#   export_catalog.py --task carries out/pipeline-r1 [--engine flux]

BEARD_TARGET = SHARED / "lib" / "catalogs" / "beard_catalog.dart"
MOTIONS_TARGET = SHARED / "lib" / "catalogs" / "motions_catalog.dart"
RESTYLE_TARGET = SHARED / "lib" / "catalogs" / "restyle_styles.dart"


def dart_double(v: float) -> str:
    return repr(float(v))


def beard_region(region: dict) -> str:
    args = [f"BeardRegionKind.{region['kind']}"]
    if region.get("below_chin"):
        args.append(f"belowChin: {dart_double(region['below_chin'])}")
    if region.get("moustache"):
        args.append("moustache: true")
    if region.get("chin_sides"):
        args.append("chinSides: true")
    return f"BeardRegion({', '.join(args)})"


def beard_lines(styles: list[dict]) -> list[str]:
    lines = [
        "// GENERATED by tgbot/tools/bench/export_catalog.py from the bench verdicts",
        "// (docs/beard-matrix.md). Do not edit by hand: change the candidate in",
        "// tgbot/tools/bench/candidates/beards.json, re-measure, re-export.",
        "",
        "import 'beards.dart';",
        "",
        "const kBeards = <Beard>[",
    ]
    for c in styles:
        lines += [
            "  Beard(",
            f"    id: {dart_str(c['id'])},",
            f"    label: {dart_str(c['label'])},",
            f"    cs: {dart_str(c['cs'])},",
            f"    section: {dart_str(c['section'])},",
            "    block:",
            f"        {dart_str(c['block'])},",
            f"    region: {beard_region(c['region'])},",
            "  ),",
        ]
    lines.append("];")
    return lines


def export_beard(args) -> None:
    verdicts = json.loads(args.source.read_text())
    engines = [e.strip() for e in args.engines.split(",") if e.strip()]
    cands = json.loads((HERE / "candidates" / "beards.json").read_text())
    styles = [c for c in cands if accepted(verdicts, c["id"], engines)]
    bench = load_bench(args.bench) if args.bench else None

    def cell_of(c: dict) -> dict | None:
        return preview_cell(bench, {**c, "group": "Men"}, engines)  # m-short, the same face on every row

    if args.list_previews:
        if not bench:
            sys.exit("--list-previews potřebuje --bench")
        for c in styles:
            if cell := cell_of(c):
                print(cell["file"])
        return
    if bench:
        assets = SHARED / "assets" / "beard"
        assets.mkdir(parents=True, exist_ok=True)
        for c in styles:
            cell = cell_of(c)
            if cell is None:
                sys.exit(f"{c['id']}: v {args.bench} není žádná buňka pro {engines}")
            write_preview(args.bench, cell, assets / f"{c['id']}.jpg")
        keep = {f"{c['id']}.jpg" for c in styles}
        for old in assets.glob("*.jpg"):
            if old.name not in keep:
                old.unlink()
    BEARD_TARGET.write_text("\n".join(beard_lines(styles)) + "\n")
    print(f"{BEARD_TARGET}: {len(styles)} of {len(cands)} candidates")


def motion_lines(motions: list[tuple[str, dict, str]]) -> list[str]:
    lines = [
        "// GENERATED by tgbot/tools/bench/export_catalog.py from the bench verdicts",
        "// (docs/live-matrix.md). Do not edit by hand: change the preset in",
        "// assets/drivers/manifest.json, re-measure, re-export.",
        "",
        "import 'motions.dart';",
        "",
        "const kMotions = <Motion>[",
    ]
    for mid, preset, cs in motions:
        lines += [
            "  Motion(",
            f"    id: {dart_str(mid)},",
            f"    label: {dart_str(preset['label'])},",
            f"    cs: {dart_str(cs)},",
            f"    seconds: {dart_double(preset['seconds'])},",
            f"    engine: MotionEngine.{preset['engine']},",
            f"    loop: {str(bool(preset.get('loop'))).lower()},",
            "  ),",
        ]
    lines.append("];")
    return lines


def accepted_motions(verdicts: dict, manifest: dict, names: dict[str, str]) -> list[tuple[str, dict, str]]:
    """A preset ships on its own engine: the gate's `live` or `wan`, never the
    `driver` rows, which measure the clip, not the result."""
    return [(mid, p, names[mid]) for mid, p in manifest.items() if accepted(verdicts, mid, [p["engine"]])]


def export_live(args) -> None:
    sys.path[:0] = [str(HERE.parents[1]), str(HERE)]
    import catalog
    import livebench

    verdicts = json.loads(args.source.read_text())
    motions = accepted_motions(verdicts, catalog.motions(), livebench.MOTION_CS)
    MOTIONS_TARGET.write_text("\n".join(motion_lines(motions)) + "\n")
    print(f"{MOTIONS_TARGET}: {len(motions)} presets")


CARRIES_CLASS = """/// What a style keeps of the new look, from the pipeline bench
/// (`docs/pipeline-matrix.md`). null = not measured; false = warn in the app.
class RestyleCarries {
  const RestyleCarries({this.hair, this.glasses, this.beard});

  final bool? hair;
  final bool? glasses;
  final bool? beard;
}

"""


def dart_opt_bool(v: bool | None) -> str:
    return "null" if v is None else str(v).lower()


def with_carries(src: str, carries: dict[str, dict]) -> str:
    """restyle_styles.dart with `carries:` on every measured style, in place:
    the rest of the file is hand-written. Idempotent. The first run adds the
    class and the field, a style that is no longer measured loses the line."""
    if "class RestyleCarries" not in src:
        src = src.replace("class RestyleStyle {", CARRIES_CLASS + "class RestyleStyle {", 1)
        src = src.replace("    required this.block,\n  });", "    required this.block,\n    this.carries = const RestyleCarries(),\n  });", 1)
        src = src.replace("  final String block;\n}", "  final String block;\n\n  /// Exported by the bench; see [RestyleCarries].\n  final RestyleCarries carries;\n}", 1)
    if "final RestyleCarries carries;" not in src:
        sys.exit("restyle_styles.dart: RestyleStyle has changed, the carries field did not fit")
    src = re.sub(r"\n    carries: RestyleCarries\([^)]*\),(?=\n  \),)", "", src)

    def patch(m: re.Match) -> str:
        c = carries.get(m.group(2))
        if c is None:
            return m.group(0)
        line = (f"\n    carries: RestyleCarries(hair: {dart_opt_bool(c.get('hair'))}, "
                f"glasses: {dart_opt_bool(c.get('glasses'))}, beard: {dart_opt_bool(c.get('beard'))}),")
        return m.group(1) + line + m.group(3)

    return re.sub(r"(  RestyleStyle\(\n    id: '([^']+)',.*?)(\n  \),)", patch, src, flags=re.S)


def export_carries(args) -> None:
    metrics = json.loads((args.source / "metrics.json").read_text())
    carries = metrics["carries"].get(args.engine)
    if not carries:
        sys.exit(f"{args.source}: nothing measured on engine {args.engine}")
    RESTYLE_TARGET.write_text(with_carries(RESTYLE_TARGET.read_text(), carries))
    print(f"{RESTYLE_TARGET}: carries of {len(carries)} styles ({args.engine})")


TASK_EXPORTS = {"beard": export_beard, "live": export_live, "carries": export_carries}


def export_task(task: str, argv: list[str]) -> None:
    ap = argparse.ArgumentParser(prog=f"export_catalog.py --task {task}")
    ap.add_argument("source", type=Path, help="verdicts json; for carries the pipeline run dir")
    ap.add_argument("--engines", default="kontext")
    ap.add_argument("--engine", default="flux", help="carries: the engine whose styles ship")
    ap.add_argument("--bench", type=Path)
    ap.add_argument("--list-previews", action="store_true")
    TASK_EXPORTS[task](ap.parse_args(argv))


def ol1nllm_catalog(styles: list[tuple[dict, list[str]]], repo: Path,
                    colours: list[tuple[str, dict, list[str]]],
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
    for c, es in styles:
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
            f"    engines: {dart_engines(es)},",
            "  ),",
        ]
    lines.append("];")
    lines += ["", "const kHairColours = <HairColourPreset>["]
    for cid, c, es in colours:
        lines += [
            "  HairColourPreset(",
            f"    id: {dart_str(cid)},",
            f"    label: {dart_str(c['cs'][:1].upper() + c['cs'][1:])},",
            f"    phrase: {dart_str(c['phrase'])},",
            *([f"    swatch: 0xFF{swatches[cid]},"] if swatches and swatches.get(cid) else []),
            f"    engines: {dart_engines(es)},",
            "  ),",
        ]
    lines.append("];")
    target.write_text("\n".join(lines) + "\n")
    print(f"{target}: {len(styles)} hairstyles, {len(colours)} colours")


def main() -> None:
    # Before the parser below: these tasks take a run dir, not verdicts.json.
    pre = argparse.ArgumentParser(add_help=False)
    pre.add_argument("--task")
    known, rest = pre.parse_known_args()
    if known.task in TASK_EXPORTS:
        export_task(known.task, rest)
        return
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

    def previews(styles: list[tuple[dict, list[str]]], assets: Path) -> None:
        if not bench:
            return
        assets.mkdir(parents=True, exist_ok=True)
        # The picture comes from an engine that *accepted* the style, not from
        # the app's whole list — a preview rendered where the gate rejected it
        # would advertise the failure.
        for c, es in styles:
            cell = preview_cell(bench, c, es)
            if cell is None:
                sys.exit(f"{c['id']}: v {args.bench} není žádná buňka pro {es}")
            write_preview(args.bench, cell, assets / f"{c['id']}.jpg")
        # nothing stale: a style that left the gate leaves its picture too
        keep = {f"{c['id']}.jpg" for c, _ in styles}
        for old in assets.glob("*.jpg"):
            if old.name not in keep:
                old.unlink()

    # Measured swatches survive an export run without --colours-bench. The run
    # dir lives on the bench box, so most exports do not have it mounted — and
    # dropping the colour a model actually paints, just because this run could
    # not recompute it, silently unmeasures the catalog.
    store = HERE / "swatches.json"
    measured = json.loads(store.read_text()) if store.exists() else {}

    def swatches(colours: list[tuple[str, dict, list[str]]]) -> dict[str, str]:
        if cbench:
            fresh = {cid: h for cid, _, es in colours
                     if (h := swatch(cbench, cid, es))}
            measured.update(fresh)
            store.write_text(json.dumps(measured, indent=2, sort_keys=True) + "\n")
        return {cid: h for cid, _, _ in colours if (h := measured.get(cid))}

    def gated(engines: list[str]) -> list[tuple[dict, list[str]]]:
        return [(c, es) for c in cands
                if (es := engines_of(verdicts, c["id"], engines))]

    if args.list_previews:
        if not bench:
            sys.exit("--list-previews potřebuje --bench")
        seen = set()
        for engines in (split(args.engines), split(args.ol1nllm_engines) if args.ol1nllm else []):
            if not engines:
                continue
            for c, es in gated(engines):
                cell = preview_cell(bench, c, es)
                if cell and cell["file"] not in seen:
                    seen.add(cell["file"])
                    print(cell["file"])
        return

    if args.ol1nllm:
        engines = split(args.ol1nllm_engines)
        styles = gated(engines)
        colours = accepted_colours(verdicts, engines)
        ol1nllm_catalog(styles, args.ol1nllm, colours, swatches(colours))
        previews(styles, args.ol1nllm / "assets" / "hair")
    engines = split(args.engines)
    styles = gated(engines)
    colours = accepted_colours(verdicts, engines)
    sw = swatches(colours)
    previews(styles, SHARED / "assets" / "hair")
    lines = [
        "// GENERATED by tgbot/tools/bench/export_catalog.py from the bench verdicts",
        "// (docs/hair-matrix.md). Do not edit by hand: change the candidate in",
        "// tgbot/tools/bench/candidates/hairstyles.json, re-measure, re-export.",
        "",
        "import 'hairstyles.dart';",
        "",
        "const kHairstyles = <Hairstyle>[",
    ]
    for c, es in styles:
        sh = c["shape"]
        lines += [
            "  Hairstyle(",
            f"    id: {dart_str(c['id'])},",
            f"    label: {dart_str(c['label'])},",
            f"    cs: {dart_str(c['cs'])},",
            f"    group: {'kHairGroupWomen' if c['group'] == 'Women' else 'kHairGroupMen'},",
            f"    section: {dart_str(c['section'])},",
            "    block:",
            f"        {dart_str(c['block'])},",
            f"    shape: HairShape(length: HairLength.{sh['length']}, bangs: HairBangs.{sh['bangs']}, updo: {str(sh['updo']).lower()}),",
            "  ),",
        ]
    lines.append("];")
    lines += ["", "const kHairColours = <HairColour>["]
    for cid, c, _ in colours:
        lines += [
            "  HairColour(",
            f"    id: {dart_str(cid)},",
            f"    label: {dart_str(c['label'])},",
            f"    cs: {dart_str(c['cs'])},",
            f"    phrase: {dart_str(c['phrase'])},",
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

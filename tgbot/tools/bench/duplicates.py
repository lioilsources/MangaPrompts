#!/usr/bin/env python3
"""Vykresluje model dva účesy z katalogu stejně?

    duplicates.py out/hair-r2 [--engines kontext] [--threshold 0.85]

Katalog, ve kterém je šestkrát týž účes pod šesti jmény, je horší než
poloviční katalog s šesti různými. Uživatel v Tsumiki našel `Long Bob`,
`Italian Bob` a `Blunt Cut` vedle sebe jako tři stejné obrázky — a měl
pravdu, model je vykresluje stejně.

Měří se **silueta vlasů**, ne celý výřez: u krátkých pánských střihů tvoří
většinu obrázku obličej, který je na všech buňkách týž (tatáž předloha), a
korelace celého výřezu proto vyšla 0,99 i tam, kde se vlasy lišily. Bere se
tedy maska vlasů výstupu (tatáž analýza, jakou počítá `score.py`, z cache
podle hashe souboru) a dvě masky se porovnají přes IoU. Kontrola, že metrika
není slepá: nejodlišnější dvojice vycházejí 0,31 (ženy) a 0,51 (muži).

Co to **nechytí**: rozdíl v textuře při stejné siluetě (rovné vs. vlnité
vlasy téže délky). Na to je `structure_ok`; tyhle dvě metriky se doplňují.

Pozor na výklad: vysoké IoU neříká „ten účes je špatný", ale „tyhle dva jsou
pro model totéž". Řešení může být i lepší popis v `candidates/hairstyles.json`
a přeměření — ne nutně vyhození.
"""

import argparse
import hashlib
import json
import sys
from pathlib import Path

import numpy as np

HERE = Path(__file__).resolve().parent
sys.path[:0] = [str(HERE.parents[1]), str(HERE)]

import hairmask as hm  # noqa: E402

PRIMARY_SRC = {"Women": "w-long.png", "Men": "m-short.png"}


def hair_masks(run: Path, engines: list[str], accepted: set[str],
               cands: dict) -> dict[str, tuple[np.ndarray, np.ndarray]]:
    """Maska vlasů a šedotónový obraz výstupu pro každý přijatý styl na jeho
    primární předloze."""
    from PIL import Image

    cache = HERE / "cache" / "analysis"
    cells = json.loads((run / "manifest.json").read_text())["cells"]
    cells = cells if isinstance(cells, dict) else {c["key"]: c for c in cells}
    out: dict[str, tuple[np.ndarray, np.ndarray]] = {}
    for c in cells.values():
        sid = c.get("style")
        if (sid not in accepted or sid in out or c.get("engine") not in engines
                or c.get("status") != "done"):
            continue
        if Path(c["src"]).name != PRIMARY_SRC[cands[sid]["group"]]:
            continue
        png = (run / c["file"]).read_bytes()
        d = cache / hashlib.sha1(png).hexdigest()[:16] / "hair.png"
        if d.exists():
            grey = np.asarray(Image.open(run / c["file"]).convert("L"), dtype=float)
            out[sid] = (hm.decode_mask(d.read_bytes()), grey)
    return out


def pairs(masks: dict, ids: list[str]):
    """(IoU siluety, korelace vzhledu uvnitř masky, a, b).

    Samotná silueta nestačí: u krátkých pánských střihů je to jen tvar hlavy,
    takže `m-cornrows` vyšly stejně jako `m-buzz` (IoU 0,97) — copánky proti
    vyholené hlavě. Druhé číslo porovnává *pixely uvnitř* sjednocení obou
    masek, takže vidí vzor a texturu, ne jen obrys. Duplicita je, když
    souhlasí obojí."""
    for a in range(len(ids)):
        for b in range(a + 1, len(ids)):
            (mx, gx), (my, gy) = masks[ids[a]], masks[ids[b]]
            if mx.shape != my.shape or gx.shape != gy.shape:
                continue
            union = mx | my
            n = float(union.sum())
            if not n:
                continue
            iou = float((mx & my).sum()) / n
            u, v = gx[union], gy[union]
            u = (u - u.mean()) / (u.std() + 1e-6)
            v = (v - v.mean()) / (v.std() + 1e-6)
            yield iou, float((u * v).mean()), ids[a], ids[b]


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("run", type=Path)
    ap.add_argument("--engines", default="kontext")
    ap.add_argument("--threshold", type=float, default=0.85,
                    help="IoU siluety, od kterého je dvojice podezřelá")
    ap.add_argument("--appearance", type=float, default=0.80,
                    help="korelace vzhledu uvnitř masky; duplicita chce obojí")
    ap.add_argument("--json", type=Path, help="zapsat dvojice nad prahem")
    args = ap.parse_args()

    engines = [e.strip() for e in args.engines.split(",") if e.strip()]
    verd = json.loads((HERE / "verdicts.json").read_text())
    cands = {c["id"]: c for c in json.loads(
        (HERE / "candidates" / "hairstyles.json").read_text())}
    accepted = {
        sid for sid, e in verd.items()
        if isinstance(e.get("verdict"), dict)
        and any(e["verdict"].get(x) == "accept" for x in engines)
    }
    masks = hair_masks(args.run, engines, accepted, cands)
    print(f"{len(masks)} siluet na primární předloze ({'+'.join(engines)})\n")

    # Pořadí v candidates/hairstyles.json je kurátorské — co je výš, je
    # běžnější a zůstává; zbytek shluku je jeho převlek. Deterministické,
    # takže se katalog mezi běhy nepřeskládá.
    order = {sid: n for n, sid in enumerate(cands)}

    dupes = []
    for group in ("Women", "Men"):
        ids = sorted(i for i in masks if cands[i]["group"] == group)
        ps = sorted(pairs(masks, ids), reverse=True)
        over = [p for p in ps
                if p[0] >= args.threshold and p[1] >= args.appearance]
        dupes += over
        print(f"=== {group}: {len(ids)} účesů, {len(over)} duplicitních dvojic "
              f"(IoU ≥ {args.threshold:.2f} a vzhled ≥ {args.appearance:.2f})")
        for iou, app, a, b in over:
            print(f"  IoU {iou:5.3f}  vzhled {app:5.3f}  {a:20s} × {b}")
        near = [p for p in ps
                if p[0] >= args.threshold and p[1] < args.appearance]
        if near:
            print(f"  -- stejná silueta, jiný vzhled (NEjsou duplicity): {len(near)}")
            for iou, app, a, b in near[:6]:
                print(f"     IoU {iou:5.3f}  vzhled {app:5.3f}  {a:20s} × {b}")

        # Shluky = souvislé komponenty nad prahem.
        parent = {i: i for i in ids}

        def find(x):
            while parent[x] != x:
                parent[x] = parent[parent[x]]
                x = parent[x]
            return x

        for _, _, a, b in over:
            ra, rb = find(a), find(b)
            if ra != rb:
                parent[ra] = rb
        groups: dict[str, list[str]] = {}
        for i in ids:
            groups.setdefault(find(i), []).append(i)
        clusters = sorted(groups.values(), key=lambda g: -len(g))
        print(f"  → {len(clusters)} skutečně různých účesů z {len(ids)}")
        for g in clusters:
            if len(g) > 1:
                keep = min(g, key=lambda s: order[s])
                drop = [s for s in sorted(g, key=lambda s: order[s]) if s != keep]
                print(f"     zůstane {keep:18s} ⟵ {', '.join(drop)}")
        print()

    if args.json:
        args.json.write_text(json.dumps(
            [{"iou": round(i, 3), "appearance": round(p, 3), "a": a, "b": b}
             for i, p, a, b in dupes],
            ensure_ascii=False, indent=2) + "\n")
        print(f"{args.json}: {len(dupes)} dvojic")
    sys.exit(1 if dupes else 0)


if __name__ == "__main__":
    main()

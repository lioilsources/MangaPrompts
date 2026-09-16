#!/usr/bin/env python3
"""Zkouška metriky na předlohách, kde známe pravdu.

    metric_check.py out/hair-r2b [--truth truth.json]

`recognised` ve `score.py` rozhoduje o tom, co se dostane do katalogů appek.
Nikdy se ale neověřovalo, jestli sama umí pojmenovat účes na **skutečné
fotce** — a neumí: na `w-bangs-3q` (lob po klíční kost s rovnou ofinou) dá
CLIP v sadě 34 nálepek skupiny první místo `face-framing`, druhé
`long-layered`, správný `lob` je devátý. Na `w-long` (dlouhé rovné vlasy) je
první `face-framing` s 0,42. Tedy: dvě ze tří ženských položek, které kdy
gate pustil, prošly na nálepku, kterou CLIP říká skoro každé ženské fotce.

Metrika, která neprojde na vstupu, nemá soudit výstup. Tenhle skript ji na
předlohách zkouší a tiskne, co vidí — pouští se před každým kolem, ne až
když výsledky nedávají smysl.

Hrubé třídy (`--coarse`) jsou druhá otázka: co CLIP zvládne, když ho
nesvádíme blízkými synonymy. Měřeno 16. 9. 2026 na čtyřech předlohách:
copánky 0,99–1,00 a pixie 0,56–0,75 pozná spolehlivě, **délku ne** — `lob`
i dlouhé vlasy hlásí jako `bob` (lob ≈ 0,00). Délku a ofinu přitom bench
měří geometricky (`below` → `length_ok`, `cover` → `bangs_ok`), objektivně
a správně. CLIP se tedy ptát na délku nemá; má se ho ptát na strukturu.
"""

import argparse
import json
import sys
from pathlib import Path

import numpy as np
from PIL import Image

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))

# Pravda o předlohách. Nejsou to domněnky — jsou to ty fotky, jsou v repu
# a dá se na ně podívat. Když s nimi metrika nesouhlasí, je vedle metrika.
TRUTH = {
    "w-long.png": {"style": "sleek-straight", "coarse": "long"},
    "w-bangs-3q.png": {"style": "lob", "coarse": "lob"},
    "w-curly-short.png": {"style": "soft-curls", "coarse": "bob"},
    "m-short.png": {"style": "m-crew", "coarse": "short"},
    "m-long.png": {"style": "m-flow", "coarse": "medium"},
    "m-receding.png": {"style": "m-caesar", "coarse": "short"},
}

COARSE = {
    "Women": {
        "pixie": "very short cropped hair, ears and neck bare",
        "bob": "a chin-length bob",
        "lob": "hair ending at the collarbone",
        "long": "long hair falling well past the shoulders",
        "updo": "hair gathered up into a bun or knot",
        "braids": "hair in braids",
    },
    "Men": {
        "buzz": "a buzz cut, hair clipped very short all over",
        "short": "a short tapered men's haircut",
        "medium": "medium-length men's hair covering the ears",
        "long": "long men's hair past the shoulders",
    },
}


def group_of(src: str) -> str:
    return "Men" if Path(src).name.startswith("m-") else "Women"


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("run", type=Path)
    ap.add_argument("--coarse", action="store_true",
                    help="místo katalogu nálepek zkusit hrubé třídy")
    args = ap.parse_args()

    import score as sc

    styles = {h["id"]: h for h in json.loads(
        (HERE / "candidates" / "hairstyles.json").read_text())}
    cells = json.loads((args.run / "manifest.json").read_text())["cells"]
    cells = list(cells.values()) if isinstance(cells, dict) else cells

    boxes: dict[str, list] = {}
    for c in cells:
        if c.get("face_box"):
            boxes.setdefault(Path(c["src"]).name, c["face_box"])

    bad = 0
    for name, box in sorted(boxes.items()):
        truth = TRUTH.get(name)
        if truth is None:
            print(f"{name}: není v TRUTH — doplň, jinak se nedá zkoušet")
            continue
        group = group_of(name)
        img = Image.open(args.run / "srcs" / name).convert("RGB")
        if args.coarse:
            keys = list(COARSE[group])
            texts = [f"a photo of a person with {COARSE[group][k]}" for k in keys]
            want = truth["coarse"]
        else:
            g = [h for h in styles.values() if h["group"] == group]
            keys = [h["id"] for h in g]
            texts = [f"a photo of a person with a {h['label']} hairstyle" for h in g]
            want = truth["style"]
        p = sc.clip_probs(sc.head_crop(img, box), texts)
        order = np.argsort(-p)
        rank = int((p > p[keys.index(want)]).sum()) + 1
        # Hrubé třídy jsou čtyři až šest, takže „rank ≤ 5“ by tam prošlo skoro
        # vždycky a nic by neměřilo; tam se ptáme na první místo. U katalogu
        # nálepek platí práh, kterým gate opravdu rozhoduje.
        ok = rank == 1 if args.coarse else rank <= sc.THRESHOLDS["clip_top"]
        bad += not ok
        top = ", ".join("%s %.2f" % (keys[i], p[i]) for i in order[:3])
        print("%-18s pravda %-16s rank %2d  %s   %s" % (
            name, want, rank, "ok" if ok else "MIMO", top))

    print()
    bar = "první místo" if args.coarse else f"rank ≤ {sc.THRESHOLDS['clip_top']}"
    if bad:
        print(f"{bad} z {len(boxes)} předloh metrika nepozná ({bar}) — verdikty "
              f"z ní neplatí o modelu, ale o ní.")
    else:
        print(f"Metrika pozná všechny předlohy ({bar}).")
    sys.exit(1 if bad else 0)


if __name__ == "__main__":
    main()

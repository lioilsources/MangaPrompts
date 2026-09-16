#!/usr/bin/env python3
"""Sestaví verdicts.json ze souhrnů doběhlých běhů.

    verdicts.py out/hair-r2 out/hair-colours-r2 [--out verdicts.json]

Verdikty se do téhle chvíle udržovaly ručně, což znamenalo, že se od měření
mohly nepozorovaně rozejít — a taky že přegatování po změně metriky bylo
ruční práce nad stovkou řádků. Tenhle skript je odvodí z `metrics.json`
každého běhu: co v souhrnu vyšlo `pass`, je `accept`, zbytek `reject`
s důvody, které spočítal `score.py`.

Běhy se berou v pořadí, v jakém jsou zadané, a **pozdější přebíjí dřívější**
— hustší běh má přednost před řidším. Kombinace střih × barva (`lob+jet-black`)
se přeskakují: verdikt patří střihu a barvě zvlášť, dvojice je jiná otázka
(viz docs/hair-matrix.md, kolo 2b).
"""

import argparse
import json
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path[:0] = [str(HERE.parents[1]), str(HERE)]

import haircolours  # noqa: E402


def entries(run: Path):
    """(klíč, engine, verdikt, důvod) ze souhrnu jednoho běhu."""
    summary = json.loads((run / "metrics.json").read_text())["summary"]
    for key, s in summary.items():
        label, engine, _medium, sweep = key.split("|", 3)
        if sweep not in ("{}", ""):
            continue  # buňky ze sweepu nejsou verdikt o stylu
        style, _, colour = label.partition("+")
        if colour and style != haircolours.KEEP_CUT:
            continue  # dvojice střih × barva — jiná otázka
        target = f"colour:{colour}" if colour else style
        yield target, engine, ("accept" if s["auto"] == "pass" else "reject"), \
            ", ".join(s["reasons"])


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("runs", nargs="+", type=Path)
    ap.add_argument("--out", type=Path, default=HERE / "verdicts.json")
    args = ap.parse_args()

    out: dict[str, dict] = {}
    for run in args.runs:
        for target, engine, verdict, reason in entries(run):
            e = out.setdefault(target, {"verdict": {}, "reasons": {}, "run": {}})
            e["verdict"][engine] = verdict
            e["run"][engine] = run.name
            if reason:
                e["reasons"][engine] = reason
            else:
                e["reasons"].pop(engine, None)

    args.out.write_text(json.dumps(out, ensure_ascii=False, indent=2) + "\n")
    n_ok = sum(1 for e in out.values() if "accept" in e["verdict"].values())
    print(f"{args.out}: {len(out)} položek, {n_ok} přijatých aspoň jedním enginem")
    for eng in sorted({k for e in out.values() for k in e["verdict"]}):
        ok = sum(1 for e in out.values() if e["verdict"].get(eng) == "accept")
        print(f"   {eng}: {ok}")


if __name__ == "__main__":
    main()

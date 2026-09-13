#!/usr/bin/env python3
"""One-off repair for runs rendered before run.py split the colour fields:
`colour` held the colour read off the photo and overwrote the target colour of
colour cells. The target survives in the file name (`style+colour__…`)."""

import json
import sys
from pathlib import Path

for run in map(Path, sys.argv[1:]):
    path = run / "manifest.json"
    m = json.loads(path.read_text())
    fixed = 0
    for row in m["cells"].values():
        if m.get("task") != "hair" or "colour_src" in row:
            continue
        head = Path(row.get("file", "")).name.split("__", 1)[0]
        row["colour_src"] = row.pop("colour", None)
        if "+" in head:
            row["colour"] = head.split("+", 1)[1]
        fixed += 1
    path.write_text(json.dumps(m, indent=1, ensure_ascii=False))
    print(f"{run}: {fixed} rows")

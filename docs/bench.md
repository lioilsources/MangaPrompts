# Bench (`tgbot/tools/bench/`)

Přesunuto z CLAUDE.md (obsah beze změny).

Measurement harness that runs on SPARK next to ComfyUI (`sync.sh` pushes the
code; ComfyUI's venv has insightface, transformers, numpy). Cells are built by
the bot's own `comfy.prepare_workflow`, `hairmask.py` and `hairprompt.py`, so it
measures what ships. `run.py restyle|hair|srcgen|analyse` renders a resumable
matrix with `--sweep '<node>.<input>=a|b'`, `mask.<CONST>=…` and `graph.*`
variants; `score.py` adds ArcFace identity (antelopev2), histogram reaction to
the unstyled baseline, and for hair length / fringe / CLIP-rank checks;
`sheet.py` writes a self-contained contact sheet; `export_catalog.py
verdicts.json [--ol1nllm DIR] [--bench out/hair-rN --colours-bench
out/hair-colours-rN]` generates the hairstyle catalogs, previews and swatches
(the verdict is a map engine → verdict; Tsumiki takes `--engines`, its
`HAIR_ENGINE`, Ol1nLLM `--ol1nllm-engines`). Full-size cell images stay on
the box: `--list-previews` prints the ones to `rsync --files-from` first. The memory
guard restarts `comfyui.service` only when available RAM sinks below 8 GB and
the queue is empty — the box is shared with the Ol1nLLM app. Synthetic
portraits (no personal data) live in `srcs/`.

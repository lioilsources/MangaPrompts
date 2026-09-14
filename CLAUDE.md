# Tsumiki — CLAUDE.md

## Overview

Flutter app for building AI image generation prompts in LEGO-style cross-matrix format. Users select blocks (head style, manga style, historical style) to compose complete Grok Image prompts.

## Commands

```bash
flutter pub get
flutter run
flutter run -d chrome    # web
flutter run -d macos
flutter build apk
flutter build ios
flutter build web
flutter analyze
```

## Architecture

```
lib/
├── main.dart
├── config/              # App config, constants
├── providers/           # State management (Riverpod or Provider)
├── services/            # Prompt assembly, export
└── ui/                  # Screens and widgets
    ├── constants/       # Visual constants, color schemes
    ├── game_logic/      # Block selection matrix logic
    └── theme/
```

## Platforms

iOS, Android, macOS, Linux, Web.

Web ships as a **Telegram Mini App**: generation goes through `tgbot/`
(FastAPI + aiogram on the JODA NAS → ComfyUI on the SPARK box over
LAN/CF-Access), never through the direct xAI/ol1n/ComfyUI clients.
Photo animation follows the same path against the **video-api on SPARK:8096**
(video-stack repo; Wan 2.2 I2V): Mini App uploads a photo + scene, the bot
delivers the mp4 into the chat. Separate video ledger (users.video_credits,
package `v1` = 10⭐/animation, VIDEO_FREE_DAILY_LIMIT=1/day free).
The third card, **Restyle a photo** (`restyle_screen.dart`, `POST /api/restyle`),
keeps the face and pose (depth ControlNet) of an uploaded photo and renders it
in a picked style (`lib/config/restyle_styles.dart`: popular looks, 42 measured
painters from Ol1nLLM's style matrix, art traditions; medium toggle
photo/illustration); it is billed as an ordinary image generation. The medium
picks the **engine** (`RESTYLE_ENGINES` in `tgbot/config.py`): photo runs
`flux_restyle.api.json` (FLUX.1-dev + PuLID + InstantX depth), illustration
`sdxl_restyle.api.json` (InstantID + xinsir union depth, checkpoint from
`RESTYLE_CHECKPOINTS`). Measurements: `docs/restyle-flux-results.md`.
The fourth card, **Try a haircut** (`hair_screen.dart`, `POST /api/hair`),
repaints only the hair of a portrait: a free analysis pass (face parsing,
`hair_analyse.api.json`) feeds `tgbot/hairmask.py`, which builds the inpaint
mask from the style's shape and reads the hair colour; the prompt is written
server-side per `HAIR_ENGINE` (`tgbot/hairprompt.py`), optionally with a new
colour (`tgbot/haircolours.py`; style id `keep-cut` = colour only, mask of the old
hair without an envelope); billing starts only after
the analysis accepted the photo. The catalog (`lib/config/hairstyle_catalog.dart`)
is generated from the bench gate (`docs/hair-matrix.md`) and the card stays
hidden while it is empty. Ol1nLLM mirrors the mask in `lib/models/hair_mask.dart`.
The cards share `TsumikiAppBar` (`TsumikiScreen` enum drives the shop chip
and the card switcher; `screenOffered` hides animate without scenes and hair
without hairstyles). Monetization: Telegram Stars credits (SQLite ledger in tgbot/db.py, packages
in tgbot/config.py, paywall UI in lib/ui/widgets/paywall_sheet.dart). Platform seams use conditional imports
(`backend_factory.dart`, `image_service.dart`, `repose_entry.dart`,
`local_image.dart`, `platform/telegram_webapp.dart`) — anything importing
dart:io/cronet_http/gal/path_provider must stay out of the web import graph.
Web deploys ONLY from CI (`.github/workflows/deploy-web.yml` → Cloudflare
Pages); local `lib/config/secrets.dart` may hold skip-worktree creds that a
local web deploy would leak. Manual release steps: `docs/telegram-release.md`.

## Prompt Structure

A prompt is assembled from ~25 independent block axes (`assets/config/blocks/*.yaml`),
ordered by the active template's `slot_order`. The axes that carry the look, and
the rules that keep them from contradicting each other:

- **`medium`** (required) — the ONLY axis that declares photo vs. drawn. Emitted
  first because FLUX/T5 weights early tokens most heavily.
- **`art_tradition`** — art-historical traditions (ukiyo-e, baroque, egyptian
  wall painting…). Sits next to `medium` because these name a medium too
  (woodblock, fresco); every one is `incompatible: [medium_photoreal]`.
- **`style`** — genre and mood only. Deliberately carries no render-medium words.
- **`pose`** / **`pose_duo`** — one body vs. two. Body and contact only, never
  framing; that lives in `framing`.

Cross-axis conflicts are declared per block via `incompatible: [<block id>]` and
resolved in `PromptEngine.getIncompatibleBlocks`. There is no "requires"
relation — a block that needs a companion (a duo pose needing a duo subject)
declares incompatibility with the subjects that would be wrong instead.

Adding a category: create the YAML, add its name to `_blockFiles` in
`block_loader.dart`, add it to `slot_order` + `optional_slots` in the templates
that should offer it, and map its `icon` in `block_picker.dart`.

## Model routing

Each template declares the ComfyUI workflow its prompt *language* is written
for (`workflow:` in `templates.yaml`): the pony templates emit Danbooru tags,
the rest emit prose, and feeding one to the other's model degrades output
silently. `effectiveWorkflowProvider` resolves the workflow — the Settings
preference defaults to `auto` (follow the template) and any other value is an
explicit override. The chosen model is always shown in the prompt preview;
auto-selection must never be silent.

Workflows live in `assets/comfyui/*.api.json` and are registered twice: in
`WORKFLOW_FILES` (`tgbot/config.py`, the web path) and in `ComfyWorkflow`
(`comfy_image_service.dart`, the native path). Currently flux, pony,
juggernaut, wai. The restyle and hair graphs are web-only and routed by their
own maps: `RESTYLE_WORKFLOW_FILES` / `RESTYLE_ENGINES` (checkpoint only on the
SDXL engine, `RESTYLE_CHECKPOINTS[medium]`) and `HAIR_WORKFLOW_FILES` /
`HAIR_ENGINE` (+ `HAIR_ANALYSE_WORKFLOW_FILE`). A new graph goes through
`tgbot/tools/check_workflow.py` against SPARK before anything else.
Nodes of our own live in `comfyui_nodes/ComfyUI-Tsumiki` (today
`TsumikiAlignToReference`: FLUX Kontext re-frames what it edits by up to 6 %,
so the hair graph warps the edit back onto the photo before pasting it through
the mask); `comfyui_nodes/deploy.sh` installs them on SPARK and must run before
a graph using them ships — Ol1nLLM sends the same graphs.

## Bench (`tgbot/tools/bench/`)

Measurement harness that runs on SPARK next to ComfyUI (`sync.sh` pushes the
code; ComfyUI's venv has insightface, transformers, numpy). Cells are built by
the bot's own `comfy.prepare_workflow`, `hairmask.py` and `hairprompt.py`, so it
measures what ships. `run.py restyle|hair|srcgen|analyse` renders a resumable
matrix with `--sweep '<node>.<input>=a|b'`, `mask.<CONST>=…` and `graph.*`
variants; `score.py` adds ArcFace identity (antelopev2), histogram reaction to
the unstyled baseline, and for hair length / fringe / CLIP-rank checks;
`sheet.py` writes a self-contained contact sheet; `export_catalog.py
verdicts.json [--ol1nllm DIR]` generates the hairstyle catalogs. The memory
guard restarts `comfyui.service` only when available RAM sinks below 8 GB and
the queue is empty — the box is shared with the Ol1nLLM app. Synthetic
portraits (no personal data) live in `srcs/`.

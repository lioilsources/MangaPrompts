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
Monetization: Telegram Stars credits (SQLite ledger in tgbot/db.py, packages
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
juggernaut, wai.

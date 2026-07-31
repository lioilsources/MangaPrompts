# MangaPrompts — CLAUDE.md

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

Three independent selector axes, each populated with blocks:
- **Head style** — character head/face type
- **Manga style** — overall artistic style
- **Historical style** — era/setting

Selected blocks are composed into a complete Grok Image prompt. Output is exported as a copyable string.

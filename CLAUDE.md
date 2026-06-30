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

## Prompt Structure

Three independent selector axes, each populated with blocks:
- **Head style** — character head/face type
- **Manga style** — overall artistic style
- **Historical style** — era/setting

Selected blocks are composed into a complete Grok Image prompt. Output is exported as a copyable string.

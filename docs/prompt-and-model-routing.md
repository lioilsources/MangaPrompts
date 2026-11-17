# Skládání promptu a routing modelů

Přesunuto z CLAUDE.md (obsah beze změny).

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

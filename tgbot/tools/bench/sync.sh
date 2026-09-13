#!/usr/bin/env bash
# Mirror what the bench needs onto the SPARK box: the bot's workflow code
# (comfy.py, hairmask.py, imagesize.py), the graphs, the restyle catalog and
# the bench itself. Results (out/, cache/) stay on the box; pull what you need.
#   tools/bench/sync.sh            # push code
#   tools/bench/sync.sh pull out/hair-r1   # fetch one run back (no full-size images)
set -euo pipefail
HOST=${BENCH_HOST:-ol1n@spark}
DEST=${BENCH_DEST:-Code/tsumiki-bench}
ROOT=$(cd "$(dirname "$0")/../../.." && pwd)

if [[ "${1:-}" == "pull" ]]; then
  run=${2:?run dir, e.g. out/hair-r1}
  mkdir -p "$ROOT/tgbot/tools/bench/$run"
  rsync -az --exclude img/ --exclude masks/ "$HOST:$DEST/tgbot/tools/bench/$run/" "$ROOT/tgbot/tools/bench/$run/"
  exit 0
fi

ssh "$HOST" "mkdir -p $DEST/tgbot/tools $DEST/assets $DEST/lib/config"
rsync -az "$ROOT"/tgbot/{comfy,hairmask,imagesize}.py "$HOST:$DEST/tgbot/"
rsync -az --delete --exclude out/ --exclude cache/ --exclude __pycache__/ --exclude "queue_*.sh" \
  "$ROOT/tgbot/tools/bench/" "$HOST:$DEST/tgbot/tools/bench/"
rsync -az --delete "$ROOT/assets/comfyui/" "$HOST:$DEST/assets/comfyui/"
rsync -az "$ROOT/lib/config/restyle_styles.dart" "$HOST:$DEST/lib/config/"
echo "synced to $HOST:$DEST"

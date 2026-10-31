#!/usr/bin/env bash
# Install the Tsumiki node pack into SPARK's ComfyUI and restart it once the
# queue is empty (the box is shared with the Ol1nLLM app — never mid-job).
# A graph that uses a node from here must not ship before this ran.
#
#   deploy.sh                  the Tsumiki node pack (as always)
#   deploy.sh --live-portrait  also LivePortraitKJ + its weights and, when
#                              missing, VideoHelperSuite + buffalo_l; see
#                              docs/live-portrait-setup.md. Run it inside a
#                              sparkctl window: it restarts ComfyUI.
set -euo pipefail
HOST=${COMFY_HOST:-ol1n@spark}
DEST=${COMFY_ROOT:-Code/ComfyUI}/custom_nodes/ComfyUI-Tsumiki
ROOT=$(cd "$(dirname "$0")" && pwd)
LIVE_PORTRAIT=${1:-}
# Pinned: live_portrait.api.json was written against these exact sources.
LIVEPORTRAIT_REV=4d9dc6205b793ffd0fb319816136d9b8c0dbfdff
VHS_REV=4d907bee61e92c2e65af3bd6383a4e4d356126d1

rsync -az --delete --exclude __pycache__/ --exclude "test_*.py" "$ROOT/ComfyUI-Tsumiki/" "$HOST:$DEST/"
if [ "$LIVE_PORTRAIT" = "--live-portrait" ]; then
  ssh "$HOST" "COMFY=${COMFY_ROOT:-Code/ComfyUI} PY=${COMFY_PYTHON:-python3} LP_REV=$LIVEPORTRAIT_REV VHS_REV=$VHS_REV bash -s" <<'REMOTE'
set -euo pipefail
cd "$COMFY"
fetch() {  # dir url rev
  [ -d "custom_nodes/$1" ] || git clone "$2" "custom_nodes/$1"
  git -C "custom_nodes/$1" fetch origin
  git -C "custom_nodes/$1" checkout "$3"
}
fetch ComfyUI-LivePortraitKJ https://github.com/kijai/ComfyUI-LivePortraitKJ "$LP_REV"
# VHS is already installed and other graphs use it: never move its revision.
[ -d custom_nodes/ComfyUI-VideoHelperSuite ] || \
  fetch ComfyUI-VideoHelperSuite https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite "$VHS_REV"
# Not `pip install -r requirements.txt`: it pins numpy<=1.26.4 into the venv
# every other node on this box shares. pykalman is the only addition.
"$PY" -m pip install pykalman
"$PY" -c "import cv2, kornia, skimage, scipy, onnxruntime, insightface, yaml"
[ -f models/liveportrait/motion_extractor.safetensors ] || \
  "$PY" -c "from huggingface_hub import snapshot_download; snapshot_download('Kijai/LivePortrait_safetensors', ignore_patterns=['animal/*'], local_dir='models/liveportrait')"
if [ ! -d models/insightface/models/buffalo_l ]; then
  mkdir -p models/insightface/models/buffalo_l
  curl -fL -o /tmp/buffalo_l.zip https://github.com/deepinsight/insightface/releases/download/v0.7/buffalo_l.zip
  unzip -o /tmp/buffalo_l.zip -d models/insightface/models/buffalo_l
  rm /tmp/buffalo_l.zip
fi
REMOTE
fi

ssh "$HOST" 'until [ "$(curl -s localhost:8188/queue | python3 -c "import json,sys; q=json.load(sys.stdin); print(len(q[\"queue_running\"]) + len(q[\"queue_pending\"]))")" = 0 ]; do sleep 20; done
  systemctl --user restart comfyui.service
  until curl -sf localhost:8188/object_info/TsumikiAlignToReference | grep -q TsumikiAlignToReference; do sleep 5; done
  echo "TsumikiAlignToReference is live"'

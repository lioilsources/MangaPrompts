#!/usr/bin/env bash
# Install the Tsumiki node pack into SPARK's ComfyUI and restart it once the
# queue is empty (the box is shared with the Ol1nLLM app — never mid-job).
# A graph that uses a node from here must not ship before this ran.
set -euo pipefail
HOST=${COMFY_HOST:-ol1n@spark}
DEST=${COMFY_ROOT:-Code/ComfyUI}/custom_nodes/ComfyUI-Tsumiki
ROOT=$(cd "$(dirname "$0")" && pwd)

rsync -az --delete --exclude __pycache__/ --exclude "test_*.py" "$ROOT/ComfyUI-Tsumiki/" "$HOST:$DEST/"
ssh "$HOST" 'until [ "$(curl -s localhost:8188/queue | python3 -c "import json,sys; q=json.load(sys.stdin); print(len(q[\"queue_running\"]) + len(q[\"queue_pending\"]))")" = 0 ]; do sleep 20; done
  systemctl --user restart comfyui.service
  until curl -sf localhost:8188/object_info/TsumikiAlignToReference | grep -q TsumikiAlignToReference; do sleep 5; done
  echo "TsumikiAlignToReference is live"'

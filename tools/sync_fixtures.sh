#!/usr/bin/env bash
# Gives packages/tsumiki_shared/test/fixtures the fixtures Python wrote. They
# live in tgbot/tests/fixtures; the package sees them through a symlink so
# there is one copy to keep honest.
#   tools/sync_fixtures.sh                   # (re)create the link
#   tools/sync_fixtures.sh --gen [python]    # regenerate first (a venv with numpy, Pillow)
#   tools/sync_fixtures.sh --copy            # real copy, for a filesystem without symlinks
set -euo pipefail
ROOT=$(cd "$(dirname "$0")/.." && pwd)
DEST="$ROOT/packages/tsumiki_shared/test/fixtures"
mode=link
while [[ $# -gt 0 ]]; do
  case "$1" in
    --gen)
      py=${2:-python3}
      [[ $# -ge 2 ]] && shift
      "$py" "$ROOT/tgbot/tools/gen_fixtures.py"
      ;;
    --copy) mode=copy ;;
    *) echo "unknown argument: $1" >&2; exit 2 ;;
  esac
  shift
done
rm -rf "$DEST"
if [[ "$mode" == copy ]]; then
  cp -R "$ROOT/tgbot/tests/fixtures" "$DEST"
else
  ln -s ../../../tgbot/tests/fixtures "$DEST"
fi
echo "$DEST ($mode)"

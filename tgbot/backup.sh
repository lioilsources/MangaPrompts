#!/bin/sh
# Daily backup of mangabot.db — the credits and Stars payment ledger.
#
# Two copies, on deliberately different hardware:
#   1. data/backup/ next to the database, for the ordinary case (bad migration,
#      someone deletes the file, corruption of the live db).
#   2. a mirror on /pool, which is a raidz1 across three spindles while the
#      database itself sits on the root SSD. That is what covers losing a disk.
#
# Neither copy leaves the machine, so a dead NAS, fire or theft still takes
# both. An off-site target is the remaining gap.
#
#   crontab -e:   0 4 * * *  /home/oli/MangaPrompts/tgbot/backup.sh
set -eu

# cron runs with PATH=/usr/bin:/bin, which on this NAS does not contain docker
# (it lives in /snap/bin). Without this the job dies on "command not found"
# and, since cron has nowhere to mail the output, does so silently — the worst
# possible failure for a backup.
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin
export PATH

KEEP_LOCAL=14
KEEP_MIRROR=30
SRC_DIR=/home/oli/MangaPrompts/tgbot/data/backup
MIRROR_DIR=/pool/Backup/tsumiki

# --- 1. snapshot, taken inside the container ---------------------------------
# data/ is root-owned (the container writes it) and neither the host nor the
# python:slim image ships the sqlite3 CLI, so the copy happens in there via
# sqlite3's backup API — the only safe way to snapshot a live WAL database.
OUT=$(docker exec -i mangabot python - "$KEEP_LOCAL" <<'PY'
import datetime, pathlib, sqlite3, sys

out = pathlib.Path("/app/data/backup")
out.mkdir(exist_ok=True)
dest = out / f"mangabot-{datetime.date.today()}.db"

src = sqlite3.connect("/app/data/mangabot.db")
dst = sqlite3.connect(dest)
with dst:
    src.backup(dst)
dst.close()
src.close()
print(f"backup: {dest} ({dest.stat().st_size} bytes)")

keep = int(sys.argv[1])
for f in sorted(out.glob("mangabot-*.db"))[:-keep]:
    f.unlink()
    print(f"pruned: {f}")

print(f"FILE={dest.name}")
PY
)
echo "$OUT" | grep -v '^FILE='
FILE=$(echo "$OUT" | sed -n 's/^FILE=//p')
[ -n "$FILE" ] || { echo "backup produced no file — aborting" >&2; exit 1; }

# --- 2. mirror onto the other disks ------------------------------------------
mkdir -p "$MIRROR_DIR"
# Write to a temp name first: a half-copied file must never sit there looking
# like a usable backup.
cp -f "$SRC_DIR/$FILE" "$MIRROR_DIR/.$FILE.part"
mv -f "$MIRROR_DIR/.$FILE.part" "$MIRROR_DIR/$FILE"

# The snapshot's validity is sqlite's business; what can still go wrong here is
# the copy, so compare the two byte for byte.
if cmp -s "$SRC_DIR/$FILE" "$MIRROR_DIR/$FILE"; then
    echo "mirror: $MIRROR_DIR/$FILE (verified)"
else
    echo "mirror: COPY MISMATCH for $FILE — mirror is not trustworthy" >&2
    exit 1
fi

ls -1t "$MIRROR_DIR"/mangabot-*.db 2>/dev/null | tail -n +$((KEEP_MIRROR + 1)) | while read -r old; do
    rm -f "$old"
    echo "pruned mirror: $old"
done

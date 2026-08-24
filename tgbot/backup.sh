#!/bin/sh
# Daily backup of mangabot.db — the credits and Stars payment ledger.
#
# Runs on the NAS host, but the copy itself happens INSIDE the container:
# data/ is owned by root (the container writes it) and the sqlite3 CLI ships
# neither on the host nor in the python:slim image. sqlite3's backup API is
# also the only safe way to copy a live WAL database.
#
#   crontab -e:   0 4 * * *  /home/oli/MangaPrompts/tgbot/backup.sh
set -eu

# cron runs with PATH=/usr/bin:/bin, which on this NAS does not contain docker
# (it lives in /snap/bin). Without this the job dies on "command not found"
# and, since cron has nowhere to mail the output, does so silently — the worst
# possible failure for a backup.
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin
export PATH

KEEP=14  # daily backups to retain

docker exec -i mangabot python - "$KEEP" <<'PY'
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
old = sorted(out.glob("mangabot-*.db"))[:-keep]
for f in old:
    f.unlink()
    print(f"pruned: {f}")
PY

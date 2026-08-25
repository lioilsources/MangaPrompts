# Telegram Mini App — release checklist (manuální kroky)

Kód je v repu (Flutter web seams, `tgbot/`, `.github/workflows/deploy-web.yml`).
Tyhle kroky vyžadují tvoje účty a jdou udělat jen ručně. Pořadí je závazné —
**rotace tokenů PŘED prvním veřejným deployem**.

## 0. Hygiena secrets (před prvním deployem)

- [ ] **Rotovat Cloudflare Access service token** používaný pro
      `comfyui.ol1n.com` / `llm.ol1n.com` (Zero Trust → Access → Service Auth).
      Starý pár je v lokální (skip-worktree) `lib/config/secrets.dart` a byl
      zapečený do dřívějších nativních buildů. Nový pár zapiš do lokální kopie
      `secrets.dart` (zůstává skip-worktree) a do nastavení nativních appek.
- [ ] **Rotovat xAI klíč** z `.env` (console.x.ai) — hygiena, web ho nepoužívá.
- [ ] Pravidlo: **web deploy jen z CI** (checkout má prázdnou committed
      `secrets.dart`). Nikdy `wrangler pages deploy` z dev stroje.
      CI má navíc dvě pojistky: assert prázdné `secrets.dart` + secret-scan bundlu.

## 1. Boti u @BotFather

- [ ] `/newbot` → **prod bot** (např. `TsumikiMangaBot`) — token do
      `tgbot/mangabot.env` na JODĚ (`BOT_TOKEN=`), nikdy do repa.
- [ ] `/newbot` → **dev bot** (např. `TsumikiMangaDevBot`) — token pro dev
      instanci backendu.
- [ ] Prod bot: `/setuserpic` (z `assets/icon/app_icon.png`), `/setdescription`,
      `/setabouttext`.

## 2. Cloudflare Pages

- [x] Vytvořit Pages projekt **`tsumiki`** (Direct Upload / wrangler,
      ne Git integration — deploy dělá GitHub Actions). Holé `tsumiki.pages.dev`
      bylo zabrané → projekt jede na **`tsumiki-7t0.pages.dev`**.
- [ ] Připojit custom doménu, např. **`app.ol1n.com`** (URL v BotFatherovi se
      pak už nikdy nemění).
- [x] Cloudflare API token s právem **Pages:Edit** → GitHub repo secrets:
      `CLOUDFLARE_API_TOKEN`, `CLOUDFLARE_ACCOUNT_ID`.
- [ ] Push na `main` → workflow **Deploy Web** nasadí produkci.

## 3. Backend na JODĚ (NAS) — SPARK dělá jen ComfyUI

Viz `tgbot/README.md` (Docker Compose, `mangabot.env`, testy).

- [x] Checkout repa na JODU, `cp mangabot.env.example mangabot.env`, vyplnit,
      `docker compose up -d --build`; `ALLOWED_ORIGINS=https://app.ol1n.com`.
- [x] Konektivita na ComfyUI: `COMFY_URL=http://<spark-ip>:8188` přes LAN
      (ComfyUI s `--listen`), nebo `https://comfyui.ol1n.com` + CF Access token.
- [x] Veřejná HTTPS: cloudflared na JODĚ (sidecar v docker-compose) s public
      hostname `tg.ol1n.com → http://mangabot:8090` (bez CF Access!).
- [x] Smoke: `curl https://tg.ol1n.com/healthz` → ok;
      `curl -X POST https://tg.ol1n.com/api/generate` → 401 (bez auth hlavičky).
- [x] **Odstranit `DEV_TOKEN` z `mangabot.env`** — API je od zapnutí tunelu
      veřejné a ten token obchází initData (generuje jako `user_id=0`).
      Nechat ho tam smí jen dev instance, ne produkce.
- [x] Denní záloha `tgbot/data/mangabot.db` (kredity + platby!) — `tgbot/backup.sh`
      běží z cronu na JODĚ ve 4:00, log v `/home/oli/mangabot-backup.log`,
      drží 14 posledních denních.
- [x] Záloha na jiném disku — `backup.sh` zrcadlí denní snapshot na
      `/pool/Backup/tsumiki` (raidz1 přes tři disky), zatímco databáze leží na
      systémovém SSD. Kopie se ověřuje `cmp` proti originálu.
- [ ] Kopii záloh dostat *pryč z JODY* — `backup.sh` už umí nahrát na
      Cloudflare R2 (`rclone` remote `r2:`, bucket `tsumiki-backups`, 90 dní),
      ale remote na JODĚ zatím není nakonfigurovaný, takže se krok přeskakuje.
      Chybí: R2 bucket + API token s Object Read & Write. **V DB už jsou reálné
      Stars platby**, takže tohle není teoretické.

## 4. BotFather — Mini App konfigurace

- [ ] Bot Settings → **Main Mini App** → `https://app.ol1n.com`
      (tím se bot objeví v záložce **Apps** ve vyhledávání a na profilu bude „Open App“).
- [ ] `/newapp` → direct link `t.me/<bot>/<shortname>` (title, popis, foto 640×360,
      volitelně demo GIF).
- [ ] `/setmenubutton` → stejná URL.
- [ ] Na profil bota nahrát **media preview** (screenshoty/video z appky) —
      podmínka viditelnosti/featuringu.
- [ ] Dev bot: Main Mini App → preview deployment (`pr-N` branch URL z Pages).

## 5. E2E ověření (dev bot, pak prod)

- [ ] Otevřít Mini App v Telegramu (Android + iOS + Desktop): appka se načte,
      `expand()` funguje, generování flux i pony doběhne, obrázek se ukáže
      v appce **a přijde do chatu**.
- [ ] Bez /start: generování funguje, jen nepřijde zpráva do chatu (log 403).
- [ ] Shodit ComfyUI → appka ukáže čitelnou chybu.
- [x] `curl` z cizího originu → CORS blokuje.

## 6. Distribuce („market“)

- [ ] **Apps tab**: po nastavení Main Mini App se bot objevuje ve vyhledávání
      Telegramu (záložka Apps) — ověřit dohledatelnost podle jména.
- [ ] **Telegram Apps Center** (tapps.center): submission přes **@tapps_bot** —
      připravit ikonu, popis (EN), screenshoty/banner, funkční `t.me` link.
      Web3/TON není podmínkou listingu.
- [ ] (Později, volitelně) **Telegram Stars** platby — podmínka featuringu
      v oficiálním Mini App Store.

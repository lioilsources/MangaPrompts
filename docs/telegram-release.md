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

- [ ] `/newbot` → **prod bot** (např. `MangaPromptsBot`) — token do
      `/etc/mangabot/env` na SPARKu (`BOT_TOKEN=`), nikdy do repa.
- [ ] `/newbot` → **dev bot** (např. `MangaPromptsDevBot`) — token pro dev
      instanci backendu.
- [ ] Prod bot: `/setuserpic` (z `assets/icon/app_icon.png`), `/setdescription`,
      `/setabouttext`.

## 2. Cloudflare Pages

- [ ] Vytvořit Pages projekt **`manga-prompts`** (Direct Upload / wrangler,
      ne Git integration — deploy dělá GitHub Actions).
- [ ] Připojit custom doménu, např. **`app.ol1n.com`** (URL v BotFatherovi se
      pak už nikdy nemění).
- [ ] Cloudflare API token s právem **Pages:Edit** → GitHub repo secrets:
      `CLOUDFLARE_API_TOKEN`, `CLOUDFLARE_ACCOUNT_ID`.
- [ ] Push na `main` → workflow **Deploy Web** nasadí produkci.

## 3. Backend na SPARKu

Viz `tgbot/README.md` (venv, `/etc/mangabot/env`, systemd, testy).

- [ ] Nasadit `tgbot/` + `mangabot.service`, `ALLOWED_ORIGINS=https://app.ol1n.com`.
- [ ] cloudflared: ingress `tg.ol1n.com → http://localhost:8090` (bez CF Access!)
      + `cloudflared tunnel route dns <tunnel> tg.ol1n.com`.
- [ ] Smoke: `curl https://tg.ol1n.com/api/generate` → 401 (bez auth hlavičky).

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
- [ ] `curl` z cizího originu → CORS blokuje.

## 6. Distribuce („market“)

- [ ] **Apps tab**: po nastavení Main Mini App se bot objevuje ve vyhledávání
      Telegramu (záložka Apps) — ověřit dohledatelnost podle jména.
- [ ] **Telegram Apps Center** (tapps.center): submission přes **@tapps_bot** —
      připravit ikonu, popis (EN), screenshoty/banner, funkční `t.me` link.
      Web3/TON není podmínkou listingu.
- [ ] (Později, volitelně) **Telegram Stars** platby — podmínka featuringu
      v oficiálním Mini App Store.

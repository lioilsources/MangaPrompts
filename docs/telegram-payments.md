# Plán: Mikroplatby v Tsumiki Mini Appce (Telegram Stars)

> **Stav: NAIMPLEMENTOVÁNO** (P1–P4). API běží na NAS **JODA** (Docker),
> SPARK dělá jen ComfyUI. Zbývají manuální kroky P5 (Fragment/TON peněženka)
> a E2E test v Telegramu — viz `docs/telegram-release.md` a `tgbot/README.md`.

## Rozhodnutí: Stars, ne přímé krypto

Telegram od června 2024 **vyžaduje, aby se digitální zboží a služby v botech
a Mini Apps platily výhradně v Telegram Stars (XTR)** — kvůli souladu
s pravidly Apple/Google (uživatel Stars kupuje in-app purchasem nebo přes
@PremiumBot). Generování obrázků je digitální služba ⇒ **Stars jsou jediná
compliant cesta**. Přímé platby TON/USDT přes TON Connect uvnitř Mini Appky by
porušily podmínky a riskovaly odstranění z katalogů (Apps tab, tapps.center).

Krypto přesto ve hře zůstává — **na výplatní straně**: vydělané Stars se
vyplácejí výhradně v **TON přes Fragment** (viz Infrastruktura / Výplata).
TON Connect (TON/USDT přímo z peněženky) dává smysl až případně později pro
use-casy mimo digitální služby; pro MVP je mimo scope.

## Produktový model (MVP)

- **Free tier**: 3 generování / 24 h zdarma (dnešní `DAILY_LIMIT` mechanismus).
- **Kredity**: 1 kredit = 1 generování. Balíčky např.:
  - 10 kreditů … 25 ⭐
  - 50 kreditů … 100 ⭐ (výchozí, zvýhodněný)
  - 250 kreditů … 400 ⭐
- Ekonomika: 1 ⭐ ≈ $0.013 hrubého pro vývojáře (po 30% store fee na nákupní
  straně efektivně ~$0.009). GPU je vlastní (SPARK), marginální náklad ≈
  elektřina ⇒ cenotvorba je hlavně o vnímané hodnotě; balíčky lze ladit později.
- **Fáze 2 (volitelné)**: měsíční „unlimited“ přes Stars subscription
  (Bot API `createInvoiceLink` se `subscription_period=2592000`).

## Platební flow (Stars + Mini App)

```
Mini App                        tgbot (SPARK)                   Telegram
   │ POST /api/invoice {package}   │                               │
   │──────────────────────────────▶│ createInvoiceLink(XTR,        │
   │                               │   payload={user,package,nonce})│
   │◀─── {link} ───────────────────│◀──────────────────────────────│
   │ WebApp.openInvoice(link)      │                               │
   │───────────────────────────────────────────────────────────────▶ platba ⭐
   │                               │◀── pre_checkout_query ────────│
   │                               │─── answerPreCheckoutQuery(ok) ▶│ (do 10 s!)
   │                               │◀── message.successful_payment ─│
   │                               │  připsat kredity (idempotentně │
   │                               │  dle telegram_payment_charge_id)
   │ event invoiceClosed('paid')   │                               │
   │ GET /api/me → nový zůstatek   │                               │
```

`POST /api/generate` pak atomicky: free kvóta → jinak odečti 1 kredit → jinak
402 + nabídka balíčků.

## Co je potřeba za infrastrukturu

### 1. Perzistence na JODĚ (nová — dnes je vše in-memory)
Platby vyžadují trvalý stav. **SQLite** (soubor v `DATA_DIR`, WAL mód) stačí:
- `users(user_id, credits, created)`
- `payments(charge_id UNIQUE, user_id, stars, credits, package, ts)` — ledger,
  idempotence příjmu `successful_payment`, podklad pro refundy a účetnictví
- `usage(user_id, ts, kind)` — free-kvóta a audit generování
- (volitelně) `jobs` — přežití restartu služby
- **Zálohy**: denní cron `sqlite3 .backup` + rsync mimo SPARK.

### 2. tgbot rozšíření (kód)
- `POST /api/invoice` — validace balíčku, `createInvoiceLink` (aiogram
  `bot.create_invoice_link(currency='XTR', prices=[LabeledPrice(...)],
  provider_token='')`), payload s nonce.
- `GET /api/me` — `{credits, free_remaining}`.
- aiogram handlery: `PreCheckoutQuery` (odpovědět **do 10 s**, validovat
  payload), `successful_payment` (idempotentní připsání kreditů + ledger),
  `/paysupport` (Telegram vyžaduje kanál pro platební podporu),
  admin příkaz pro refund (`refundStarPayment(user_id, charge_id)`).
- `/api/generate`: transakční odečet kreditu/kvóty (SQLite `BEGIN IMMEDIATE`).

### 3. Flutter Mini App (kód)
- `telegram_webapp` shim: `openInvoice(url)` + event `invoiceClosed`
  (js_interop `onEvent('invoiceClosed', cb)`).
- UI: zůstatek kreditů (AppBar chip), paywall bottom-sheet s balíčky po
  vyčerpání free kvóty, refresh `/api/me` po zaplacení.

### 4. Telegram účty a výplata (manuální, jednorázově)
- **Nic se nezapíná u BotFathera** — Stars invoicy fungují rovnou přes Bot API.
- **TON peněženka** (Tonkeeper nebo Wallet v Telegramu) pro příjem výplat.
- **Fragment** účet propojený s botem — výplata Stars → TON: hold **21 dní**
  od přijetí, minimum **1 000 ⭐**, poplatek Telegramu ~0.
- Případná konverze TON → fiat přes burzu; **příjmy je třeba danit** (ČR:
  příjem z podnikání + případná konverze krypto→fiat je zdanitelná událost).

### 5. Testování
- Bot API **test environment** (testovací server Telegramu, test Stars) pro
  celý flow bez reálných peněz; poté smoke s nejmenším balíčkem naostro
  + ověření `refundStarPayment`.
- Unit testy: idempotence `successful_payment` (dvojité doručení), atomický
  odečet kreditů při souběhu, payload validace v pre-checkout.

### 6. Provoz
- `/healthz` endpoint + jednoduchý uptime monitoring (např. UptimeRobot na
  `tg.ol1n.com/healthz`); logy `journalctl -u mangabot`.
- Rate-limit na `/api/invoice` (WAF pravidlo jako u `/api/generate`).

## Fáze a odhad

| Fáze | Obsah | Odhad |
|---|---|---|
| P1 | SQLite vrstva (users/payments/usage) + migrace limitů z paměti | 1 d |
| P2 | Invoice endpoint + aiogram payment handlery + refund/paysupport | 1 d |
| P3 | Flutter: openInvoice shim, zůstatek, paywall UI | 1 d |
| P4 | Test env E2E + reálný smoke + zálohy/monitoring | 0,5 d |
| P5 | Manuální: Fragment + TON peněženka, první výplata | 0,5 d |
| **Celkem** | | **~4 dny** |

Bonus po nasazení: bot s Main Mini App **přijímající Stars** splňuje podmínky
pro featuring v oficiálním Telegram Mini App Store — po P4 požádat o listing
featured sekce a aktualizovat tapps.center profil.

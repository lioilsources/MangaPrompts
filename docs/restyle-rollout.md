# Restyle fotky — plán uvedení do provozu a E2E testu

Zadání pro Claude, který **má přístup na SPARK, JODU a repo**. Kód je hotový
a otestovaný lokálně (unit + widget testy, `flutter build web`), ale nikdo ho
zatím nepustil proti reálnému ComfyUI ani proti Telegramu. Tenhle dokument je
postup, jak to udělat, aniž by se spálil GPU čas nebo rozbila produkce.

- Větev: **`claude/tsumiki-new-card-c182q4`** (repo `lioilsources/MangaPrompts`)
- Co přibylo: karta „Restyle a photo“ v Mini Appce, `POST /api/restyle`
  v `tgbot/`, workflow `assets/comfyui/sdxl_restyle.api.json`
- Účtování: **jako běžné generování obrázku** (`spend_generation`, stejná free
  kvóta i kredity, jeden obrázkový job na uživatele)

Pořadí kroků je závazné: **1 → 2 jsou zdarma a odhalí většinu problémů, teprve
3 stojí GPU čas a teprve 5 se dotkne produkce.**

---

## 0. Co ověřit dřív, než se něco změní

```bash
git fetch origin claude/tsumiki-new-card-c182q4
git log --oneline origin/main..origin/claude/tsumiki-new-card-c182q4
```

Na JODĚ i na SPARKu **nejdřív zjisti skutečný stav**, nespoléhej na tenhle
dokument ani na `docs/telegram-release.md` (jeho zaškrtnutí mohou být stará):

```bash
# JODA
cd <checkout>/tgbot && git status && docker compose ps
grep -v SECRET mangabot.env | grep -E 'COMFY_URL|ALLOWED_ORIGINS|MINIAPP_URL|FREE_DAILY_LIMIT'
curl -s https://tg.ol1n.com/healthz
```

Poznač si do reportu: na jaké URL Mini App reálně běží (`app.ol1n.com`, nebo
ještě `tsumiki-7t0.pages.dev`), který bot je produkční a jestli existuje dev bot.

---

## 1. Pre-flight proti ComfyUI (zdarma, ~1 s)

Workflow je portovaný z Ol1nLLM. Třídy uzlů i váhy tam byly ověřené proti témuž
serveru, ale verze custom nodes se mohly pohnout. V repu je na to skript —
přečte `*.api.json`, stáhne `GET /object_info` a porovná **třídy, názvy vstupů
i názvy souborů modelů**:

```bash
cd <checkout>/tgbot
python3 tools/check_workflow.py ../assets/comfyui/sdxl_restyle.api.json \
    --url http://<spark-ip>:8188 \
    --ckpt Juggernaut-XL_v9_RunDiffusionPhoto_v2.safetensors
# přes veřejný hostname: --url https://comfyui.ol1n.com --cf-id … --cf-secret …
```

Očekávaný výstup: `OK — … can run … (19 nodes)`. Cokoli jiného vypíše konkrétní
uzel a důvod.

Co graf potřebuje (kdyby skript hlásil chybějící třídu):

| Custom node pack | Třídy |
|---|---|
| comfyui_controlnet_aux | `DepthAnythingV2Preprocessor` |
| ComfyUI-KJNodes | `ImageResizeKJv2` |
| ComfyUI_InstantID | `InstantIDModelLoader`, `InstantIDFaceAnalysis`, `ApplyInstantIDAdvanced` |
| ComfyUI-Impact-Pack (+ Impact-Subpack) | `FaceDetailer`, `UltralyticsDetectorProvider` |

Váhy: `depth_anything_v2_vitl.pth`, `controlnet-union-sdxl-promax-xinsir.safetensors`,
`ip-adapter.bin` (InstantID), `instantid-controlnet-sdxl.safetensors`,
`bbox/face_yolov8m.pt`, checkpoint `Juggernaut-XL_v9_RunDiffusionPhoto_v2.safetensors`.

⚠️ **Jednu věc `/object_info` neukáže**: `InstantIDFaceAnalysis` si při prvním
běhu načítá InsightFace balík **antelopev2** (`models/insightface/models/antelopev2`).
Třída se v `/object_info` tváří v pořádku i bez něj a spadne až za běhu. Ověř
existenci složky na SPARKu ručně; když chybí, je to stažení, ne přepis kódu.

---

## 2. Suchý běh workflow bez appky (levné, jeden job)

Než se nasazuje backend, pusť graf ručně — tím se oddělí „workflow nefunguje“
od „backend ho špatně skládá“:

```bash
cd <checkout>/tgbot
python3 - <<'PY'
import asyncio, aiohttp, json, sys
sys.path.insert(0, '.')
from comfy import ComfyClient, prepare_workflow
from imagesize import latent_for

photo = open('/cesta/k/portretu.jpg','rb').read()
tpl = json.load(open('../assets/comfyui/sdxl_restyle.api.json'))

async def main():
    c = ComfyClient('http://<spark-ip>:8188', client_id='preflight')
    async with aiohttp.ClientSession() as s:
        name = await c.upload_image(s, photo, 'preflight_restyle.png')
        wf = prepare_workflow(
            tpl,
            prompt='a photorealistic photograph of a person, natural skin texture, '
                   'realistic lighting, true-to-life detail, ukiyo-e style, bold black '
                   'outlines, flat color areas, japanese woodblock print aesthetic',
            negative='illustration, painting, drawing, cartoon, anime, 3d render, '
                     'bad quality, blurry, deformed, bad anatomy, bad hands',
            batch=1, image_name=name,
            checkpoint='Juggernaut-XL_v9_RunDiffusionPhoto_v2.safetensors',
            latent=latent_for(photo),
        )
        img = await c.wait_for_image(s, (await c.queue_prompt(s, wf))[0], timeout=600)
        open('/tmp/restyle_preflight.png','wb').write(img)
        print('hotovo:', len(img), 'B, bucket', latent_for(photo))
asyncio.run(main())
PY
```

**Na co se u výsledku dívat** (tohle je hlavní věc, kterou lokální testy
ověřit nemohly):

1. **Tvář** — je to poznatelně tentýž člověk? Když ne, ladit
   `__face_apply__.ip_weight` (teď 0.6, což je odhad podle doporučení
   InstantID pro stylizaci, **ne měření**) směrem nahoru k 0.8.
2. **Póza a rámování** — sedí postoj a orientace předlohy? Fotka na výšku
   nesmí přijít o hlavu ani chodidla — to hlídá letterboxing
   (`ImageResizeKJv2`, `pad`) na SDXL bucket. Zkus schválně fotku 1:2.
3. **Styl** — je na výsledku vidět ukiyo-e, nebo jen fotka s jinými barvami?
   InstantID embedding je fotografický a přebíjí stylový blok; když styl
   neprojde ani na Juggernautu, sniž `ip_weight`, ne strength hloubky.
4. **Kolik to trvalo** — první běh je pomalý (načtení InstantID + antelopev2 +
   DepthAnything). Backend má na job `JOB_TIMEOUT` 300 s a klient 5 min. Když
   se první běh do toho nevejde, zvedni `JOB_TIMEOUT` v `mangabot.env`, ne
   v kódu.

Pak totéž s promptem pro `illustration` (`a painted illustration of a person,
artwork, …` + negativ s `photograph`). **Očekávané riziko**: oba režimy jedou
defaultně na Juggernautu (fotoreal SDXL finetune), takže „Illustration“ může
zůstat fotografická. Pokud ano, není to bug v kódu — nastav na JODĚ
`RESTYLE_CKPT_ILLUSTRATION=<nějaký kreslený SDXL ckpt, který je na serveru>`
a zopakuj. Pozor: booru modely (pony/illustrious) čtou InstantID embedding
jako šum — ověř, že tvář na nich přežije, jinak zůstaň u Juggernautu.

---

## 3. Nasazení backendu na JODU

Docker image kopíruje `*.py`, takže nový `imagesize.py` se přibalí sám;
workflow se mountuje z checkoutu (`../assets/comfyui:/app/workflows:ro`),
takže **stačí přepnout checkout na větev a rebuildnout**:

```bash
cd <checkout> && git fetch origin && git checkout claude/tsumiki-new-card-c182q4
cd tgbot && docker compose up -d --build && docker compose logs -f mangabot
```

Volitelně do `mangabot.env` (jen když to vyšlo z kroku 2):
`RESTYLE_CKPT_PHOTO=`, `RESTYLE_CKPT_ILLUSTRATION=`.

Smoke test API:

```bash
curl -s https://tg.ol1n.com/healthz                        # {"status":"ok"}
curl -s -X POST https://tg.ol1n.com/api/restyle -d '{}'    # 401 bez auth
```

---

## 4. Web build a **kudy ho pustit do Telegramu**

Web se nasazuje **jen z CI** (`.github/workflows/deploy-web.yml`) — lokální
`wrangler pages deploy` je zakázaný, protože by mohl vynést creds z lokální
`secrets.dart`. Workflow běží i na pull requesty a nasazuje preview na branch
`pr-<N>` projektu Pages `tsumiki`.

Tady je past, na kterou si dej pozor:

> Build **nedostává** `TG_BACKEND_URL` (CI záměrně neposílá žádné dart-define),
> takže i preview deployment mluví s **produkčním** backendem `tg.ol1n.com`.
> Ten validuje `initData` proti **produkčnímu** `BOT_TOKEN`. Preview otevřený
> z **dev bota** tedy dostane 401 — testovat se musí přes produkčního bota.

Doporučená cesta (nesahá na to, co vidí stávající uživatelé):

1. Otevři PR z větve → CI nasadí preview, poznač si jeho URL
   (`https://pr-<N>.tsumiki-7t0.pages.dev`).
2. Na JODĚ přidej tenhle origin do `ALLOWED_ORIGINS` (čárkou oddělený seznam,
   **přesné originy**) a restartuj službu — jinak preview zablokuje CORS.
3. U **produkčního** bota v BotFatherovi udělej `/newapp` druhou Mini App
   (direct link `t.me/<bot>/restyletest`) s preview URL. Menu button ani Main
   Mini App neměň — produkce jede dál na main.
4. Otestuj podle kroku 5.
5. Po testu: preview origin z `ALLOWED_ORIGINS` zase pryč, testovací app
   smazat.

Rychlejší, ale hrubší varianta: merge do `main` → CI nasadí produkci → testuj
rovnou v ostré appce. Vezmi ji jen když je krok 2 čistý a jsi ochotný případný
rollback řešit revertem a dalším deployem.

---

## 5. E2E scénáře v Telegramu

Účet použij takový, kde nevadí utratit kredity; každý běh stojí 1 free
generování nebo 1 kredit. Před a po každém scénáři si čti zůstatek
(`/api/me`, nebo chip ⚡ v appce) — **hlavní věc, kterou tady ověřuješ, je že
se za neúspěch neplatí**.

| # | Scénář | Očekávání |
|---|---|---|
| 1 | Portrét, Photo, libovolný styl | obrázek v appce **i v chatu**, popisek `🖼 <styl> · photo`, zůstatek −1 |
| 2 | Tentýž portrét, Illustration | jiný výsledek než 1 (jestli ne, viz krok 2 — je to volba checkpointu) |
| 3 | Fotka **bez tváře** (krajina) | job selže s čitelnou hláškou (ideálně „no face detected…“), **zůstatek se vrátí** |
| 4 | Fotka na výšku ~1:2 | hlava i nohy v záběru (letterboxing funguje) |
| 5 | Odeslat druhý restyle, než doběhne první | 429 „wait for your previous generation to finish“ |
| 6 | Vyčerpat kvótu i kredity | 402 → otevře se paywall, Stars nákup projde, restyle pak jede |
| 7 | Shodit ComfyUI a odeslat | 502, čitelná chyba v appce, **zůstatek se vrátí** |
| 8 | Zavřít appku hned po odeslání | obrázek stejně dorazí do chatu |
| 9 | Uživatel bez `/start` u bota | obrázek je v appce, do chatu nedorazí, v logu 403 (ne pád) |
| 10 | Přepínač karet (builder / restyle / animace) | karty se nevrší, návrat na kořenovou kartu funguje, chip ⚡/🎬 sedí ke kartě |

Na obou platformách, kde to jde (Android + iOS + Desktop), aspoň scénář 1 a 10.

---

## 6. Co reportovat zpátky

- Výstup kroku 1 (pre-flight) doslova.
- **Obrázky** z kroku 2 a scénářů 1–2 + 4 — tohle je to jediné, co nikdo zatím
  neviděl, a jediné, co rozhodne, jestli je nastavení dobré.
- Naměřený čas jednoho restyle jobu (první a druhý běh).
- Jestli jsi měnil `ip_weight`, `RESTYLE_CKPT_*` nebo `JOB_TIMEOUT` a na co.
- Tabulku scénářů 1–10 s výsledkem, hlavně u 3 a 7 skutečný zůstatek před/po.

## 7. Rollback

Backend: `git checkout main && docker compose up -d --build` na JODĚ.
Web: revert merge commitu v `main`, CI přenasadí. Karta zmizí z Mini Appky
sama, endpoint bez ní nikdo nevolá; nic v databázi restyle nemění (žádná
migrace, jen řádky v `usage`, které vypadají stejně jako generování).

## 8. Známé odhady, které tenhle test má potvrdit nebo vyvrátit

Nejsou to bugy, jsou to místa, kde padlo rozhodnutí bez měření na tomhle
serveru:

- `ip_weight` 0.6 / `cn_strength` 0.8 u InstantID — převzato z Ol1nLLM
  jako doporučení pro stylizaci, ne jako naměřená hodnota.
- Hloubka 0.75 se `end_percent` 0.9 — v Ol1nLLM ověřené pro repose nad SDXL,
  tady poprvé s InstantID v jednom grafu.
- `FaceDetailer` podmíněný **zpřed** hloubkového ControlNetu (pracuje s výřezem,
  celoobrazová hloubka na něj nesedí) — logika sedí, výsledek neviděn.
- Oba režimy média na jednom checkpointu — viz krok 2.
- 8 „Popular“ stylů (anime, komiks, akvarel, olej, tužka, pop art, cyberpunk,
  noir) **není** z měřené matice Ol1nLLM, na rozdíl od zbylých 40.

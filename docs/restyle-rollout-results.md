# Restyle fotky — výsledky kroků 1–3

Měřeno 2026-09-09 proti ComfyUI na SPARKu (`http://192.168.88.66:8188`,
`/home/ol1n/Code/ComfyUI`, ruční běh, ne systemd). Postup podle
[`restyle-rollout.md`](restyle-rollout.md); tenhle soubor je odpověď na jeho
kapitolu 6. Kroky 4–5 (web do Telegramu, E2E scénáře) zatím **neproběhly**.

## 0. Skutečný stav

| | |
|---|---|
| Mini App URL | `https://tsumiki-7t0.pages.dev/` — menu button produkčního bota míří sem, **ne** na `app.ol1n.com` |
| Produkční bot | `@tsumikimanga_bot` (id 8996021002), `has_main_web_app: false` |
| Dev bot | **neexistuje** — v `mangabot.env` je jediný `BOT_TOKEN` |
| `ALLOWED_ORIGINS` | `https://app.ol1n.com,https://tsumiki-7t0.pages.dev` |
| `COMFY_URL` | `http://192.168.88.66:8188` (LAN, CF varianta zakomentovaná) |
| `FREE_DAILY_LIMIT` | 3 · `VIDEO_FREE_DAILY_LIMIT` 1 · `JOB_TIMEOUT` nenastaven → default 300 s |
| `https://tg.ol1n.com/healthz` | `{"status":"ok"}` |

Dvě věci, které plán předpokládal jinak:

- **Checkout na JODĚ je single-branch klon.** `remote.origin.fetch` je jen
  `+refs/heads/main:refs/remotes/origin/main`, takže `git fetch origin` z kroku 3
  **tiše neudělá nic** a `git checkout <větev>` pak spadne na „did not match any
  file(s)". Správně:
  `git fetch origin claude/tsumiki-new-card-c182q4:claude/tsumiki-new-card-c182q4`.
- **ComfyUI na SPARKu neběží pod systemd.** `comfyui.service` je `inactive
  (dead)`, port 8188 drží ruční `python main.py --listen --reserve-vram 8 …`
  (pid 1196022, spuštěno 2026-09-09 06:03). Reboot SPARKu tedy restyle shodí
  a nic ho nenahodí zpátky.

## 1. Pre-flight — prošel, ale až po opravě skriptu

Původní běh nahlásil na **všech** workflow s `LoadImage` (tedy i na čtyřech,
které v produkci normálně jedou):

```
1 problem(s) with ../assets/comfyui/sdxl_restyle.api.json on http://192.168.88.66:8188:
  • node 2 (LoadImage): unknown input 'upload' (node version drift?)
```

`upload` je tlačítko frontendu, ne vstup uzlu — tahle verze ComfyUI ho už
v `INPUT_TYPES` nedeklaruje a `get_input_data` (execution.py:161) zahodí každý
klíč, který `INPUT_TYPES` nezná. Falešný poplach, opraveno v 09aa2cf
(`FRONTEND_ONLY_INPUTS`); kontrola přejmenovaného vstupu, kvůli které skript
existuje, zůstává. Po opravě:

```
OK — http://192.168.88.66:8188 can run ../assets/comfyui/sdxl_restyle.api.json (19 nodes)
```

a čistě projde i zbylých sedm workflow v `assets/comfyui/`.

**antelopev2 je na místě** — `models/insightface/models/antelopev2/` obsahuje
všech pět `.onnx` (1k3d68, 2d106det, genderage, glintr100, scrfd_10g_bnkps).
Žádné stahování není potřeba.

## 2. Suchý běh — co měření ukázalo

Předloha: `ab_repose_ref.png` (1024×1024, referenční portrét, na kterém se na
tomhle serveru dělalo A/B repose) a `tall_ref.png` (768×1536, celá postava,
vygenerováno lightning workflow kvůli testu 1:2).

| # | Předloha | Medium | Styl | Checkpoint | ip_weight | Bucket | Čas |
|---|---|---|---|---|---|---|---|
| 1 | portrét | photo | ukiyo-e | Juggernaut | 0.6 | 1024×1024 | **66,5 s** (studený běh) |
| 2 | portrét | illustration | ukiyo-e | Juggernaut | 0.6 | 1024×1024 | 88,5 s |
| 3 | portrét | illustration | ukiyo-e | **SDXL base** | 0.6 | 1024×1024 | 74,6 s |
| 4 | portrét | illustration | anime | SDXL base | 0.6 | 1024×1024 | 98,6 s |
| 5 | portrét | illustration | anime | Animagine XL 4.0 | 0.6 | 1024×1024 | 116,7 s |
| 6 | 1:2 postava | illustration | ukiyo-e | SDXL base | 0.6 | **768×1344** | 98,5 s |
| 7 | portrét | illustration | ukiyo-e | SDXL base | **0.8** | 1024×1024 | 90,5 s |

**Čas.** Studený běh 66,5 s, další 74–117 s. `JOB_TIMEOUT` 300 s stačí
s velkou rezervou, měnit ho není proč. Načtení InstantID + antelopev2 +
DepthAnything se do prvního běhu vešlo bez problémů.

**Styl na Juggernautu neprojde (běhy 1–2).** Přesně ta obava z plánu: oba
režimy na fotoreal finetunu skončí jako fotka. V `photo` je to obhajitelné
(medium to říká a negativ to vynucuje), ale styl se projevil jen jako
ornamentální textura na zdi a na košili — žádné ukiyo-e signifikanty.
V `illustration` je výsledek pořád fotografický, jen s plošším stínováním.

**`RESTYLE_CKPT_ILLUSTRATION=sd_xl_base_1.0.safetensors` to řeší (běh 3).**
Ostré obrysy, plochy, omezená paleta, dřevořezové linky v pozadí — a identita
i póza drží. InstantID je trénovaný na SDXL base, takže embedding sedí.

**Booru model potvrdil varování z plánu (běh 5).** Animagine kreslí čistou
linku, ale prózu čte špatně (duhový gradient místo palety) a **identita se
ztratí** — obecný anime obličej, změněné proporce těla. Pro `illustration`
nepoužívat. SDXL base zvládne i „anime" styl (běh 4), byť spíš jako digitální
malbu než anime.

**ip_weight 0.8 je horší volba, ne lepší (běh 7 vs. 3).** Plán navrhoval při
špatné podobě zvednout 0.6 → 0.8. Podoba se opravdu zřetelně zlepší, jenže
InstantID embedding je fotografický a při 0.8 přebije stylový blok **na
postavě**: pozadí je grafické, člověk zůstane fotka. Výsledek je nesourodý.
**Nechat 0.6.** Na běhu 6 (mužská postava) drží při 0.6 podoba i styl
současně, takže rozptyl je hlavně mezi předlohami.

**Letterboxing funguje (běh 6).** Fotka 1:2 spadla do bucketu 768×1344, hlava
i boty zůstaly v záběru, nic se neuřízlo. Vedlejší efekt: `pad` (48 px vlevo
i vpravo, ~6 % šířky) se v obraze projeví jako svislé pruhy — u ukiyo-e z nich
model udělal okraje svitku, u jiných stylů to může vypadat jako artefakt.

## 3. Backend na JODĚ — nasazeno

Větev `09aa2cf` vyfetchována a checkoutnuta, image přebuildován, kontejner
`mangabot` běží. Do `mangabot.env` doplněn jediný řádek
`RESTYLE_CKPT_ILLUSTRATION=sd_xl_base_1.0.safetensors` (záloha
`mangabot.env.bak-20260909`); `ip_weight` ani `JOB_TIMEOUT` **neměněny**.

```
$ curl -s https://tg.ol1n.com/healthz            → {"status":"ok"}
$ curl -s -X POST https://tg.ol1n.com/api/restyle -d '{}'  → HTTP 401
$ docker exec mangabot python -c "import config; print(config.RESTYLE_CHECKPOINTS)"
{'photo': 'Juggernaut-XL_v9_RunDiffusionPhoto_v2.safetensors',
 'illustration': 'sd_xl_base_1.0.safetensors'}
```

Všech osm workflow je v kontejneru vidět na `/app/workflows`.

## 4. Web — merge do main

Zvolena rychlejší varianta z plánu (merge → CI nasadí produkci), protože krok 2
dopadl čistě a dev bot neexistuje, takže by se preview stejně testovalo přes
produkčního bota. Před mergem lokálně: `flutter analyze` (12 × info, všechno
starší a mimo restyle soubory), `flutter test` (28 prošlo), `flutter build web
--release` prošel.

Rollback zůstává podle kapitoly 7 plánu: revert merge commitu, CI přenasadí.

## 5. Scénář 3 předběžně ověřen mimo Telegram

Fotka bez tváře (vygenerovaná krajina 1216×832) prohnaná stejným grafem:

```
comfy.ComfyError: ComfyUI: Reference Image: No face detected.
```

Přesně ta čitelná hláška, kterou scénář 3 chtěl — `execution_error_message`
vytáhne výjimku uzlu z historie a `InstantIDFaceAnalysis` ji formuluje
srozumitelně. Refund na to navazuje v `_watch_job` (app.py:589): `ComfyError`
→ `db.undo_usage(usage_id)`. Skutečný zůstatek před/po tím **ověřený není**,
to chce Telegram účet.

### Nález: neúspěšný restyle uživateli nic neřekne do chatu

`_fail_video_job` u videa pošle do chatu „the animation failed — … Nothing was
charged for it.". `_watch_job` u obrázku a restyle jen nastaví `job.error`
a zaloguje. Kdo appku zavře hned po odeslání (scénář 8), se o selhání
nedozví — a hlavně se nedozví, že se mu nic nestrhlo. U videa to vyhodnotili
jako problém, protože render přežije session; restyle trvá 66–117 s, což je
stejná kategorie. Není to bug v tomhle rolloutu, ale stojí za zvážení.

## 6. Co zbývá

E2E scénáře 1–10 potřebují Telegram účet, tedy ruční zásah. Prioritní je
**7** (shozené ComfyUI) a doměření zůstatku u **3** — jediné, co potvrdí, že
se za neúspěch opravdu neplatí.

Dvě věci k zvážení mimo tenhle rollout:

- Povolit `comfyui.service` na SPARKu, ať restyle přežije reboot.
- Rozšířit fetch refspec checkoutu na JODĚ, ať `git fetch origin` nelže.

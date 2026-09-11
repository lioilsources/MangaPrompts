# Couple card — Fáze 0, část ověřitelná z repa

Vstup: handoff plán „Tsumiki bot — karta Couple". Tenhle dokument je jeho
**revize proti skutečnému stavu repozitářů** plus odpovědi na dvě otázky
z Fáze 0, které šly zodpovědět bez přístupu na hardware.

**Co je ověřené:** obsah `lioilsources/MangaPrompts` a `lioilsources/Ol1nLLM`
(lokální checkouty), veřejné zdroje k Wan Animate 2 a Wan 2.6/2.7.
**Co ověřené není:** cokoli na Sparku a JODĚ — verze custom nodes, dostupné
váhy, ONNX runtime na ARM64, časy renderu. Tahle část Fáze 0 zůstává celá
otevřená a je v §8 jako checklist.

**Žádný kód pro kartu jsem nepsal.** Dva nálezy níž (§2) mění zadání natolik,
že preprocess z Fáze 1 by se se slušnou pravděpodobností zahodil.

---

## 1. Shrnutí: co z plánu platí a co ne

| Premisa plánu | Stav |
|---|---|
| „Existující jednopostavová Animate karta v Tsumiki (1 ref → skeleton → face stream → Move/Replace)" | **Neplatí v tomhle repu**, viz §2.1 |
| „ImageStudio (Go) jako wrapper fronty" | Tsumiki bot tuhle službu nezná, viz §2.2 |
| Wan 2.2 Animate + skeleton preprocessing jako základ | **Nejspíš překonané** — Wan Animate 2 skeleton nepotřebuje, viz §3 |
| Dva průchody kvůli jedné referenci na model | **Platí i pro Animate 2** — žádný ze zdrojů nezmiňuje dvě reference |
| Identita se musí měřit, ne odhadovat | Platí a v domě už na to existuje kalibrovaný aparát, viz §4 |
| ArcFace práh 0.62 | Jako **per-frame minimum nedosažitelný**, viz §4.2 |

---

## 2. Blokující nálezy

### 2.1 Jednopostavová Animate karta v Tsumiki neexistuje

Karta „Animate a photo" v Tsumiki **nepoužívá Wan Animate ani ComfyUI**, a totéž
platí pro Ol1nLLM — tam je animace akce na dlaždici („Rozhýbat"), která posílá
`{scene, image, seed}` na tutéž video-api (`lib/services/video_service.dart`).
Ani jedna appka nemá pole pro driving video; video je u obou jen **výstup**.
`POST /api/animate` bere jednu fotku a **id presetu scény** z katalogu, který
bot proxuje z video-api na Sparku (`tgbot/video.py`: Wan 2.2 I2V + RIFE, jeden
GPU worker, ~150 s na beat); hotové mp4 doručí bot do chatu. Grep přes celý
repo nenašel `WanAnimate`, `WanVideoWrapper`, `skeleton`, `ViTPose`, `DWPose`
ani driving video (jediný zásah na „driving" je komentář o kvótách
v `tgbot/db.py:2`).

Důsledky:
1. **Není co rozšířit.** Couple karta není varianta stávající karty, je to nový
   kontrakt na backendu.
2. **Definice hotovo nemá základnu.** „Pod 2× času jednopostavové karty"
   se v tomhle repu nedá změřit, protože ta karta tady není.
3. Popisovaná karta nejspíš žije v **video-stack** nebo v jiném produktu —
   v žádné ze dvou Flutter appek není. **Než začne Fáze 1: najít ji, zapsat
   její workflow JSON a naměřený čas.** Do té doby je „stávající mechanismus"
   v plánu nepodložený.

### 2.2 Není rozhodnuto, která služba pipeline poveze

Bot dnes umí přesně dvě backendové cesty: ComfyUI (obrázky, `tgbot/comfy.py`)
a video-api (video, `tgbot/video.py`). Plán mluví o „ImageStudio (Go)" jako
frontě — třetí služba znamená nový klient, env pár, CF Access pár a vlastní
perzistenci pro re-attach.

Tvrdý detail: tabulka `video_jobs` drží **jeden `remote_id` na job**
(`tgbot/db.py:54`), protože dnešní video job je jeden vzdálený render.
Couple job má šest stavů a nejmíň tři vzdálené průchody.

**Doporučení (ušetří nejvíc práce):** ať celý řetězec P0–P5 vlastní wrapper
a ven vystaví **týž kontrakt jako video-api** — submit vrátí `job_id` +
odhad minut, poll vrátí stav a průběh, result vrátí mp4. Pak je změna v botu
jeden endpoint plus rozhodnutí o účtování, ne stavový stroj a migrace schématu.
Pokud wrapper tenhle kontrakt mít nemůže, je potřeba počítat s tím explicitně
ve Fázi 4, ne to objevit při integraci.

---

## 3. Wan Animate 2 mění Fázi 0 i Fázi 1

Otázka z plánu („ověřit, zda existuje open-weights Wan-Animate-2") má odpověď:
**ano.** Podle veřejných zdrojů (ověřit na boxu, ne věřit tomuhle odstavci):

- Wan-Animate-2, **Apache 2.0**, váhy zveřejněné **7. 8. 2026**, 14B;
  Comfy-Org repack, nativní nody `WanAnimate2ToVideo` a `WanAnimate2Cache`.
- **Skeleton se nepotřebuje**: model konzumuje driving video přímo
  („no intermediate motion extractor", „you do not need OpenPose or any
  skeleton extraction"). To **maže podstatnou část Fáze 1** — ViTPose,
  face cropy, prostorové zarovnání skeletonu.
- **Dvě reference nikde.** Model card ani workflow o multi-character
  nemluví; RunComfy explicitně píše „one reference character still".
  ⇒ **Dvouprůchodová architektura z plánu zůstává v platnosti**, stejně jako
  identity gate. Animate 2 řeší přípravu vstupu, ne dvě identity.
- **A hlavně nemá masku.** `WanAnimate2ToVideo` má vstupy `reference_image`,
  `pose_video`, `continue_motion`, `pose_strength`, `reference_image_strength`
  — a **žádný `character_mask` ani `background_video`**, které starší
  `WanAnimateToVideo` (2.2) má. Bez nich neumí „nahraď jednu osobu a zbytek
  scény nech být", tedy Mix režim, na kterém couple karta stojí.
- **Kapacita je otevřená otázka**: model card ladí defaulty na 8× A800 pro
  720p a testuje 480p na 2× A800. Spark je jeden GB10. Distill LoRA
  (lightx2v) a int8 repack jsou přesně to, co z toho dělá otázku měření.

Co dál stále potřebujeme sami, i s Animate 2: **rozdělení dvou osob**
(tracking, per-osoba masky, okluzní mapa). Komunitní multi-character workflow
to řeší **textovým maskováním přes segment-anything-2**, ne YOLO trackingem —
levnější cesta k `mask_A`/`mask_B` než co navrhuje Fáze 1.

**Rozhodnutí pro Fázi 0 (revize):** dřívější doporučení „změřit obě cesty
a vybrat rychlejší" **neplatí** — chybějící maska není otázka výkonu. Pro
couple kartu je cesta **Wan 2.2 Animate** (nativní `WanAnimateToVideo`,
Mix režim); Animate 2 je lepší volba pro **jednopostavovou** kartu, až se
najde (§2.1).

Mix režim navíc dělá dvouprůchod čistěji, než navrhoval plán: P1 nahradí A
s `background_video` = původní driving, P2 nahradí B s `background_video` =
výstup P1. Osobu A tedy nese background video a kompozici řeší model uvnitř —
odpadá ruční kompozit přes masku i obava ze švu a rozdílného nasvícení (§5).

Jeden experiment s Animate 2 přesto stojí za to: `reference_image` je obyčejný
obrázek, takže **jeden společný snímek obou lidí** jako reference by mohl nést
obě identity v jednom průchodu a maskování by odpadlo. Levné, a kdyby to vyšlo,
ruší to celou dvouprůchodovou větev.

Instalace, přesné soubory, velikosti a testy jsou v
[`docs/couple-spark-setup.md`](../docs/couple-spark-setup.md).

### 3.1 Wan 2.6/2.7 není jen benchmark, je to produktové rozhodnutí

Wan 2.6 je **closed API, váhy nikdy nevyšly**. Zároveň jeho R2V režim podle
zdrojů umí **až tři reference současně se zachovanou identitou u více postav** —
tedy přesně to, co tahle karta lokálně obchází dvouprůchodovým hackem.

Proto: benchmark ve Fázi 2 nemá být „kde je strop", ale **go/no-go s cenou za
klip**. Když API řeší dvě identity konstrukcí a lokální cesta jen aproximací,
je legitimní výsledek „karta jede přes API a lokální cesta se zahodí".
Rozhodnout dřív, než se investuje do Fáze 3.

---

## 4. Identity gate — tři opravy návrhu

### 4.1 Gate nesmí soudit okludované snímky

Plán měří ArcFace per snímek a pod prahem posílá job do refine. U polibku ale
skóre padá ze tří důvodů, které **nejsou selhání identity**: zavřené oči,
extrémní profil a samotná okluze. Gate podle `min` přes celý klip proto
u `kiss` a `hug` spolehlivě vyrobí `FAILED_IDENTITY` a retry smyčka spálí dvě
GPU iterace na snímky, které nikdy nešly opravit.

Oprava: okluzní mapa z P0 už tuhle informaci nese. **Hodnotit jen čisté
snímky** (obličej neokludovaný, volitelně blízko čelnímu pohledu), okludovaný
úsek reportovat zvlášť a nenechat ho rozhodovat o pass/fail.

### 4.2 Práh 0.62 jako per-frame minimum je nedosažitelný

V domě už existuje kalibrovaná stupnice: `tools/facebench/bench.py` v Ol1nLLM.
Naměřené hodnoty jsou v jeho `CLAUDE.md`: jednoprůchodový face inpaint **0.48**,
dvouprůchodový **0.72** (nic pod 0.67), strop té cesty **~0.75–0.8**. To jsou
**statické obrázky, v nejlepším případě**.

⚠️ **Plán míří na jiný model, než kterým dům měří.** Plán píše
`insightface buffalo_l`; facebench používá **`antelopev2`**
(`tools/facebench/bench.py:36-41`) a podobnost počítá jako skalární součin
znovu L2-normalizovaných `normed_embedding` (`:55-59`). Jiný rozpoznávací model
= jiná stupnice, takže s buffalo_l **nebudou čísla porovnatelná** s korpusem
0.48/0.72 výš. Doporučení: **antelopev2**, mimo jiné proto, že ho na boxu už
používá `InstantIDFaceAnalysis`. Facebench si sám dokumentuje význam hodnot
(`bench.py:13`): `1.0` táž tvář, `~0.6` stejná osoba, `< 0.4` cizí — plánovaných
0.62 tedy sedí přesně na hranu „stejná osoba", což je rozumný **medián**
a přísné **minimum**.

Požadovat 0.62 na **každém snímku videa** — s motion blur, profily a
kompresí — je tedy přísnější než co zvládl jednoprůchodový still. Doporučení:
gate na **p10 čistých snímků**, ne na minimum, a práh kalibrovat per `action`
(§5 plánu se na to ptá — odpověď je „per action", protože `kiss` má
strukturálně nižší skóre než `gaze`).

A hlavně: **použít stupnici facebenche**, ne vyrobit druhou. Jinak nepůjde
porovnat, jestli je couple karta lepší nebo horší než face inpaint v Ol1nLLM.

### 4.3 Na dvě reference existuje naměřený negativní výsledek

Strategie B staví na multi-ID stillu ze dvou referencí. V Ol1nLLM je zapsané
měření, kde **Kontext se dvěma referencemi dal 0.17 a tvář vůbec nevyměnil**.
Jiný model než InfiniteYou/Qwen-Image-Edit, ale je to varování, že dvoureferenční
podmínění je přesně místo, kde identita tiše umírá.

Proto: ve Strategii B **změřit facebenchem už ten still**, než se z něj vyrobí
video. Je to nejlevnější možný gate a zabije větev dřív, než spotřebuje GPU.

### 4.4 Co z měřicího aparátu jde použít a co ne

- **Jádro facebenche ano** — ~30 řádků (`embedding()` / `sim()`), a je to
  jediné místo v domě, kde je stupnice kalibrovaná.
- **Facebench jako CLI ne.** Bere v obrázku **největší detekovaný obličej**
  (`bench.py:53-54`) a ostatní ignoruje. U dvojice by měřil jednoho člověka,
  a nedeterministicky podle velikosti bboxu. Pro couple je potřeba párování
  detekcí na identity napříč snímky — to je nová práce, ne konfigurace.
- **Lab jako orchestrátor ano** (sweep os `__face_apply__.ip_weight`,
  `param.faceIdentity` už existuje), **jeho metriky ne** — počítá RGB
  histogramy, tedy barvu, a čte jen statické PNG.

### 4.5 Mina: FaceDetailer přemaluje *každý* obličej týmž embeddingem

Refine z Fáze 3 se nemůže opřít o dnešní nastavení Impact FaceDetaileru: ten
detekuje bboxy přes `face_yolov8m.pt` a na **každý nalezený obličej** pustí
tentýž embedding (`lib/services/comfyui_service.dart:1803-1840` v Ol1nLLM).
Ve snímku s dvěma lidmi by tedy oběma nasadil jednu a tutéž tvář — a přesně
v okamžiku polibku, kdy jsou obličeje u sebe, je pravděpodobnost, že detektor
najde oba, nejvyšší. P4 musí **směrovat embedding per osoba** (maska nebo
výřez na jednu detekci), jinak refine identitu nezachrání, ale zničí.

### 4.6 Co už je na téhle mašině změřené

Mezitím proběhlo měření restyle karty proti Sparku
([`docs/restyle-rollout-results.md`](../docs/restyle-rollout-results.md),
2026-09-09). Čtyři výsledky platí i pro couple kartu:

- **antelopev2 na Sparku je** — `models/insightface/models/antelopev2/` má
  všech pět `.onnx`. Doporučení z §4.2 tedy nic nestojí, žádné stahování.
- **Zvýšení síly identity zabije styl.** Změřeno: `ip_weight` 0.8 proti 0.6
  podobu zlepší, ale InstantID embedding je fotografický a při 0.8 přebije
  stylový blok **na postavě** — pozadí grafické, člověk fotka. To je přímo
  varování pro P4: retry smyčka, která na nízké skóre reaguje přitvrzením
  identity, si kupuje gate za cenu stylu, a nikdo to nezměří, protože gate
  měří jen identitu. **P4 musí mít strop síly, ne jen strop iterací.**
- **Booru modely s InstantID identitu ztrácejí** (Animagine XL 4.0: obecný
  anime obličej, změněné proporce). Viz §6.
- **Jediný časový bod ze stejného železa**: SDXL 1 MP s InstantID + depth CN +
  FaceDetailer = **66–117 s** na obrázek, studený běh 66,5 s. Pro video je to
  jen dolní mez řádu, ale znamená to, že načtení InstantID a antelopev2 není
  problém, a že `JOB_TIMEOUT` se u obrázkové cesty měnit nemusel.

---

## 5. Co plán neměří: fotometrická konzistence

Definice hotovo měří identitu. Klip ale může projít gate a přesto vypadat
slepený: dva sekvenční průchody s relight LoRA můžou nechat dvě osoby v jednom
snímku nasvícené jinak, a **kompozitní fallback** (vzít A z `out_A` přes masku
po P2) dělá šev přesně v místě kontaktu — tedy nejhorší u `kiss` a `hug`, což
jsou vlajkové akce karty.

Doporučení: přidat do akceptace jednu položku navíc — „obě osoby v jednom
snímku mají stejné světlo a v místě kontaktu není šev". Klidně jako lidský
verdikt nad testovací sadou, ale explicitně, jinak se to zjistí od uživatelů.

---

## 6. Vnitřní rozpor v definici v1

- §1 nabízí `style: photo | anime` **už v v1**.
- Fáze 5 říká, že ArcFace na anime obličejích nefunguje a gate tam potřebuje
  CLIP/DINO variantu — **až po v1**.
- Fáze 1 dává do testovací sady „2 páry ref fotek (foto + anime)".
- Definice hotovo žádá, aby gate prošel na ≥ 90 % testovací sady.

Takhle napsané v1 **nejde dokončit**: sada obsahuje anime, gate na anime
neexistuje. Rozhodnout jedno z dvou — buď `anime` z v1 ven, nebo CLIP/DINO
varianta gate patří do Fáze 3, ne do Fáze 5.

Měření restyle karty ale posouvá odpověď dál: na booru modelu (Animagine XL
4.0) se s InstantID **ztratila samotná identita**, ne jen měřitelnost. Když
anime cesta nedrží tvář, nemá smysl řešit, čím ji měřit. Doporučení: **`anime`
z v1 ven**, a otevřít ho až s vlastním mechanismem identity, ne s jiným
gate. (Restyle karta na tohle používá SDXL base, který kreslený výstup zvládne
a identitu udrží — pro couple kartu je to nejlevnější kandidát na „kreslený"
režim, ne booru model.)

---

## 7. Co plán neřeší na straně Tsumiki

Tohle v handoffu chybí celé a je to práce, která na kartě stejně bude:

- **Cena a ledger.** Každý job v Tsumiki se platí. Couple = preprocess + dva
  průchody + refine, tedy násobek jedné animace (dnes `v1` = 1 animace za 10 ⭐,
  free kvóta 1/den). Potřeba: vlastní balíček nebo násobič, rozhodnutí, jestli
  čerpá `video_credits` nebo nový ledger, a **free kvóta nejspíš 0**.
- **Refundy a jejich zneužití.** Pravidlo domu je „neúspěšný render nestojí nic"
  (`undo_usage`). Couple job ale spálí násobně víc GPU a `FAILED_IDENTITY` po
  dvou retry je legitimní výsledek. Karta, která umí spotřebovat tři rendery
  a pokaždé vrátit peníze, je DoS na jediný GPU worker. Potřeba **denní strop
  pokusů**, nezávislý na tom, že se kredit vrací.
- **Upload.** Dnes jde jedna fotka jako base64 v JSON (strop 24 M znaků).
  Couple potřebuje dvě fotky **a video** v jednom requestu; base64 videa v JSON
  je špatný tvar (paměť, CF tunel). Multipart nebo předpodepsaný upload.
- **Deadline a re-attach.** Deadline se počítá z `minutes_est` vráceného při
  submitu a ukládá se, aby ho restart bota neztratil. Wrapper musí vracet odhad
  **za všechny průchody dohromady**, jinak job spadne na podlahu 1800 s —
  přesně ta chyba, která už jednou u videa nastala a musela se opravovat.
- **Retence a souhlas.** Plán chce souhlas v metadatech jobu, ale Tsumiki na to
  nemá tabulku ani politiku. Horší: **nahrané reference se dnes na serveru
  nechávají ležet** — i moje restyle karta nahrává `tsumiki_restyle_<job>.png`
  do input složky ComfyUI a nikdy ho nemaže. U dvou tváří reálných lidí plus
  jejich videa je to rozhodnutí, které se musí udělat, ne zdědit.
- **Provoz.** ComfyUI na Sparku dnes **neběží pod systemd** (ruční
  `python main.py`, viz results doc). Couple job běží desítky minut a plán
  počítá s re-attachem po restartu bota — ten ale předpokládá, že se render
  server vrátí. Než tahle karta půjde do provozu, `comfyui.service` musí být
  enabled, jinak jeden reboot Sparku zabije job, za který se vrací kredit.
- **Dobrá zpráva:** UI je levné. Čtvrtá karta je dnes jedna položka v enumu
  `TsumikiScreen` (`lib/ui/widgets/tsumiki_app_bar.dart:15`), přepínač i shop
  chip si ji vezmou samy. Jen `bool get video` bude muset být volba ledgeru
  místo booleanu, pokud couple dostane vlastní.

---

## 8. Zbytek Fáze 0 — checklist pro Claude s přístupem na Spark/JODU

Pořadí je záměrné: první tři body můžou zrušit půlku plánu.

- [x] **Najít skutečnou jednopostavovou Animate kartu** (video-stack? jiný
      produkt?). → **Neexistuje nikde**, viz §11.1.
- [ ] **Rozhodnout, která služba veze pipeline** a jestli umí vystavit kontrakt
      video-api (§2.2). Tohle určuje rozsah práce v botu.
- [ ] **Pořídit Wan 2.2 Animate a ověřit Mix režim se dvěma lidmi** — celý
      postup, soubory a velikosti v [`docs/couple-spark-setup.md`](../docs/couple-spark-setup.md).
      Klíčová otázka: přežije osoba A druhý průchod, když ji nese
      `background_video`? → uzel i graf hotové a pre-flight čistý (§11.2, §11.4),
      **běh čeká na doběhnutí vah**.
- [x] Ověřit WanAnimatePreprocess (výběr osoby, masky per osoba) a relight
      LoRA. → nainstalováno, a **výběr osoby tam není** (§11.3).
- [x] Ověřit **segment-anything-2** a textové maskování jako alternativu
      k YOLO trackingu pro `mask_A`/`mask_B`. → §11.3.
- [x] InsightFace na ARM64: ONNX runtime v ComfyUI venv, jinak CPU. **Balík
      `antelopev2`, ne `buffalo_l`** (§4.2). Změřit čas na 200 snímků × 2 osoby —
      gate poběží na každém jobu. → **CPU, 69 s** (§11.5).
- [x] Vzít **jádro facebenche** (`embedding()`/`sim()`) a ověřit ho na snímcích
      vytažených z videa, aby stupnice zůstala společná (§4.2, §4.4). → §11.5.

Výstupem je doplnění tohohle souboru, ne nový dokument.

---

## 11. Co je naměřené na Sparku (2026-09-11)

ComfyUI `~/Code/ComfyUI`, HEAD 2026-08-31 (`v0.19.3-8-ga3bdd979`), torch
2.11.0+cu130, GB10 sm_121, 130,7 GB unified, 710 GB volných na disku.
Oproti §7 a proti `docs/restyle-rollout-results.md` je jedna věc **už opravená**:
ComfyUI **běží pod systemd** (`comfyui.service`, `run.sh` s `--reserve-vram 8
--disable-async-offload --disable-pinned-memory --cache-lru 2
--use-sage-attention`). Provozní riziko „reboot Sparku zabije job, za který se
vrací kredit" je tím zavřené.

### 11.1 Jednopostavová Animate karta neexistuje ani ve video-stacku

§2.1 nechalo otevřené, jestli karta z handoffu nežije ve video-stacku. Nežije.
`serve.py` (video-api :8096) bere `{image, scene, seed}`, kde `scene` je preset
beatů ze `scenes/*.json`, a renderuje `chain.py` → **Wan 2.2 I2V** (nebo LTX)
+ RIFE. Žádný vstup na driving video, žádný `WanAnimate` v celém repu.

Důsledek zůstává ten z §2.1, jen je teď jistý: **„pod 2× času jednopostavové
karty" nemá v domě základnu.** Základnou musí být měření S2
(`docs/couple-spark-setup.md` §4), ne existující karta.

### 11.2 Doporučený soubor z plánu se na téhle instalaci nenačte

Plán (setup doc §3) volí `wan2.2_animate_14B_int8_convrot.safetensors`
(18,41 GB) s odůvodněním, že bf16 na GB10 zamrzá. Hlavička toho souboru ale
nese klíče `weight_scale` a tenzory I8/U8, zatímco `comfy/quant_ops.py`
v téhle verzi zná jen `TensorCoreFP8 / MXFP8 / NVFP4` a scaled fp8 pozná podle
`scale_weight`. Slovo „convrot" není ve zdrojích ComfyUI nikde. **Int8 convrot
je novější formát, než jaký tahle instalace umí přečíst.**

Náhrada, která nevyžaduje aktualizaci produkčního boxu:
`Kijai/WanVideo_comfy_fp8_scaled` →
`Wan22Animate/Wan2_2-Animate-14B_fp8_scaled_e4m3fn_KJ_v2.safetensors`,
**17,32 GB**, klíče `scale_weight` + F8_E4M3 — tedy přesně tvar, který na boxu
už funguje (ověřeno proti hlavičce běžícího
`wan2.2_i2v_high_noise_14B_fp8_scaled.safetensors`). Je navíc o gigabajt menší
než int8 a jde do **nativního** uzlu, takže masky zůstávají k dispozici.

Co z §3 setup docu na boxu **už bylo** a stahovat se nemuselo:
`umt5_xxl_fp8_e4m3fn_scaled` a `wan_2.1_vae`. Reálné stahování je tedy
17,3 GB + relight LoRA 1,44 GB + lightx2v distill 0,03 GB + ViTPose-L 1,23 GB
+ YOLOv10m + SAM2 — ne 27,9 GB z plánu.

**`WanAnimate2ToVideo` na boxu není** (`/object_info` zná 1778 tříd, Animate 2
mezi nimi ne). Levný experiment ze setup docu §6 tedy není levný: chce
aktualizaci ComfyUI na stroji, na kterém běží UGC továrna, Tsumiki i video-api,
a na kterém jsou vlastní patche (`fix: patche pro SPARK — unpin_weight nepadá`).
Doporučení: **odložit S4 za S3** a udělat ho až na základě čísel, ne místo nich.

### 11.3 WanAnimatePreprocess je jednopostavový — a mlčky

Nejdůležitější nález téhle vlny. `PoseAndFaceDetection` volá detektor a bere
`[0][0]["bbox"]`, a `Yolo.process_results()` má `single_person=True` a vrací
**největší** bbox ve snímku (`select_type='max'`). Uzel tedy pro dvojici
nevyrobí dvě pózy — vyrobí jednu, a ta se mezi lidmi **přepíná podle toho, kdo
je zrovna větší**. Je to táž chyba jako `bench.py` beroucí největší obličej
(§4.4), jen ve videu a tím hůř viditelná.

Plán s tím počítal opačně („přes WanAnimatePreprocess vyrobit `mask_A` a
`mask_B` a odpovídající pózy", setup doc §5). **Takhle to nejde.**

Architektura, která to obchází bez patchování uzlu (a je implementovaná
v `tgbot/tools/couple/graph.py`):

1. SAM2 video segmentor, jeden kladný bod na osobu na prvním snímku →
   `mask_A`, `mask_B` propagované přes klip.
2. `driving_A` = driving s **osobou B přemalovanou na černo**
   (`ImageCompositeMasked` + `mask_B`), a naopak.
3. `PoseAndFaceDetection` běží nad `driving_A` a `driving_B` zvlášť — největší
   osoba je pak triviálně ta správná.

Černá, ne rozostření: YOLO rozostřené tělo pořád najde. Bod na osobu je
zadaný ručně (`--point-a`, `--point-b`) — pro bench je to poctivé, pro kartu
to bude potřebovat buď dvě kliknutí v UI, nebo automatický výběr.

**segment-anything-2 je k dispozici dvakrát** a je dobré vědět, který je který:
`Sam2Segmentation` + `DownloadAndLoadSAM2Model` z `ComfyUI-segment-anything-2`
(Kijai, doinstalováno; bere body/bboxy, má `segmentor: video` s propagací přes
klip — tohle používá graf výš) a `SAM2Segment` z `ComfyUI-RMBG`, což je
**textové** maskování přes GroundingDINO. Textová varianta z §3 („two people"
→ dvě masky) tedy existuje, ale jako druhá cesta: propagace přes video je
u kontaktních akcí důležitější než pohodlí promptu.

### 11.4 Nastavení se přebírá z video-stacku, ne vymýšlí

Setup doc §2 se ptal, čím video-stack dosahuje 150 s/beat.
`workflows/i2v_final_14b_lightning_portrait.json`: fp8_scaled 14B high+low,
**Seko 4-step distill LoRA** (strength 1.0), `ModelSamplingSD3` shift 5.0,
`KSamplerAdvanced` **steps 4, cfg 1.0**, euler/simple, 480×832, length 81.

Kijaiův referenční Animate workflow má **stejný tvar**: 4 kroky, cfg 1.0,
`lcm`/`simple`, `lightx2v_I2V_14B_480p_cfg_step_distill_rank64` na 1.2
a relight LoRA na 1.0, 832×480, length 77. Bench proto startuje odtud, ne
z defaultů uzlu — je to jediné nastavení, o kterém se na tomhle železe ví, že
je rychlé.

Graf pro obě cesty je `tgbot/tools/couple/graph.py`, spouštěč a měření
`tgbot/tools/couple/run.py`. Preprocess i oba průchody jsou v **jednom** grafu:
maska vypsaná do h264 a načtená zpátky by přišla s kompresním šumem přesně na
hraně, na které záleží, a póza s obličeji stojí reálný čas (CPU, §11.5), takže
počítat ji dvakrát by se prodražilo. Časy per průchod se proto berou z
websocketu (`run.py` razítkuje každý uzel), ne z `/history` — ten nese jen
`execution_start` a `execution_success`.

Pre-flight proti běžícímu serveru je čistý: **52 uzlů** pro couple, 25 pro solo,
všechny třídy nainstalované, žádný neznámý ani nezapojený povinný vstup
(`run.py check couple`).

### 11.5 Identity gate: hotový, změřený, a jede na CPU

`onnxruntime` v ComfyUI venv hlásí `['AzureExecutionProvider',
'CPUExecutionProvider']` — **žádné CUDA EP**. Na CPU tedy jede InsightFace
i celý preprocess (ViTPose, YOLO). Proto se místo ViTPose-H (2,43 GB) stahuje
**ViTPose-L** (1,23 GB), což je i to, co má Kijaiův referenční workflow
v loaderu. `onnxruntime-gpu` pro tuhle platformu na PyPI existuje (1.30.0), ale
instalovat ho znamená přepsat balík, na kterém stojí běžící InstantID —
sahat na to má smysl až kdyby CPU byl doložitelně úzké hrdlo, ne preventivně.

Gate je `tools/facebench/vidbench.py` v repu **Ol1nLLM** (větev
`claude/couple-identity-gate`). Doplňuje k `bench.py` jen ty dvě věci, které
tam chyběly — čtení po snímcích a párování detekcí na osoby — a `embedding()`
se `sim()` importuje, takže stupnice zůstává společná s 0.48 / 0.72 z face
inpaintu. Párování je **prostorové** (stopy přes IoU), ne podle podobnosti;
přiřazovat každý snímek k podobnější referenci by vybíralo maximum z dvojice
a skóre by se nafouklo. Gate je p10 čistých snímků (§4.1, §4.2), okludované
snímky nerozhodují.

Ověřeno na syntetickém klipu (dvě různé tváře z `facebench/bench`, křížení
uprostřed, změna velikosti, mp4 komprese): stopy přežily přiblížení
**200/200 snímků**, přiřazení nezávisí na pořadí `--refs`, margin 0.78,
cross-podobnost 0.17–0.20, vlastní podobnost 0.93–0.96 (ne 1.0 — sráží ji
komprese a přeškálování, což je zdravá kontrola stupnice).

**Čas gate: 69 s na 200 snímků × 2 osoby** (0,35 s/snímek, CPU). Pro pětisekundový
klip při 16 fps (81 snímků) to vychází na ~28 s. Proti renderu je to malé, ale
není to zadarmo a do odhadu `minutes_est` (§7) to patří.

---

## 9. Odpovědi na otevřené otázky z §5 plánu

- **Jedno „couple" foto místo dvou?** Odložit, jak plán navrhuje. Oddělení dvou
  identit z jedné fotky je další místo, kde identita tiše umírá (§4.3).
- **Kolik Strategie B v v1?** Jen jako **levný gate na still** (§4.3), ne jako
  produkční režim. `gaze`/`smile` bez okluze zvládne i hlavní cesta.
- **Jeden práh, nebo per action?** **Per action**, a navíc na p10 čistých
  snímků místo minima (§4.1, §4.2). Jeden globální práh nutně buď propustí
  špatné `gaze`, nebo shodí každý `kiss`.

## 10. Zdroje k §3 (ověřit na boxu, ne převzít)

- https://huggingface.co/Wan-AI/Wan2.2-Animate-2-14B
- https://blog.comfy.org/p/wan-animate-2-is-now-available-in
- https://www.runcomfy.com/comfyui-workflows/wan-animate-2-comfyui-identity-preserving-motion-transfer
- https://docs.comfy.org/tutorials/video/wan/wan2-2-animate
- https://wan27.org/blog/wan-2-6-open-source-guide

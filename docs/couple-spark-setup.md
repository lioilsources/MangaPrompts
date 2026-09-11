# Couple karta — co dotáhnout na SPARKu (Wan Animate + Wan 2.6)

Zadání pro Claude běžícího **na SPARKu u ComfyUI**. Cíl: pořídit a ověřit
komponenty, které na boxu ještě nejsou, aby se dala postavit karta „video páru
se zachovanou identitou obou lidí". Navazuje na
[`reports/couple_phase0.md`](../reports/couple_phase0.md) — tam je revize
původního handoff plánu; tady je jen ta část, která se dělá na železe.

Předpoklady z posledního měření
([`restyle-rollout-results.md`](restyle-rollout-results.md)): ComfyUI
v `/home/ol1n/Code/ComfyUI`, běží ručně (`python main.py --listen
--reserve-vram 8`), LAN `http://192.168.88.66:8188`. Na boxu už jsou KJNodes,
controlnet_aux, Impact Pack, InstantID a **antelopev2**.

---

## 1. Které Animate to má být — rozhoduje maska, ne stáří

Na výběr jsou dvě rodiny a **novější není ta správná**:

| | **Wan 2.2 Animate** | **Wan Animate 2** |
|---|---|---|
| ComfyUI uzel | `WanAnimateToVideo` | `WanAnimate2ToVideo` |
| Vstupy navíc | `character_mask`, `background_video`, `face_video`, `continue_motion_max_frames` | `continue_motion`, `pose_strength`, `reference_image_strength` |
| Režimy | **Mix** (nahradí postavu ve videu) + Move | jen animace reference podle pohybu |
| Skeleton preprocessing | ano (WanAnimatePreprocess) | **ne**, žere driving video přímo |
| Použitelné pro couple | **ano** | ne, viz níž |

**Animate 2 nemá `character_mask` ani `background_video`.** Bez nich neumí
„nahraď jednu osobu ve scéně a zbytek nech být", což je přesně to, co couple
karta potřebuje. Je to lepší volba pro **jednopostavovou** kartu, ne pro tuhle.

Naopak Mix režim ve Wan 2.2 Animate dává dvouprůchodovou architekturu skoro
zadarmo a **lépe, než navrhoval původní plán**:

```
P1: reference=ref_a, character_mask=mask_A, background_video=driving      → out_A
P2: reference=ref_b, character_mask=mask_B, background_video=out_A        → out_AB
```

Osoba A přežije druhý průchod proto, že ji nese `background_video`, ne proto,
že ji po renderu ručně kompozitujeme přes masku. Kompozici dělá model uvnitř,
takže padá i obava z odlišného nasvícení obou lidí a ze švu v místě kontaktu.

**Stáhnout se ale vyplatí obojí** — Animate 2 kvůli jednomu levnému
experimentu v §6, který může celou dvouprůchodovou cestu zrušit.

---

## 2. S0 — inventura, než se cokoli stáhne

```bash
CU=/home/ol1n/Code/ComfyUI
df -h $CU/models                     # potřeba ~50 GB volných, viz §8
cat $CU/extra_model_paths.yaml 2>/dev/null   # modely můžou žít jinde
cd $CU && git log --oneline -1 && git describe --tags 2>/dev/null
python -c "import torch; print(torch.__version__, torch.cuda.get_device_capability())"
curl -s http://127.0.0.1:8188/object_info | python3 -c \
  "import json,sys; d=json.load(sys.stdin); print([k for k in d if 'Animate' in k])"
```

Poslední příkaz je rozcestník: prázdný seznam znamená, že ComfyUI je starší než
srpen 2026 a **nejdřív se aktualizuje**, protože `WanAnimateToVideo` i
`WanAnimate2ToVideo` jsou nativní uzly, ne custom node.

Nejcennější položka inventury je jinde: **jak má video-stack nastavený Wan 2.2
I2V**. Na tomhle boxu dělá ~150 s na pětisekundový beat, zatímco komunita hlásí
u Wan 2.2 na GB10 15–30 min na 5 s a zamrzání ve fp16. Ten rozdíl je
konfigurace, ne hardware.

```bash
grep -rn "safetensors\|steps\|lightx2v\|attention\|fp8\|int8" \
    ~/Code/video-stack/*.py | head -40
```

Vypsat: kvantizaci, počet kroků, distill LoRA, attention backend, rozlišení.
**Animate se má rozjíždět se stejnou volbou**, ne od nuly.

---

## 3. S1 — Wan 2.2 Animate (hlavní cesta)

Soubory a přesné velikosti (ověřeno přes HF API 2026-09-11):

| Soubor | Kam | Velikost |
|---|---|---|
| `Comfy-Org/Wan_2.2_ComfyUI_Repackaged` → `split_files/diffusion_models/wan2.2_animate_14B_int8_convrot.safetensors` | `models/diffusion_models/` | 18,41 GB |
| tentýž repo → `split_files/loras/wan2.2_animate_14B_relight_lora_bf16.safetensors` | `models/loras/` | 1,44 GB |
| tentýž repo → `split_files/text_encoders/umt5_xxl_fp8_e4m3fn_scaled.safetensors` | `models/text_encoders/` | 6,74 GB |
| tentýž repo → `split_files/vae/wan_2.1_vae.safetensors` | `models/vae/` | 0,25 GB |
| `Comfy-Org/Wan-Animate-2` → `clip_vision/clip_vision_h.safetensors` | `models/clip_vision/` | 1,26 GB |

`int8_convrot` místo `bf16` (34,55 GB) je záměr: komunita na GB10 hlásí, že
plná přesnost zamrzá v sampleru, a menší soubor se na unified memory chová líp.
Kdyby int8 dělal problém, alternativa pro **WanVideoWrapper** cestu je
`Kijai/WanVideo_comfy_fp8_scaled` →
`Wan22Animate/Wan2_2-Animate-14B_fp8_scaled_e4m3fn_KJ_v2.safetensors` (17,32 GB).
Nativní uzel má ale masku i background video, takže wrapper ber až jako záložní.

```bash
CU=/home/ol1n/Code/ComfyUI; TMP=/tmp/wandl; mkdir -p $TMP
# starší instalace mají místo `hf` příkaz `huggingface-cli`
hf download Comfy-Org/Wan_2.2_ComfyUI_Repackaged \
  split_files/diffusion_models/wan2.2_animate_14B_int8_convrot.safetensors \
  split_files/loras/wan2.2_animate_14B_relight_lora_bf16.safetensors \
  split_files/text_encoders/umt5_xxl_fp8_e4m3fn_scaled.safetensors \
  split_files/vae/wan_2.1_vae.safetensors --local-dir $TMP
hf download Comfy-Org/Wan-Animate-2 clip_vision/clip_vision_h.safetensors --local-dir $TMP

mv $TMP/split_files/diffusion_models/*.safetensors $CU/models/diffusion_models/
mv $TMP/split_files/loras/*.safetensors           $CU/models/loras/
mv $TMP/split_files/text_encoders/*.safetensors   $CU/models/text_encoders/
mv $TMP/split_files/vae/*.safetensors             $CU/models/vae/
mv $TMP/clip_vision/*.safetensors                 $CU/models/clip_vision/
```

Preprocessing pro masky a pózy — custom node, který na boxu není:

```bash
cd $CU/custom_nodes && git clone https://github.com/kijai/ComfyUI-WanAnimatePreprocess
# jeho modely: yolov10m.onnx (detekce) + ViTPose (L nebo H); viz README repa,
# stahují se do models/detection resp. models/vitpose
```

Restart ComfyUI a kontrola, že uzly i váhy sedí:

```bash
curl -s http://127.0.0.1:8188/object_info | python3 -c \
  "import json,sys; d=json.load(sys.stdin)
print('WanAnimateToVideo' in d, 'WanAnimate2ToVideo' in d)
print([k for k in d if 'WanAnimate' in k or 'ViTPose' in k])"
```

Až bude workflow v API formátu uložené, projede ho pre-flight z Tsumiki repa —
porovná třídy uzlů, názvy vstupů i názvy souborů modelů proti `/object_info`:

```bash
python3 tgbot/tools/check_workflow.py <workflow>.api.json --url http://127.0.0.1:8188
```

---

## 4. S2 — první běh, Move režim, jedna postava

Cíl je jediný: **kolik to na téhle mašině trvá**. Šablona „Wan2.2 Animate"
je v Template Library ComfyUI, vstupy jsou referenční obrázek a driving video.

Změřit a zapsat: 3 s při 480p a při 720p, studený a teplý běh, špičku paměti.
Rozměry musí být násobky 16.

Rozhodovací bod: pokud 5 s na 720p trvá přes ~10 min, couple karta se dvěma
průchody a refinem je **přes hodinu na klip** a je potřeba to říct nahlas dřív,
než se postaví zbytek. V takovém případě jsou možnosti: 480p pro v1, kratší
klipy, distill LoRA s méně kroky, nebo rovnou cesta přes API z §7.

---

## 5. S3 — Mix režim se dvěma lidmi (klíčový test)

Tohle rozhoduje, jestli karta vůbec může existovat lokálně.

1. Driving video páru, 3–5 s, oba obličeje aspoň částečně vidět.
2. Přes WanAnimatePreprocess vyrobit `mask_A` a `mask_B` a odpovídající pózy.
3. **P1**: `reference_image=ref_a`, `character_mask=mask_A`,
   `background_video=` původní driving.
4. **P2**: `reference_image=ref_b`, `character_mask=mask_B`,
   `background_video=` výstup P1.

Co sledovat, a v tomhle pořadí:

- **Přežije A druhý průchod?** Tohle je hlavní otázka. Když `background_video`
  drží A beze změny, dvouprůchod funguje. Když ho P2 přemaluje, je potřeba
  ochranná maska nebo jiná architektura.
- **Co dělají masky během kontaktu**, kde se překrývají. Polibek a objetí jsou
  vlajkové akce karty a zároveň nejhorší případ.
- Nasvícení obou lidí v jednom snímku a šev v místě dotyku.
- Časy obou průchodů zvlášť.

---

## 6. S4 — levný experiment, který může zrušit dvouprůchod

Animate 2 sice neumí masky, ale `reference_image` je obyčejný obrázek. Nabízí
se tedy jednoprůchodová cesta: **reference = jeden společný snímek obou lidí**,
`pose_video` = driving video páru. Obě identity by pak nesla jedna reference
a maskování by odpadlo úplně.

Model je dokumentovaný jako „one reference character", takže je dost možné, že
na dvojici zkolabuje na jednoho člověka. Test je ale levný a výhra velká, tak
ať proběhne dřív, než se doladí S3.

```bash
CU=/home/ol1n/Code/ComfyUI; TMP=/tmp/wandl2; mkdir -p $TMP
hf download Comfy-Org/Wan-Animate-2 \
  diffusion_models/wan_animate_2_distill_int8_convrot.safetensors \
  vae/Wan2_1_VAE_bf16.safetensors --local-dir $TMP
mv $TMP/diffusion_models/*.safetensors $CU/models/diffusion_models/
mv $TMP/vae/*.safetensors              $CU/models/vae/
```

16,65 GB + 0,25 GB; `umt5` i `clip_vision_h` už budou z §3. Distill varianta
má destilaci zapečenou, takže **lightx2v LoRA k ní nestahuj**, dokud se
neukáže, že je potřeba.

Jako referenci použij nejdřív reálnou fotku dvojice. Teprve když to projde,
má smysl řešit skládání společného snímku ze dvou portrétů.

---

## 7. S5 — Wan 2.6 R2V přes API

Váhy nikdy nevyšly, je to **jen API**. Zároveň je to jediná cesta, která
víc postav se zachovanou identitou umí konstrukcí, ne aproximací — proto stojí
za změření, i když se nakonec nepoužije.

- Účet: **Alibaba Cloud Model Studio** (mezinárodní, ne čínský), z něj API klíč.
- Model id `wan2.6-r2v`, asynchronní API, 2–10 s, 720p/1080p, 30 fps, H.264.
- Cena (Alibaba global): **$0,086012/s při 720p**, $0,143353/s při 1080p.
  Přeprodejci kolem $0,10 / $0,15.
- Dokumentace sama píše, že konzistence referencí **není absolutní** a detaily
  ujíždějí „při rychlém pohybu, okluzi a interakci více postav". Tedy přesně
  v tom, co tahle karta dělá. **Nečekat jistotu, změřit stejným gate jako
  lokální cestu.**

Test: tytéž `ref_a`, `ref_b` a stejná akce jako v S3, pětisekundový klip,
720p. Zapsat cenu, čas a skóre identity.

**Cenový kontext, který rozhodne o produktu:** pětisekundový klip na 720p stojí
zhruba **$0,43**. Jedna animace se dnes v Tsumiki prodává za 10 ⭐, což je
podle `docs/telegram-payments.md` kolem **$0,13** hrubého. API cesta tedy musí
mít jinou cenovku, ne jen jiný backend.

---

## 8. Rozpočet místa a co měřit

Stažení celkem: §3 je **27,9 GB**, §6 přidá **16,9 GB**, plus modely
preprocesoru. S rezervou na výstupy počítej **~50 GB**.

Identitu měř **stejnou stupnicí jako zbytek domu**, jinak se výsledky nedají
porovnat s naměřenými 0,48 / 0,72 z face inpaintu: jádro
`tools/facebench/bench.py` z repa Ol1nLLM, tedy `antelopev2` a kosinus
znovu normalizovaných embeddingů. Antelopev2 je na boxu už nainstalovaný.

Dvě věci se musí dopsat, facebench je sám neumí: **čtení po snímcích** a
**párování detekcí na osoby** — bere jen největší obličej ve snímku, takže by
u dvojice měřil jednoho člověka a nedeterministicky. Hodnotit jen snímky, kde
obličej není okludovaný, jinak každý polibek spadne z důvodů, které nejsou
selhání identity.

---

## 9. Co reportovat

Doplnit do `reports/couple_phase0.md`, ne zakládat nový dokument:

1. Verze ComfyUI a jestli `/object_info` zná oba Animate uzly.
2. Nastavení, kterým video-stack dosahuje 150 s/beat, a jestli šlo převzít.
3. Časy z S2 a S3 po průchodech, špička paměti, rozlišení.
4. **Přežil A druhý průchod?** Ideálně dva snímky, před a po P2.
5. Výsledek experimentu z S4 jednou větou: nese jedna reference dvě identity?
6. Z S5 cena, čas a skóre; a jestli API drží identitu v okluzi líp než lokál.
7. Skóre identity per osoba, na čistých snímcích, stupnicí facebenche.

## 10. Zdroje k číslům výš

- https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged
- https://huggingface.co/Comfy-Org/Wan-Animate-2
- https://huggingface.co/Kijai/WanVideo_comfy_fp8_scaled
- https://github.com/kijai/ComfyUI-WanAnimatePreprocess
- https://docs.comfy.org/tutorials/video/wan/wan2-2-animate
- https://blog.comfy.org/p/wan-animate-2-is-now-available-in
- https://gate.ai/blog/wan-2-6-r2v-alibaba-specs-pricing-api-use-cases
- https://forums.developer.nvidia.com/t/image-to-video-generation-using-the-spark-vs-pc/370077
- https://github.com/ecarmen16/SparkyUI/

"""Bench task `pipeline` (Prompts/07-PLAN-restyler.md §6b): the whole chain
beard → glasses → hair → styles on one photo, and what each step leaves behind.

The chain goes through `POST /api/render` of a running instance, so the bench
measures the contract the phone uses too. Masks are the Python originals of what
the phone computes, always on the ORIGINAL photo; the axis `param.order` shows
what that costs.

What the contract cannot say, and what happens to it:

* **Seeds.** `/api/render` has no seed: `prepare_workflow` draws its own. In an
  API cell `seed` only tells replicates apart, a re-render is not reproducible.
* **`<node>.<input>` and `graph.pulid_from`.** The server takes no graph. Such a
  cell gets its edits through `/api/render` and then renders the restyle directly
  on ComfyUI (`row["path"] == "direct"`), through the same `prepare_workflow`.
  There the seed is real.
* **`--engines kontext`** needs `flux_restyle_kontext.api.json`, which is not in
  assets/ yet and is not in the server's whitelist: refused at plan time until
  the file exists, then always direct.

`param.*` (order, lookPosition) is decided on the phone, so it goes through the
API. A `/api/render` job holds 12 steps: the first of a chain carries the edits
and as many styles as fit, later ones send the last edit's output as `source`.

    run.py pipeline --api http://127.0.0.1:8095 --url http://spark:8188 \\
        --looks candidates/looks.json --look-ids goatee-quiff,full-sidepart \\
        --order beard,glasses,hair hair,glasses,beard \\
        --styles ukiyoe,vangogh-arles,anime --engines flux,sdxl \\
        --srcs srcs/m-short.png --seeds 1 --out out/pipeline-r0

Token: `RESTYLER_APP_TOKEN` (`Authorization: app …`), or `RESTYLER_DEV_TOKEN`
(`dev …`); optional `CF_ACCESS_CLIENT_ID/SECRET`.
"""

from __future__ import annotations

import base64
import hashlib
import itertools
import json
import os
import time
from collections import defaultdict
from pathlib import Path

import numpy as np
from PIL import Image

import beardbench as bb
import beardmask as bm
import beardprompt
import catalog
import haircolours
import hairmask as hm
from comfy import prepare_workflow
from comfysync import CellError, Comfy, apply_node_sweep, set_seed
from imagesize import latent_for

METRICS_VERSION = 1
DEFAULT_ORDER = "beard,glasses,hair"
STEPS = ("beard", "glasses", "hair")
USER = "bench-pipeline"
MAX_STEPS = 12  # config.RENDER_MAX_STEPS; the server refuses more
ENGINE_GRAPHS = {"flux": "restyle_flux", "sdxl": "restyle_sdxl"}
DIRECT_ENGINES = {"kontext": "flux_restyle_kontext.api.json"}
TEMPLATES = {"flux": "flux_restyle.api.json", "sdxl": "sdxl_restyle.api.json", **DIRECT_ENGINES}
PULID_NODES = ("ApplyPulidFlux", "ApplyInstantIDAdvanced")

THRESHOLDS = {
    "identity_min": 0.50,  # three Kontext hops and a restyle; calibrate on the look `none`
    "rate": 2 / 3,
    "style_reaction_min": 0.10,
}
CLOTHED_TEXTS = ["a photo or painting of a fully clothed person",
                 "a photo or painting of a naked person with bare skin"]


class QuotaExhausted(Exception):
    """402: nothing else can be rendered today. Stops the run, not the cell."""


# ── looks ───────────────────────────────────────────────────────────────────


def load_looks(path: str | Path) -> dict[str, dict]:
    return {look["id"]: look for look in json.loads(Path(path).read_text())}


def glasses_tools():
    """The glasses session's code: present after the merge, absent in this tree
    until then. Lazy, so looks without glasses run either way."""
    try:
        import glassesmask
        import glassesprompt
    except ImportError as e:
        raise SystemExit("look with glasses: glassesmask/glassesprompt are not in this tree "
                         "(they come with the glasses branch); pick a look without glasses") from e
    if not hasattr(catalog, "glasses"):
        raise SystemExit("look with glasses: catalog.glasses() is not in this tree")
    return glassesmask, glassesprompt


def look_steps(look: dict, order: str) -> list[str]:
    return [s for s in order.split(",") if s in look]


def look_parts(look: dict, order: str, colour: str | None) -> list[str]:
    """`RestyleLook.of` of the app (restyle_prompt.dart): fixed beard, glasses,
    hair, whatever order the edits ran in. `colour` is the hair colour word."""
    parts = []
    if "beard" in look:
        b = catalog.beards()[look["beard"]["style"]]
        parts.append("clean-shaven" if b["id"] == beardprompt.CLEAN else f"with a {b['block']}")
    if "glasses" in look:
        _, gp = glasses_tools()
        g = catalog.glasses()[look["glasses"]["style"]]
        if g["id"] != gp.NO_GLASSES:
            finish = look["glasses"].get("finish")
            parts.append(f"wearing {finish + ' ' if finish else ''}{g['block']}")
    if "hair" in look:
        target = look["hair"]
        word = haircolours.COLOURS[target["colour"]]["phrase"] if target.get("colour") else colour
        h = catalog.hair_style(target["style"])
        if h["id"] == haircolours.KEEP_CUT:
            if word:
                parts.append(f"with {word} hair")
        else:
            parts.append(f"with a {h['block']}" + (f", {word} hair" if word else ""))
    return parts


# ── plan ────────────────────────────────────────────────────────────────────


def direct_keys(sweep: dict) -> list[str]:
    """Sweep keys the API cannot carry."""
    return [k for k in sweep if not k.startswith("param.")]


def is_direct(ident: dict) -> bool:
    return ident["engine"] in DIRECT_ENGINES or bool(direct_keys(ident["sweep"]))


def plan(args, sweeps: list[dict], seeds: list[int], srcs: list[str], engines: list[str]) -> list[dict]:
    looks = load_looks(args.looks)
    picked = [s.strip() for s in args.look_ids.split(",")] if args.look_ids else list(looks)
    for lid in picked:
        if lid not in looks:
            raise SystemExit(f"unknown look '{lid}'")
        look = looks[lid]
        for b in [look["beard"]["style"]] if "beard" in look else []:
            if b not in catalog.beards():
                raise SystemExit(f"look {lid}: unknown beard '{b}'")
        if "glasses" in look:
            glasses_tools()
        if "hair" in look and look["hair"]["style"] not in catalog.hairstyles():
            raise SystemExit(f"look {lid}: unknown hairstyle '{look['hair']['style']}'")
    for e in engines:
        if e in DIRECT_ENGINES:
            if not (catalog.ASSETS / DIRECT_ENGINES[e]).exists():
                raise SystemExit(f"engine {e}: assets/comfyui/{DIRECT_ENGINES[e]} does not exist yet")
        elif e not in ENGINE_GRAPHS:
            raise SystemExit(f"unknown pipeline engine '{e}'")
    for sweep in sweeps:
        bad = [k for k in sweep if k.startswith("param.") and k != "param.lookPosition"]
        if bad:
            raise SystemExit(f"unknown axis {bad} (order goes through --order)")
    styles = [s.strip() for s in (args.styles or "").split(",") if s.strip()]
    if not styles:
        raise SystemExit("pipeline needs --styles")
    for s in styles:
        catalog.restyle_style(s)  # fail on a typo before any GPU time
    orders = args.order or [DEFAULT_ORDER]
    media = [m.strip() for m in args.media.split(",") if m.strip()]
    cells = []
    for lid, src, seed, sweep in itertools.product(picked, srcs, seeds, sweeps):
        look = looks[lid]
        # One edit has no order: only the first would render anything new.
        for order in (orders if len(look_steps(look, DEFAULT_ORDER)) > 1 else orders[:1]):
            for engine, medium, style in itertools.product(engines, media, [catalog.BASELINE, *styles]):
                cells.append({
                    "task": "pipeline", "engine": engine, "medium": medium, "src": Path(src).name,
                    "look": lid, "style": f"{lid}/{style}", "restyle": style, "seed": seed,
                    "sweep": {**sweep, "param.order": order},
                    "ckpt": (args.ckpt or None) if engine == "sdxl" else None,
                })
    return cells


def chain_key(ident: dict) -> str:
    """Cells of one chain share their edits. The seed is in the key: a replicate
    has its own edits, or two seeds would measure one Kontext output twice."""
    ident = {k: ident[k] for k in ("src", "look", "seed")} | {"order": ident["sweep"]["param.order"]}
    return hashlib.sha1(json.dumps(ident, sort_keys=True).encode()).hexdigest()[:10]


def jobs_for(chain: list[dict], n_edits: int) -> list[list[dict]]:
    """API cells of a chain split into `/api/render` jobs of ≤ 12 steps; the
    first job also carries the edits."""
    api = [c for c in chain if not is_direct(c)]
    first = MAX_STEPS - n_edits
    jobs = [api[:first]] if first > 0 else [[]]
    rest = api[first:]
    jobs += [rest[i: i + MAX_STEPS] for i in range(0, len(rest), MAX_STEPS)]
    return jobs


def describe(cells: list[dict], looks: dict[str, dict]) -> dict:
    """What a plan costs, without touching anything: `--plan` prints this."""
    chains: dict[str, list[dict]] = defaultdict(list)
    for c in cells:
        chains[chain_key(c)].append(c)
    steps = render_jobs = 0
    for chain in chains.values():
        n_edits = len(look_steps(looks[chain[0]["look"]], chain[0]["sweep"]["param.order"]))
        api = sum(not is_direct(c) for c in chain)
        jobs = jobs_for(chain, n_edits)
        steps += n_edits + api
        render_jobs += len(jobs) if api or n_edits else 0
    direct = sum(map(is_direct, cells))
    return {"cells": len(cells), "chains": len(chains), "render_jobs": render_jobs,
            "api_generations": steps, "direct_cells": direct}


# ── edit steps (what the phone computes) ────────────────────────────────────


def b64(data: bytes) -> str:
    return base64.b64encode(data).decode()


def edit_steps(look: dict, order: str, analysis: hm.HairAnalysis, rgb: np.ndarray) -> tuple[list[dict], dict]:
    """(`/api/render` steps, what each one aimed at). Masks are built on the
    original photo; a photo the app would refuse raises HairMaskError."""
    colour = hm.estimate_colour(rgb, analysis.hair)
    steps, targets, previous = [], {}, "source"
    for name in look_steps(look, order):
        spec = look[name]
        if name == "beard":
            style = catalog.beards()[spec["style"]]
            beard = bm.detect_beard(rgb, analysis)
            res = bm.build_mask(analysis, bb.region_of(style, {}), bb.mode_of(style), beard)
            prompt = catalog.beard_prompt(style, colour)
            targets[name] = {"style": style["id"], "section": style["section"], "kind": style["region"]["kind"]}
        elif name == "glasses":
            gm, gp = glasses_tools()
            style = catalog.glasses()[spec["style"]]
            res = gm.build_mask(analysis, gm.GlassesFit(**style["fit"]), remove=style["id"] == gp.NO_GLASSES)
            prompt = catalog.glasses_prompt(style, spec.get("finish"))
            targets[name] = {"style": style["id"], "removed": style["id"] == gp.NO_GLASSES}
        else:
            style = catalog.hair_style(spec["style"])
            res = hm.build_mask(analysis, hm.HairShape(**style["shape"]),
                                "hair" if style["id"] == haircolours.KEEP_CUT else None)
            prompt = catalog.hair_prompt(style, colour, "kontext", spec.get("colour"))
            targets[name] = {"style": style["id"], "shape": style["shape"]}
        targets[name]["face_box"] = list(res.face_box)
        steps.append({"id": name, "graph": "kontext_edit", "input": previous, "prompt": prompt,
                      "mask": b64(hm.to_png(res.mask))})
        previous = name
    return steps, targets


def style_step(ident: dict, step_id: str, parent: str, prompt: str, negative: str) -> dict:
    step = {"id": step_id, "graph": ENGINE_GRAPHS[ident["engine"]], "input": parent,
            "prompt": prompt, "negative": negative}
    if ident["engine"] == "sdxl":
        step["medium"] = ident["medium"]
    return step


def style_prompt(ident: dict, look: dict, colour: str | None) -> tuple[str, str]:
    order = ident["sweep"]["param.order"]
    position = ident["sweep"].get("param.lookPosition", "middle")
    return catalog.restyle_look_prompt(ident["restyle"], ident["medium"], look_parts(look, order, colour), position)


# ── the running instance ────────────────────────────────────────────────────


class RenderClient:
    """`POST /api/render` and its job. `http` is a requests.Session, or anything
    with its `post`/`get` (the tests pass FastAPI's TestClient)."""

    def __init__(self, base: str, headers: dict, http=None, poll: float = 3.0):
        self.base = base.rstrip("/")
        self.headers = headers
        self.poll = poll
        if http is None:
            import requests

            http = requests.Session()
        self.http = http

    @classmethod
    def from_env(cls, base: str, user: str = USER) -> "RenderClient":
        app, dev = os.environ.get("RESTYLER_APP_TOKEN"), os.environ.get("RESTYLER_DEV_TOKEN")
        if not app and not dev:
            raise SystemExit("set RESTYLER_APP_TOKEN (AUTH_MODE=app) or RESTYLER_DEV_TOKEN")
        headers = {"Authorization": f"app {app}", "X-User": user} if app else {"Authorization": f"dev {dev}"}
        if os.environ.get("CF_ACCESS_CLIENT_ID"):
            headers["CF-Access-Client-Id"] = os.environ["CF_ACCESS_CLIENT_ID"]
            headers["CF-Access-Client-Secret"] = os.environ.get("CF_ACCESS_CLIENT_SECRET", "")
        return cls(base, headers)

    def submit(self, source: bytes, steps: list[dict], wait_429: float = 900) -> str:
        deadline = time.time() + wait_429
        while True:
            r = self.http.post(f"{self.base}/api/render", headers=self.headers,
                               json={"source": b64(source), "steps": steps})
            if r.status_code == 200:
                return r.json()["job_id"]
            if r.status_code == 402:
                raise QuotaExhausted(r.text[:200])
            if r.status_code == 429 and time.time() < deadline:
                time.sleep(self.poll)  # someone's job under this X-User: one at a time
                continue
            raise CellError(f"/api/render HTTP {r.status_code}: {r.text[:300]}")

    def wait(self, job_id: str, timeout: float) -> dict:
        deadline = time.time() + timeout
        while time.time() < deadline:
            r = self.http.get(f"{self.base}/api/jobs/{job_id}", headers=self.headers)
            if r.status_code != 200:
                raise CellError(f"/api/jobs HTTP {r.status_code}: {r.text[:200]}")
            data = r.json()
            if data["status"] in ("done", "error"):
                return data
            time.sleep(self.poll)
        raise CellError(f"job {job_id} timed out after {timeout:.0f} s")

    def step(self, job_id: str, step_id: str) -> bytes:
        r = self.http.get(f"{self.base}/api/jobs/{job_id}/step/{step_id}", headers=self.headers)
        if r.status_code != 200:
            raise CellError(f"step {step_id}: HTTP {r.status_code}")
        return r.content


# ── direct cells ────────────────────────────────────────────────────────────


def apply_pulid_from(wf: dict, original_name: str) -> None:
    """`graph.pulid_from=original`: the identity embedding from the selfie, not
    from the chain's last output (a chain of identities adds up). The depth map
    and the canvas keep the look; the new LoadImage feeds only the adapter."""
    wf["200"] = {"class_type": "LoadImage", "inputs": {"image": original_name, "upload": "image"}}
    nodes = [n for n in wf.values() if n.get("class_type") in PULID_NODES]
    if not nodes:
        raise CellError("graph.pulid_from: no identity node in this graph")
    for node in nodes:
        node["inputs"]["image"] = ["200", 0]


def render_direct(c: Comfy, ident: dict, source: bytes, original: bytes, prompt: str, negative: str,
                  host, timeout: float) -> bytes:
    template = json.loads((catalog.ASSETS / TEMPLATES[ident["engine"]]).read_text())
    name = c.upload(source, f"bench_chain_{hashlib.sha1(source).hexdigest()[:12]}.png")
    ckpt = (ident["ckpt"] or host.DEFAULT_CKPT) if ident["engine"] == "sdxl" else None
    wf = prepare_workflow(template, prompt=prompt, negative=negative, image_name=name,
                          checkpoint=ckpt, latent=latent_for(source))
    if ident["sweep"].get("graph.pulid_from") == "original":
        apply_pulid_from(wf, c.upload(original, f"bench_src_{hashlib.sha1(original).hexdigest()[:12]}.png"))
    apply_node_sweep(wf, {k: v for k, v in ident["sweep"].items() if not k.startswith("param.")})
    set_seed(wf, ident["seed"])
    prefix = f"bench_{ident['key']}"
    host.set_save_prefix(wf, prefix)
    return c.run(wf, (prefix,), timeout=timeout)[prefix]


# ── run ─────────────────────────────────────────────────────────────────────


def cell_name(ident: dict) -> str:
    restyle = ident["restyle"].replace("_", "")
    return f"{ident['look']}__{restyle}__{ident['engine']}__{Path(ident['src']).stem}__s{ident['seed']}__{ident['key']}.png"


class ChainRun:
    """One chain: its edits (once) and its style cells."""

    def __init__(self, args, host, client: RenderClient, comfy: Comfy, out: Path, manifest: dict,
                 cells: list[dict], looks: dict[str, dict], src: Path, save) -> None:
        self.args, self.host, self.client, self.comfy = args, host, client, comfy
        self.out, self.manifest, self.cells, self.src, self.save = out, manifest, cells, src, save
        self.first = cells[0]
        self.key = chain_key(self.first)
        self.look = looks[self.first["look"]]
        self.order = self.first["sweep"]["param.order"]
        self.dir = out / "chains" / self.key
        self.original = src.read_bytes()
        self.rgb = bb.rgb_of(self.original)
        self.analysis = bb.full_analysis(comfy, Path(args.cache), self.original)
        self.colour = hm.estimate_colour(self.rgb, self.analysis.hair)

    def record(self, ident: dict, **fields) -> None:
        self.manifest["cells"][ident["key"]] = {**ident, **fields}
        self.save()

    def edits_done(self, chain: dict, steps: list[dict]) -> bool:
        return all(chain["steps"].get(s["id"], {}).get("status") == "done" for s in steps)

    def last_output(self, steps: list[dict]) -> bytes:
        return (self.dir / f"{steps[-1]['id']}.png").read_bytes() if steps else self.original

    def run_job(self, chain: dict, source: bytes, steps: list[dict], ids: dict[str, dict], labels: dict) -> None:
        job = self.client.submit(source, steps)
        state = self.client.wait(job, self.args.timeout)
        for step_id, st in state["steps"].items():
            if step_id in ids:
                ident = ids[step_id]
                if st["status"] == "done":
                    name = cell_name(ident)
                    self.host.save_png_and_thumb(self.out, name, self.client.step(job, step_id))
                    self.record(ident, file=f"img/{name}", status="done", path="api", chain=self.key,
                                prompt=labels[step_id])
                else:
                    self.record(ident, file=None, status="error", path="api", chain=self.key,
                                error=f"{st['status']}: {st.get('error') or ''}"[:300])
            else:
                chain["steps"][step_id] = {"status": st["status"], "error": st.get("error")}
                if st["status"] == "done":
                    self.dir.mkdir(parents=True, exist_ok=True)
                    (self.dir / f"{step_id}.png").write_bytes(self.client.step(job, step_id))
                    chain["steps"][step_id]["file"] = f"chains/{self.key}/{step_id}.png"
        self.save()

    def run(self) -> None:
        chains = self.manifest.setdefault("chains", {})
        chain = chains.setdefault(self.key, {
            "look": self.first["look"], "order": self.order, "src": self.first["src"],
            "seed": self.first["seed"], "steps": {}, "targets": {}})
        try:
            edits, targets = edit_steps(self.look, self.order, self.analysis, self.rgb)
        except hm.HairMaskError as e:
            for ident in self.cells:
                self.record(ident, file=None, status="refused", error=e.code, chain=self.key)
            return
        chain["targets"] = targets
        self.dir.mkdir(parents=True, exist_ok=True)
        for step in edits:
            (self.dir / f"{step['id']}_mask.png").write_bytes(base64.b64decode(step["mask"]))
        todo = [c for c in self.cells
                if self.manifest["cells"].get(c["key"], {}).get("status") not in ("done", "refused")]
        cached = self.edits_done(chain, edits)
        parent = edits[-1]["id"] if edits else "source"
        batches = jobs_for(todo, 0 if cached else len(edits))
        for i, batch in enumerate(batches):
            if not batch and (i or cached or not edits):
                continue
            ids, labels, steps = {}, {}, []
            for n, ident in enumerate(batch):
                prompt, negative = style_prompt(ident, self.look, self.colour)
                step_id = f"s{n}"
                ids[step_id], labels[step_id] = ident, prompt
                steps.append(style_step(ident, step_id, parent if not cached and i == 0 else "source", prompt, negative))
            if not cached and i == 0:
                self.run_job(chain, self.original, [*edits, *steps], ids, labels)
                cached = self.edits_done(chain, edits)
                if not cached:
                    # The steps are `skipped` in the job; later batches have no input.
                    for ident in todo:
                        if ident["key"] not in self.manifest["cells"] and not is_direct(ident):
                            self.record(ident, file=None, status="error", chain=self.key, error="edits failed")
                    break
            else:
                self.run_job(chain, self.last_output(edits), steps, ids, labels)
        direct = [c for c in todo if is_direct(c)]
        if direct and not cached and edits:
            self.run_job(chain, self.original, edits, {}, {})
            cached = self.edits_done(chain, edits)
        for ident in direct:
            if edits and not cached:
                self.record(ident, file=None, status="error", chain=self.key, error="edits failed")
                continue
            self.direct(ident, edits)

    def direct(self, ident: dict, edits: list[dict]) -> None:
        name = cell_name(ident)
        try:
            prompt, negative = style_prompt(ident, self.look, self.colour)
            png = render_direct(self.comfy, ident, self.last_output(edits), self.original, prompt, negative,
                                self.host, self.args.timeout)
            self.host.save_png_and_thumb(self.out, name, png)
            self.record(ident, file=f"img/{name}", status="done", path="direct", chain=self.key, prompt=prompt)
        except CellError as e:
            self.record(ident, file=None, status="error", path="direct", chain=self.key, error=str(e)[:300])


def run(args, host) -> None:
    cells = host.plan_cells(args)
    looks = load_looks(args.looks)
    out = Path(args.out)
    out.mkdir(parents=True, exist_ok=True)
    manifest_path = out / "manifest.json"
    manifest = json.loads(manifest_path.read_text()) if manifest_path.exists() else {"cells": {}}
    done = sum(manifest["cells"].get(c["key"], {}).get("status") in ("done", "refused") for c in cells)
    d = describe(cells, looks)
    host.log(f"{d['cells']} cells in {d['chains']} chains, {done} finished; {d['render_jobs']} /api/render jobs "
             f"= {d['api_generations']} generations of the instance's quota, {d['direct_cells']} direct on ComfyUI")
    if args.plan:
        return
    client = RenderClient.from_env(args.api)
    comfy = Comfy(args.url)
    manifest.update(task="pipeline", looks=looks, thresholds=THRESHOLDS)
    manifest.setdefault("srcs", {})
    src_paths = {Path(s).name: Path(s) for s in host.csv(args.srcs)}
    for name, p in src_paths.items():
        (out / "srcs").mkdir(exist_ok=True)
        (out / "srcs" / name).write_bytes(p.read_bytes())
        manifest["srcs"][name] = f"srcs/{name}"

    def save() -> None:
        manifest_path.write_text(json.dumps(manifest, indent=1, ensure_ascii=False))

    chains: dict[str, list[dict]] = defaultdict(list)
    for c in cells:
        chains[chain_key(c)].append(c)
    for i, (key, chain) in enumerate(chains.items(), 1):
        if all(manifest["cells"].get(c["key"], {}).get("status") in ("done", "refused") for c in chain):
            continue
        started = time.time()
        if args.url.startswith(("http://127.0.0.1", "http://localhost")):
            comfy.guard(args.min_free_gb, host.log)  # the guard's systemctl is the box's own
        try:
            ChainRun(args, host, client, comfy, out, manifest, chain, looks, src_paths[chain[0]["src"]], save).run()
        except QuotaExhausted as e:
            save()
            raise SystemExit(f"the instance's daily limit ran out ({e}); the run resumes where it stopped. "
                             "A bench instance needs FREE_DAILY_LIMIT above the plan's generations.") from e
        except CellError as e:
            for ident in chain:
                if manifest["cells"].get(ident["key"], {}).get("status") != "done":
                    manifest["cells"][ident["key"]] = {**ident, "file": None, "status": "error", "error": str(e)[:300]}
            save()
        host.log(f"[{i}/{len(chains)}] chain {key} {chain[0]['look']} {chain[0]['sweep']['param.order']} "
                 f"{chain[0]['src']}: {time.time() - started:.0f} s")


# ── metrics ─────────────────────────────────────────────────────────────────


def scale_box(box: list[int], src_shape: tuple[int, ...], out_shape: tuple[int, ...]) -> tuple[int, int, int, int]:
    """A face box of the source on an output of another size (a restyle renders
    on an SDXL bucket)."""
    sy, sx = out_shape[0] / src_shape[0], out_shape[1] / src_shape[1]
    return (int(box[0] * sx), int(box[1] * sy), int(box[2] * sx), int(box[3] * sy))


def rate_of(values: list) -> float | None:
    vals = [v for v in values if v is not None]
    return sum(map(bool, vals)) / len(vals) if vals else None


def carries(rows: list[tuple[dict, dict]], looks: dict[str, dict]) -> dict:
    """engine → restyle style → {hair, glasses, beard}: True/False, or None when
    no default-axis cell measured that step. Sweep cells and the reverse order do
    not vote: a verdict is about what ships, as in verdicts.py."""
    votes: dict[tuple, list] = defaultdict(list)
    for row, m in rows:
        sweep = {k: v for k, v in row["sweep"].items() if k != "param.order"}
        if sweep or row["sweep"]["param.order"] != DEFAULT_ORDER or row.get("restyle") == catalog.BASELINE:
            continue
        for step in STEPS:
            if step in looks[row["look"]]:
                votes[(row["engine"], row["restyle"], step)].append(m.get(f"{step}_kept"))
    out: dict[str, dict] = {}
    for (engine, style, step), vals in votes.items():
        r = rate_of(vals)
        entry = out.setdefault(engine, {}).setdefault(style, dict.fromkeys(("hair", "glasses", "beard")))
        entry[step] = None if r is None else r >= THRESHOLDS["rate"]
    return out


def summarise(manifest: dict, metrics: dict) -> dict:
    T = THRESHOLDS
    groups: dict[tuple, list] = defaultdict(list)
    for key, row in manifest["cells"].items():
        groups[(row["style"], row["engine"], row["medium"], json.dumps(row["sweep"], sort_keys=True))].append(
            (row, metrics.get(key, {})))
    out = {}
    for (style, engine, medium, sweep), items in sorted(groups.items()):
        done = [m for _, m in items if m.get("status") == "done"]
        ids = [m["identity"] for m in done if m.get("identity") is not None]
        baseline = style.endswith("/" + catalog.BASELINE)
        reasons = []
        s = {"cells": len(items), "done": len(done),
             "refused": sum(r["status"] == "refused" for r, _ in items),
             "errors": sum(r["status"] == "error" for r, _ in items),
             "identity_min": min(ids) if ids else None,
             "identity_mean": round(sum(ids) / len(ids), 3) if ids else None}
        if not done:
            reasons.append("nothing rendered")
        if s["errors"]:
            reasons.append(f"{s['errors']} errors")
        if len(ids) < len(done):
            reasons.append("face lost")
        elif ids and min(ids) < T["identity_min"]:
            reasons.append(f"identity {min(ids):.2f}")
        for key in ("beard_kept", "glasses_kept", "hair_kept"):
            s[key] = rate_of([m.get(key) for m in done])
            if s[key] is not None and s[key] < T["rate"]:
                reasons.append(f"{key} {s[key]:.0%}")
        for key in ("clothed", "clean"):
            s[key] = rate_of([m.get(key) for m in done])
            if s[key] is not None and s[key] < 1:
                reasons.append(key)
        reacts = [m["reaction"] for m in done if m.get("reaction") is not None]
        s["reaction_mean"] = round(sum(reacts) / len(reacts), 3) if reacts else None
        if not baseline and reacts and s["reaction_mean"] < T["style_reaction_min"]:
            reasons.append(f"style_reaction {s['reaction_mean']:.2f}")
        s["auto"], s["reasons"] = ("pass" if not reasons else "fail"), reasons
        out[f"{style}|{engine}|{medium}|{sweep}"] = s
    return out


# ── scoring (SPARK) ─────────────────────────────────────────────────────────


class Kept:
    """Whether a step's change is still in a later image."""

    def __init__(self, sc, comfy, cache: Path, src_img: np.ndarray, src_a: hm.HairAnalysis) -> None:
        self.sc, self.comfy, self.cache = sc, comfy, cache
        self.src_img, self.src_a = src_img, src_a
        self.lower = bm.lower_face_box(src_a.face, src_a.nose, src_a.lips)
        self.box = hm.face_box(src_a.face)

    def __call__(self, step: str, target: dict, png: bytes, img: np.ndarray, mask_png: bytes | None) -> bool | None:
        a = bb.full_analysis(self.comfy, self.cache, png)
        if step == "beard":
            if self.lower is None:
                return None
            texts = [bb.SECTION_TEXTS[s] for s in bb.SECTIONS]
            crop = bb.crop_box(scale_box(list(self.lower), self.src_img.shape, img.shape), img.shape)
            src_crop = bb.crop_box(self.lower, self.src_img.shape)
            return bb.beard_ok(self.sc.clip_probs(Image.fromarray(img).crop(crop), texts),
                               self.sc.clip_probs(Image.fromarray(self.src_img).crop(src_crop), texts),
                               target["section"])
        if step == "hair":
            if self.box is None:
                return None
            box = scale_box(list(self.box), self.src_img.shape, img.shape)
            shape = target["shape"]
            src_box = self.box
            below, below_src = self.sc.hair_below(a.hair, box), self.sc.hair_below(self.src_a.hair, src_box)
            length = self.sc.length_ok(target["style"], shape, below, below_src)
            bangs = self.sc.bangs_ok(shape, self.sc.fringe_cover(a.hair, box),
                                     self.sc.fringe_cover(self.src_a.hair, src_box))
            return bool(bangs and length is not False)
        worn = getattr(self.sc, "worn_ok", None)
        glasses = getattr(a, "glasses", None)
        if worn is None or glasses is None or mask_png is None:
            return None  # the glasses metrics arrive with the glasses branch
        mask = hm.decode_mask(mask_png)
        if mask.shape != glasses.shape:
            mask = hm._resize(mask, (glasses.shape[1], glasses.shape[0]))
        return worn(glasses, mask, removed=target.get("removed", False))[0]


def score_run(run: Path, manifest: dict, url: str, cache: Path) -> dict:
    import score as sc

    prev = json.loads((run / "metrics.json").read_text()) if (run / "metrics.json").exists() else {"cells": {}}
    c = sc.Comfy(url)
    looks = manifest["looks"]
    srcs: dict[str, dict] = {}
    cells: dict[str, dict] = {}

    def src_info(name: str) -> dict:
        if name not in srcs:
            png = (run / manifest["srcs"][name]).read_bytes()
            img = bb.rgb_of(png)
            a = bb.full_analysis(c, cache, png)
            srcs[name] = {"img": img, "emb": sc.embedding(img)[0], "kept": Kept(sc, c, cache, img, a)}
        return srcs[name]

    def mask_of(key: str, step: str) -> bytes | None:
        p = run / "chains" / key / f"{step}_mask.png"
        return p.read_bytes() if p.exists() else None

    # Baselines: the chain's output under the medium alone.
    baselines = {}
    for row in manifest["cells"].values():
        if row.get("restyle") == catalog.BASELINE and row["status"] == "done":
            gk = (row["chain"], row["engine"], row["medium"], json.dumps(row["sweep"], sort_keys=True))
            baselines[gk] = sc.histogram(bb.rgb_of((run / row["file"]).read_bytes()))

    # Where a change got lost: every later edit, per chain.
    lost: dict[str, dict] = {}
    for key, chain in manifest.get("chains", {}).items():
        steps = [s for s in chain["order"].split(",") if chain["steps"].get(s, {}).get("status") == "done"]
        lost[key] = {}
        for i, later in enumerate(steps):
            png = (run / chain["steps"][later]["file"]).read_bytes()
            img = bb.rgb_of(png)
            for step in steps[: i + 1]:
                lost[key].setdefault(step, {})[later] = src_info(chain["src"])["kept"](
                    step, chain["targets"][step], png, img, mask_of(key, step))

    for key, row in manifest["cells"].items():
        if row["status"] != "done":
            cells[key] = {"status": row["status"], "error": row.get("error")}
            continue
        if (prev.get("metrics_version") == METRICS_VERSION and key in prev["cells"]
                and prev["cells"][key].get("scored_file") == row["file"]):
            cells[key] = prev["cells"][key]
            continue
        src = src_info(row["src"])
        png = (run / row["file"]).read_bytes()
        img = bb.rgb_of(png)
        emb, n_faces = sc.embedding(img)
        probs = sc.clip_probs(Image.fromarray(img), CLOTHED_TEXTS)
        m = {"status": "done", "scored_file": row["file"], "faces": n_faces, "clean": n_faces == 1,
             "identity": None if emb is None or src["emb"] is None else round(float(emb @ src["emb"]), 3),
             "clothed": bool(probs[0] >= 0.5)}
        gk = (row["chain"], row["engine"], row["medium"], json.dumps(row["sweep"], sort_keys=True))
        if row["restyle"] != catalog.BASELINE and gk in baselines:
            m["reaction"] = round(sc.cos_dist(sc.histogram(img), baselines[gk]), 3)
        targets = manifest["chains"][row["chain"]]["targets"]
        for step, target in targets.items():
            m[f"{step}_kept"] = src["kept"](step, target, png, img, mask_of(row["chain"], step))
        cells[key] = m
        print(f"{row['style']:36} {row['engine']:7} {json.dumps({k: v for k, v in m.items() if k not in ('status', 'scored_file')})}", flush=True)
    rows = [(row, cells.get(k, {})) for k, row in manifest["cells"].items()]
    return {"metrics_version": METRICS_VERSION, "cells": cells, "lost": lost, "thresholds": THRESHOLDS,
            "summary": summarise(manifest, cells), "carries": carries(rows, looks)}


def write_summary_md(run: Path, manifest: dict, metrics: dict) -> None:
    pct = lambda v: "—" if v is None else f"{v:.0%}"  # noqa: E731
    lines = [f"# {run.name} — pipeline", "",
             "| look/style | engine | medium | axes | done | identity min/mean | beard | glasses | hair | reaction | clothed | clean | auto |",
             "|---|---|---|---|---|---|---|---|---|---|---|---|---|"]
    for key, s in metrics["summary"].items():
        style, engine, medium, sweep = key.split("|", 3)
        ident = f"{s['identity_min']:.2f} / {s['identity_mean']:.2f}" if s["identity_min"] is not None else "—"
        auto = s["auto"] + ("" if not s["reasons"] else f" ({', '.join(s['reasons'])})")
        lines.append(f"| {style} | {engine} | {medium} | {sweep} | {s['done']}/{s['cells']} | {ident} | "
                     f"{pct(s['beard_kept'])} | {pct(s['glasses_kept'])} | {pct(s['hair_kept'])} | "
                     f"{s['reaction_mean'] if s['reaction_mean'] is not None else '—'} | {pct(s['clothed'])} | {pct(s['clean'])} | {auto} |")
    lines += ["", "## Where a change got lost (edit chain, later steps)", "",
              "| chain | look | order | step | still there on |", "|---|---|---|---|---|"]
    for key, steps in metrics.get("lost", {}).items():
        chain = manifest["chains"][key]
        for step, later in steps.items():
            on = ", ".join(f"{k}: {'yes' if v else 'no' if v is not None else '—'}" for k, v in later.items())
            lines.append(f"| {key} | {chain['look']} | {chain['order']} | {step} | {on} |")
    lines += ["", "## carries", "", "| engine | style | hair | glasses | beard |", "|---|---|---|---|---|"]
    word = lambda v: "—" if v is None else ("yes" if v else "no")  # noqa: E731
    for engine, styles in sorted(metrics.get("carries", {}).items()):
        for style, c in sorted(styles.items()):
            lines.append(f"| {engine} | {style} | {word(c['hair'])} | {word(c['glasses'])} | {word(c['beard'])} |")
    (run / "summary.md").write_text("\n".join(lines) + "\n")


def badge_bits(m: dict) -> list[tuple[str, str]]:
    bits = [("ok" if m.get(k) else "bad", label) for k, label in
            (("beard_kept", "beard"), ("glasses_kept", "glasses"), ("hair_kept", "hair"), ("clothed", "clothed"))
            if m.get(k) is not None]
    if m.get("reaction") is not None:
        bits.append(("dim", f"react {m['reaction']}"))
    return bits


def main(argv: list[str], host) -> None:
    ap = host.task_parser("pipeline", engines="flux")
    ap.add_argument("--api", default="http://127.0.0.1:8095", help="base URL of the instance with /api/render")
    ap.add_argument("--looks", default=str(Path(__file__).parent / "candidates" / "looks.json"))
    ap.add_argument("--look-ids", help="comma-separated ids from --looks (default: all)")
    ap.add_argument("--order", nargs="*", help=f"axis order, default {DEFAULT_ORDER}")
    args = ap.parse_args(argv)
    run(args, host)

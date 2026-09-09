#!/usr/bin/env python3
"""Pre-flight: does this ComfyUI server actually understand this workflow?

Checks a *.api.json against a live `GET /object_info` before any GPU time is
spent: node classes present, every input name known to the installed version
of the node, no required input left unwired, and every model file the graph
names present in that input's enum. Catches the three ways a workflow ported
from another box fails — a custom node pack that is not installed, a node
whose inputs were renamed between versions, and a missing checkpoint or
ControlNet — and it catches them in a second instead of after a queued job.

    python3 tools/check_workflow.py ../assets/comfyui/sdxl_restyle.api.json \
        --url http://192.168.1.50:8188

Placeholders (__PROMPT__, __CKPT__, …) are ignored: they are substituted at
request time. Pass --ckpt to check the checkpoint that will be substituted in.
"""

from __future__ import annotations

import argparse
import json
import sys
import urllib.request

PLACEHOLDER_PREFIX = "__"
MODEL_SUFFIXES = (".safetensors", ".ckpt", ".bin", ".pth", ".pt", ".onnx")


def fetch_object_info(url: str, headers: dict[str, str] | None = None) -> dict:
    req = urllib.request.Request(
        f"{url.rstrip('/')}/object_info", headers=headers or {}
    )
    with urllib.request.urlopen(req, timeout=60) as resp:
        return json.loads(resp.read())


def _spec_inputs(spec: dict) -> tuple[dict, dict]:
    """(required, optional) input definitions of one node class."""
    block = spec.get("input") or {}
    return (block.get("required") or {}), (block.get("optional") or {})


def _enum_options(definition) -> list | None:
    """Combo inputs are defined as `[[option, …], {…}]`; everything else
    (INT, FLOAT, links) has a type string first and no options."""
    if isinstance(definition, list) and definition and isinstance(definition[0], list):
        return definition[0]
    return None


def check_workflow(wf: dict, object_info: dict) -> list[str]:
    """Human-readable problems, empty when the server can run this graph."""
    problems: list[str] = []
    for node_id, node in sorted(wf.items()):
        cls = node.get("class_type")
        title = f"node {node_id} ({cls})"
        spec = object_info.get(cls)
        if spec is None:
            problems.append(f"{title}: class is not installed on the server")
            continue

        required, optional = _spec_inputs(spec)
        known = {**required, **optional}
        inputs = node.get("inputs") or {}

        for key, value in sorted(inputs.items()):
            if key not in known:
                problems.append(f"{title}: unknown input '{key}' (node version drift?)")
                continue
            # A [node_id, slot] pair is a link, checked by ComfyUI itself.
            if isinstance(value, list):
                continue
            if not isinstance(value, str) or value.startswith(PLACEHOLDER_PREFIX):
                continue
            options = _enum_options(known[key])
            if options is None:
                continue
            if value not in options:
                kind = "model file" if value.endswith(MODEL_SUFFIXES) else "value"
                problems.append(
                    f"{title}: {kind} '{value}' is not offered for '{key}' "
                    f"({len(options)} options installed)"
                )

        for key, definition in sorted(required.items()):
            if key in inputs:
                continue
            # A required input with a default is fine to leave out.
            meta = definition[1] if isinstance(definition, list) and len(definition) > 1 else {}
            if isinstance(meta, dict) and "default" in meta:
                continue
            if _enum_options(definition) is not None:
                continue
            problems.append(f"{title}: required input '{key}' is not wired")
    return problems


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("workflow", help="path to a *.api.json workflow")
    ap.add_argument("--url", default="http://localhost:8188", help="ComfyUI base URL")
    ap.add_argument("--ckpt", help="checkpoint substituted for __CKPT__ at request time")
    ap.add_argument("--cf-id", help="CF-Access-Client-Id (public hostname only)")
    ap.add_argument("--cf-secret", help="CF-Access-Client-Secret")
    args = ap.parse_args()

    wf = json.loads(open(args.workflow).read())
    if args.ckpt:
        wf = json.loads(json.dumps(wf).replace("__CKPT__", args.ckpt))

    headers = {}
    if args.cf_id and args.cf_secret:
        headers = {
            "CF-Access-Client-Id": args.cf_id,
            "CF-Access-Client-Secret": args.cf_secret,
        }
    try:
        object_info = fetch_object_info(args.url, headers)
    except Exception as e:  # noqa: BLE001 — a pre-flight must explain itself
        print(f"could not read {args.url}/object_info: {e}", file=sys.stderr)
        return 2

    problems = check_workflow(wf, object_info)
    if not problems:
        print(f"OK — {args.url} can run {args.workflow} ({len(wf)} nodes)")
        return 0
    print(f"{len(problems)} problem(s) with {args.workflow} on {args.url}:")
    for p in problems:
        print(f"  • {p}")
    return 1


if __name__ == "__main__":
    raise SystemExit(main())

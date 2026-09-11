#!/usr/bin/env python3
"""ComfyUI graphs for the Couple card bench — one clip, two identities.

Built in code rather than stored as a static *.api.json because the whole point
is that P1 and P2 are the *same* pass with different inputs. `run.py` submits
these and times them; `check_workflow.py` pre-flights whatever they emit.

The architecture is the Mix mode of the native `WanAnimateToVideo` node
(docs/couple-spark-setup.md §1):

    P1: reference=ref_a, character_mask=mask_A, background_video=driving  -> out_A
    P2: reference=ref_b, character_mask=mask_B, background_video=out_A    -> out_AB

Person A survives the second pass because `background_video` carries them, so
the model composites instead of us — no seam at the point of contact and no two
differently lit people in one frame.

Preprocess and both passes live in **one** graph. A mask written out as h264
and read back would arrive with compression noise along exactly the edge that
matters, and the pose/face streams cost real time on this box (ONNX runs on
CPU, see `ONNX_DEVICE`), so recomputing them per pass would double it. Per-pass
timings come from the websocket instead: `run.py` stamps each node as it starts.

## Why preprocess runs once per person

`PoseAndFaceDetection` is single-person by construction. It calls the YOLO
detector and takes `[0][0]["bbox"]`, and the detector's `process_results()`
defaults to `single_person=True`, returning the **largest** box in that frame.
On a couple video the pose and face streams would therefore jump between the
two people whenever their apparent sizes swap — the same failure mode as
facebench taking the largest face in a still.

So each person gets their own detection pass over a copy of the driving video
in which **only that person** is left and everything else is black; the largest
box is then trivially the right one. Seeding is manual: a few positive points
down each person on the first frame, which SAM2's video segmentor propagates
through the clip. Why "keep one" and not "remove the other" — which is the
obvious move and does not work — is in the comment at that node.
"""

from __future__ import annotations

import json

ANIMATE_UNET = "wan2.2_animate_14B_fp8_scaled_e4m3fn.safetensors"
RELIGHT_LORA = "wan2.2_animate_14B_relight_lora_bf16.safetensors"
DISTILL_LORA = "lightx2v_I2V_14B_480p_cfg_step_distill_rank64_bf16.safetensors"
TEXT_ENCODER = "umt5_xxl_fp8_e4m3fn_scaled.safetensors"
VAE = "wan_2.1_vae.safetensors"
VITPOSE = "vitpose-l-wholebody.onnx"
YOLO = "yolov10m.onnx"
SAM2 = "sam2.1_hiera_base_plus.safetensors"

# Kijai's reference Animate workflow: 4 steps with the lightx2v distill LoRA at
# 1.2, cfg 1.0, lcm/simple. video-stack reaches its 150 s/beat on the same
# shape (4 steps, cfg 1.0, euler/simple, Seko distill), so Animate starts from
# this box's known-good settings rather than from node defaults.
STEPS = 4
CFG = 1.0
SAMPLER = "lcm"
SCHEDULER = "simple"
DISTILL_STRENGTH = 1.2
RELIGHT_STRENGTH = 1.0

# onnxruntime in the ComfyUI venv has no CUDA EP on this box (aarch64), so the
# pose models run on CPU. A measured property of the install, not a preference.
ONNX_DEVICE = "CPUExecutionProvider"

# The prompt is not decoration — at cfg 1.0 with a 4-step distill it is one of
# the few things steering content, and it decides how many people appear.
# Measured the hard way: running the solo pass with the couple's "two people…"
# text produced two dancers that resembled neither the reference nor the driving
# clip. One prompt per mode, therefore.
LOOK = "natural skin texture, soft light, photorealistic, sharp focus, stable camera"
PROMPT_SOLO = "a person, " + LOOK
PROMPT_COUPLE = "two people, " + LOOK


def _resize(src, width, height):
    """Letterboxed resize to a multiple of 16 — Animate requires it."""
    return {"class_type": "ImageResizeKJv2", "inputs": {
        "image": src, "width": width, "height": height, "upscale_method": "lanczos",
        "keep_proportion": "pad_edge_pixel", "pad_color": "0, 0, 0",
        "crop_position": "top", "divisible_by": 16}}


def _points(points):
    return json.dumps([{"x": int(x), "y": int(y)} for x, y in points])


def _save(src, prefix, fps):
    return {"class_type": "VHS_VideoCombine", "inputs": {
        "images": src, "frame_rate": fps, "loop_count": 0, "filename_prefix": prefix,
        "format": "video/h264-mp4", "pingpong": False, "save_output": True}}


def model_edge(distill):
    """Which node the model hangs off — the distill LoRA is rewired out, not
    zeroed, when it is disabled."""
    return "lora_distill" if distill else "lora_relight"


def _loaders(steps, distill, relight, prompt, sampler=None):
    """Everything shared by both passes. Both passes reuse one model, one text
    encoding and one VAE — loading them twice would dominate the measurement.

    `distill` 0 drops the lightx2v LoRA from the model chain entirely, which is
    what a run at full step count wants; the chain is rewired, not just set to
    strength 0, so the comparison is clean."""
    g = {
        "unet": {"class_type": "UNETLoader", "inputs": {
            "unet_name": ANIMATE_UNET, "weight_dtype": "default"}},
        "lora_relight": {"class_type": "LoraLoaderModelOnly", "inputs": {
            "model": ["unet", 0], "lora_name": RELIGHT_LORA, "strength_model": relight}},
        "lora_distill": {"class_type": "LoraLoaderModelOnly", "inputs": {
            "model": ["lora_relight", 0], "lora_name": DISTILL_LORA,
            "strength_model": distill}},
        "clip": {"class_type": "CLIPLoader", "inputs": {
            "clip_name": TEXT_ENCODER, "type": "wan", "device": "default"}},
        "pos": {"class_type": "CLIPTextEncode", "inputs": {
            "clip": ["clip", 0], "text": prompt}},
        # cfg is 1.0, so the negative only has to be a well-formed empty one.
        "neg": {"class_type": "ConditioningZeroOut", "inputs": {"conditioning": ["pos", 0]}},
        "vae": {"class_type": "VAELoader", "inputs": {"vae_name": VAE}},
        # `lcm` belongs to the distilled schedule. Running it without the
        # distill LoRA diverged into an all-black clip on the first try, so the
        # sampler follows the LoRA rather than being a constant.
        "sampler": {"class_type": "KSamplerSelect", "inputs": {
            "sampler_name": sampler or (SAMPLER if distill else "euler")}},
        "sigmas": {"class_type": "BasicScheduler", "inputs": {
            "model": ["lora_distill", 0], "scheduler": SCHEDULER,
            "steps": steps, "denoise": 1.0}},
    }
    if not distill:
        g.pop("lora_distill")
        g["sigmas"]["inputs"]["model"] = ["lora_relight", 0]
    return g


def _video(name, length, fps):
    return {"class_type": "VHS_LoadVideo", "inputs": {
        "video": name, "force_rate": fps, "custom_width": 0, "custom_height": 0,
        "frame_load_cap": length, "skip_first_frames": 0, "select_every_nth": 1,
        "format": "AnimateDiff"}}


def _detect(g, who, images, width, height, fps, prefix, save=True):
    """ViTPose + face crops for one person, and the pose video Animate consumes."""
    g["pose_" + who] = {"class_type": "PoseAndFaceDetection", "inputs": {
        "model": ["onnx", 0], "images": images, "width": width, "height": height,
        "face_padding": 0}}
    g["draw_" + who] = {"class_type": "DrawViTPose", "inputs": {
        "pose_data": ["pose_" + who, 0], "width": width, "height": height,
        "retarget_padding": 0, "body_stick_width": 4, "hand_stick_width": 2,
        "draw_head": True}}
    if save:
        g["save_pose_" + who] = _save(["draw_" + who, 0], "%s_pose_%s" % (prefix, who), fps)
        g["save_face_" + who] = _save(["pose_" + who, 1], "%s_face_%s" % (prefix, who), fps)


def _pass(g, who, ref_image, background, width, height, length, seed, fps, prefix,
          model, cfg, mask=None, ref_fit=True):
    """One Animate pass. Without `mask` this is Move mode (one person, whole
    frame); with it, Mix mode (replace the masked person, keep the rest)."""
    # `WanAnimateToVideo` scales the reference to **cover** width×height and
    # centre-crops it (`common_upscale(..., "center")`), so anything that is not
    # already the target aspect loses its edges: a 1024² portrait comes out as
    # an eyes-to-chin band, and a 832×1216 full-body shot loses the head
    # entirely. `ref_fit` letterboxes it first so the whole person survives —
    # Kijai's reference workflow resizes the reference for the same reason.
    ref = "ref_" + who
    g[ref] = {"class_type": "LoadImage", "inputs": {"image": ref_image}}
    if ref_fit:
        g["reffit_" + who] = _resize([ref, 0], width, height)
        ref = "reffit_" + who
    wan = {"positive": ["pos", 0], "negative": ["neg", 0], "vae": ["vae", 0],
           "width": width, "height": height, "length": length, "batch_size": 1,
           "continue_motion_max_frames": 5, "video_frame_offset": 0,
           "reference_image": [ref, 0],
           "face_video": ["pose_" + who, 1], "pose_video": ["draw_" + who, 0]}
    if mask is not None:
        # The background must arrive with the person being replaced **painted
        # out**, not as the untouched frame. `character_mask` only says "make
        # something new here"; the concat latent still carries whatever pixels
        # the background holds there, and with four distill steps the model
        # simply keeps them. Measured: feeding the raw driving clip as
        # background gave back the driving clip (identity 0.10 / 0.07 against
        # the references) while the same reference in Move mode transferred
        # cleanly. Kijai's reference workflow does the same — its
        # `background_image` comes from `DrawMaskOnImage`.
        g["bg_" + who] = {"class_type": "DrawMaskOnImage", "inputs": {
            "image": background, "mask": mask, "color": "0, 0, 0"}}
        wan["background_video"] = ["bg_" + who, 0]
        wan["character_mask"] = mask
    g["wan_" + who] = {"class_type": "WanAnimateToVideo", "inputs": wan}
    g["noise_" + who] = {"class_type": "RandomNoise", "inputs": {"noise_seed": seed}}
    g["guider_" + who] = {"class_type": "CFGGuider", "inputs": {
        "model": [model, 0], "positive": ["wan_" + who, 0],
        "negative": ["wan_" + who, 1], "cfg": cfg}}
    g["sample_" + who] = {"class_type": "SamplerCustomAdvanced", "inputs": {
        "noise": ["noise_" + who, 0], "guider": ["guider_" + who, 0],
        "sampler": ["sampler", 0], "sigmas": ["sigmas", 0],
        "latent_image": ["wan_" + who, 2]}}
    g["trim_" + who] = {"class_type": "TrimVideoLatent", "inputs": {
        "samples": ["sample_" + who, 0], "trim_amount": ["wan_" + who, 3]}}
    g["out_" + who] = {"class_type": "VAEDecode", "inputs": {
        "samples": ["trim_" + who, 0], "vae": ["vae", 0]}}
    g["save_out_" + who] = _save(["out_" + who, 0], "%s_out_%s" % (prefix, who), fps)


def solo(video, reference, width=832, height=480, length=77, seed=42, fps=16.0,
         prefix="couple_solo", steps=STEPS, distill=DISTILL_STRENGTH,
         relight=RELIGHT_STRENGTH, prompt=PROMPT_SOLO, cfg=CFG, sampler=None,
         ref_fit=True):
    """S2 — Move mode, one person, no mask. The cheapest thing that answers
    "how long does this machine take per clip", which every later decision
    depends on (docs/couple-spark-setup.md §4)."""
    g = _loaders(steps, distill, relight, prompt, sampler)
    g["load"] = _video(video, length, fps)
    g["src"] = _resize(["load", 0], width, height)
    g["onnx"] = {"class_type": "OnnxDetectionModelLoader", "inputs": {
        "vitpose_model": VITPOSE, "yolo_model": YOLO, "onnx_device": ONNX_DEVICE}}
    _detect(g, "a", ["src", 0], width, height, fps, prefix)
    _pass(g, "a", reference, None, width, height, length, seed, fps, prefix,
          model_edge(distill), cfg, ref_fit=ref_fit)
    return g


def couple(video, ref_a, ref_b, point_a, point_b, width=832, height=480,
           length=77, seed=42, fps=16.0, prefix="couple", steps=STEPS,
           distill=DISTILL_STRENGTH, relight=RELIGHT_STRENGTH,
           prompt=PROMPT_COUPLE, cfg=CFG, sampler=None, ref_fit=True):
    """S3 — the test that decides whether this card can exist locally.

    `point_a` / `point_b` are lists of (x, y) on the first frame **in the
    resized frame's coordinates** — a few points down each person, which SAM2's
    video segmentor propagates through the clip.
    """
    g = _loaders(steps, distill, relight, prompt, sampler)
    g["load"] = _video(video, length, fps)
    g["src"] = _resize(["load", 0], width, height)
    g["sam2"] = {"class_type": "DownloadAndLoadSAM2Model", "inputs": {
        "model": SAM2, "segmentor": "video", "device": "cuda", "precision": "fp16"}}
    g["black"] = {"class_type": "EmptyImage", "inputs": {
        "width": width, "height": height, "batch_size": 1, "color": 0}}
    g["onnx"] = {"class_type": "OnnxDetectionModelLoader", "inputs": {
        "vitpose_model": VITPOSE, "yolo_model": YOLO, "onnx_device": ONNX_DEVICE}}

    for who, points, other_points in (("a", point_a, point_b),
                                      ("b", point_b, point_a)):
        # One point is not enough: SAM2 answers a single click with whichever
        # granularity it likes, and a click that lands on hair returns the hair.
        # Measured on the bench clip — a point on the woman's shoulder gave her
        # head alone, while the man's chest gave his whole body. Several points
        # down the body say "this person", and the *other* person's points as
        # negatives say where this one ends, which is what keeps the two masks
        # apart once they touch.
        g["seg_" + who] = {"class_type": "Sam2Segmentation", "inputs": {
            "sam2_model": ["sam2", 0], "image": ["src", 0], "keep_model_loaded": True,
            "coordinates_positive": _points(points),
            "coordinates_negative": _points(other_points),
            "individual_objects": False}}
        # The mask Animate gets: grown and blurred so the seam has room, then
        # blockified onto the latent grid, as in Kijai's reference workflow.
        g["grow_" + who] = {"class_type": "GrowMaskWithBlur", "inputs": {
            "mask": ["seg_" + who, 0], "expand": 10, "incremental_expandrate": 0.0,
            "tapered_corners": True, "flip_input": False, "blur_radius": 1.0,
            # fill_holes matters: SAM2 left a hole in the man's striped shirt on
            # the front-facing bench clip, the body came out in two pieces, and
            # ViTPose then produced NaN face keypoints that crash
            # PoseAndFaceDetection outright ("cannot convert float NaN to
            # integer", nodes.py:157 — the node has no guard).
            "lerp_alpha": 1.0, "decay_factor": 1.0, "fill_holes": True}}
        g["block_" + who] = {"class_type": "BlockifyMask", "inputs": {
            "masks": ["grow_" + who, 0], "block_size": 32}}
        g["maskimg_" + who] = {"class_type": "MaskToImage", "inputs": {
            "mask": ["block_" + who, 0]}}
        g["save_mask_" + who] = _save(["maskimg_" + who, 0],
                                      "%s_mask_%s" % (prefix, who), fps)

    for who, other in (("a", "b"), ("b", "a")):
        # Keep **only** this person and black out everything else — the frame,
        # not just the other body.
        #
        # Painting the other person black was the obvious move and it does not
        # work: a crisp black human silhouette is still a person to YOLO, and
        # once the two embrace it is the *larger* one, so `single_person=True`
        # picks it and ViTPose then reads pose off a black cut-out. Measured on
        # the bench clip: blacking out A left the detector on A's silhouette at
        # frames 40 and 80 (conf 0.72 / 0.79) instead of on B. Filling from a
        # temporal median of the clip is no better — with two people present in
        # almost every frame, the median still contains them.
        #
        # Keeping only the target leaves exactly one person-shaped thing in the
        # frame. Same clip, same frames: conf 0.89–0.96 on the right person
        # throughout, for both people. The black background costs nothing —
        # ViTPose crops to the box anyway.
        g["keep_" + who] = {"class_type": "InvertMask", "inputs": {
            "mask": ["block_" + who, 0]}}
        g["solo_" + who] = {"class_type": "ImageCompositeMasked", "inputs": {
            "destination": ["src", 0], "source": ["black", 0], "x": 0, "y": 0,
            "resize_source": True, "mask": ["keep_" + who, 0]}}
        # Saved because it is the only way to see *what the pose detector saw*
        # when a pose stream comes out wrong.
        g["save_solo_" + who] = _save(["solo_" + who, 0],
                                      "%s_solo_%s" % (prefix, who), fps)
        _detect(g, who, ["solo_" + who, 0], width, height, fps, prefix)

    # P1 replaces A against the original driving video; P2 replaces B against
    # P1's output, which is what carries A through the second pass.
    model = model_edge(distill)
    _pass(g, "a", ref_a, ["src", 0], width, height, length, seed, fps, prefix,
          model, cfg, mask=["block_a", 0], ref_fit=ref_fit)
    _pass(g, "b", ref_b, ["out_a", 0], width, height, length, seed, fps, prefix,
          model, cfg, mask=["block_b", 0], ref_fit=ref_fit)
    return g


def preprocess(*args, **kw):
    """P0 alone — masks, poses and face crops, no sampling.

    Worth its own command: it is the half that runs on CPU, it is what decides
    whether the two people stay separated during contact, and it can be looked
    at (and timed) without the 17 GB of Animate weights being present.
    """
    g = couple(*args, **kw)
    for key in list(g):
        if key.split("_")[0] in ("ref", "wan", "noise", "guider", "sample",
                                 "trim", "out", "unet", "lora", "clip", "pos",
                                 "neg", "vae", "sigmas", "sampler"):
            g.pop(key)
    g.pop("save_out_a", None)
    g.pop("save_out_b", None)
    return g

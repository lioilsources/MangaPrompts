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
with the *other* person painted black; the largest box is then trivially the
right one. Seeding is manual: one positive point per person on the first frame,
which SAM2's video segmentor propagates through the clip.
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

PROMPT = ("two people, natural skin texture, soft light, photorealistic, "
          "sharp focus, stable camera")


def _resize(src, width, height):
    """Letterboxed resize to a multiple of 16 — Animate requires it."""
    return {"class_type": "ImageResizeKJv2", "inputs": {
        "image": src, "width": width, "height": height, "upscale_method": "lanczos",
        "keep_proportion": "pad_edge_pixel", "pad_color": "0, 0, 0",
        "crop_position": "top", "divisible_by": 16}}


def _save(src, prefix, fps):
    return {"class_type": "VHS_VideoCombine", "inputs": {
        "images": src, "frame_rate": fps, "loop_count": 0, "filename_prefix": prefix,
        "format": "video/h264-mp4", "pingpong": False, "save_output": True}}


def _loaders(steps, distill, relight, prompt):
    """Everything shared by both passes. Both passes reuse one model, one text
    encoding and one VAE — loading them twice would dominate the measurement."""
    return {
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
        "sampler": {"class_type": "KSamplerSelect", "inputs": {"sampler_name": SAMPLER}},
        "sigmas": {"class_type": "BasicScheduler", "inputs": {
            "model": ["lora_distill", 0], "scheduler": SCHEDULER,
            "steps": steps, "denoise": 1.0}},
    }


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
          mask=None):
    """One Animate pass. Without `mask` this is Move mode (one person, whole
    frame); with it, Mix mode (replace the masked person, keep the rest)."""
    g["ref_" + who] = {"class_type": "LoadImage", "inputs": {"image": ref_image}}
    g["ref_fit_" + who] = _resize(["ref_" + who, 0], width, height)
    wan = {"positive": ["pos", 0], "negative": ["neg", 0], "vae": ["vae", 0],
           "width": width, "height": height, "length": length, "batch_size": 1,
           "continue_motion_max_frames": 5, "video_frame_offset": 0,
           "reference_image": ["ref_fit_" + who, 0],
           "face_video": ["pose_" + who, 1], "pose_video": ["draw_" + who, 0]}
    if mask is not None:
        wan["background_video"] = background
        wan["character_mask"] = mask
    g["wan_" + who] = {"class_type": "WanAnimateToVideo", "inputs": wan}
    g["noise_" + who] = {"class_type": "RandomNoise", "inputs": {"noise_seed": seed}}
    g["guider_" + who] = {"class_type": "CFGGuider", "inputs": {
        "model": ["lora_distill", 0], "positive": ["wan_" + who, 0],
        "negative": ["wan_" + who, 1], "cfg": CFG}}
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
         relight=RELIGHT_STRENGTH, prompt=PROMPT):
    """S2 — Move mode, one person, no mask. The cheapest thing that answers
    "how long does this machine take per clip", which every later decision
    depends on (docs/couple-spark-setup.md §4)."""
    g = _loaders(steps, distill, relight, prompt)
    g["load"] = _video(video, length, fps)
    g["src"] = _resize(["load", 0], width, height)
    g["onnx"] = {"class_type": "OnnxDetectionModelLoader", "inputs": {
        "vitpose_model": VITPOSE, "yolo_model": YOLO, "onnx_device": ONNX_DEVICE}}
    _detect(g, "a", ["src", 0], width, height, fps, prefix)
    _pass(g, "a", reference, None, width, height, length, seed, fps, prefix)
    return g


def couple(video, ref_a, ref_b, point_a, point_b, width=832, height=480,
           length=77, seed=42, fps=16.0, prefix="couple", steps=STEPS,
           distill=DISTILL_STRENGTH, relight=RELIGHT_STRENGTH, prompt=PROMPT):
    """S3 — the test that decides whether this card can exist locally.

    `point_a` / `point_b` are (x, y) on the first frame **in the resized
    frame's coordinates**: one click on each person, which SAM2 propagates.
    """
    g = _loaders(steps, distill, relight, prompt)
    g["load"] = _video(video, length, fps)
    g["src"] = _resize(["load", 0], width, height)
    g["sam2"] = {"class_type": "DownloadAndLoadSAM2Model", "inputs": {
        "model": SAM2, "segmentor": "video", "device": "cuda", "precision": "fp16"}}
    g["black"] = {"class_type": "EmptyImage", "inputs": {
        "width": width, "height": height, "batch_size": 1, "color": 0}}
    g["onnx"] = {"class_type": "OnnxDetectionModelLoader", "inputs": {
        "vitpose_model": VITPOSE, "yolo_model": YOLO, "onnx_device": ONNX_DEVICE}}

    for who, point in (("a", point_a), ("b", point_b)):
        g["seg_" + who] = {"class_type": "Sam2Segmentation", "inputs": {
            "sam2_model": ["sam2", 0], "image": ["src", 0], "keep_model_loaded": True,
            "coordinates_positive": json.dumps([{"x": int(point[0]), "y": int(point[1])}]),
            "individual_objects": False}}
        # The mask Animate gets: grown and blurred so the seam has room, then
        # blockified onto the latent grid, as in Kijai's reference workflow.
        g["grow_" + who] = {"class_type": "GrowMaskWithBlur", "inputs": {
            "mask": ["seg_" + who, 0], "expand": 10, "incremental_expandrate": 0.0,
            "tapered_corners": True, "flip_input": False, "blur_radius": 1.0,
            "lerp_alpha": 1.0, "decay_factor": 1.0, "fill_holes": False}}
        g["block_" + who] = {"class_type": "BlockifyMask", "inputs": {
            "masks": ["grow_" + who, 0], "block_size": 32}}
        g["maskimg_" + who] = {"class_type": "MaskToImage", "inputs": {
            "mask": ["block_" + who, 0]}}
        g["save_mask_" + who] = _save(["maskimg_" + who, 0],
                                      "%s_mask_%s" % (prefix, who), fps)

    for who, other in (("a", "b"), ("b", "a")):
        # Paint the other person black so the single-person detector cannot
        # wander onto them. Black, not blurred: YOLO still finds a blurred body.
        g["solo_" + who] = {"class_type": "ImageCompositeMasked", "inputs": {
            "destination": ["src", 0], "source": ["black", 0], "x": 0, "y": 0,
            "resize_source": True, "mask": ["seg_" + other, 0]}}
        _detect(g, who, ["solo_" + who, 0], width, height, fps, prefix)

    # P1 replaces A against the original driving video; P2 replaces B against
    # P1's output, which is what carries A through the second pass.
    _pass(g, "a", ref_a, ["src", 0], width, height, length, seed, fps, prefix,
          mask=["block_a", 0])
    _pass(g, "b", ref_b, ["out_a", 0], width, height, length, seed, fps, prefix,
          mask=["block_b", 0])
    return g

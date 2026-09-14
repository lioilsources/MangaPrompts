"""ComfyUI nodes for Tsumiki's graphs (MangaPrompts assets/comfyui)."""

from __future__ import annotations

import logging

import numpy as np
import torch

from .align import estimate, warp

log = logging.getLogger("tsumiki")


class TsumikiAlignToReference:
    """Warps an edited image onto the source it was edited from, matching only
    outside `mask` (the part the edit was told to keep). Without enough
    agreement it passes the image through unchanged and says so in the log."""

    CATEGORY = "tsumiki"
    RETURN_TYPES = ("IMAGE",)
    FUNCTION = "align"

    @classmethod
    def INPUT_TYPES(cls):
        return {
            "required": {"image": ("IMAGE",), "reference": ("IMAGE",)},
            "optional": {"mask": ("MASK", {"tooltip": "1 = edited region, excluded from matching"})},
        }

    def align(self, image, reference, mask=None):
        if image.shape[1:3] != reference.shape[1:3]:
            raise ValueError(f"image {tuple(image.shape)} and reference {tuple(reference.shape)} differ in size")
        out = []
        for i in range(image.shape[0]):
            ed = (image[i].clamp(0, 1).cpu().numpy() * 255).round().astype(np.uint8)
            ref = (reference[min(i, reference.shape[0] - 1)].clamp(0, 1).cpu().numpy() * 255).round().astype(np.uint8)
            keep = None
            if mask is not None:
                m = mask[min(i, mask.shape[0] - 1)].cpu().numpy()
                if m.shape == ref.shape[:2]:
                    keep = m < 0.5
            a = estimate(ed, ref, keep)
            log.info("TsumikiAlignToReference: %s", a.describe())
            out.append(torch.from_numpy(warp(ed, ref, a).astype(np.float32) / 255.0))
        return (torch.stack(out).to(image.device),)


NODE_CLASS_MAPPINGS = {"TsumikiAlignToReference": TsumikiAlignToReference}
NODE_DISPLAY_NAME_MAPPINGS = {"TsumikiAlignToReference": "Align to reference (Tsumiki)"}

"""Put an edited image back onto its source frame.

FLUX Kontext re-frames what it edits: on the Hairdresser's portraits the head
came back 38–72 px higher and up to 4 % smaller (docs/hair-matrix.md, round 2).
Composited over the source through a hair mask, that shift shows as a doubled
collar and a band of the old hairline across the forehead. The kept region
(outside the mask: face, clothes) is the same content in both images, so a
similarity transform matched there undoes the re-framing.

numpy + OpenCV only, so it is testable without torch or a GPU.
"""

from __future__ import annotations

from dataclasses import dataclass

import cv2
import numpy as np

MIN_INLIERS = 12
MAX_SCALE_DEV = 0.15  # larger than any re-framing measured; beyond it the match is wrong
MAX_ROTATION_DEG = 4.0
RANSAC_PX = 3.0
RATIO = 0.75
MASK_ERODE_PX = 8  # keep features off the mask edge, where the edit bleeds


@dataclass
class Alignment:
    matrix: np.ndarray  # 2x3, edit → reference
    inliers: int
    scale: float
    rotation_deg: float
    applied: bool
    reason: str = ""

    def describe(self) -> str:
        m = self.matrix
        return (
            f"{'aligned' if self.applied else 'kept as is'}: scale {self.scale:.4f}, "
            f"rot {self.rotation_deg:.2f}°, shift ({m[0, 2]:.1f}, {m[1, 2]:.1f}) px, "
            f"{self.inliers} inliers{' — ' + self.reason if self.reason else ''}"
        )


IDENTITY = np.array([[1.0, 0.0, 0.0], [0.0, 1.0, 0.0]])


def _gray(rgb: np.ndarray) -> np.ndarray:
    return cv2.cvtColor(np.ascontiguousarray(rgb), cv2.COLOR_RGB2GRAY)


def estimate(edit: np.ndarray, reference: np.ndarray, keep: np.ndarray | None = None) -> Alignment:
    """Similarity transform mapping `edit` onto `reference` (both HxWx3 uint8,
    same size), matched only where `keep` (HxW bool) is True."""
    if edit.shape != reference.shape:
        raise ValueError(f"edit {edit.shape} and reference {reference.shape} differ")
    roi = None
    if keep is not None:
        k = keep.astype(np.uint8) * 255
        if MASK_ERODE_PX:
            k = cv2.erode(k, np.ones((2 * MASK_ERODE_PX + 1,) * 2, np.uint8))
        roi = k
    sift = cv2.SIFT_create()
    k_ref, d_ref = sift.detectAndCompute(_gray(reference), roi)
    k_ed, d_ed = sift.detectAndCompute(_gray(edit), roi)
    if d_ref is None or d_ed is None or len(k_ref) < 2 or len(k_ed) < 2:
        return Alignment(IDENTITY, 0, 1.0, 0.0, False, "no features")
    pairs = cv2.BFMatcher().knnMatch(d_ed, d_ref, k=2)
    good = [p[0] for p in pairs if len(p) == 2 and p[0].distance < RATIO * p[1].distance]
    if len(good) < MIN_INLIERS:
        return Alignment(IDENTITY, len(good), 1.0, 0.0, False, "too few matches")
    src = np.float32([k_ed[m.queryIdx].pt for m in good])
    dst = np.float32([k_ref[m.trainIdx].pt for m in good])
    matrix, inl = cv2.estimateAffinePartial2D(
        src, dst, method=cv2.RANSAC, ransacReprojThreshold=RANSAC_PX, maxIters=4000, confidence=0.995
    )
    if matrix is None:
        return Alignment(IDENTITY, 0, 1.0, 0.0, False, "no consistent transform")
    inliers = int(inl.sum())
    scale = float(np.hypot(matrix[0, 0], matrix[1, 0]))
    rotation = float(np.degrees(np.arctan2(matrix[1, 0], matrix[0, 0])))
    if inliers < MIN_INLIERS:
        return Alignment(matrix, inliers, scale, rotation, False, "too few inliers")
    if abs(scale - 1) > MAX_SCALE_DEV or abs(rotation) > MAX_ROTATION_DEG:
        return Alignment(matrix, inliers, scale, rotation, False, "implausible transform")
    return Alignment(matrix, inliers, scale, rotation, True)


def warp(edit: np.ndarray, reference: np.ndarray, alignment: Alignment) -> np.ndarray:
    """`edit` in the reference frame. The strip the shift uncovers repeats the
    edit's own border: filled from the reference it brought the old hair's
    crown back above the new cut."""
    if not alignment.applied:
        return edit
    h, w = reference.shape[:2]
    return cv2.warpAffine(edit, alignment.matrix, (w, h), flags=cv2.INTER_LANCZOS4, borderMode=cv2.BORDER_REPLICATE)

#!/usr/bin/env python3
"""generate_mattes.py — foreground/background separation for the photo shaders.

For every photo shader in vj/manifest.json, run rembg on its source image to
produce a foreground alpha matte (white = foreground). Saved next to the image as
<name>.matte.png and recorded back into manifest.json under each entry's "matte".

The VJ rig binds this as iMatte (iChannel1) so photo shaders can treat the
foreground as a separate, independently-animated layer.

Run:  python vj/generate_mattes.py
"""
from __future__ import annotations
import json
from pathlib import Path
from PIL import Image
from rembg import remove, new_session

VJ = Path(__file__).resolve().parent
ROOT = VJ.parent
MANIFEST = VJ / "manifest.json"


def main() -> None:
    manifest = json.loads(MANIFEST.read_text())
    photos = [s for s in manifest["shaders"] if s["type"] == "photo" and s.get("image")]
    session = new_session("u2net")
    done = skipped = failed = 0
    for s in photos:
        img_path = ROOT / s["image"]
        matte_rel = s["image"].rsplit(".", 1)[0] + ".matte.png"
        matte_path = ROOT / matte_rel
        s["matte"] = matte_rel
        if matte_path.exists():
            skipped += 1
            continue
        try:
            src = Image.open(img_path).convert("RGB")
            mask = remove(src, session=session, only_mask=True)  # L-mode mask
            mask.save(matte_path)
            done += 1
            print(f"  matte: {s['id']}")
        except Exception as e:  # noqa: BLE001
            failed += 1
            print(f"  ! failed {s['id']}: {e}")
    MANIFEST.write_text(json.dumps(manifest, indent=2))
    print(f"\nmattes: {done} generated, {skipped} existing, {failed} failed "
          f"({len(photos)} photo shaders). manifest.json updated.")


if __name__ == "__main__":
    main()

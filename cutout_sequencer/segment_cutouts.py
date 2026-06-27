"""
segment_cutouts.py - Re-extracts cutout layers using rembg AI background removal.
For each layer PNG, runs rembg directly on the layer to get a clean subject mask.
"""
import os, json, sys
from pathlib import Path
from PIL import Image
import numpy as np
from rembg import remove, new_session

CUTOUTS_DIR = Path("cutouts")
BATCH = [
    "IMG_0398","IMG_0415","IMG_0417","IMG_0418","IMG_0419",
    "IMG_0586","IMG_0767","IMG_0824","IMG_0825","IMG_0826"
]

def process_photo(photo_id, session):
    photo_dir = CUTOUTS_DIR / photo_id
    orig_path = photo_dir / "original.jpg"
    meta_path = photo_dir / "meta.json"
    if not orig_path.exists() or not meta_path.exists():
        print(f"  [SKIP] {photo_id} missing files"); return
    meta = json.loads(meta_path.read_text())
    orig = Image.open(orig_path).convert("RGBA")
    W, H = orig.size
    orig_arr = np.array(orig)
    print(f"  Running rembg on original {W}x{H}...")
    ai_result = remove(Image.open(orig_path).convert("RGB"), session=session)
    ai_alpha = np.array(ai_result)[:, :, 3].astype(np.float32) / 255.0
    for layer in meta["layers"]:
        fn = photo_dir / layer["fileName"]
        if not fn.exists():
            print(f"  [SKIP] {layer['fileName']}"); continue
        print(f"  Layer: {layer['name']}", end=" -> ")
        layer_img = Image.open(fn).convert("RGBA")
        if layer_img.size != (W, H):
            layer_img = layer_img.resize((W, H), Image.LANCZOS)
        layer_arr = np.array(layer_img).astype(np.float32)
        ex_alpha = layer_arr[:, :, 3] / 255.0
        # Multiply existing spatial mask with AI subject mask
        combined = ex_alpha * ai_alpha
        # If layer has very low overlap with AI mask, fall back to ai_mask clipped to layer region
        if combined.max() < 0.01:
            combined = ex_alpha * 0.5 + ai_alpha * ex_alpha * 0.5
        if combined.max() < 0.005:
            combined = ex_alpha  # last resort: keep original
        # Use original photo pixels (RGBA) composited with combined alpha
        out = orig_arr.copy().astype(np.float32)
        out[:, :, 3] = np.clip(combined * 255.0, 0, 255)
        result = Image.fromarray(out.astype(np.uint8), "RGBA")
        result.save(fn)
        print(f"saved ({combined.mean()*100:.1f}% coverage)")

session = new_session("u2net")
target = sys.argv[1:] if len(sys.argv)>1 else BATCH
for pid in target:
    print(f"\n=== {pid} ===")
    try: process_photo(pid, session)
    except Exception as e: print(f"ERROR: {e}"); import traceback; traceback.print_exc()
print("\nDone!")

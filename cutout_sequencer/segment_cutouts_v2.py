"""
segment_cutouts_v2.py
Better approach: crop each layer to its bbox from old mask,
run rembg on that crop, composite back at original position.
For layers with very little alpha: run rembg on full original,
but restrict to the region where the old mask had any content.
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

def bbox_of_mask(alpha, threshold=0.05):
    """Return (y0,y1,x0,x1) bounding box of non-zero alpha, or None."""
    rows = np.any(alpha > threshold, axis=1)
    cols = np.any(alpha > threshold, axis=0)
    if not rows.any() or not cols.any():
        return None
    y0, y1 = np.where(rows)[0][[0, -1]]
    x0, x1 = np.where(cols)[0][[0, -1]]
    return int(y0), int(y1), int(x0), int(x1)

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

    # Run rembg on the full photo once
    print(f"  rembg on full image ({W}x{H})...")
    full_ai = remove(Image.open(orig_path).convert("RGB"), session=session)
    full_ai_alpha = np.array(full_ai)[:, :, 3].astype(np.float32) / 255.0

    for layer in meta["layers"]:
        fn = photo_dir / layer["fileName"]
        if not fn.exists():
            print(f"  [SKIP] {layer['fileName']}"); continue
        print(f"  Layer: {layer['name']}", end=" -> ")

        layer_img = Image.open(fn).convert("RGBA")
        if layer_img.size != (W, H):
            layer_img = layer_img.resize((W, H), Image.LANCZOS)
        old_arr = np.array(layer_img).astype(np.float32)
        old_alpha = old_arr[:, :, 3] / 255.0

        # Get bounding box of old alpha region (where the GLSL blob was)
        bb = bbox_of_mask(old_alpha, threshold=0.02)
        if bb is None:
            # No usable alpha at all — skip
            print("no alpha, using full AI mask")
            out = orig_arr.copy().astype(np.float32)
            out[:, :, 3] = np.clip(full_ai_alpha * 255.0, 0, 255)
            Image.fromarray(out.astype(np.uint8), "RGBA").save(fn)
            continue

        y0, y1, x0, x1 = bb
        # Pad bbox by 5% for context
        pad_y = max(10, int((y1-y0)*0.05))
        pad_x = max(10, int((x1-x0)*0.05))
        y0c = max(0, y0-pad_y); y1c = min(H, y1+pad_y)
        x0c = max(0, x0-pad_x); x1c = min(W, x1+pad_x)

        # Crop original to that region
        crop_orig = Image.fromarray(orig_arr[y0c:y1c, x0c:x1c, :3])
        
        # Run rembg on the crop
        crop_ai = remove(crop_orig, session=session)
        crop_ai_arr = np.array(crop_ai)
        crop_ai_alpha = crop_ai_arr[:, :, 3].astype(np.float32) / 255.0

        # Also get full-image AI alpha restricted to this region
        full_region_alpha = full_ai_alpha[y0c:y1c, x0c:x1c]

        # Combine: take max of crop-specific AI and full AI in this region
        combined_crop = np.maximum(crop_ai_alpha, full_region_alpha * 0.7)

        # Build output: use original photo pixels, alpha = combined
        out = orig_arr.copy().astype(np.float32)
        out[:, :, 3] = 0  # start transparent everywhere
        out[y0c:y1c, x0c:x1c, 3] = np.clip(combined_crop * 255.0, 0, 255)

        coverage = combined_crop.mean()
        print(f"bbox={x0}:{x1},{y0}:{y1}, crop_ai={crop_ai_alpha.mean()*100:.1f}%, coverage={coverage*100:.1f}%")
        Image.fromarray(out.astype(np.uint8), "RGBA").save(fn)

    print(f"  Done: {photo_id}")

session = new_session("u2net")
target = sys.argv[1:] if len(sys.argv)>1 else BATCH
for pid in target:
    print(f"\n=== {pid} ===")
    try: process_photo(pid, session)
    except Exception as e:
        print(f"ERROR: {e}")
        import traceback; traceback.print_exc()
print("\nAll done!")

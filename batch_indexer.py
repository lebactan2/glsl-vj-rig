import os
import json
import re
from pathlib import Path

ROOT = Path('d:/GLSL bds')
SKIP_DIRS = {'.git', 'node_modules', '__pycache__', 'layered_glsl', 'trippy_ornaments_all', 'trippy_ornaments_3_001'}
SKIP_FILES = {'index.html', 'boilerplate.html', 'layer_search.html'}

MANUAL_CLEAN_TAGS = {
    # Claude Batch (Batch 1 - 23 files)
    "IMG_0187": ["apartment", "building", "window", "grill", "ornate", "flag", "vietnamese flag", "night", "sky"],
    "IMG_0188": ["gate", "street", "lattice", "diamond", "wall", "teal", "night"],
    "IMG_4841": ["storefront", "restaurant", "glow", "green", "interior", "street"],
    "IMG_5132": ["vase", "ceramic", "branches", "kumquat", "orange", "wall", "green"],
    "IMG_5146": ["banner", "text", "vietnamese text", "trees", "orange trees", "red"],
    "IMG_5373": ["porcelain", "mosaic", "window", "double happiness", "frame", "temple", "maroon", "blue", "white"],
    "IMG_5527": ["steel", "armor", "sculpture", "wall", "gallery", "riveted"],
    "IMG_5577": ["plaque", "bamboo", "crane", "blossom", "engraving", "gold"],
    "IMG_5614": ["facade", "house", "colonial", "columns", "rosette", "pediment"],
    "IMG_5620": ["wood", "panels", "warehouse", "brown", "stacked"],
    "IMG_5636": ["panel", "relief", "gold", "brass", "mythological", "forge"],
    "IMG_5662": ["gate", "clouds", "pyramids", "metal", "theatrical", "red"],
    "IMG_5689": ["lantern", "paper", "festival", "bamboo", "stakes", "outdoors", "green", "red", "white"],
    "IMG_5693": ["votive", "paper", "box", "clock", "rooster", "floral", "red"],
    "IMG_5700": ["altar", "float", "boat", "foliage", "doll", "deity", "black", "gold"],
    "IMG_5702": ["shrine", "float", "figure", "deity", "attendants", "red", "gold"],
    "IMG_5715": ["branch", "silhouettes", "window", "panes", "glass", "grid", "white"],
    "IMG_5761": ["fence", "construction", "rebar", "columns", "crane", "yellow", "green"],
    "IMG_5762": ["fence", "construction", "hair", "silhouette", "woman", "green"],
    "IMG_6006": ["storefront", "awning", "sign", "banner", "green", "lunar new year"],
    "IMG_6007": ["sign", "restaurant", "roof", "numbers", "double sign", "red", "green"],
    "IMG_6291": ["fabric", "brocade", "pattern", "text", "vietnamese text", "red", "gold", "floral"],
    "IMG_6348": ["candy", "cart", "led", "stickers", "checkered", "street", "night"],

    # Codex Batch (Batch 2 - 22 files)
    "IMG_6349": ["scooter", "tote", "wall", "red", "gold", "pale"],
    "IMG_6350": ["cart", "food", "street", "box", "worker", "lamps", "night", "white", "red"],
    "IMG_6385": ["awning", "storefront", "sign", "street", "yellow", "green"],
    "IMG_6442": ["tile", "floor", "embossed", "square", "blue", "cream"],
    "IMG_6444": ["banner", "sky", "leasing", "roadside", "red", "blue"],
    "IMG_6469": ["textile", "figures", "border", "embroidered", "pastel", "black", "floral"],
    "IMG_6494": ["wheelchair", "cart", "sidewalk", "man", "tiled", "metal"],
    "IMG_6495": ["wheelchair", "cart", "shutter", "pillar", "beige", "black"],
    "IMG_6496": ["fence", "construction", "facade", "branches", "leaves", "green", "gray"],
    "IMG_6516": ["table", "chairs", "bowls", "restaurant", "night", "green", "blue"],
    "IMG_6527": ["banner", "food", "birds", "silhouettes", "yellow", "red"],
    "IMG_6529": ["board", "sign", "blossoms", "flower", "congratulation", "blue", "orange"],
    "IMG_6581": ["pickup", "road", "stickers", "skyline", "black", "city"],
    "IMG_8926": ["painting", "ribbons", "shapes", "cream", "red", "blue", "orange", "abstract"],
    "IMG_8953": ["print", "cloth", "interior", "framed", "floral", "dark"],
    "IMG_9015": ["relief", "wall", "light", "driftwood", "brown", "pale", "fluorescent"],
    "IMG_9017": ["roofs", "shacks", "aerial", "metal", "pale"],
    "IMG_9031": ["wall", "grille", "window", "turquoise", "white", "decorative"],
    "IMG_9072": ["facade", "arches", "canopy", "stone", "mosaic", "glass", "gray"],
    "IMG_9074": ["shards", "cups", "ceramic", "wall", "broken", "blue", "white"],
    "IMG_9077": ["rack", "net", "bundles", "red", "blue", "white", "diamond"],
    "IMG_9078": ["rack", "net", "bundles", "red", "blue", "white", "diamond"],

    # Trippy Ornaments Batch
    "IMG_9786": ["ornament", "pattern", "geometry", "flower", "red", "gold", "black"],
    "IMG_9787": ["ornament", "pattern", "geometry", "flower", "red", "gold", "blue"],
    "IMG_9868": ["ornament", "pattern", "geometry", "mandala", "green", "gold"],
    "IMG_9869": ["ornament", "pattern", "geometry", "mandala", "purple", "gold"],

    # VJ / Utility / Helper
    "layer_viewer": [],
    "scene_6687": ["vj", "scene", "abstract", "loops", "geometry"],
    "sequencer": ["vj", "sequencer", "interface", "controls"],
}

def main():
    old_index_path = ROOT / 'moodboard_htmls' / 'search_index.json'
    old_index = {}
    if old_index_path.exists():
        with open(old_index_path, 'r', encoding='utf-8') as f:
            try:
                old_index = json.load(f)
            except Exception:
                pass

    unified_index = {}

    # First, read metadata from layered_glsl if any
    layered_dir = ROOT / 'layered_glsl'
    layer_search_index = []
    if layered_dir.exists():
        for p in layered_dir.glob('*.glsl'):
            try:
                content = p.read_text(encoding='utf-8')
                import re
                match = re.search(r'/\*\s*@layer_metadata\s*(\{.*?\})\s*\*/', content, re.DOTALL)
                if match:
                    meta = json.loads(match.group(1))
                    key = p.stem.replace('_manual', '')
                    tags = set()
                    for layer in meta.get('layers', []):
                        for kw in layer.get('keywords', []):
                            tags.add(kw.lower())
                    unified_index[key] = list(tags)
                    layer_search_index.append(meta)
            except Exception:
                pass

    for p in ROOT.rglob('*.html'):
        if any(part.startswith('.') and part != '.html' for part in p.parts): continue
        if any(skip in p.parts for skip in SKIP_DIRS): continue
        if p.name in SKIP_FILES: continue

        # The key in our unified index is the stem, e.g. 'IMG_0398'
        key = p.stem.replace('_manual', '')
        
        try:
            with open(p, 'r', encoding='utf-8') as f:
                content = f.read()
        except Exception:
            continue
            
        # Get tags for this file:
        # 1. First choice: clean keywords from layered metadata (if available)
        # 2. Second choice: manual clean scene object tags (if defined)
        # 3. Third choice: empty list (to avoid any raw variables/noise leaking as tags)
        if key in unified_index:
            unique_tags = sorted(list(set(unified_index[key])))
        elif key in MANUAL_CLEAN_TAGS:
            unique_tags = sorted(list(set(MANUAL_CLEAN_TAGS[key])))
        else:
            unique_tags = []
        
        # Store the unique tags array
        unified_index[key] = unique_tags

    out_path = ROOT / 'unified_search_index.json'
    with open(out_path, 'w', encoding='utf-8') as f:
        json.dump(unified_index, f)
        
    print(f"Generated unified index for {len(unified_index)} files at {out_path}")

if __name__ == '__main__':
    main()

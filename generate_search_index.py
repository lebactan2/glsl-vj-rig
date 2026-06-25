#!/usr/bin/env python3
"""
Parse layered GLSL files to extract `@layer_metadata` JSON blocks and build a search index.
"""

import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parent
LAYERED_GLSL_DIR = ROOT / "layered_glsl"
OUT_INDEX = ROOT / "search_index.json"

def extract_metadata(filepath: Path) -> dict | None:
    try:
        content = filepath.read_text(encoding="utf-8")
        # Look for /* @layer_metadata ... */
        match = re.search(r"/\*\s*@layer_metadata\s*(.*?)\s*\*/", content, re.DOTALL)
        if match:
            json_str = match.group(1)
            metadata = json.loads(json_str)
            metadata["filename"] = filepath.name
            return metadata
    except Exception as e:
        print(f"Error processing {filepath.name}: {e}")
    return None

def main():
    if not LAYERED_GLSL_DIR.exists():
        print(f"Directory {LAYERED_GLSL_DIR} does not exist. Run process_layers_with_llm.py first.")
        return

    index = []
    files = sorted(LAYERED_GLSL_DIR.glob("*.glsl"))
    
    print(f"Scanning {len(files)} files in {LAYERED_GLSL_DIR.name}...")
    for filepath in files:
        metadata = extract_metadata(filepath)
        if metadata:
            index.append(metadata)
            print(f"  Processed {filepath.name}")
        else:
            print(f"  No metadata found in {filepath.name}")

    with OUT_INDEX.open("w", encoding="utf-8") as f:
        json.dump(index, f, indent=2)

    print(f"\nGenerated search index with {len(index)} entries at {OUT_INDEX.relative_to(ROOT)}.")

if __name__ == "__main__":
    main()

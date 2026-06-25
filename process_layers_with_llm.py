#!/usr/bin/env python3
"""
Rewrite GLSL fragment shaders with OpenAI to separate objects into distinct layer functions
and add searchable metadata.
"""

from __future__ import annotations

import argparse
import json
import os
import re
import sys
import time
import urllib.error
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parent
DEFAULT_MODEL = "gpt-4.1"
STATE_FILE = ROOT / "layered_shaders_state.json"
OUT_GLSL_DIR = ROOT / "layered_glsl"
OUT_HTML_DIR = ROOT / "layered_htmls"
BOILERPLATE = ROOT / "moodboard_htmls" / "boilerplate.html"

SKIP_DIRS = {
    ".git",
    "node_modules",
    "animated_glsl",
    "animated_htmls",
    "layered_glsl",
    "layered_htmls",
    "screenshots_backup",
}

SYSTEM_PROMPT = """You are an expert WebGL fragment shader developer.
Rewrite the provided GLSL fragment shader so that distinct visual elements or "objects" are separated into individual layer functions.

Rules:
1. Identify the visual objects in the shader (e.g. background, specific objects, effects).
2. Create a `void layer_ObjectName(in vec2 p, inout vec3 col)` function for each object, replacing `ObjectName` with a descriptive name. If the original uses a different variable for coordinates or adds things to `col`, adapt accordingly but keep it modular.
3. In the `main()` function, call these layer functions sequentially to composite the final image in the exact same way it was originally composed.
4. Add a JSON metadata block at the top of the file wrapped in a multi-line comment: `/* @layer_metadata ... */`.
5. The JSON must have a "title" string and a "layers" array. Each layer in the array should have a "name" string and a "keywords" array of strings for word searching.
6. Return ONLY valid WebGL 1.0 fragment shader code. Do not use textures, includes, extra uniforms, markdown, prose, or comments outside the code block.
7. The available uniforms are:
   - uniform vec2 iResolution;
   - uniform float iTime;
   The wrapper already supplies precision and uniforms, so do not repeat them.

Example output format:
/*
@layer_metadata
{
  "title": "Example Shader",
  "layers": [
    {"name": "Background", "keywords": ["background", "gradient", "blue"]},
    {"name": "Main Object", "keywords": ["circle", "red", "glowing"]}
  ]
}
*/

void layer_Background(in vec2 uv, inout vec3 col) {
    // ...
}

void layer_MainObject(in vec2 uv, inout vec3 col) {
    // ...
}

void main() {
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec3 col = vec3(0.0);
    layer_Background(uv, col);
    layer_MainObject(uv, col);
    gl_FragColor = vec4(col, 1.0);
}
"""

def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Use OpenAI to separate GLSL shaders into searchable layers."
    )
    parser.add_argument("--model", default=DEFAULT_MODEL)
    parser.add_argument("--limit", type=int, default=None)
    parser.add_argument("--root", type=Path, default=ROOT)
    parser.add_argument(
        "--glob",
        action="append",
        default=None,
        help="Glob pattern relative to --root.",
    )
    parser.add_argument("--state-file", type=Path, default=STATE_FILE)
    parser.add_argument("--out-glsl-dir", type=Path, default=OUT_GLSL_DIR)
    parser.add_argument("--out-html-dir", type=Path, default=OUT_HTML_DIR)
    parser.add_argument("--force", action="store_true", help="Process files even if state says they are done.")
    parser.add_argument("--sleep", type=float, default=0.0, help="Seconds to wait between API calls.")
    return parser.parse_args()

def load_state(path: Path) -> dict:
    if not path.exists():
        return {"processed": {}}
    with path.open("r", encoding="utf-8") as f:
        data = json.load(f)
    data.setdefault("processed", {})
    return data

def save_state(path: Path, state: dict) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    tmp = path.with_suffix(path.suffix + ".tmp")
    with tmp.open("w", encoding="utf-8") as f:
        json.dump(state, f, indent=2, sort_keys=True)
        f.write("\n")
    tmp.replace(path)

def is_skipped(path: Path, root: Path) -> bool:
    try:
        rel_parts = path.relative_to(root).parts
    except ValueError:
        return True
    return any(part in SKIP_DIRS for part in rel_parts)

def discover_glsl(root: Path, patterns: list[str] | None) -> list[Path]:
    if patterns:
        files: list[Path] = []
        for pattern in patterns:
            files.extend(root.glob(pattern))
    else:
        files = list(root.rglob("*.glsl"))
    return sorted(
        p for p in files if p.is_file() and not is_skipped(p, root)
    )

def output_glsl_path(source: Path, args: argparse.Namespace) -> Path:
    rel = source.relative_to(args.root)
    return args.out_glsl_dir / rel

def output_html_path(source: Path, args: argparse.Namespace) -> Path:
    stem = source.stem
    rel_parent = source.relative_to(args.root).parent
    if rel_parent.name.lower() == "glsl":
        rel_parent = rel_parent.parent
    return args.out_html_dir / rel_parent / f"{stem}.html"

def build_prompt(path: Path, shader: str) -> str:
    return f"""Shader file: {path.as_posix()}

Rewrite this shader into distinct layer functions with @layer_metadata JSON block at the top. Keep it compilable in the existing project wrapper and output only GLSL code:

```glsl
{shader}
```
"""

def call_openai(model: str, prompt: str, api_key: str) -> str:
    payload = {
        "model": model,
        "input": [
            {
                "role": "system",
                "content": [{"type": "input_text", "text": SYSTEM_PROMPT}],
            },
            {
                "role": "user",
                "content": [{"type": "input_text", "text": prompt}],
            },
        ],
    }
    req = urllib.request.Request(
        "https://api.openai.com/v1/responses",
        data=json.dumps(payload).encode("utf-8"),
        headers={
            "Authorization": f"Bearer {api_key}",
            "Content-Type": "application/json",
        },
        method="POST",
    )
    try:
        with urllib.request.urlopen(req, timeout=120) as resp:
            response = json.loads(resp.read().decode("utf-8"))
    except urllib.error.HTTPError as exc:
        body = exc.read().decode("utf-8", errors="replace")
        raise RuntimeError(f"OpenAI API error {exc.code}: {body}") from exc

    text = response.get("output_text")
    if text:
        return text

    chunks: list[str] = []
    for item in response.get("output", []):
        for content in item.get("content", []):
            if content.get("type") in {"output_text", "text"} and content.get("text"):
                chunks.append(content["text"])
    if chunks:
        return "\n".join(chunks)
    raise RuntimeError("OpenAI response did not contain output text.")

def extract_glsl(text: str) -> str:
    fenced = re.search(r"```(?:glsl)?\s*(.*?)```", text, re.DOTALL | re.IGNORECASE)
    code = fenced.group(1) if fenced else text
    code = code.strip()
    if "void main" not in code or "gl_FragColor" not in code:
        raise ValueError("Model output does not look like a complete fragment shader.")
    code = re.sub(r"^\s*precision\s+\w+\s+float\s*;\s*", "", code)
    code = re.sub(r"^\s*uniform\s+vec2\s+iResolution\s*;\s*", "", code)
    code = re.sub(r"^\s*uniform\s+float\s+iTime\s*;\s*", "", code)
    return code.strip() + "\n"

def render_html(title: str, glsl: str) -> str:
    template = BOILERPLATE.read_text(encoding="utf-8")
    return template.replace("{TITLE}", f"Shader: {title}").replace("{GLSL_CONTENT}", glsl)

def process_file(path: Path, args: argparse.Namespace, state: dict, api_key: str) -> None:
    rel = path.relative_to(args.root).as_posix()
    if not args.force and rel in state["processed"]:
        print(f"skip processed {rel}")
        return

    original = path.read_text(encoding="utf-8")
    prompt = build_prompt(path.relative_to(args.root), original)
    response_text = call_openai(args.model, prompt, api_key)
    rewritten = extract_glsl(response_text)

    out_glsl = output_glsl_path(path, args)
    out_glsl.parent.mkdir(parents=True, exist_ok=True)
    out_glsl.write_text(rewritten, encoding="utf-8")

    out_html = output_html_path(path, args)
    out_html.parent.mkdir(parents=True, exist_ok=True)
    out_html.write_text(render_html(path.stem, rewritten), encoding="utf-8")

    state["processed"][rel] = {
        "model": args.model,
        "source": str(path),
        "glsl": str(out_glsl),
        "html": str(out_html),
        "processed_at": int(time.time()),
    }
    save_state(args.state_file, state)
    print(f"processed {rel} -> {out_glsl}")

def main() -> int:
    args = parse_args()
    args.root = args.root.resolve()
    args.state_file = args.state_file.resolve()
    args.out_glsl_dir = args.out_glsl_dir.resolve()
    args.out_html_dir = args.out_html_dir.resolve()

    files = discover_glsl(args.root, args.glob)
    if args.limit is not None:
        files = files[: args.limit]

    print(f"selected {len(files)} shader(s)")
    for path in files:
        print(f"  {path.relative_to(args.root).as_posix()}")

    api_key = os.environ.get("OPENAI_API_KEY")
    if not api_key:
        print("OPENAI_API_KEY is not set. Set it before running API mode.", file=sys.stderr)
        return 2

    state = load_state(args.state_file)
    for index, path in enumerate(files, start=1):
        print(f"[{index}/{len(files)}] {path.relative_to(args.root).as_posix()}")
        process_file(path, args, state, api_key)
        if args.sleep and index < len(files):
            time.sleep(args.sleep)
    return 0

if __name__ == "__main__":
    raise SystemExit(main())

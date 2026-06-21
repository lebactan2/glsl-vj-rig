#!/usr/bin/env python3
"""
Rewrite GLSL fragment shaders with OpenAI and regenerate preview HTML.

Defaults are intentionally safe:
- writes rewritten shaders under animated_glsl/
- writes matching preview HTML under animated_htmls/
- tracks completed files in processed_shaders.json

Use --in-place only when you are ready to overwrite existing .glsl files.
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
STATE_FILE = ROOT / "processed_shaders.json"
OUT_GLSL_DIR = ROOT / "animated_glsl"
OUT_HTML_DIR = ROOT / "animated_htmls"
BOILERPLATE = ROOT / "moodboard_htmls" / "boilerplate.html"

SKIP_DIRS = {
    ".git",
    "node_modules",
    "animated_glsl",
    "animated_htmls",
    "screenshots_backup",
}


SYSTEM_PROMPT = """You are an expert WebGL fragment shader developer.
Rewrite the provided GLSL fragment shader so it has bespoke, tasteful animation
using the existing iTime uniform. Preserve the original mood, visual structure,
dominant colors, and recognizable pattern language. Return only valid WebGL 1.0
fragment shader code that includes exactly one void main() function. Do not use
textures, includes, extra uniforms, markdown, prose, or comments outside code.
The available uniforms are:
- uniform vec2 iResolution;
- uniform float iTime;
The wrapper already supplies precision and uniforms, so do not repeat them.
"""


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Use OpenAI to add bespoke iTime animation to GLSL shaders."
    )
    parser.add_argument("--model", default=DEFAULT_MODEL)
    parser.add_argument("--limit", type=int, default=None)
    parser.add_argument("--root", type=Path, default=ROOT)
    parser.add_argument(
        "--glob",
        action="append",
        default=None,
        help="Glob pattern relative to --root. Can be repeated. Defaults to all .glsl outside skipped dirs.",
    )
    parser.add_argument("--state-file", type=Path, default=STATE_FILE)
    parser.add_argument("--out-glsl-dir", type=Path, default=OUT_GLSL_DIR)
    parser.add_argument("--out-html-dir", type=Path, default=OUT_HTML_DIR)
    parser.add_argument("--in-place", action="store_true")
    parser.add_argument("--force", action="store_true", help="Process files even if state says they are done.")
    parser.add_argument("--dry-run", action="store_true", help="List selected files without calling the API.")
    parser.add_argument("--no-html", action="store_true", help="Skip preview HTML generation.")
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
    if args.in_place:
        return source
    rel = source.relative_to(args.root)
    return args.out_glsl_dir / rel


def output_html_path(source: Path, args: argparse.Namespace) -> Path:
    stem = source.stem
    if args.in_place:
        parent = source.parent
        if parent.name.lower() == "glsl" and parent.parent.name:
            return parent.parent / f"{stem}.html"
        return args.root / "moodboard_htmls" / f"{stem}.html"
    rel_parent = source.relative_to(args.root).parent
    if rel_parent.name.lower() == "glsl":
        rel_parent = rel_parent.parent
    return args.out_html_dir / rel_parent / f"{stem}.html"


def build_prompt(path: Path, shader: str) -> str:
    return f"""Shader file: {path.as_posix()}

Rewrite this shader with bespoke animation. Keep it compilable in the existing
project wrapper and output only GLSL code:

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

    out_html = None
    if not args.no_html:
        out_html = output_html_path(path, args)
        out_html.parent.mkdir(parents=True, exist_ok=True)
        out_html.write_text(render_html(path.stem, rewritten), encoding="utf-8")

    state["processed"][rel] = {
        "model": args.model,
        "source": str(path),
        "glsl": str(out_glsl),
        "html": str(out_html) if out_html else None,
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

    if args.dry_run:
        return 0

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

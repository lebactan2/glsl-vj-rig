#!/usr/bin/env python3
from __future__ import annotations

import colorsys
import hashlib
import math
from dataclasses import dataclass
from pathlib import Path

from PIL import Image, ImageOps
from pillow_heif import register_heif_opener


ROOT = Path(__file__).resolve().parent

BATCHES = [
    {
        "title": "Trippy Ornaments",
        "source": ROOT / "Trippy Ornaments",
        "output": ROOT / "moodboard_htmls" / "trippy_ornaments_all",
    },
    {
        "title": "Trippy Ornaments 3-001",
        "source": ROOT / "Trippy Ornaments-3-001" / "Trippy Ornaments",
        "output": ROOT / "moodboard_htmls" / "trippy_ornaments_all",
    },
]

IMAGE_EXTS = {".jpg", ".jpeg", ".png", ".webp", ".heic"}


@dataclass
class ImageStats:
    palette: list[tuple[float, float, float]]
    brightness: float
    saturation: float
    contrast: float
    warmness: float
    width: int
    height: int


def stable_seed(text: str) -> int:
    return int(hashlib.sha256(text.encode("utf-8")).hexdigest()[:16], 16)


def clamp01(value: float) -> float:
    return max(0.0, min(1.0, value))


def fmt(value: float) -> str:
    return f"{value:.4f}"


def vec3(color: tuple[float, float, float]) -> str:
    return f"vec3({fmt(color[0])}, {fmt(color[1])}, {fmt(color[2])})"


def load_image(path: Path) -> Image.Image:
    img = Image.open(path)
    img = ImageOps.exif_transpose(img)
    return img.convert("RGB")


def crop_square(img: Image.Image) -> Image.Image:
    side = min(img.size)
    left = (img.width - side) // 2
    top = (img.height - side) // 2
    return img.crop((left, top, left + side, top + side))


def fallback_palette(seed: int) -> list[tuple[float, float, float]]:
    colors = []
    for i in range(5):
        h = (((seed >> (i * 9)) & 511) / 511.0 + i * 0.137) % 1.0
        s = 0.48 + 0.34 * (((seed >> (i * 5 + 3)) & 31) / 31.0)
        v = 0.45 + 0.43 * (((seed >> (i * 7 + 1)) & 31) / 31.0)
        colors.append(colorsys.hsv_to_rgb(h, s, v))
    return colors


def analyze_image(img: Image.Image, seed: int) -> ImageStats:
    sample = crop_square(img).resize((96, 96), Image.Resampling.LANCZOS)
    quantized = sample.quantize(colors=6, method=Image.Quantize.MEDIANCUT)
    palette_raw = quantized.getpalette() or []
    counts = sorted(quantized.getcolors(96 * 96) or [], reverse=True)

    colors: list[tuple[float, float, float]] = []
    for count, index in counts:
        base = index * 3
        if base + 2 >= len(palette_raw):
            continue
        r, g, b = palette_raw[base], palette_raw[base + 1], palette_raw[base + 2]
        color = (r / 255.0, g / 255.0, b / 255.0)
        if max(color) - min(color) > 0.015 or not colors:
            colors.append(color)
        if len(colors) >= 5:
            break

    for color in fallback_palette(seed):
        if len(colors) >= 5:
            break
        colors.append(color)

    if hasattr(sample, "get_flattened_data"):
        pixels = list(sample.get_flattened_data())
    else:
        pixels = list(sample.getdata())
    luminances = []
    saturations = []
    warm_delta = []
    for r8, g8, b8 in pixels:
        r, g, b = r8 / 255.0, g8 / 255.0, b8 / 255.0
        lum = 0.2126 * r + 0.7152 * g + 0.0722 * b
        luminances.append(lum)
        h, s, v = colorsys.rgb_to_hsv(r, g, b)
        saturations.append(s)
        warm_delta.append(r - b)

    mean_lum = sum(luminances) / len(luminances)
    variance = sum((v - mean_lum) ** 2 for v in luminances) / len(luminances)
    mean_sat = sum(saturations) / len(saturations)
    mean_warm = sum(warm_delta) / len(warm_delta)

    return ImageStats(
        palette=colors[:5],
        brightness=mean_lum,
        saturation=mean_sat,
        contrast=math.sqrt(variance),
        warmness=mean_warm,
        width=img.width,
        height=img.height,
    )


def save_preview(img: Image.Image, path: Path) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    preview = img.copy()
    preview.thumbnail((1400, 1400), Image.Resampling.LANCZOS)
    preview.save(path, "JPEG", quality=88, optimize=True)


def shader_for(name: str, stats: ImageStats, batch_title: str) -> str:
    seed = stable_seed(f"{batch_title}:{name}")
    palette = stats.palette
    sector = 5 + (seed % 8)
    rings = 10.0 + ((seed >> 4) % 10) * 1.4
    twist = 0.45 + ((seed >> 9) % 100) / 95.0
    bead_count = 12.0 + ((seed >> 15) % 16)
    pulse = 0.18 + stats.saturation * 0.42
    overlay = 0.18 + stats.saturation * 0.26
    warp = 0.006 + stats.contrast * 0.035
    edge_gain = 0.35 + stats.contrast * 1.15
    warmth = 0.45 + clamp01((stats.warmness + 0.35) / 0.7) * 0.35
    variant = seed % 5

    c1, c2, c3, c4, c5 = [vec3(color) for color in palette]

    if variant == 0:
        motif = """
    float ornament = sin(k.x * 15.0 + petals * 2.0 + t * 1.5) *
                     cos(k.y * 17.0 - ringWave * 0.3 - t);
    float inlay = smoothstep(0.52, 0.96, ornament);
    patternColor = mix(patternColor, c3, inlay * 0.75);
    mask = max(mask, inlay * 0.55);
    mask = max(mask, smoothstep(0.020, 0.0, abs(fract(r * 7.0 - t * 0.10) - 0.5)) * 0.45);
"""
    elif variant == 1:
        motif = """
    vec2 tile = fract(k * 5.0 + vec2(t * 0.06, -t * 0.04)) - 0.5;
    float clover = cos(atan(tile.y, tile.x) * 4.0) * 0.16 + 0.24 - length(tile);
    float lead = smoothstep(0.018, 0.0, abs(clover));
    patternColor = mix(patternColor, c3, smoothstep(0.0, 0.08, clover) * 0.80);
    patternColor = mix(patternColor, c5, lead * 0.90);
    mask = max(mask, smoothstep(0.0, 0.08, clover) * 0.50 + lead * 0.30);
"""
    elif variant == 2:
        motif = """
    float braid = sin((k.x + k.y) * 22.0 + t * 1.4) + sin((k.x - k.y) * 20.0 - t * 1.1);
    float thread = smoothstep(1.05, 1.85, braid + petals * 0.45);
    float stitch = smoothstep(0.025, 0.0, abs(sin(a * 18.0 + r * 20.0 - t * 1.8)));
    patternColor = mix(patternColor, c3, thread * 0.78);
    patternColor += c5 * stitch * 0.25;
    mask = max(mask, thread * 0.55 + stitch * 0.24);
"""
    elif variant == 3:
        motif = """
    float liquid = sin(k.x * 10.0 + sin(k.y * 6.0 + t) * 2.0 + t * 1.7);
    float islands = smoothstep(0.16, 0.86, liquid + petals * 0.38);
    float rim = smoothstep(0.045, 0.0, abs(liquid + petals * 0.38 - 0.22));
    patternColor = mix(patternColor, c3, islands * 0.72);
    patternColor = mix(patternColor, c5, rim * 0.65);
    mask = max(mask, islands * 0.46 + rim * 0.32);
"""
    else:
        motif = """
    float scallop = sin((r * 18.0 - t * 2.0) + cos(a * segments) * 1.8);
    float enamel = smoothstep(0.18, 0.84, scallop + lattice * 0.55);
    float pin = smoothstep(0.025, 0.0, abs(sin(a * 30.0 + t) * 0.5 + cos(r * 28.0 - t * 1.3) * 0.5));
    patternColor = mix(patternColor, c3, enamel * 0.68);
    patternColor = mix(patternColor, c5, pin * 0.52);
    mask = max(mask, enamel * 0.46 + pin * 0.28);
"""

    return f"""uniform sampler2D iChannel0;
uniform vec2 iImageResolution;

mat2 rot(float a) {{
    float s = sin(a);
    float c = cos(a);
    return mat2(c, -s, s, c);
}}

vec2 coverUv(vec2 uv, vec2 canvas, vec2 image) {{
    float canvasAspect = canvas.x / canvas.y;
    float imageAspect = image.x / image.y;
    vec2 scale = canvasAspect > imageAspect
        ? vec2(1.0, canvasAspect / imageAspect)
        : vec2(imageAspect / canvasAspect, 1.0);
    return (uv - 0.5) * scale + 0.5;
}}

float luma(vec3 c) {{
    return dot(c, vec3(0.2126, 0.7152, 0.0722));
}}

void main() {{
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 texUv = coverUv(uv, iResolution, iImageResolution);
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    float t = iTime * {fmt(pulse)};
    vec2 photoP = texUv - 0.5;
    float r = length(p);
    float a = atan(p.y, p.x);
    float segments = {fmt(float(sector))};
    float slice = 6.2831853 / segments;
    float ma = abs(mod(a + slice * 0.5 + sin(t) * 0.025, slice) - slice * 0.5);
    vec2 k = vec2(cos(ma), sin(ma)) * r;
    k += 0.035 * vec2(sin(k.y * 8.0 + t * 2.2), cos(k.x * 7.0 - t * 1.8));

    float ringWave = sin(r * {fmt(rings)} - t * 3.0);
    float petals = cos(ma * {fmt(float(sector * 2))} + r * {fmt(twist * 5.0)} + sin(t + r * 2.0));
    float lattice = sin((k.x + k.y) * {fmt(18.0 + stats.saturation * 18.0)}) *
                    sin((k.x - k.y) * {fmt(16.0 + stats.contrast * 42.0)});
    float bead = smoothstep(0.86, 0.99, cos(ma * {fmt(bead_count)} - t * 2.4)) *
                 smoothstep(0.035, 0.0, abs(fract(r * {fmt(4.0 + stats.brightness * 7.5)} - t * 0.18) - 0.5));

    vec2 warp = vec2(
        sin(k.y * {fmt(7.0 + stats.saturation * 8.0)} + t * 1.8 + petals),
        cos(k.x * {fmt(6.0 + stats.contrast * 16.0)} - t * 1.6 + ringWave)
    ) * {fmt(warp)};
    vec2 sampleUv = clamp(texUv + warp * smoothstep(1.35, 0.05, r), 0.001, 0.999);
    vec3 photo = texture2D(iChannel0, sampleUv).rgb;
    vec3 photoSoft = texture2D(iChannel0, clamp(texUv + warp * 2.5, 0.001, 0.999)).rgb;

    vec3 c1 = {c1};
    vec3 c2 = {c2};
    vec3 c3 = {c3};
    vec3 c4 = {c4};
    vec3 c5 = {c5};

    vec3 patternColor = mix(c1, c2, smoothstep(-0.55, 0.70, ringWave + petals * 0.34));
    patternColor = mix(patternColor, c4, smoothstep(0.15, 0.92, lattice));
    float mask = 0.10 + smoothstep(0.78, 0.98, abs(lattice)) * 0.18;
{motif}
    mask = max(mask, bead * 0.42);

    float edge = length(photo - photoSoft) * {fmt(edge_gain)};
    mask *= smoothstep(1.28, 0.02, r);
    mask *= 0.65 + smoothstep(0.05, 0.38, edge + abs(luma(photo) - {fmt(stats.brightness)}) * 0.35);

    vec3 tintedPhoto = mix(photo.bgr, photo, {fmt(warmth)});
    vec3 col = mix(tintedPhoto, patternColor, clamp(mask * {fmt(overlay)}, 0.0, 0.42));
    col += c5 * bead * {fmt(0.08 + stats.saturation * 0.13)};
    col += vec3(1.0, 0.95, 0.82) * smoothstep(0.96, 1.0, sin(r * 42.0 - t * 7.0 + petals)) * 0.035;
    col = mix(col, col * (0.74 + 0.26 * smoothstep(1.45, 0.02, length(photoP) * 2.0)), 0.55);

    gl_FragColor = vec4(pow(clamp(col, 0.0, 1.0), vec3(0.94)), 1.0);
}}
"""


def html_for(title: str, glsl: str) -> str:
    return f"""<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Shader: {title}</title>
    <style>body {{ margin: 0; overflow: hidden; background-color: #000; }} canvas {{ display: block; width: 100vw; height: 100vh; }}</style>
</head>
<body>
    <canvas id="glcanvas"></canvas>
    <script id="vertex-shader" type="x-shader/x-vertex">attribute vec2 position; void main() {{ gl_Position = vec4(position, 0.0, 1.0); }}</script>
    <script id="fragment-shader" type="x-shader/x-fragment">
        precision highp float; uniform vec2 iResolution; uniform float iTime;

{glsl}
    </script>
    <script>
        function main() {{
            const canvas = document.getElementById("glcanvas"); const gl = canvas.getContext("webgl");
            if (!gl) {{ console.error("WebGL unavailable"); return; }}
            const vs = gl.createShader(gl.VERTEX_SHADER); gl.shaderSource(vs, document.getElementById("vertex-shader").text); gl.compileShader(vs);
            const fs = gl.createShader(gl.FRAGMENT_SHADER); gl.shaderSource(fs, document.getElementById("fragment-shader").text); gl.compileShader(fs);
            if (!gl.getShaderParameter(fs, gl.COMPILE_STATUS)) {{ console.error("FS compile error: " + gl.getShaderInfoLog(fs)); }}
            const prog = gl.createProgram(); gl.attachShader(prog, vs); gl.attachShader(prog, fs); gl.linkProgram(prog);
            if (!gl.getProgramParameter(prog, gl.LINK_STATUS)) {{ console.error("Link error: " + gl.getProgramInfoLog(prog)); console.error("FS Log: " + gl.getShaderInfoLog(fs)); }}
            const pos = gl.getAttribLocation(prog, "position"); const res = gl.getUniformLocation(prog, "iResolution"); const time = gl.getUniformLocation(prog, "iTime");
            const imageResolution = gl.getUniformLocation(prog, "iImageResolution"); const channel = gl.getUniformLocation(prog, "iChannel0");
            const buf = gl.createBuffer(); gl.bindBuffer(gl.ARRAY_BUFFER, buf); gl.bufferData(gl.ARRAY_BUFFER, new Float32Array([-1,-1, 1,-1, -1,1, -1,1, 1,-1, 1,1]), gl.STATIC_DRAW);
            const texture = gl.createTexture();
            const image = new Image();
            image.onload = () => {{
                gl.bindTexture(gl.TEXTURE_2D, texture);
                gl.pixelStorei(gl.UNPACK_FLIP_Y_WEBGL, true);
                gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
                gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);
                gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR);
                gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR);
                gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, gl.RGBA, gl.UNSIGNED_BYTE, image);
                requestAnimationFrame(render);
            }};
            image.onerror = () => console.error("Could not load source texture for {title}");
            image.src = "assets/{title}.jpg";
            function render(t) {{
                canvas.width = window.innerWidth; canvas.height = window.innerHeight; gl.viewport(0, 0, gl.canvas.width, gl.canvas.height);
                gl.useProgram(prog); gl.enableVertexAttribArray(pos); gl.bindBuffer(gl.ARRAY_BUFFER, buf); gl.vertexAttribPointer(pos, 2, gl.FLOAT, false, 0, 0);
                gl.uniform2f(res, gl.canvas.width, gl.canvas.height); gl.uniform1f(time, t * 0.001);
                gl.uniform2f(imageResolution, image.naturalWidth || 1, image.naturalHeight || 1);
                gl.activeTexture(gl.TEXTURE0); gl.bindTexture(gl.TEXTURE_2D, texture); gl.uniform1i(channel, 0);
                gl.drawArrays(gl.TRIANGLES, 0, 6); requestAnimationFrame(render);
            }}
        }} window.onload = main;
    </script>
</body>
</html>
"""


def index_for(title: str, items: list[str]) -> str:
    cards = "\n".join(
        f"""        <article class="card">
            <div class="thumbs">
                <img src="assets/{name}.jpg" alt="{name} original">
                <iframe src="{name}.html" title="{name} shader"></iframe>
            </div>
            <div class="meta"><strong>{name}</strong><a href="{name}.html">Open shader</a></div>
        </article>"""
        for name in items
    )
    return f"""<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{title} Shader Folder</title>
    <style>
        * {{ box-sizing: border-box; }}
        body {{ margin: 0; background: #111; color: #f2efe8; font-family: Arial, sans-serif; }}
        header {{ position: sticky; top: 0; z-index: 2; padding: 18px 24px; background: rgba(17,17,17,.92); border-bottom: 1px solid #333; }}
        h1 {{ margin: 0; font-size: 22px; font-weight: 700; }}
        p {{ margin: 6px 0 0; color: #b8b0a3; }}
        main {{ display: grid; grid-template-columns: repeat(auto-fill, minmax(320px, 1fr)); gap: 18px; padding: 18px; }}
        .card {{ background: #1b1b1b; border: 1px solid #333; border-radius: 8px; overflow: hidden; }}
        .thumbs {{ display: grid; grid-template-columns: 1fr 1fr; aspect-ratio: 16 / 9; background: #000; }}
        img, iframe {{ width: 100%; height: 100%; border: 0; object-fit: cover; }}
        .meta {{ display: flex; justify-content: space-between; gap: 12px; padding: 12px; align-items: center; }}
        a {{ color: #ffca6a; text-decoration: none; white-space: nowrap; }}
    </style>
</head>
<body>
    <header><h1>{title}</h1><p>{len(items)} photo-derived GLSL shaders</p></header>
    <main>
{cards}
    </main>
</body>
</html>
"""


def process_batch(batch: dict[str, Path | str]) -> int:
    title = str(batch["title"])
    source = Path(batch["source"])
    output = Path(batch["output"])
    assets = output / "assets"
    glsl_dir = output / "glsl"
    assets.mkdir(parents=True, exist_ok=True)
    glsl_dir.mkdir(parents=True, exist_ok=True)

    image_paths = sorted(
        [p for p in source.iterdir() if p.is_file() and p.suffix.lower() in IMAGE_EXTS],
        key=lambda p: p.name.lower(),
    )
    names: list[str] = []
    for path in image_paths:
        name = path.stem
        seed = stable_seed(f"{title}:{name}")
        img = load_image(path)
        save_preview(img, assets / f"{name}.jpg")
        stats = analyze_image(img, seed)
        glsl = shader_for(name, stats, title)
        (glsl_dir / f"{name}.glsl").write_text(glsl, encoding="utf-8")
        (output / f"{name}.html").write_text(html_for(name, glsl), encoding="utf-8")
        names.append(name)
        print(f"{title}: {name}")

    (output / "index.html").write_text(index_for(title, names), encoding="utf-8")
    return len(names)


def main() -> int:
    register_heif_opener()
    total = 0
    for batch in BATCHES:
        total += process_batch(batch)
    print(f"Generated {total} photo-derived GLSL shaders.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

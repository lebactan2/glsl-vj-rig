# Implementation Plan: batch object-separation of the whole shader DB (the "6687 method")

Goal: process **every shader in the repo** into **self-contained per-object layers** that follow the proven `vj/scene_6687/` pattern, so the VJ sequencer can pick any single object, place it natively, and slice it into beat-segments. Keep each shader's original look; where a clean split is impossible, **rewrite the shader** into discrete objects from the reference image.

Standalone plan — does not modify the other `implementation_plan_*.md`.

## What the 6687 method is (learned from the repo)

Each object is its **own standalone fragment shader** (not a function sharing `main()` locals). Pattern in [vj/scene_6687/granite.glsl](vj/scene_6687/granite.glsl), [mosaic.glsl](vj/scene_6687/mosaic.glsl), [grate.glsl](vj/scene_6687/grate.glsl), [pavers.glsl](vj/scene_6687/pavers.glsl), [seams.glsl](vj/scene_6687/seams.glsl):

- Own `void main()`. Computes its own `uv`/`p` (same coords as the original → native position).
- **Region mask first**: `if (box(uv,…) < 0.5) { gl_FragColor = vec4(0.0); return; }` → alpha 0 outside the object.
- Inside: render the object, output `gl_FragColor = vec4(col, uOpacity)`. **Alpha = the object's silhouette/coverage.**
- A base layer (granite) covers full screen (alpha = uOpacity everywhere); object layers are masked to their region.
- The host ([vj/scene_6687.html](vj/scene_6687.html)) composites layers alpha-over in z-order with a per-layer `uOpacity` + visibility.

Why this beats the current `layered_glsl/*.glsl`: those use `layer_X(p, …main-locals…, inout col)` so a single object **can't render alone** (needs `main`'s locals like `blockUV,cell,frameOuter`). The 6687 contract makes every object independently renderable + alpha-masked = exactly what the sequencer's segment/scale/z-order path wants.

## The contract every emitted layer must meet

```glsl
// host injects header: precision; uniform vec2 iResolution; uniform float iTime;
//                      uniform float iBass,iMid,iTreble,iLevel,iBeat; uniform float uOpacity;
<helpers this object needs>
void main(){
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p  = uv*2.0-1.0; p.x *= iResolution.x/iResolution.y;   // match original's coords
    if ( /* pixel NOT in this object */ ) { gl_FragColor = vec4(0.0); return; }
    vec3 col = /* this object's exact original code path */;
    gl_FragColor = vec4(col, uOpacity);                          // alpha = coverage
}
```
- Native position preserved (same `p`).
- Alpha-only-where-object → sequencer slices vertical beat-segments, scales/highlights the hit segment, z-orders by lane (already built in `vj/sequencer.html`).
- No fetch at runtime: see Phase 4 (inline bundle).

## DB inventory (decide path per family)

| Family | Count (approx) | Path |
|--------|----------------|------|
| Procedural scene shaders (root `*.glsl`, named `*.glsl`) | ~120 | **Object-split** — `if`-region blocks become masked layers. |
| Photo kaleidoscope (`moodboard_htmls/**/glsl/IMG_*.glsl`, use `iChannel0`) | ~49 | Not object-scenes — emit **1 layer = whole effect** (mask = full frame), keep as is. |
| Already split (`layered_glsl/*`) | 139 | Re-derive to the 6687 contract (drop shared-locals signature). |

## Model assignment

| Model | Use for |
|-------|---------|
| **Haiku** | Inventory/glob scripts, the inline bundler, JSON manifest emit, mechanical header/mask scaffolding. |
| **Sonnet** | The split harness (parse `if`-regions → masked standalone files), composite-diff validator, sequencer/showcase wiring. |
| **Opus** | Shaders that won't split mechanically (shared control flow, raymarch/SDF scenes, domain-warp noise fields) — hand-rewrite into discrete masked objects matching the reference image. |

---

## Phase 1 — Auto-split by `if`-region — **Sonnet**
For each procedural shader, identify object blocks (existing `if (region) { col = … }` in `main()`, plus the `@layer_metadata` already in `layered_glsl/`). Emit one standalone file per object using the contract: lift the region test into the early-out mask, keep that block's exact body, set alpha = `uOpacity`. Reuse/extend the existing `process_layers_with_llm.py` as the driver. Output `layers2/<id>/<Object>.glsl` + per-id `meta.json` (object name + object-noun tags).
**Verify:** each file compiles standalone.

## Phase 2 — Look-preserving validation (diff) — **Sonnet**
For each shader, composite all its emitted objects alpha-over in original draw order; render off-screen and **diff against the original shader render** at a few `iTime` values. Pass if mean abs error < epsilon. Fail → mark `needs-rewrite`.
**Verify:** report pass/fail per shader; list the `needs-rewrite` set.

## Phase 3 — Rewrite the hard ones — **Opus**
For `needs-rewrite` shaders (objects entangled in shared math, raymarch/SDF, heavy domain warp): re-author from the reference image as discrete masked objects (one SDF/region per object) that **read like the original** rather than matching pixels exactly. Same contract.
**Verify:** side-by-side vs reference image; objects toggle independently.

## Phase 4 — Inline bundle + manifest (no localhost) — **Haiku**
Bundle every emitted layer source into `vj/layers_bundle.js` (`window.LAYER_SRC[id#object] = "<glsl>"`, `window.LAYER_INDEX = [{id,object,name,tags,order}]`). Plain `<script src>`, no fetch.
**Verify:** open `vj/sequencer.html` from `file://` (double-click) — layer list populates, a single object renders, network panel empty.

## Phase 5 — Wire consumers — **Sonnet**
`vj/sequencer.html`: read `window.LAYER_INDEX`; compile from `window.LAYER_SRC` (header + source); keep the atlas + per-segment scale/z-order path. Showcase `index.html`: include the bundle, render layers inline, search by tags.
**Verify:** pick `breeze_blocks#BreezeBlocks` (and a former-fail shader) — renders only that object, segmented, double-click works.

## Suggested order
Phase 1 → 2 first on a 10-shader pilot (incl. `breeze_blocks`, `flower_vase`, `IMG_0398`, one raymarch e.g. `grey_tiles`) to calibrate the splitter + epsilon, then batch all. Phase 3 only for the validator's fail list. Phases 4–5 once a batch passes.

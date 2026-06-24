# Implementation Plan: self-contained object-layers for the VJ sequencer

Goal for the next agent: turn every shader in `layered_glsl/` into a set of **truly separable, self-contained object-layers** with **clear tags**, **inline-bundled so they render with no localhost** (double-click `index.html`), **keeping each shader's original look**, and **ready to be sliced into beat-segments** by `vj/sequencer.html`.

This is standalone — it does not modify the other `implementation_plan_*.md` files.

## Why this is needed (verified against the repo)

- `layered_glsl/*.glsl` already split each shader into `layer_<Name>()` functions + a `@layer_metadata` header (name + keywords), and a `main()` that calls them.
- **Problem:** many layer fns take *main-computed locals* as extra params, e.g. in [layered_glsl/breeze_blocks.glsl](layered_glsl/breeze_blocks.glsl):
  `layer_BreezeBlocks(p, blockUV, cell, q, col, frameOuter, hole)` and
  `layer_HolesBackground(uv, cell, hole, frameOuter, col)`.
  Those locals (`blockUV,cell,q,frameOuter,hole`) only exist inside `main()`, so a single layer **cannot be rendered on its own** — the sequencer currently falls back to rendering the *whole* shader per channel (see `compileLayer`/`renderLayers` in [vj/sequencer.html](vj/sequencer.html)). That loses true per-object separation.
- The sequencer fetches layers over HTTP (`fetch("../layered_glsl/…")` and `fetch("layers_manifest.json")`), so it **needs a localhost** today.

## Target contract (what "done" looks like)

1. **Self-contained layer function.** Every object becomes one function with a fixed signature, no shared main-locals, no `out`/`inout` params:
   ```glsl
   // returns rgb + alpha; alpha = this object's silhouette coverage (0..1), 0 where absent
   vec4 layer_<Name>(vec2 uv);   // uv = gl_FragCoord.xy / iResolution.xy
   ```
   Each fn computes its own `p = uv*2.0-1.0; p.x *= iResolution.x/iResolution.y;` and any locals it needs. May use `iTime`, `iBass/iMid/iTreble/iLevel/iBeat`.
2. **Look preserved.** Compositing every layer of a shader **in order, alpha-over**, must reproduce the original `main()` output (diff against the current `layered_glsl/<id>.glsl` render).
3. **Clear tags.** Per layer: a short human `name` and 3–8 **object-noun** keywords (the thing, not adjectives-only). Drop generic GLSL noise.
4. **Inline, no localhost.** Emit one JS bundle (e.g. `vj/layers_bundle.js`) that assigns `window.LAYER_SRC = { "<id>#<fn>": "<glsl source string>", … }` and `window.LAYER_INDEX = [ {id, fn, name, tags, order} … ]`. `index.html` and `vj/sequencer.html` read these globals instead of `fetch` → double-click works.
5. **Segment-ready.** Because each layer renders standalone with an alpha silhouette, the sequencer slices it into 16/32/64 vertical beat-segments and scales/highlights the hit segment (already implemented — keep that path, just feed it real per-object layers).

## Model Assignment Strategy (token-saving)

| Model | Use for |
|-------|---------|
| **Haiku** | The bundler script, JSON/JS emit, file scaffolding, mechanical regex passes. |
| **Sonnet** | The refactor harness (parse each file, lift main-locals into each layer fn), the inline-loader wiring in `index.html`/`sequencer.html`, tag cleanup script. |
| **Opus** | Only the shaders where lifting locals is non-mechanical (shared control flow, `if/else` regions feeding several layers) — hand-refactor those to self-contained fns while matching the look. |

---

## Phase 1 — Refactor layer fns to self-contained — **Sonnet (+ Opus for hard ones)**
For each `layered_glsl/*.glsl`: for every `layer_X`, inline the main-computed locals it depended on into the fn body, change its signature to `vec4 layer_X(vec2 uv)` returning `vec4(col, alpha)`, where `alpha` marks where the object draws (replace the `inout col` writes with a local `col` + coverage flag). Keep a thin `main()` that alpha-composites all layers in order for visual regression.
**Verify:** render refactored file vs original — pixels match (allow tiny epsilon).

## Phase 2 — Clean tags — **Sonnet**
Rewrite each `@layer_metadata` so every layer has `name` + concise object-noun `keywords`. Pull from the existing per-image `unified_search_index.json` where helpful. Output a flat index `[ {id, fn, name, tags} ]`.
**Verify:** every layer has ≥3 tags; no duplicate-noise tokens (`float`, `vec3`, `main`, …).

## Phase 3 — Inline bundle (no localhost) — **Haiku**
`node` script scans the refactored `layered_glsl/`, emits `vj/layers_bundle.js` (`window.LAYER_SRC` map of `id#fn -> source`, `window.LAYER_INDEX` array). Keep it a plain `<script src>` (no module/fetch).
**Verify:** open `vj/sequencer.html` from `file://` (double-click) — layers list populates and a layer renders with **no network**.

## Phase 4 — Wire the consumers — **Sonnet**
- `vj/sequencer.html`: replace `loadLayersManifest()` (fetch) with reading `window.LAYER_INDEX`; replace `compileLayer()` fetch with `window.LAYER_SRC[id]`; compile `LAYER_HEADER + src + "void main(){ gl_FragColor = layer_<fn>(gl_FragCoord.xy/iResolution.xy); }"`. Keep the existing atlas + segment-scale path.
- `index.html` (root showcase): include `layers_bundle.js`; let it render layers inline (no server) and search by the cleaned tags.
**Verify:** sequencer picks a single object (e.g. `breeze_blocks#layer_BreezeBlocks`) and it renders **only that object**, segmented; double-click works.

## Suggested order
Phase 1 → 2 → 3 → 4. Start with 5–10 shaders end-to-end (incl. `breeze_blocks`, `flower_vase`, `IMG_0398`) to lock the contract, then batch the rest. Reserve Opus only for files where Phase 1 can't be done mechanically.

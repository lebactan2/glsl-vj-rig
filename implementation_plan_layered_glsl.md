# Implementation Plan (for Antigravity): self-contained object-layers for the VJ sequencer

Goal for the **Antigravity agent**: turn every shader in `layered_glsl/` into a set of **truly separable, self-contained object-layers** with **clear tags**, **inline-bundled so they render with no localhost** (double-click `index.html`), **keeping each shader's original look**, and **ready to be sliced into beat-segments** by `vj/sequencer.html`.

This is standalone — it does not modify the other `implementation_plan_*.md` files.

## How to run this in Antigravity

- Open this repo in **Antigravity**; drive the work from the **Agent Manager** so each phase is its own task with an **Artifact** (task list + walkthrough + browser screenshots) you can review and approve.
- **Verification uses Antigravity's built-in browser** (not Puppeteer): open the target HTML over `file://` (double-click equivalent) **and** via a quick local static server when HTTP is needed, take screenshots, and attach them to the task Artifact as proof. The "Verify" line in each phase is the browser check to record.
- Work **trunk-based**: small commits per phase; let the Agent Manager run phases in parallel only where files don't overlap (the per-shader refactor in Phase 1 parallelizes well by file).
- Keep a running **task-list Artifact**: one row per `layered_glsl/*.glsl`, status = refactored / tagged / bundled / verified.

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

## Model assignment (Antigravity models)

Antigravity lets you pick the backing model per agent/task. Use the cheapest that does the job:

| Model | Use for |
|-------|---------|
| **Gemini Flash (fast tier)** | The bundler script, JSON/JS emit, file scaffolding, mechanical regex passes, the per-image tag cleanup script. |
| **Gemini 3 Pro (default agent)** | The refactor harness (parse each file, lift main-locals into each layer fn), inline-loader wiring in `index.html`/`sequencer.html`, and running the **browser-tool verification** at each phase. |
| **Gemini 3 Pro (deep-think / high effort)** *(or Claude Sonnet if enabled)* | Only the shaders where lifting locals is non-mechanical (shared control flow, `if/else` regions feeding several layers) — hand-refactor to self-contained fns while matching the look. |

> Set the model on the Agent Manager task. Spin separate agents per shader-batch for the parallel Phase-1 work; keep one agent owning the shared wiring (Phases 3–4) to avoid file conflicts.

---

## Phase 1 — Refactor layer fns to self-contained — *Gemini 3 Pro (deep-think for hard files)*
For each `layered_glsl/*.glsl`: for every `layer_X`, inline the main-computed locals it depended on into the fn body, change its signature to `vec4 layer_X(vec2 uv)` returning `vec4(col, alpha)`, where `alpha` marks where the object draws (replace the `inout col` writes with a local `col` + coverage flag). Keep a thin `main()` that alpha-composites all layers in order for visual regression.
**Verify (Antigravity browser):** open the original vs refactored file in the built-in browser, screenshot both, attach to the task Artifact; pixels match (allow tiny epsilon).

## Phase 2 — Clean tags — *Gemini Flash*
Rewrite each `@layer_metadata` so every layer has `name` + concise object-noun `keywords`. Pull from the existing per-image `unified_search_index.json` where helpful. Output a flat index `[ {id, fn, name, tags} ]`.
**Verify:** script asserts every layer has ≥3 tags and no noise tokens (`float`, `vec3`, `main`, …); record the count in the Artifact.

## Phase 3 — Inline bundle (no localhost) — *Gemini Flash*
`node` script scans the refactored `layered_glsl/`, emits `vj/layers_bundle.js` (`window.LAYER_SRC` map of `id#fn -> source`, `window.LAYER_INDEX` array). Keep it a plain `<script src>` (no module/fetch).
**Verify (Antigravity browser):** open `vj/sequencer.html` from `file://` in the built-in browser (the double-click case) — layers list populates and a layer renders with the **network panel empty**; screenshot to the Artifact.

## Phase 4 — Wire the consumers — *Gemini 3 Pro*
- `vj/sequencer.html`: replace `loadLayersManifest()` (fetch) with reading `window.LAYER_INDEX`; replace `compileLayer()` fetch with `window.LAYER_SRC[id]`; compile `LAYER_HEADER + src + "void main(){ gl_FragColor = layer_<fn>(gl_FragCoord.xy/iResolution.xy); }"`. Keep the existing atlas + segment-scale path.
- `index.html` (root showcase): include `layers_bundle.js`; let it render layers inline (no server) and search by the cleaned tags.
**Verify (Antigravity browser):** pick a single object (e.g. `breeze_blocks#layer_BreezeBlocks`) — it renders **only that object**, segmented; double-click `file://` works; attach screenshot + a short browser walkthrough recording to the Artifact.

## Suggested order
Phase 1 → 2 → 3 → 4. In the Agent Manager, start one agent on 5–10 shaders end-to-end (incl. `breeze_blocks`, `flower_vase`, `IMG_0398`) to lock the contract, then fan out parallel agents (one per shader-batch) for Phase 1. Reserve the deep-think model only for files where Phase 1 can't be done mechanically. Each finished batch updates the shared task-list Artifact.

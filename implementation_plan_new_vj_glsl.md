# Implementation Plan: `new_vj_glsl`

Turn the existing library of ~200 Shadertoy-style `.glsl` files into a browser-based **VJ rig** that (1) reacts to music via Web Audio FFT uniforms and (2) supports stacking shaders as layers with blend modes, with a path to true foreground/background separation for the photo-derived shaders.

This plan is **standalone** — it does not modify `implementation_plan.md` or `implementation_plan_codex.md`.

## Background (verified against the repo)

Two shader families exist, and they need different treatment:

- **Procedural shaders** — e.g. [0398.glsl](file:///d:/GLSL%20bds/0398.glsl), driven entirely by `iResolution` + `iTime`. "Objects" are `if`-region computations, no real depth. Layering = refactor regions to emit alpha.
- **Photo-derived shaders** — e.g. [IMG_0187.glsl](file:///d:/GLSL%20bds/moodboard_htmls/trippy_ornaments_all/glsl/IMG_0187.glsl), sample a real photo via `uniform sampler2D iChannel0` + `iImageResolution`. Layering by depth needs a pre-computed matte/depth map.

The render harness pattern already exists in [index.html](file:///d:/GLSL%20bds/index.html) (fullscreen quad, `iResolution`/`iTime` uniforms, `requestAnimationFrame` loop).

## Model Assignment Strategy (token-saving)

Assign the cheapest model that can do each task well. Rule of thumb used below:

| Model | Use for |
|-------|---------|
| **Haiku** | Mechanical/boilerplate: file scaffolding, HTML/CSS layout, glob-and-list scripts, repetitive find/replace, JSON manifests. |
| **Sonnet** | Moderate logic: Web Audio wiring, WebGL FBO/compositing plumbing, Python image-pipeline glue, UI event handling. |
| **Opus** | Hard creative/ambiguous: mapping audio bands into each shader's *existing* animation tastefully, region→alpha refactors, depth/matte integration decisions. |

> Only spawn sub-agents/switch models if you (the user) explicitly ask. The table is guidance for *how to delegate* if you do.

---

## Phase 1 — Audio-reactive single-shader harness

Goal: load any `.glsl` from the repo, inject audio uniforms, switch shaders live.

### [NEW] vj/harness.html  — **Model: Haiku**
Self-contained page based on [index.html](file:///d:/GLSL%20bds/index.html): canvas, fullscreen quad, shader loader (fetch `.glsl` by path), `iResolution`/`iTime` plumbing, keyboard shortcut to cycle shaders from a manifest. Pure boilerplate.

### [NEW] vj/audio.js  — **Model: Sonnet**
Web Audio: `getUserMedia` (mic) **and** `<audio>` file input → `AnalyserNode` (fftSize 1024, smoothing 0.8). Compute smoothed `iBass / iMid / iTreble / iLevel` (0..1) plus a simple beat flag (bass rising-edge over adaptive threshold). Expose values to the render loop; push as `uniform1f`.

### [NEW] vj/manifest.json  — **Model: Haiku**
Glob all `.glsl` (root + `moodboard_htmls/**/glsl`), tag each `procedural` vs `photo` (photo = contains `iChannel0`), record required textures. Generate via a tiny script.

### [MODIFY shader headers at load time] — **Model: Haiku**
Harness prepends the uniform block when compiling so source files stay untouched:
```glsl
uniform float iBass, iMid, iTreble, iLevel; // + existing iResolution/iTime
```

**Verify:** open harness, play a track, confirm `iLevel` debug readout moves with audio and a test shader visibly pulses.

## Phase 2 — Audio mapped into the art (the high-value, hard part)

### Audio-reactivity passes per shader — **Model: Opus**
For a curated set (~10–15 hero shaders, not all 200), edit each so audio scales the *existing* `iTime`-driven terms — speed/amplitude/brightness — tastefully. Examples already located:
- [0398.glsl:40](file:///d:/GLSL%20bds/0398.glsl#L40) screen wave amplitude `* (0.05 + iBass*0.2)`; volume flare `col += iLevel*0.4`.
- [IMG_0187.glsl:39-49](file:///d:/GLSL%20bds/moodboard_htmls/trippy_ornaments_all/glsl/IMG_0187.glsl#L39) push `ringWave`/`petals`/warp by `iTreble`; pulse rotation/segments on beat.

This is judgment-heavy (don't strobe, keep the mood) → Opus.

### [OPTIONAL] Batch "naive" reactivity — **Model: Sonnet**
For the long tail, a script that multiplies obvious `iTime*k` motion terms by `(1.0 + iBass)` as a quick baseline. Lower quality, cheap, covers volume.

**Verify:** A/B each hero shader muted vs. playing; confirm motion tracks the beat without seizure-level flashing.

## Phase 3 — Multi-layer VJ mixer

### [NEW] vj/mixer.js + mixer UI  — **Model: Sonnet**
Render N shaders (start with 2–4) each to its own WebGL framebuffer/texture, composite with selectable blend modes (`add`/`screen`/`multiply`/`alpha`). Per-layer opacity, optionally audio-driven. Hotkeys/sliders to assign a shader per layer and crossfade.

### Region → alpha refactor (procedural layering) — **Model: Opus**
For chosen procedural shaders, refactor named `if`-regions to output `vec4(col, alpha)` so a region (e.g. the [0398.glsl:51](file:///d:/GLSL%20bds/0398.glsl#L51) sculpture) becomes an isolated transparent layer. Requires understanding each shader's structure → Opus.

**Verify:** stack two layers, confirm blend modes + opacity work and a refactored region composites with transparency over another shader.

## Phase 4 — Foreground/background for photo shaders

### [MODIFY] image pipeline to emit matte/depth — **Model: Sonnet**
Extend [generate_photo_glsl_from_images.py](file:///d:/GLSL%20bds/generate_photo_glsl_from_images.py): per source photo, also produce an alpha matte (`rembg`/SAM) **or** depth map (Depth Anything / MiDaS), saved alongside the image.

### Bind `iChannel1` (mask/depth) + isolate fg — **Model: Opus**
Update photo shaders to sample the matte/depth as `iChannel1`, isolate foreground (`mask > 0.5`), apply distinct fg/bg effects, parallax-by-depth on beat. Creative + per-shader → Opus.

**Verify:** load a photo shader with its matte; confirm foreground can be moved/effected independently of background.

---

## Open Questions

> [!IMPORTANT]
> 1. **Host:** Build in the browser (full control, this plan) or port shaders to Synesthesia/Resolume ISF (audio + layer mixing for free, less custom work)? -> fully in browser
> 2. **Audio input:** Mic, audio-file upload, or both? (Plan assumes both.) -> both
> 3. **Scope of Phase 2/4:** Confirm a hero set (~10–15) rather than all ~200 shaders, to keep token/effort cost bounded.-> use random 5 from procedural batch, other 5 from photo derived. specify in the naming of these glsl
> 4. **Phase 4 dependency:** OK to add `rembg`/depth-model Python deps for matte generation? -> ok

## Suggested Build Order

Phase 1 → Phase 3 (mixer) → Phase 2 (reactivity) → Phase 4 (depth). Phases 1 and 3 are mostly Haiku/Sonnet and unblock a usable rig fast; reserve Opus spend for Phases 2 and 4 where it matters.

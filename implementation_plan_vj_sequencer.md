# Implementation Plan: `vj_sequencer` — Tile Highway

A browser GLSL VJ **instrument**: a vertical, *Guitar-Hero-style* step sequencer. The screen is split into **3 columns / channels** (drums, bass, voice — extensible to more). Each channel drives one **street-tile GLSL pattern** (line, mosaic, circular). The user programs beats in a grid; active steps spawn tiles that **fall down their lane** and trigger their pattern at a hit line. The **more beats** the user sequences, the more tiles/pattern fill the screen.

This plan is **standalone** — it does not modify `implementation_plan.md`, `implementation_plan_codex.md`, or `implementation_plan_new_vj_glsl.md`.

## Channel → pattern mapping

| Column | Channel | Street-tile pattern | Reuse source |
|--------|---------|---------------------|--------------|
| 1 | Drums | **line** (rhythmic stripes / slats) | [vj/scene_6687/grate.glsl](vj/scene_6687/grate.glsl), [seams.glsl](vj/scene_6687/seams.glsl) |
| 2 | Bass | **mosaic** (grid tile blocks) | [vj/scene_6687/mosaic.glsl](vj/scene_6687/mosaic.glsl) |
| 3 | Voice | **circular** (concentric rings / radial petals) | kaleidoscope math in [IMG_0187.glsl](moodboard_htmls/trippy_ornaments_all/glsl/IMG_0187.glsl) |

## Background (verified against the repo)

- WebGL compositor, FBO, render-loop, and texture plumbing already exist in [vj/mixer.js](vj/mixer.js); the audio FFT engine in [vj/audio.js](vj/audio.js) can later drive or be driven by the sequencer.
- All three tile patterns already exist in some form (table above) — Phase 2 adapts, not invents.
- The self-contained, inline-shader, double-click-friendly pattern is established in [vj/scene_6687.html](vj/scene_6687.html) and is the recommended shape for this tool too.

## Architecture decision

Render the whole highway in **one fullscreen fragment shader** fed a small **data texture** that encodes the grid (`stepTex`, size `steps × channels`, one texel per cell = on/off + velocity), plus transport uniforms (`uPlayhead`, `uStepCount`, `uChannels`, `uStepDur`, `uTime`, per-channel `uDensity`). The shader derives the lane from `uv.x`, the step-row from `uv.y` + scroll, samples `stepTex` to know which tiles are live, and calls the matching channel pattern. A **DOM grid overlay** handles editing (cheap, accessible) — the GPU only renders. This mirrors how FFT data is passed as a texture and avoids N per-lane passes.

## Model Assignment Strategy (token-saving)

| Model | Use for |
|-------|---------|
| **Haiku** | DOM grid/transport UI scaffolding, CSS, data-texture upload boilerplate, file/HTML scaffolding. |
| **Sonnet** | Transport/clock logic, grid↔texture encoding, WebGL engine plumbing, UI event wiring, optional Web Audio synth. |
| **Opus** | The highway shader (steps→falling tiles→patterns), the 3 tile-pattern functions, and the beat-density visual mapping — the hard creative GLSL. |

> The table guides delegation only. Don't spawn sub-agents / switch models unless explicitly asked.

---

## Phase 1 — Sequencer state + transport

### [NEW] vj/seq/transport.js — **Model: Sonnet**
Clock: `bpm`, `stepsPerBeat`, `play()/stop()`, `startTime`. Compute `playhead = ((now-start)/stepDur) % stepCount` (fractional, for smooth scroll). Fire a `onStep(channel, step, velocity)` callback when the playhead crosses an active cell (for audio/flash hooks).

### [NEW] vj/seq/grid.js — **Model: Sonnet**
Grid model `Uint8Array[channels * steps]` (0/velocity). `toggle(c,s)`, `clear()`, `addChannel()`, and `encodeTexture()` → packs into an `RGBA`/`LUMINANCE` data texture (`steps` wide × `channels` tall). Re-upload only when edited.

**Verify:** log that `playhead` advances at the set BPM; toggling a cell changes the encoded bytes.

## Phase 2 — Tile-pattern functions (the channel looks)

Each as a GLSL function `vec3 pat_x(vec2 uv, float intensity, float age)` (`intensity` 0..1 from velocity/hit proximity, `age` for per-tile animation), so the highway shader includes and calls them.

### [NEW] vj/seq/patterns/line.glsl (drums) — **Model: Opus**
Rhythmic stripes/slats (adapt grate); spacing/brightness scale with `intensity`; glint sweeps with `age`.

### [NEW] vj/seq/patterns/mosaic.glsl (bass) — **Model: Opus**
Grid tile block (adapt scene_6687 mosaic); tiles light up proportional to `intensity`, grout shimmer on `age`.

### [NEW] vj/seq/patterns/circular.glsl (voice) — **Model: Opus**
Concentric rings / radial petals (from kaleidoscope `ringWave`/`petals`); ring count and bloom scale with `intensity`.

**Verify:** preview each fullscreen at `intensity=1`; confirm the three looks read as line / mosaic / circular.

## Phase 3 — Vertical "highway" renderer

### [NEW] vj/seq/highway.glsl — **Model: Opus**
Fullscreen shader: `lane = floor(uv.x * uChannels)`; map `uv.y` + scroll to a step index; for the cell `(lane, step)` sample `stepTex`. If active, draw a falling tile whose interior is that lane's pattern, offset downward by `(step - uPlayhead)`, with a **hit-line glow** that peaks as the tile crosses the bottom trigger line. Inactive cells transparent. Lane dividers + hit line drawn on top.

### [NEW] vj/seq/engine.js — **Model: Sonnet**
WebGL setup; compile `highway.glsl` with the three pattern functions prepended; upload `stepTex`; set transport + density uniforms each frame; render loop. Reuse helpers/patterns from [vj/mixer.js](vj/mixer.js).

**Verify:** program a few steps across channels; tiles fall in the correct columns and flash at the hit line in time with the BPM.

## Phase 4 — Beat-density mapping

### Density uniforms — **Model: Opus**
Compute active-step counts (per channel + global) in JS → `uDensity[c]`. Feed into the patterns so **more beats = more tiles / larger pattern / more bloom** ("appear accordingly"). Keep it musical, not strobing.

**Verify:** A/B a sparse vs a dense sequence — visibly more pattern coverage when denser.

## Phase 5 — UI: grid editor + transport + channels

### [NEW] vj/sequencer.html — **Model: Haiku → Sonnet**
Self-contained page (inline shaders, double-click friendly like [vj/scene_6687.html](vj/scene_6687.html)). DOM **step grid** (click cells to toggle, per channel), channel labels with a pattern **swatch**, **BPM** slider, **play / stop / clear**, **add channel** (extensible beyond 3), fullscreen + hide-UI keys. Canvas renders behind the grid.

**Verify:** click cells to program a beat; transport plays/stops; adding a 4th channel adds a lane + pattern.

## Phase 6 — Audio (optional, makes it an A/V instrument)

### Per-channel sound on trigger — **Model: Sonnet**
On `onStep`, play a sound per channel: synthesized (WebAudio osc/noise for drums/bass/voice) or samples; **or** drive visuals from mic/track via [vj/audio.js](vj/audio.js) instead of an internal clock.

**Verify:** each active step clicks/plays in time; visuals stay in sync.

---

## Open Questions

> [!IMPORTANT]
> 1. **Audio:** synthesize sounds inside the tool (true sequencer), or visual-only synced to an external track/mic? (Plan supports either; Phase 6 optional.)
> 2. **Grid size / tempo:** default steps per pattern (16?), default BPM (120?), max channels?
> 3. **Scroll direction:** tiles fall **downward** to a hit line at the bottom (classic Guitar Hero) — confirm vs rising.
> 4. **Persistence:** save/load sequences (localStorage / shareable URL)?
> 5. **Hosting:** self-contained single HTML (recommended, double-click + GitHub Pages), consistent with the rest of `vj/`?

## Suggested Build Order

Phase 1 → 2 → 3 → 5 (playable skeleton fast) → 4 (density polish) → 6 (audio). Phases 1 and 5 are mostly Haiku/Sonnet; reserve Opus for the GLSL in Phases 2–4.

# GLSL VJ Rig

Browser-based VJ rig that turns the repo's ~166 Shadertoy-style shaders into an
audio-reactive, multi-layer instrument. Built per
[implementation_plan_new_vj_glsl.md](../implementation_plan_new_vj_glsl.md).

## Run

Must be served over HTTP (`file://` blocks shader `fetch` + ES modules):

```bash
npx serve          # then open http://localhost:3000/vj/
# or: python -m http.server  -> http://localhost:8000/vj/
```

## Controls

- **Layer 1 / Layer 2** — pick any shader (grouped procedural / photo), opacity, blend mode (normal/add/screen/multiply). Layer 2 has an on/off toggle.
- **Audio** — `🎤 Mic` for live input, or load an audio file; `⏯` play/pause; **reactivity** scales how hard the visuals respond.
- **Keys** — `H` hide UI · `R` randomize both layers · `F` fullscreen.

## How audio reactivity works

`audio.js` runs an FFT and exposes smoothed `bass / mid / treble / level` plus a
beat flag. These reach the shaders two ways:

1. **Generic (works on every shader, no edits):** the compositor applies a
   beat-driven zoom punch, loudness brightness pulse, and treble RGB-split.
2. **Per-shader opt-in:** every shader is compiled with `uniform float iBass,
   iMid, iTreble, iLevel, iBeat;` injected. Edit a shader to use them for bespoke
   reactivity (Phase 2 of the plan, e.g. `0398.glsl` screen wave `* (0.05 + iBass*0.2)`).

## Files

- `index.html` — UI + glue
- `mixer.js` — WebGL engine: per-layer FBOs, compositor, audio post-FX
- `audio.js` — Web Audio FFT + beat detection
- `manifest.json` — generated shader catalog (`node build_manifest.js` to rebuild)
- `verify.js` — headless-Chrome check: compiles all shaders, screenshots a mix
  (`node vj/verify.js`)

## Foreground / background separation (Phase 4)

`generate_mattes.py` runs **rembg** on each photo's source image to produce a
foreground matte (`<name>.matte.png`, white = subject), recorded in
`manifest.json`. The rig binds it as **`iMatte`** (texture unit 1, black 1×1
fallback when absent). Photo shaders use it so the **foreground subject pops
toward camera on beats/bass while the background keeps its kaleidoscope warp** —
a true per-photo layer split driven by audio.

Regenerate mattes (downloads the u2net model on first run):
```bash
python vj/generate_mattes.py
```

## Status vs. plan

- ✅ **Phase 1** audio-reactive harness, **Phase 3** multi-layer mixer, **Phase 2**
  audio mapping (generic post-FX on every shader + bespoke hand-tuning of a hero
  set: `0398/0995/1213/1333/1720` and **all 49 photo shaders** via
  `inject_audio_photo.js`), **Phase 4** foreground matte pipeline + `iMatte`
  separation on all 49 photo shaders.
- Verified: **166/166 shaders compile & load**, 49/49 mattes generated, no
  runtime errors (`node vj/verify.js`).

## Injection scripts (idempotent, re-runnable)

- `inject_audio_photo.js` — bass/level/beat into the kaleidoscope warp, spin, zoom
- `inject_matte_photo.js` — foreground pop via `iMatte`
- Hero procedural shaders were hand-edited; re-running the scripts won't touch them.

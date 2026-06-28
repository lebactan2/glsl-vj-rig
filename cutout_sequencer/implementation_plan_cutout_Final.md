# Implementation Plan - Cutout Sequencer Final Updates

This plan outlines the final changes to refine the Photo Cutout Sequencer, aligning features with the VJ engine, improving responsiveness, updating the layout for large screens, and resolving minor visual and control issues.

## Answers to Your Specific Questions

### 5. Why pattern GLSL cant be previewed?
Currently, the preview panel uses a static `<img>` tag and only loads baked `.png` cutouts. GLSL/pattern layers are dynamically compiled fragment shaders that require a WebGL context to render. Since the preview panel lacks a WebGL context, it displays a text placeholder instead.
**Solution:** We will introduce a lightweight `previewCanvas` with a WebGL context in the preview panel. When a GLSL pattern is selected, it will be compiled and rendered live on this preview canvas.

### 6. Where is the URL for this git demo online?
The git demo online is served at:
**[https://lebactan2.github.io/glsl-vj-rig/cutout_sequencer/sequencer.html](https://lebactan2.github.io/glsl-vj-rig/cutout_sequencer/sequencer.html)**
*(Assuming your GitHub Pages is pointing to the repository root on `origin`).*

### 10. Separating graphics rendering and MIDI output for zero lag
To prevent rendering load (e.g. shader compilation or large draw loops) from causing jitter in MIDI note transmission:
1. **Timestamp Scheduling (Web MIDI API)**: We schedule MIDI notes using precise future timestamps (`performance.now() + offset`). The browser's audio/MIDI subsystem queues these events and sends them to hardware with sub-millisecond precision, even if the JS main thread is temporarily busy.
2. **Worker Separation (Alternative)**: If compiling heavy shaders stalls the UI thread for longer than the lookahead window, we can offload the entire WebGL canvas rendering loop to a Web Worker using `OffscreenCanvas`. The worker compiles and draws graphics in a background thread, leaving the main JS thread completely free for MIDI clock ticks. We will configure future timestamping first, as it is standard and very low latency.

---

## Proposed Changes

### 1. Lock Button to Tracks
- Add track lock status (`state.lock[c]`) initialization, save, and load logic.
- Prevent drawing or erasing cells on locked tracks.
- Disable selects (`nm`, `nsel`, `gsel`), grid cells, reordering (`grip`), and FX drop handlers when `state.lock[c]` is true.
- Pass a `locked` check to `makeKnob` to freeze VOL, A, PIT, D, S, and R dials for locked tracks.

### 2. Move Track Volume to ADSR panel
- Move the track Volume knob (`kVol.el`) from the outer lane container into the collapsible `adsr-row` alongside A/PIT/D/S/R controls.
- Refine layout styles to make it compact.

### 3. Disable Context Menu
- Add `document.addEventListener("contextmenu", e => e.preventDefault())` to block the browser right-click menu, making right-drag beat clearing seamless.

### 4. Left/Right Mouse Drag Slicing
- Update step cells listeners:
  - Left-drag writes beats (`state.grid[i] = 1`).
  - Right-drag clears beats (`state.grid[i] = 0`).

### 7. Blinking MIDI Indicators
- Create a `.flash-orange` CSS animation class with orange text-glow/shadow (`#ff7e39`).
- Flash the `toggleMidiNotes` button orange on MIDI note output.
- Flash the `toggleMidiClock` button orange on every 16th-note clock step.

### 8. 32-Inch Screen UI Adaptations
- Update CSS media queries under `@media (min-width: 1900px)`:
  - Modify `dashboard-top` to `grid-template-columns: 1fr 1fr 480px` and set height to `360px` to enlarge the outputs.
  - Scale text sizes up to `16px` / `18px`.
  - Compress the FX control panel column width.

### 9. Load All GLSL Shaders from vj/sequencer.html
- Retrieve the 6687 pattern lists from `window.LAYER_SOURCES` and `window.LAYER_METADATA` (using the bundled script).
- Populate all objects in the dropdown list (`loadLayersManifest`) and show them sorted by category (BACKGROUND, OBJECTS, PATTERNS, MISC) inside the PHOTOS & CUTOUTS scroll view.
- Update `compileLayer(id)` to dynamically compile and link the shader code from `window.FILE_GLOBALS` when a 6687 layer is assigned.

---

## Verification Plan

### Manual Verification
1. Open the sequencer at `http://localhost:8000/cutout_sequencer/sequencer.html`.
2. Right-click anywhere and ensure no browser menu appears.
3. Left-drag to create beats, and right-drag to clear them.
4. Lock a track: check that selects, dials, and reordering are disabled for that track.
5. Verify that GLSL patterns compile and animate inside the green preview panel.
6. Verify MIDI Notes and Clock visual blinking (flashing orange).
7. Resize screen or inspect in HD (width > 1900px) to verify correct large-screen scaling.

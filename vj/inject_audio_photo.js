// inject_audio_photo.js — adds bespoke audio reactivity to the kaleidoscope
// photo shaders. They share byte-identical hook lines, so one pass covers all.
// Uniforms (iBass/iLevel/iBeat) are supplied by the VJ rig's injected header;
// the standalone HTML previews keep their own inlined copies and are unaffected.
// Idempotent: re-running is a no-op. Run:  node vj/inject_audio_photo.js
const fs = require("fs");
const path = require("path");

const ROOT = path.resolve(__dirname, "..");
const manifest = JSON.parse(fs.readFileSync(path.join(__dirname, "manifest.json"), "utf8"));

// [find, replace] — find strings are identical across every photo shader
const EDITS = [
  // beat zoom-punch into the kaleidoscope center
  ["float r = length(p);",
   "float r = length(p) * (1.0 - iBeat * 0.10);"],
  // loudness/beat spin of the mirrored angle
  ["float ma = abs(mod(a + slice * 0.5 + sin(t) * 0.025, slice) - slice * 0.5);",
   "float ma = abs(mod(a + slice * 0.5 + sin(t) * 0.025 + iLevel * 0.5 + iBeat * 0.3, slice) - slice * 0.5);"],
  // bass-driven liquid warp of the photo sample
  ["vec2 sampleUv = clamp(texUv + warp * smoothstep(1.35, 0.05, r), 0.001, 0.999);",
   "vec2 sampleUv = clamp(texUv + warp * (1.0 + iBass * 3.0) * smoothstep(1.35, 0.05, r), 0.001, 0.999);"],
];
const MARKER = "iBass * 3.0"; // presence => already injected

let done = 0, skipped = 0, missed = 0;
for (const s of manifest.shaders) {
  if (s.type !== "photo") continue;
  const fp = path.join(ROOT, s.shader);
  let src = fs.readFileSync(fp, "utf8");
  if (src.includes(MARKER)) { skipped++; continue; }
  let ok = true;
  for (const [find] of EDITS) if (!src.includes(find)) { ok = false; break; }
  if (!ok) { console.warn("  ! pattern not found, skipping:", s.id); missed++; continue; }
  for (const [find, repl] of EDITS) src = src.replace(find, repl);
  fs.writeFileSync(fp, src);
  done++;
}
console.log(`photo audio injection: ${done} edited, ${skipped} already done, ${missed} unmatched`);

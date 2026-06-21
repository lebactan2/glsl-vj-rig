// fix_coveruv.js — corrects the inverted "cover" mapping in every photo shader.
// The original stretched portrait photos on wide canvases (sampling outside the
// image -> clamped vertical streaks). Cover must CROP, so the scale factors are
// reciprocated. Line-ending agnostic + idempotent. Run: node vj/fix_coveruv.js
const fs = require("fs");
const path = require("path");
const ROOT = path.resolve(__dirname, "..");
const manifest = JSON.parse(fs.readFileSync(path.join(__dirname, "manifest.json"), "utf8"));

// two independent, non-overlapping single-line swaps
const SWAPS = [
  ["vec2(1.0, canvasAspect / imageAspect)", "vec2(1.0, imageAspect / canvasAspect)"],
  ["vec2(imageAspect / canvasAspect, 1.0)", "vec2(canvasAspect / imageAspect, 1.0)"],
];

let done = 0, skipped = 0, missed = 0;
for (const s of manifest.shaders) {
  if (s.type !== "photo") continue;
  const fp = path.join(ROOT, s.shader);
  let src = fs.readFileSync(fp, "utf8");
  const before = src;
  for (const [find, repl] of SWAPS) src = src.split(find).join(repl);
  if (src === before) {
    if (src.includes("vec2(1.0, imageAspect / canvasAspect)")) skipped++;
    else { console.warn("  ! coverUv not found:", s.id); missed++; }
    continue;
  }
  fs.writeFileSync(fp, src);
  done++;
}
console.log(`coverUv fix: ${done} edited, ${skipped} already fixed, ${missed} unmatched`);

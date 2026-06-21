// inject_matte_photo.js — uses the rembg matte (iMatte) to treat each photo's
// foreground subject as a separate layer: the foreground pops toward camera on
// beats/bass while the background keeps its kaleidoscope warp. Subtle with no
// audio. iMatte is supplied by the rig header; standalone HTMLs keep inlined
// copies and are unaffected. Idempotent. Run:  node vj/inject_matte_photo.js
const fs = require("fs");
const path = require("path");

const ROOT = path.resolve(__dirname, "..");
const manifest = JSON.parse(fs.readFileSync(path.join(__dirname, "manifest.json"), "utf8"));

const ANCHOR = "vec3 photo = texture2D(iChannel0, sampleUv).rgb;";
const MARKER = "iMatte, texUv";
const INJECT = `vec3 photo = texture2D(iChannel0, sampleUv).rgb;
    float fgMask = texture2D(iMatte, texUv).r;                       // 1 = foreground subject
    vec2 fgUv = clamp(texUv + (texUv - 0.5) * (iBeat * 0.10 + iBass * 0.04), 0.001, 0.999);
    photo = mix(photo, texture2D(iChannel0, fgUv).rgb, fgMask);      // foreground pops; bg stays warped`;

let done = 0, skipped = 0, missed = 0;
for (const s of manifest.shaders) {
  if (s.type !== "photo") continue;
  const fp = path.join(ROOT, s.shader);
  let src = fs.readFileSync(fp, "utf8");
  if (src.includes(MARKER)) { skipped++; continue; }
  if (!src.includes(ANCHOR)) { console.warn("  ! anchor not found:", s.id); missed++; continue; }
  src = src.replace(ANCHOR, INJECT);
  fs.writeFileSync(fp, src);
  done++;
}
console.log(`matte foreground injection: ${done} edited, ${skipped} already done, ${missed} unmatched`);

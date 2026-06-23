// build_layers_manifest.js — scan layered_glsl/*.glsl; for each separated layer capture
// its metadata (name + keywords) and the exact call text used in the file's main(), so the
// sequencer can render that single layer with a sentinel-alpha wrapper.
// Run:  node vj/build_layers_manifest.js
const fs = require("fs");
const path = require("path");
const ROOT = path.resolve(__dirname, "..");
const DIR = path.join(ROOT, "layered_glsl");

function mainCalls(src) {
  // last main() body
  const mi = src.lastIndexOf("void main");
  if (mi < 0) return {};
  const body = src.slice(mi);
  const calls = {};
  for (const m of body.matchAll(/(layer_\w+)\s*\(([^;]*)\)\s*;/g)) {
    calls[m[1]] = m[0].trim();   // fn -> full "layer_X(p, iTime, col);"
  }
  return calls;
}

const out = [];
for (const f of fs.readdirSync(DIR).filter((x) => x.endsWith(".glsl"))) {
  const src = fs.readFileSync(path.join(DIR, f), "utf8");
  const id = f.replace(/\.glsl$/, "");
  let meta = null;
  const mm = src.match(/@layer_metadata\s*([\s\S]*?)\*\//);
  if (mm) { try { meta = JSON.parse(mm[1]); } catch (e) {} }
  if (!meta || !meta.layers) continue;
  const calls = mainCalls(src);
  const fns = [...src.matchAll(/void\s+(layer_\w+)\s*\(/g)].map((x) => x[1]);
  meta.layers.forEach((L, i) => {
    const fn = fns[i] || ("layer_" + L.name.replace(/[^A-Za-z0-9]/g, ""));
    const call = calls[fn];
    if (!call) return;                    // need a usable call signature
    out.push({ id, file: f, fn, name: L.name, call, keywords: L.keywords || [] });
  });
}
fs.writeFileSync(path.join(__dirname, "layers_manifest.json"), JSON.stringify(out));
console.log(`layers_manifest.json: ${out.length} layers from ${new Set(out.map(o=>o.id)).size} shaders`);

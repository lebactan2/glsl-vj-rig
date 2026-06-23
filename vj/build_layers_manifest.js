// build_layers_manifest.js — one entry per layered_glsl shader (rendered whole, at native
// position). Tags come from the cleaned per-image index (unified_search_index.json), falling
// back to the file's @layer_metadata keywords.  Run: node vj/build_layers_manifest.js
const fs = require("fs");
const path = require("path");
const ROOT = path.resolve(__dirname, "..");
const DIR = path.join(ROOT, "layered_glsl");

let unified = {};
try { unified = JSON.parse(fs.readFileSync(path.join(ROOT, "unified_search_index.json"), "utf8")); } catch (e) {}

const out = [];
for (const f of fs.readdirSync(DIR).filter((x) => x.endsWith(".glsl"))) {
  const id = f.replace(/\.glsl$/, "");
  const src = fs.readFileSync(path.join(DIR, f), "utf8");
  let title = id, kw = [];
  const mm = src.match(/@layer_metadata\s*([\s\S]*?)\*\//);
  if (mm) { try { const m = JSON.parse(mm[1]); title = m.title || id; (m.layers||[]).forEach(L => kw.push(L.name, ...(L.keywords||[]))); } catch (e) {} }
  const tags = (unified[id] && unified[id].length ? unified[id] : kw).map(s => String(s).toLowerCase());
  out.push({ id, file: f, title, tags: [...new Set(tags)] });
}
out.sort((a, b) => a.id.localeCompare(b.id));
fs.writeFileSync(path.join(__dirname, "layers_manifest.json"), JSON.stringify(out));
console.log(`layers_manifest.json: ${out.length} shaders (${out.filter(o=>o.tags.length).length} tagged)`);

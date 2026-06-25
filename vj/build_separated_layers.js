// build_separated_layers.js — split each layered_glsl/*.glsl into self-contained per-object
// renderers of the form  vec4 layer_<Name>(vec2 uv)  (returns rgb + alpha=coverage, 0 where the
// object is absent). Original `void layer_X(...)` fns are kept (overload by signature); the vec4
// wrapper reconstructs that object's setup from the file's main, drops other objects + bg fills,
// and uses a sentinel (col<0 = untouched = transparent). Emits an INLINE bundle so the showcase /
// sequencer need no localhost.  Out: vj/layers_bundle.js + layered_6687/<id>.glsl
// Run: node vj/build_separated_layers.js
const fs = require("fs");
const path = require("path");
const ROOT = path.resolve(__dirname, "..");
const SRC = path.join(ROOT, "layered_glsl");
const OUT = path.join(ROOT, "layered_6687");

function mainBody(src) {
  const i = src.lastIndexOf("void main");
  if (i < 0) return { pre: src, body: "" };
  const open = src.indexOf("{", i);
  let depth = 0, end = open;
  for (let k = open; k < src.length; k++) { if (src[k] === "{") depth++; else if (src[k] === "}") { depth--; if (depth === 0) { end = k; break; } } }
  return { pre: src.slice(0, i), body: src.slice(open + 1, end) };
}
// transform the file's main body to render only `fn`, sentinel alpha
function objBody(body, fn) {
  const out = []; let colInit = false, colType = "vec3";
  for (const line of body.split("\n")) {
    const t = line.trim();
    if (/gl_FragColor/.test(t)) continue;
    if (/\blayer_\w+\s*\(/.test(t) && !new RegExp("\\b" + fn + "\\s*\\(").test(t)) continue; // drop other objects
    const m = line.match(/^(\s*)(vec[234])\s+col\s*(=[^;]*)?;/);                              // col decl (any type, init or not)
    if (m && !colInit) { colType = m[2]; out.push(m[1] + colType + " col = " + colType + "(-1.0);"); colInit = true; continue; }
    if (/^\s*col\s*=\s*vec[34]\(\s*[-0-9.,\s]*\)\s*;/.test(t)) continue;                       // drop bg fills
    out.push(line);
  }
  let s = out.join("\n");
  if (!colInit) s = "  vec3 col = vec3(-1.0);\n" + s;
  return s;
}
// raymarch / value-returning layers can't be region-split -> emit whole scene as one layer
function sceneBody(body) {
  return body.replace(/gl_FragColor\s*=\s*[^;]*;/, "").trimEnd();
}

if (fs.existsSync(OUT)) fs.rmSync(OUT, { recursive: true, force: true });
fs.mkdirSync(OUT, { recursive: true });
const FILE_GLOBALS = {}, LAYER_SOURCES = {}, LAYER_METADATA = {};
let nObj = 0;
for (const f of fs.readdirSync(SRC).filter((x) => x.endsWith(".glsl"))) {
  const id = f.replace(/\.glsl$/, "");
  const src = fs.readFileSync(path.join(SRC, f), "utf8");
  const mm = src.match(/@layer_metadata\s*([\s\S]*?)\*\//);
  if (!mm) continue;
  let meta; try { meta = JSON.parse(mm[1]); } catch (e) { continue; }
  const fns = [...src.matchAll(/void\s+(layer_\w+)\s*\(/g)].map((x) => x[1]);
  const { pre, body } = mainBody(src);
  const helpers = pre.replace(/\/\*\s*@layer_metadata[\s\S]*?\*\//, "").trim();   // helpers + void layer fns
  const names = [];
  let combined = helpers + "\n";
  const RET = "  vec3 _rgb = vec3(col);\n  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));";
  const vec4fns = [...src.matchAll(/vec4\s+(layer_\w+)\s*\(\s*vec2/g)].map((x) => x[1]); // already 6687-style
  const nonRegion = vec4fns.length === 0 && /=\s*layer_\w+\s*\(/.test(body);      // layer used as a value -> SDF/raymarch
  if (vec4fns.length) {                                                           // export existing self-contained fns directly
    vec4fns.forEach((fn) => { names.push(fn.replace(/^layer_/, "")); nObj++; });
    LAYER_METADATA[id] = { title: meta.title || id, layers: meta.layers };
  } else if (nonRegion) {
    combined += `\nvec4 layer_Scene(vec2 _uv){\n${sceneBody(body)}\n  return vec4(clamp(vec3(col),0.0,1.0), 1.0);\n}\n`;
    names.push("Scene"); nObj++;
    LAYER_METADATA[id] = { title: meta.title || id, layers: [{ name: "Scene", keywords: [...new Set(meta.layers.flatMap(l => l.keywords || []))] }] };
  } else {
    meta.layers.forEach((L, i) => {
      const fn = fns[i]; if (!fn) return;
      const nm = L.name.replace(/\s+/g, "");                                      // matches html: name w/o spaces
      combined += `\nvec4 layer_${nm}(vec2 _uv){\n${objBody(body, fn)}\n${RET}\n}\n`;
      names.push(nm); nObj++;
    });
    LAYER_METADATA[id] = { title: meta.title || id, layers: meta.layers };
  }
  FILE_GLOBALS[id] = combined;
  LAYER_SOURCES[id] = names;
  fs.writeFileSync(path.join(OUT, id + ".glsl"), combined);
}
// reference photo + batch + shader path per shader (from index.html's ALL_FILES)
const PHOTOS = {}, BATCH = {}, PATHS = {};
try {
  const h = fs.readFileSync(path.join(ROOT, "index.html"), "utf8");
  const m = h.match(/const ALL_FILES\s*=\s*(\[[\s\S]*?\]);/);
  const arr = JSON.parse(m[1]); const byName = {};
  arr.forEach((f) => { byName[f.name] = f; });
  Object.keys(FILE_GLOBALS).forEach((id) => {
    const f = byName[id] || byName["IMG_" + id] || byName[id + "_manual"];
    if (f && f.img_path) PHOTOS[id] = f.img_path;
    BATCH[id] = (f && f.batch) || "Procedural";
    PATHS[id] = (f && f.path) || ("layered_glsl/" + id + ".glsl");
  });
} catch (e) { console.warn("no photos:", e.message); }
const bundle =
  "// AUTO-GENERATED by vj/build_separated_layers.js — inline object-layers (no localhost)\n" +
  "window.FILE_GLOBALS = " + JSON.stringify(FILE_GLOBALS) + ";\n" +
  "window.LAYER_SOURCES = " + JSON.stringify(LAYER_SOURCES) + ";\n" +
  "window.LAYER_METADATA = " + JSON.stringify(LAYER_METADATA) + ";\n" +
  "window.LAYER_PHOTOS = " + JSON.stringify(PHOTOS) + ";\n" +
  "window.LAYER_BATCH = " + JSON.stringify(BATCH) + ";\n" +
  "window.LAYER_PATHS = " + JSON.stringify(PATHS) + ";\n";
fs.writeFileSync(path.join(ROOT, "layers_bundle.js"), bundle);   // root: referenced as ../layers_bundle.js
console.log(`layers_bundle.js: ${nObj} objects from ${Object.keys(FILE_GLOBALS).length} shaders`);

// build_search_index.js — extracts searchable words (comments + identifiers) from each
// showcase shader so the dashboard search can match shader CONTENT, not just the name.
// Run:  node moodboard_htmls/build_search_index.js
const fs = require("fs");
const path = require("path");
const DIR = __dirname;

const sources = [
  { dir: DIR, suffix: ".html" },                                  // root procedural previews
  { dir: path.join(DIR, "trippy_ornaments_manual"), suffix: "_manual.html" },
  { dir: path.join(DIR, "trippy_ornaments_manual_batch2"), suffix: "_manual.html" },
  { dir: path.join(DIR, "trippy_ornaments_all"), suffix: ".html" },
];
const SKIP = new Set(["index.html", "boilerplate.html"]);

function fragText(html) {
  const m = html.match(/x-shader\/x-fragment[^>]*>([\s\S]*?)<\/script>/i);
  return m ? m[1] : html;
}
function words(text) {
  const set = new Set();
  (text.match(/[A-Za-z]{3,}/g) || []).forEach((w) => {
    const l = w.toLowerCase();
    // drop GLSL keywords / boilerplate noise so matches are about the imagery
    if (!STOP.has(l)) set.add(l);
  });
  return [...set].join(" ");
}
const STOP = new Set("float vec vec2 vec3 vec4 mat mat2 mat3 void main uniform varying attribute precision highp mediump lowp const return for int bool true false gl_fragcoord gl_fragcolor iresolution itime ichannel iimageresolution texture2d mix smoothstep clamp fract floor abs length dot sin cos tan atan pow exp min max step normalize sqrt mod the and for with this that".split(/\s+/));

const index = {};
let count = 0;
for (const { dir, suffix } of sources) {
  if (!fs.existsSync(dir)) continue;
  for (const f of fs.readdirSync(dir)) {
    if (SKIP.has(f) || !f.endsWith(suffix)) continue;
    const name = f.slice(0, -suffix.length).replace(/_manual$/, "").toLowerCase();
    const html = fs.readFileSync(path.join(dir, f), "utf8");
    const w = words(fragText(html));
    index[name] = (index[name] ? index[name] + " " : "") + w;   // merge if seen twice
    count++;
  }
}
fs.writeFileSync(path.join(DIR, "search_index.json"), JSON.stringify(index));
console.log(`wrote search_index.json: ${Object.keys(index).length} shaders (${count} files scanned)`);

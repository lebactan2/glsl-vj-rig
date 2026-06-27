// categorize_layers.js — classify every separated layer into background / patterns / objects / misc.
// Renders each object headless to measure screen coverage, and reads its GLSL + tags to detect
// tiling/shape/object cues. Writes vj/layer_categories.json { "<id>#<Name>": "background|patterns|objects|misc" }.
// Run AFTER vj/build_separated_layers.js (needs layers_bundle.js). Then re-run the build to embed.
//   node vj/build_separated_layers.js && node vj/categorize_layers.js && node vj/build_separated_layers.js
const http = require("http"), fs = require("fs"), path = require("path"), pup = require("puppeteer");
const ROOT = path.resolve(__dirname, "..");
const MIME = { ".html":"text/html", ".js":"text/javascript", ".json":"application/json", ".glsl":"text/plain" };
function srv(){ return new Promise(r=>{ const s=http.createServer((q,o)=>{ const u=decodeURIComponent(q.url.split("?")[0]);
  fs.readFile(path.join(ROOT,u),(e,d)=>{ if(e){o.writeHead(404);o.end();return;} o.writeHead(200,{"Content-Type":MIME[path.extname(u)]||"application/octet-stream"}); o.end(d); }); });
  s.listen(0,()=>r({s,port:s.address().port})); }); }

(async () => {
  const { s, port } = await srv();
  const b = await pup.launch({ headless:"new", args:["--use-gl=angle","--use-angle=swiftshader","--enable-unsafe-swiftshader","--no-sandbox"] });
  const pg = await b.newPage();
  await pg.goto(`http://localhost:${port}/index.html`, { waitUntil:"domcontentloaded" }).catch(()=>{});
  const cats = await pg.evaluate(async (base) => {
    const H = "precision highp float;\nuniform vec2 iResolution;\nuniform float iTime;\nuniform float iBass,iMid,iTreble,iLevel,iBeat;\n";
    const V = "attribute vec2 p;void main(){gl_Position=vec4(p,0.,1.);}";
    eval(await (await fetch(base + "/layers_bundle.js")).text());
    const G = window.FILE_GLOBALS, S = window.LAYER_SOURCES, M = window.LAYER_METADATA;
    const PAT_KW = /gate|window|lattice|grid|grille|grate|fence|stripe|tile|weave|brick|mesh|\bnet\b|perforat|breeze|\bhole|slat|\bbars?\b|seam|pattern|checker|scale/i;
    const SHAPE_KW = /circle|square|rectangle|\brect\b|triangle|\bdot|star|disc|ring|sphere|ball|round|oval|polygon|diamond|cross|arrow|spiral|blossom|wave/i;
    const OBJ_KW = /vase|chair|book|cup|bottle|lamp|plant|flower|\bpot\b|figure|sculpture|\bcar\b|scooter|bird|cage|clothes|shelf|branch|stone|pedestal|pillar|box|emblem|sign|fixture/i;
    const BG_KW  = /background|wall|floor|cement|concrete|granite|plaster|sky|gradient|backdrop|ground|ceiling|monochrom|paint|stucco|forest|trees|poster|mural|curtain|scene/i;
    const W = 90, H2 = 90;
    const c = document.createElement("canvas"); c.width = W; c.height = H2;
    const gl = c.getContext("webgl", { premultipliedAlpha:false, alpha:true, preserveDrawingBuffer:true });
    const buf = gl.createBuffer(); gl.bindBuffer(gl.ARRAY_BUFFER, buf);
    gl.bufferData(gl.ARRAY_BUFFER, new Float32Array([-1,-1,3,-1,-1,3]), gl.STATIC_DRAW);
    const px = new Uint8Array(W*H2*4);
    function fnSrc(src, fn){ const i = src.indexOf("vec4 " + fn + "("); if (i<0) return ""; // grab the fn body
      let d=0, st=src.indexOf("{", i), k=st; for(; k<src.length; k++){ if(src[k]==="{")d++; else if(src[k]==="}"){d--; if(!d){k++;break;}} } return src.slice(i,k); }
    const out = {};
    for (const id in S){
      const PAT = window.PAT; // unused
      for (const nm of S[id]){
        const code = H + "\n" + G[id] + `\nvoid main(){ gl_FragColor = layer_${nm}(gl_FragCoord.xy/iResolution.xy); }`;
        let cov = 0, varc = 1;
        const vs = gl.createShader(gl.VERTEX_SHADER); gl.shaderSource(vs,V); gl.compileShader(vs);
        const fsh = gl.createShader(gl.FRAGMENT_SHADER); gl.shaderSource(fsh,code); gl.compileShader(fsh);
        if (gl.getShaderParameter(fsh, gl.COMPILE_STATUS)){
          const pr=gl.createProgram(); gl.attachShader(pr,vs); gl.attachShader(pr,fsh); gl.linkProgram(pr); gl.useProgram(pr);
          const lp=gl.getAttribLocation(pr,"p"); gl.enableVertexAttribArray(lp); gl.vertexAttribPointer(lp,2,gl.FLOAT,false,0,0);
          gl.uniform2f(gl.getUniformLocation(pr,"iResolution"), W, H2); gl.uniform1f(gl.getUniformLocation(pr,"iTime"), 1.0);
          gl.viewport(0,0,W,H2); gl.clearColor(0,0,0,0); gl.clear(gl.COLOR_BUFFER_BIT); gl.drawArrays(gl.TRIANGLES,0,3);
          gl.readPixels(0,0,W,H2,gl.RGBA,gl.UNSIGNED_BYTE,px);
          let n=0, sr=0,sg=0,sb=0, sr2=0,sg2=0,sb2=0;
          for(let i=0;i<px.length;i+=4){ if(px[i+3]>20){ n++; const r=px[i],g=px[i+1],bl=px[i+2]; sr+=r;sg+=g;sb+=bl; sr2+=r*r;sg2+=g*g;sb2+=bl*bl; } }
          cov = n/(W*H2);
          if(n>0){ const vr=sr2/n-(sr/n)**2, vg=sg2/n-(sg/n)**2, vb=sb2/n-(sb/n)**2; varc=Math.sqrt((vr+vg+vb)/3); }
          gl.deleteProgram(pr);
        }
        gl.deleteShader(vs); gl.deleteShader(fsh);
        // keywords
        const L = (M[id] && M[id].layers || []).find(x => x.name.replace(/\s+/g,"") === nm) || {};
        const kw = ((L.keywords||[]).join(" ") + " " + (L.name||nm) + " " + id).toLowerCase();
        const fn = fnSrc(G[id], "layer_"+nm);
        const tiling = /\bfract\s*\(|\bmod\s*\(/.test(fn) && (/for\s*\(/.test(fn) || (fn.match(/fract\s*\(/g)||[]).length >= 2);
        // classify
        let cat;
        if (cov >= 0.72) cat = "background";                                                         // fills the screen
        else if (BG_KW.test(kw) && cov >= 0.3) cat = "background";                                   // floor/wall/cement/backdrop
        else if (cov >= 0.5 && varc < 22) cat = "background";                                        // large + flat/monochrome
        else if (PAT_KW.test(kw) || (tiling && cov > 0.12)) cat = "patterns";                        // repeating, partial
        else if (SHAPE_KW.test(kw) || OBJ_KW.test(kw)) cat = "objects";                              // named shapes / things
        else if (cov <= 0.45 && cov > 0.0) cat = "objects";                                          // small discrete coverage = an object
        else cat = "misc";
        out[id + "#" + nm] = cat;
      }
    }
    return out;
  }, `http://localhost:${port}`);
  fs.writeFileSync(path.join(__dirname, "layer_categories.json"), JSON.stringify(cats));
  const tally = {}; Object.values(cats).forEach(c => tally[c]=(tally[c]||0)+1);
  console.log("categorized", Object.keys(cats).length, JSON.stringify(tally));
  await b.close(); s.close();
})();

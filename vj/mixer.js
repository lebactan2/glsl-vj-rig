// mixer.js — WebGL engine: renders N shader layers to framebuffers, then
// composites them with per-layer opacity + blend mode, plus a global
// audio-reactive post FX so EVERY shader reacts to music without being edited.
const ROOT = "../"; // vj/ lives one level under repo root

// header injected before every loaded .glsl (the source files don't declare these)
const HEADER = `precision highp float;
uniform vec2 iResolution;
uniform float iTime;
uniform float iBass;
uniform float iMid;
uniform float iTreble;
uniform float iLevel;
uniform float iBeat;
uniform sampler2D iMatte; // foreground matte (white=fg); black fallback when none
`;

const VERT = `attribute vec2 position; void main(){ gl_Position = vec4(position,0.0,1.0); }`;

// blend(base, layer, op, mode): 0 normal, 1 add, 2 screen, 3 multiply
const COMPOSITE_FS = `precision highp float;
uniform vec2 iResolution;
uniform sampler2D tex0; uniform float op0;
uniform sampler2D tex1; uniform float op1; uniform int mode1; uniform bool use1;
uniform float uLevel; uniform float uBeat; uniform float uTreble; uniform float uReact;
vec3 blendf(vec3 base, vec3 layer, float op, int mode){
  if(mode==1) return base + layer*op;
  if(mode==2) return mix(base, 1.0-(1.0-base)*(1.0-layer), op);
  if(mode==3) return mix(base, base*layer, op);
  return mix(base, layer, op);
}
void main(){
  vec2 uv = gl_FragCoord.xy / iResolution.xy;
  // beat zoom punch around center
  vec2 c = uv - 0.5;
  c *= 1.0 - uBeat * uReact * 0.06;
  vec2 z = c + 0.5;
  // treble-driven RGB split
  float split = uTreble * uReact * 0.004;
  vec3 base = vec3(
    texture2D(tex0, z + vec2(split,0.0)).r,
    texture2D(tex0, z).g,
    texture2D(tex0, z - vec2(split,0.0)).b) * op0;
  vec3 outc = base;
  if(use1){
    vec3 l1 = vec3(
      texture2D(tex1, z + vec2(split,0.0)).r,
      texture2D(tex1, z).g,
      texture2D(tex1, z - vec2(split,0.0)).b);
    outc = blendf(base, l1, op1, mode1);
  }
  // loudness brightness pulse
  outc *= 1.0 + uLevel * uReact * 0.5;
  gl_FragColor = vec4(clamp(outc,0.0,1.0), 1.0);
}`;

function compile(gl, type, src) {
  const s = gl.createShader(type);
  gl.shaderSource(s, src);
  gl.compileShader(s);
  if (!gl.getShaderParameter(s, gl.COMPILE_STATUS)) {
    const log = gl.getShaderInfoLog(s);
    gl.deleteShader(s);
    throw new Error(log);
  }
  return s;
}

function program(gl, vsSrc, fsSrc) {
  const vs = compile(gl, gl.VERTEX_SHADER, vsSrc);
  const fs = compile(gl, gl.FRAGMENT_SHADER, fsSrc);
  const p = gl.createProgram();
  gl.attachShader(p, vs); gl.attachShader(p, fs); gl.linkProgram(p);
  if (!gl.getProgramParameter(p, gl.LINK_STATUS)) throw new Error(gl.getProgramInfoLog(p));
  return p;
}

export class Mixer {
  constructor(canvas) {
    this.canvas = canvas;
    const gl = canvas.getContext("webgl", { antialias: true, preserveDrawingBuffer: false });
    if (!gl) throw new Error("WebGL unavailable");
    this.gl = gl;
    this.quad = gl.createBuffer();
    gl.bindBuffer(gl.ARRAY_BUFFER, this.quad);
    gl.bufferData(gl.ARRAY_BUFFER, new Float32Array([-1,-1, 1,-1, -1,1, -1,1, 1,-1, 1,1]), gl.STATIC_DRAW);
    this.composite = program(gl, VERT, COMPOSITE_FS);
    // 1x1 black fallback for iMatte (foreground = 0 -> no fg effect)
    this.blackTex = gl.createTexture();
    gl.bindTexture(gl.TEXTURE_2D, this.blackTex);
    gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, 1, 1, 0, gl.RGBA, gl.UNSIGNED_BYTE, new Uint8Array([0, 0, 0, 255]));
    this.layers = [this._mkLayer(), this._mkLayer()];
    this.layers[0].opacity = 1.0;
    this.layers[0].enabled = true;
    this.react = 1.0;
    this._resize();
  }

  _mkLayer() {
    return { program: null, meta: null, enabled: false, opacity: 1.0, mode: 0,
             tex: null, fbo: null, image: null, imgTex: null, imgRes: [1, 1],
             matteTex: null, error: null };
  }

  _mkTarget(w, h) {
    const gl = this.gl;
    const tex = gl.createTexture();
    gl.bindTexture(gl.TEXTURE_2D, tex);
    gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, w, h, 0, gl.RGBA, gl.UNSIGNED_BYTE, null);
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR);
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR);
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);
    const fbo = gl.createFramebuffer();
    gl.bindFramebuffer(gl.FRAMEBUFFER, fbo);
    gl.framebufferTexture2D(gl.FRAMEBUFFER, gl.COLOR_ATTACHMENT0, gl.TEXTURE_2D, tex, 0);
    gl.bindFramebuffer(gl.FRAMEBUFFER, null);
    return { tex, fbo };
  }

  _resize() {
    const gl = this.gl;
    const w = this.canvas.width = window.innerWidth;
    const h = this.canvas.height = window.innerHeight;
    for (const L of this.layers) {
      if (L.fbo) gl.deleteFramebuffer(L.fbo);
      if (L.tex) gl.deleteTexture(L.tex);
      const t = this._mkTarget(w, h);
      L.tex = t.tex; L.fbo = t.fbo;
    }
  }

  async loadLayer(index, meta) {
    const gl = this.gl;
    const L = this.layers[index];
    L.error = null;
    try {
      const src = await fetch(ROOT + meta.shader).then((r) => {
        if (!r.ok) throw new Error("fetch " + r.status);
        return r.text();
      });
      const prog = program(gl, VERT, HEADER + "\n" + src);
      if (L.program) gl.deleteProgram(L.program);
      L.program = prog;
      L.meta = meta;
      L.enabled = true;
      // photo shaders need a texture
      if (meta.type === "photo" && meta.image) {
        await this._loadImage(L, ROOT + meta.image, "imgTex", "imgRes");
        L.matteTex = null;
        if (meta.matte) {
          try { await this._loadImage(L, ROOT + meta.matte, "matteTex"); }
          catch (e) { L.matteTex = null; } // matte optional
        }
      } else {
        L.image = null;
      }
    } catch (e) {
      L.error = String(e.message || e);
      L.enabled = false;
      throw e;
    }
    return L;
  }

  _loadImage(L, url, texField = "imgTex", resField = null) {
    const gl = this.gl;
    return new Promise((resolve, reject) => {
      const img = new Image();
      img.onload = () => {
        if (!L[texField]) L[texField] = gl.createTexture();
        gl.bindTexture(gl.TEXTURE_2D, L[texField]);
        gl.pixelStorei(gl.UNPACK_FLIP_Y_WEBGL, true);
        gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
        gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);
        gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR);
        gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR);
        gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, gl.RGBA, gl.UNSIGNED_BYTE, img);
        if (resField) { L.image = img; L[resField] = [img.naturalWidth, img.naturalHeight]; }
        resolve();
      };
      img.onerror = () => reject(new Error("image load failed: " + url));
      img.src = url;
    });
  }

  _bindQuad(prog) {
    const gl = this.gl;
    const loc = gl.getAttribLocation(prog, "position");
    gl.bindBuffer(gl.ARRAY_BUFFER, this.quad);
    gl.enableVertexAttribArray(loc);
    gl.vertexAttribPointer(loc, 2, gl.FLOAT, false, 0, 0);
  }

  _renderLayer(L, t, audio) {
    const gl = this.gl;
    if (!L.program || !L.enabled) {
      gl.bindFramebuffer(gl.FRAMEBUFFER, L.fbo);
      gl.clearColor(0, 0, 0, 1); gl.clear(gl.COLOR_BUFFER_BIT);
      gl.bindFramebuffer(gl.FRAMEBUFFER, null);
      return;
    }
    gl.bindFramebuffer(gl.FRAMEBUFFER, L.fbo);
    gl.viewport(0, 0, this.canvas.width, this.canvas.height);
    gl.useProgram(L.program);
    this._bindQuad(L.program);
    const u = (n) => gl.getUniformLocation(L.program, n);
    gl.uniform2f(u("iResolution"), this.canvas.width, this.canvas.height);
    gl.uniform1f(u("iTime"), t);
    const set = (n, v) => { const l = u(n); if (l) gl.uniform1f(l, v); };
    set("iBass", audio.bass); set("iMid", audio.mid);
    set("iTreble", audio.treble); set("iLevel", audio.level); set("iBeat", audio.beat);
    if (L.meta && L.meta.type === "photo" && L.imgTex) {
      gl.activeTexture(gl.TEXTURE0);
      gl.bindTexture(gl.TEXTURE_2D, L.imgTex);
      const ch = u("iChannel0"); if (ch) gl.uniform1i(ch, 0);
      const ir = u("iImageResolution"); if (ir) gl.uniform2f(ir, L.imgRes[0], L.imgRes[1]);
    }
    // foreground matte on unit 1 (black fallback => fg=0 => no effect)
    const im = u("iMatte");
    if (im) {
      gl.activeTexture(gl.TEXTURE1);
      gl.bindTexture(gl.TEXTURE_2D, L.matteTex || this.blackTex);
      gl.uniform1i(im, 1);
    }
    gl.drawArrays(gl.TRIANGLES, 0, 6);
    gl.bindFramebuffer(gl.FRAMEBUFFER, null);
  }

  render(t, audio) {
    const gl = this.gl;
    if (this.canvas.width !== window.innerWidth || this.canvas.height !== window.innerHeight) this._resize();
    this._renderLayer(this.layers[0], t, audio);
    this._renderLayer(this.layers[1], t, audio);

    gl.viewport(0, 0, this.canvas.width, this.canvas.height);
    gl.useProgram(this.composite);
    this._bindQuad(this.composite);
    const u = (n) => gl.getUniformLocation(this.composite, n);
    gl.uniform2f(u("iResolution"), this.canvas.width, this.canvas.height);
    gl.activeTexture(gl.TEXTURE0); gl.bindTexture(gl.TEXTURE_2D, this.layers[0].tex);
    gl.uniform1i(u("tex0"), 0);
    gl.uniform1f(u("op0"), this.layers[0].enabled ? this.layers[0].opacity : 0.0);
    gl.activeTexture(gl.TEXTURE1); gl.bindTexture(gl.TEXTURE_2D, this.layers[1].tex);
    gl.uniform1i(u("tex1"), 1);
    gl.uniform1f(u("op1"), this.layers[1].opacity);
    gl.uniform1i(u("mode1"), this.layers[1].mode);
    gl.uniform1i(u("use1"), this.layers[1].enabled ? 1 : 0);
    gl.uniform1f(u("uLevel"), audio.level);
    gl.uniform1f(u("uBeat"), audio.beat);
    gl.uniform1f(u("uTreble"), audio.treble);
    gl.uniform1f(u("uReact"), this.react);
    gl.drawArrays(gl.TRIANGLES, 0, 6);
  }
}

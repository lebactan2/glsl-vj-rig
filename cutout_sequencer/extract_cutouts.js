const puppeteer = require('puppeteer');
const fs = require('fs');
const path = require('path');

const ROOT = path.resolve(__dirname, "..");
const BATCH_IDS = [
  "IMG_0398",
  "IMG_0415",
  "IMG_0417",
  "IMG_0418",
  "IMG_0419",
  "IMG_0586",
  "IMG_0767",
  "IMG_0824",
  "IMG_0825",
  "IMG_0826"
];

async function main() {
  console.log("Launching headless browser...");
  const browser = await puppeteer.launch({
    headless: "new",
    args: [
      '--allow-file-access-from-files',
      '--disable-web-security'
    ]
  });
  const page = await browser.newPage();
  
  // Set up console redirect to see console logs from page
  page.on('console', msg => console.log('BROWSER:', msg.text()));

  await page.goto('about:blank');
  
  for (const id of BATCH_IDS) {
    console.log(`\n========================================`);
    console.log(`Processing ${id}...`);
    
    const glslPath = path.join(ROOT, "layered_6687", `${id}.glsl`);
    if (!fs.existsSync(glslPath)) {
      console.error(`Shader not found: ${glslPath}`);
      continue;
    }
    const glslSrc = fs.readFileSync(glslPath, "utf8");
    
    const imgPath = path.join(ROOT, "moodboard_htmls", "assets", `${id}.jpg`);
    if (!fs.existsSync(imgPath)) {
      console.error(`Image not found: ${imgPath}`);
      continue;
    }
    
    // Read image as base64 to bypass local file access security blocks completely
    const imgBase64 = fs.readFileSync(imgPath).toString("base64");
    
    // Parse layer metadata from original shader
    const origGlslPath = path.join(ROOT, "layered_glsl", `${id}.glsl`);
    if (!fs.existsSync(origGlslPath)) {
      console.error(`Original shader not found: ${origGlslPath}`);
      continue;
    }
    const origGlsl = fs.readFileSync(origGlslPath, "utf8");
    const mm = origGlsl.match(/@layer_metadata\s*([\s\S]*?)\*\//);
    if (!mm) {
      console.error(`Metadata not found in ${origGlslPath}`);
      continue;
    }
    
    const meta = JSON.parse(mm[1]);
    const layers = meta.layers;
    console.log(`Layers found: ${layers.map(l => l.name).join(", ")}`);
    
    // Run the extraction process inside browser environment
    const results = await page.evaluate(async (glslSrc, imgBase64, layers) => {
      const canvas = document.createElement('canvas');
      const gl = canvas.getContext('webgl', { premultipliedAlpha: false, antialias: true, alpha: true });
      if (!gl) return { error: "WebGL context failed to initialize." };
      
      const vsSrc = `
        attribute vec2 position;
        varying vec2 vUv;
        void main() {
          vUv = position * 0.5 + 0.5;
          gl_Position = vec4(position, 0.0, 1.0);
        }
      `;
      
      const compileShader = (type, src) => {
        const s = gl.createShader(type);
        gl.shaderSource(s, src);
        gl.compileShader(s);
        if (!gl.getShaderParameter(s, gl.COMPILE_STATUS)) {
          throw new Error(gl.getShaderInfoLog(s));
        }
        return s;
      };
      
      const createProgram = (fsSrc) => {
        const vs = compileShader(gl.VERTEX_SHADER, vsSrc);
        const fs = compileShader(gl.FRAGMENT_SHADER, fsSrc);
        const prog = gl.createProgram();
        gl.attachShader(prog, vs);
        gl.attachShader(prog, fs);
        gl.linkProgram(prog);
        if (!gl.getProgramParameter(prog, gl.LINK_STATUS)) {
          throw new Error(gl.getProgramInfoLog(prog));
        }
        return prog;
      };
      
      const loadImage = (base64) => {
        return new Promise((resolve) => {
          const img = new Image();
          img.onload = () => resolve(img);
          img.src = "data:image/jpeg;base64," + base64;
        });
      };
      
      const img = await loadImage(imgBase64);
      
      // Determine viewport size keeping original aspect ratio up to max 1024px
      const maxDim = 1024;
      let width = maxDim;
      let height = maxDim;
      if (img.width > img.height) {
        width = maxDim;
        height = Math.round((img.height / img.width) * maxDim);
      } else {
        height = maxDim;
        width = Math.round((img.width / img.height) * maxDim);
      }
      canvas.width = width;
      canvas.height = height;
      
      // Bind original image to texture unit 0 (iChannel0)
      const tex = gl.createTexture();
      gl.bindTexture(gl.TEXTURE_2D, tex);
      gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, gl.RGBA, gl.UNSIGNED_BYTE, img);
      gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR);
      gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR);
      gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
      gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);
      
      // Bind 1x1 black matte fallback to texture unit 1 (iMatte)
      const matteTex = gl.createTexture();
      gl.bindTexture(gl.TEXTURE_2D, matteTex);
      gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, 1, 1, 0, gl.RGBA, gl.UNSIGNED_BYTE, new Uint8Array([0, 0, 0, 255]));
      
      const quad = gl.createBuffer();
      gl.bindBuffer(gl.ARRAY_BUFFER, quad);
      gl.bufferData(gl.ARRAY_BUFFER, new Float32Array([-1,-1, 1,-1, -1,1, -1,1, 1,-1, 1,1]), gl.STATIC_DRAW);
      
      gl.enable(gl.BLEND);
      gl.blendFunc(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA);
      
      const output = {};
      
      for (const layer of layers) {
        const layerName = layer.name;
        const fnName = "layer_" + layerName.replace(/\s+/g, "");
        
        // Define full shader code declaring all standard uniforms to prevent compilation errors
        const fsSrc = `
          precision highp float;
          uniform vec2 iResolution;
          uniform float iTime;
          uniform float iBass;
          uniform float iMid;
          uniform float iTreble;
          uniform float iLevel;
          uniform float iBeat;
          uniform sampler2D iChannel0;
          uniform sampler2D iMatte;
          
          ${glslSrc}
          
          void main() {
            vec2 uv = gl_FragCoord.xy / iResolution.xy;
            vec4 c = ${fnName}(uv);
            vec3 photo = texture2D(iChannel0, uv).rgb;
            gl_FragColor = vec4(photo, c.a);
          }
        `;
        
        try {
          const prog = createProgram(fsSrc);
          gl.useProgram(prog);
          
          gl.viewport(0, 0, width, height);
          gl.clearColor(0, 0, 0, 0);
          gl.clear(gl.COLOR_BUFFER_BIT);
          
          const pos = gl.getAttribLocation(prog, "position");
          gl.enableVertexAttribArray(pos);
          gl.vertexAttribPointer(pos, 2, gl.FLOAT, false, 0, 0);
          
          gl.uniform2f(gl.getUniformLocation(prog, "iResolution"), width, height);
          gl.uniform1f(gl.getUniformLocation(prog, "iTime"), 0.0);
          gl.uniform1f(gl.getUniformLocation(prog, "iBass"), 0.0);
          gl.uniform1f(gl.getUniformLocation(prog, "iMid"), 0.0);
          gl.uniform1f(gl.getUniformLocation(prog, "iTreble"), 0.0);
          gl.uniform1f(gl.getUniformLocation(prog, "iLevel"), 0.0);
          gl.uniform1f(gl.getUniformLocation(prog, "iBeat"), 0.0);
          
          gl.activeTexture(gl.TEXTURE0);
          gl.bindTexture(gl.TEXTURE_2D, tex);
          gl.uniform1i(gl.getUniformLocation(prog, "iChannel0"), 0);
          
          gl.activeTexture(gl.TEXTURE1);
          gl.bindTexture(gl.TEXTURE_2D, matteTex);
          gl.uniform1i(gl.getUniformLocation(prog, "iMatte"), 1);
          
          gl.drawArrays(gl.TRIANGLES, 0, 6);
          
          output[layerName] = canvas.toDataURL("image/png");
        } catch (e) {
          console.error("Shader error in layer " + layerName + ": " + e.message);
          output[layerName] = { error: e.message };
        }
      }
      
      return output;
    }, glslSrc, imgBase64, layers);
    
    // Write out transparent PNGs
    const cutoutDir = path.join(ROOT, "cutout_sequencer", "cutouts", id);
    if (!fs.existsSync(cutoutDir)) {
      fs.mkdirSync(cutoutDir, { recursive: true });
    }
    
    for (const [layerName, dataUrl] of Object.entries(results)) {
      if (typeof dataUrl === 'object' && dataUrl.error) {
        console.error(`  Failed ${layerName}:`, dataUrl.error);
        continue;
      }
      const base64Data = dataUrl.replace(/^data:image\/png;base64,/, "");
      const fileName = layerName.replace(/\s+/g, "") + ".png";
      const filePath = path.join(cutoutDir, fileName);
      fs.writeFileSync(filePath, base64Data, "base64");
      console.log(`  Extracted layer: ${fileName}`);
    }
    
    // Write metadata config
    const metaPath = path.join(cutoutDir, "meta.json");
    fs.writeFileSync(metaPath, JSON.stringify({
      id: id,
      title: meta.title,
      tags: meta.layers.flatMap(l => l.keywords),
      layers: meta.layers.map(l => ({
        name: l.name,
        fileName: l.name.replace(/\s+/g, "") + ".png",
        keywords: l.keywords
      }))
    }, null, 2));
    
    // Copy the original image into the folder too for easy offline previewing
    const copyImgPath = path.join(cutoutDir, "original.jpg");
    fs.writeFileSync(copyImgPath, Buffer.from(imgBase64, "base64"));
  }
  
  await browser.close();
  console.log("\n========================================");
  console.log("All cutouts successfully extracted.");
}

main().catch(err => {
  console.error("Extraction failed:", err);
});

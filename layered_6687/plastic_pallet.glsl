void layer_PalletStructure(in vec2 p, in vec2 f, in vec2 nF, in vec2 fineUV, out float plastic, out float node, out float beams, out float nHole, out float nIndents, out float hBeam, out float vBeam, out float isFineGrid) {
    node = step(abs(nF.x - 0.5), 0.15) * step(abs(nF.y - 0.5), 0.15);
    nHole = step(length(nF - 0.5), 0.04);
    nIndents = step(length(abs(nF - 0.5) - 0.09), 0.025);
    
    hBeam = step(abs(f.y - 0.5), 0.1) * step(abs(nF.x - 0.5), 0.5);
    vBeam = step(abs(f.x - 0.5), 0.1) * step(abs(nF.y - 0.5), 0.5);
    beams = max(hBeam, vBeam);
    
    float fineGrid = step(fineUV.x, 0.25) + step(fineUV.y, 0.25);
    fineGrid = clamp(fineGrid, 0.0, 1.0);
    
    float h1 = step(0.18, f.x) * step(f.x, 0.4) * step(0.18, f.y) * step(f.y, 0.4);
    float h2 = step(0.6, f.x) * step(f.x, 0.82) * step(0.18, f.y) * step(f.y, 0.4);
    float h3 = step(0.18, f.x) * step(f.x, 0.4) * step(0.6, f.y) * step(f.y, 0.82);
    float h4 = step(0.6, f.x) * step(f.x, 0.82) * step(0.6, f.y) * step(f.y, 0.82);
    float allBigHoles = h1 + h2 + h3 + h4;
    
    plastic = max(node, beams);
    isFineGrid = 0.0;
    if (plastic < 0.5) {
        if (allBigHoles < 0.5) {
            plastic = fineGrid;
            isFineGrid = plastic;
        }
    }
    plastic *= (1.0 - nHole);
}

void layer_PalletMaterial(in vec2 p, in vec2 f, in vec2 nF, in vec2 fineUV, in float plastic, in float node, in float beams, in float nHole, in float nIndents, in float hBeam, in float vBeam, in float isFineGrid, in vec3 palletCol, inout vec3 col) {
    if (plastic > 0.5) {
        col = palletCol;
        
        if (node > 0.5 && nHole < 0.5) {
            if (nIndents > 0.5) {
                col *= 0.4;
            } else {
                col *= smoothstep(0.04, 0.06, length(nF - 0.5));
                float dX = abs(abs(nF.x - 0.5) - 0.15);
                float dY = abs(abs(nF.y - 0.5) - 0.15);
                col *= smoothstep(0.0, 0.015, min(dX, dY)) * 0.3 + 0.7;
            }
        } else if (beams > 0.5) {
            float bX = min(abs(f.y - 0.4), abs(f.y - 0.6));
            float bY = min(abs(f.x - 0.4), abs(f.x - 0.6));
            float distToEdge = beams == hBeam ? bX : bY;
            if (hBeam > 0.5 && vBeam > 0.5) distToEdge = min(bX, bY);
            col *= smoothstep(0.0, 0.02, distToEdge) * 0.4 + 0.6;
        } else if (isFineGrid > 0.5) {
            col *= 0.75;
            float gX = min(fineUV.x, 0.25 - fineUV.x);
            float gY = min(fineUV.y, 0.25 - fineUV.y);
            col *= smoothstep(0.0, 0.1, max(gX, gY)) * 0.5 + 0.5;
        }
        
        float tex = fract(sin(dot(p*100.0, vec2(12.98, 78.23))) * 43758.54);
        col *= 0.95 + 0.05 * tex;
    }
}

void layer_BackgroundHoles(in vec2 p, in float plastic, in vec3 palletCol, inout vec3 col) {
    if (plastic <= 0.5) {
        vec2 p2 = p + vec2(0.1, -0.1);
        vec2 f2 = fract(p2);
        vec2 nF2 = fract(p2 + 0.5);
        float b2 = max(step(abs(f2.y - 0.5), 0.1), step(abs(f2.x - 0.5), 0.1));
        float n2 = step(abs(nF2.x - 0.5), 0.15) * step(abs(nF2.y - 0.5), 0.15);
        if (max(b2, n2) > 0.5) {
            col = palletCol * 0.25;
        }
    }
}

vec4 layer_PalletStructure(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 3.0;
    p.x *= iResolution.x / iResolution.y;
    
    vec2 id = floor(p);
    vec2 f = fract(p);
    vec2 nF = fract(p + 0.5);
    vec2 fineUV = fract(p * 12.0);
    
    float plastic = 0.0;
    float node, beams, nHole, nIndents, hBeam, vBeam, isFineGrid;
    layer_PalletStructure(p, f, nF, fineUV, plastic, node, beams, nHole, nIndents, hBeam, vBeam, isFineGrid);
    
    vec3 palletCol = vec3(0.65, 0.72, 0.2);
    vec3 col = vec3(-1.0);
    
    

  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

vec4 layer_PalletMaterial(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 3.0;
    p.x *= iResolution.x / iResolution.y;
    
    vec2 id = floor(p);
    vec2 f = fract(p);
    vec2 nF = fract(p + 0.5);
    vec2 fineUV = fract(p * 12.0);
    
    float plastic = 0.0;
    float node, beams, nHole, nIndents, hBeam, vBeam, isFineGrid;
    
    vec3 palletCol = vec3(0.65, 0.72, 0.2);
    vec3 col = vec3(-1.0);
    
    layer_PalletMaterial(p, f, nF, fineUV, plastic, node, beams, nHole, nIndents, hBeam, vBeam, isFineGrid, palletCol, col);
    

  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

vec4 layer_BackgroundHoles(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 3.0;
    p.x *= iResolution.x / iResolution.y;
    
    vec2 id = floor(p);
    vec2 f = fract(p);
    vec2 nF = fract(p + 0.5);
    vec2 fineUV = fract(p * 12.0);
    
    float plastic = 0.0;
    float node, beams, nHole, nIndents, hBeam, vBeam, isFineGrid;
    
    vec3 palletCol = vec3(0.65, 0.72, 0.2);
    vec3 col = vec3(-1.0);
    
    layer_BackgroundHoles(p, plastic, palletCol, col);
    

  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

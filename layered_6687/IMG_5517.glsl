void layer_Ground(in vec2 p, in float globalNoise, inout vec3 col) {
    col = vec3(0.45, 0.42, 0.4);
    vec2 gp = p * 4.0;
    float r = length(gp - vec2(0.0, -4.0));
    float arcLines = fract(r * 2.0);
    float radialLines = fract(atan(gp.y + 4.0, gp.x) * 20.0);
    
    if (arcLines < 0.1 || radialLines < 0.1) {
        col *= 0.8;
    }
    col += (globalNoise - 0.5) * 0.1;
}

void layer_PillarBase(in vec2 p, in float iTime, in float globalNoise, inout vec3 col) {
    bool isLeftFace = (p.x < -0.55 && p.x > -1.2 && p.y < 0.7);
    bool isFrontFace = (p.x >= -0.55 && p.x < 1.0 && p.y > -0.9 && p.y < 0.7 - p.x*0.05);
    
    if (isFrontFace || isLeftFace) {
        vec3 tLight = vec3(0.65, 0.68, 0.7);
        vec3 tMed = vec3(0.5, 0.55, 0.58);
        vec3 tDark = vec3(0.35, 0.4, 0.45);
        
        vec2 tp = p;
        if (isLeftFace) {
            tp.x *= 1.5;
            tp.y += tp.x * 0.1;
        } else {
            tp.y += tp.x * 0.05;
        }
        
        float tileH = 0.15;
        float tileW = 0.6;
        
        float row = floor(tp.y / tileH);
        float offset = mod(row, 2.0) * (tileW * 0.5);
        float colIdx = floor((tp.x + offset) / tileW);
        
        vec2 cellP = vec2(fract((tp.x + offset) / tileW), fract(tp.y / tileH));
        
        float rand = fract(sin(dot(vec2(colIdx, row), vec2(12.9898, 78.233))) * 43758.5453);
        
        vec3 tileCol = tMed;
        if (rand < 0.3) tileCol = tLight;
        else if (rand > 0.7) tileCol = tDark;
        
        float grain = fract(sin(tp.x * 100.0) * 123.4) * 0.1;
        tileCol += (grain - 0.05);
        tileCol += (globalNoise - 0.5) * 0.05;
        
        float groutThicknessX = 0.02;
        float groutThicknessY = 0.08;
        
        if (cellP.x < groutThicknessX || cellP.x > 1.0 - groutThicknessX ||
            cellP.y < groutThicknessY || cellP.y > 1.0 - groutThicknessY) {
            tileCol = vec3(0.8, 0.8, 0.8);
            tileCol *= 0.9 + 0.1 * fract(sin(tp.x*50.0 + tp.y*50.0)*432.1);
        } else {
            if (cellP.y < groutThicknessY + 0.1) tileCol *= 0.8;
            if (cellP.x > 1.0 - groutThicknessX - 0.05) tileCol *= 0.9;
            
            float specRoll = fract(tp.x + tp.y + iTime*0.5);
            if (specRoll > 0.9 && specRoll < 0.95) {
                tileCol += vec3(0.15); 
            }
        }
        
        col = tileCol;
        
        if (abs(p.x - -0.55) < 0.02) col *= 0.7;
        
        if (p.y > 0.55 - p.x*0.05 && p.y < 0.7 - p.x*0.05) {
            col = vec3(0.7);
            if (p.y < 0.6 - p.x*0.05 && p.y > 0.58 - p.x*0.05) col = vec3(0.9);
        }
    }
}

void layer_TopColumn(in vec2 p, in float globalNoise, inout vec3 col) {
    if (p.x > -0.4 && p.x < 0.8 && p.y > 0.68 - p.x*0.05) {
        col = vec3(0.65, 0.65, 0.68);
        col *= 0.9 + 0.1 * cos((p.x - 0.2) * 2.0);
        col += (globalNoise - 0.5) * 0.03;
    }
}

void layer_DecorativeTile(in vec2 p, in float iTime, inout vec3 col) {
    if (p.x > 1.1) {
        col = vec3(0.8, 0.8, 0.75);
        vec2 decP = p - vec2(1.4, 0.2);
        float a = atan(decP.y, decP.x);
        float rDec = length(decP);
        
        float petals = abs(sin((a + iTime*0.5) * 4.0)); 
        if (rDec < 0.3 + petals * 0.1) {
            col = vec3(0.5, 0.5, 0.4);
            if (fract(rDec * 20.0) < 0.2) col *= 0.8;
        }
        if (rDec < 0.1) col = vec3(0.8, 0.7, 0.5);
    }
}

vec4 layer_Ground(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;
    
    vec3 col = vec3(-1.0);
    
    float globalNoise = fract(sin(dot(p + iTime*0.05, vec2(12.9898, 78.233))) * 43758.5453);
    
    layer_Ground(p, globalNoise, col);


  return vec4(clamp(col,0.0,1.0), step(0.0, max(col.r, max(col.g, col.b))));
}

vec4 layer_PillarBase(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;
    
    vec3 col = vec3(-1.0);
    
    float globalNoise = fract(sin(dot(p + iTime*0.05, vec2(12.9898, 78.233))) * 43758.5453);
    
    layer_PillarBase(p, iTime, globalNoise, col);


  return vec4(clamp(col,0.0,1.0), step(0.0, max(col.r, max(col.g, col.b))));
}

vec4 layer_TopColumn(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;
    
    vec3 col = vec3(-1.0);
    
    float globalNoise = fract(sin(dot(p + iTime*0.05, vec2(12.9898, 78.233))) * 43758.5453);
    
    layer_TopColumn(p, globalNoise, col);


  return vec4(clamp(col,0.0,1.0), step(0.0, max(col.r, max(col.g, col.b))));
}

vec4 layer_DecorativeTile(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;
    
    vec3 col = vec3(-1.0);
    
    float globalNoise = fract(sin(dot(p + iTime*0.05, vec2(12.9898, 78.233))) * 43758.5453);
    
    layer_DecorativeTile(p, iTime, col);


  return vec4(clamp(col,0.0,1.0), step(0.0, max(col.r, max(col.g, col.b))));
}

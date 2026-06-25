void layer_BackgroundCourtyard(in vec2 p, in float iTime, inout vec3 col) {
    if (p.y < -0.4) {
        col = vec3(0.7, 0.6, 0.5); 
        vec2 tp = p * vec2(10.0, 5.0 / max(0.1, (p.y + 1.0)));
        if (fract(tp.x) < 0.05 || fract(tp.y) < 0.05) col = vec3(0.5, 0.4, 0.3);
    } else {
        col = vec3(0.5, 0.7, 0.75); 
        
        if (abs(p.x) > 0.3 && p.y > -0.4 && p.y < 0.4) {
            col = vec3(0.3, 0.6, 0.55); 
            if (fract(p.x * 20.0) < 0.2) col *= 0.7; 
        }
        
        if (length(p - vec2(-0.2, -0.1)) < 0.2 || length(p - vec2(0.3, 0.0)) < 0.25) {
            col = vec3(0.2, 0.4, 0.2); 
            col *= 0.8 + 0.2 * fract(sin(p.x*100.0 + iTime)*40.0); 
        }
    }
}

void layer_TempleGateHeader(in vec2 p, in float iTime, inout vec3 col) {
    if (p.y > 0.65) {
        col = vec3(0.4, 0.1, 0.1); 
        if (p.y < 0.95 && p.y > 0.7) {
            col = vec3(0.8, 0.7, 0.2); 
            if (abs(p.y - 0.82) < 0.08) {
                if (fract(p.x * 5.0) < 0.7 && abs(p.x) < 0.8) {
                    col = vec3(0.7, 0.15, 0.15); 
                }
            }
            col *= 0.9 + 0.1 * fract(sin(dot(p + iTime*0.05, vec2(12.9898, 78.233))) * 43758.5453);
        }
    }
}

void layer_TempleGatePillars(in vec2 p, inout vec3 col) {
    float dPillarL = max(abs(p.x - (-0.7)) - 0.1, abs(p.y) - 0.65);
    float dPillarR = max(abs(p.x - 0.7) - 0.1, abs(p.y) - 0.65);
    
    if (min(dPillarL, dPillarR) < 0.0) {
        col = vec3(0.3, 0.15, 0.15); 
        if (fract(p.y * 30.0) < 0.1 || fract(p.x * 10.0 + (fract(p.y*15.0)>0.5?0.5:0.0)) < 0.1) {
            col = vec3(0.2, 0.1, 0.1);
        }
        
        if (abs(abs(p.x) - 0.7) < 0.06 && p.y < 0.6 && p.y > -0.6) {
            col = vec3(0.9, 0.9, 0.9); 
            if (fract(p.y * 5.0) < 0.6 && abs(abs(p.x) - 0.7) < 0.03) {
                if (fract(p.y * 25.0) < 0.5 || abs(abs(p.x) - 0.7) < 0.01) {
                    col = vec3(0.05); 
                }
            }
        }
    }
}

void layer_TempleGateGrid(in vec2 p, in float iTime, inout vec3 col, out float isGate) {
    isGate = 0.0;
    if (abs(p.x) < 0.6 && p.y > -0.65 && p.y < 0.65) {
        vec3 gateCol = vec3(0.85, 0.75, 0.2); 
        gateCol += 0.1 * sin(p.y * 20.0 - iTime * 3.0) * sin(p.x * 20.0);
        
        if (abs(p.x) > 0.58) isGate = 1.0; 
        if (abs(p.y) > 0.63) isGate = 1.0;
        if (abs(p.x) < 0.015) isGate = 1.0; 
        
        if (abs(p.y - 0.4) < 0.01) isGate = 1.0;
        if (abs(p.y - 0.2) < 0.01) isGate = 1.0;
        if (abs(p.y - (-0.3)) < 0.01) isGate = 1.0;
        if (abs(p.y - (-0.45)) < 0.01) isGate = 1.0;
        
        if (fract(p.x * 15.0) < 0.1 && p.y > 0.4) isGate = 1.0;
        if (fract(p.x * 15.0) < 0.1 && p.y < -0.45) isGate = 1.0;
        
        if (p.y > -0.45 && p.y < -0.3) {
            vec2 lp = vec2(fract(p.x * 5.0), p.y);
            if (abs(length(lp - vec2(0.5, -0.4)) - 0.08) < 0.01) isGate = 1.0;
            if (abs(lp.x - 0.5) < 0.01) isGate = 1.0;
        }
        
        if (isGate > 0.0) col = gateCol;
    }
}

void layer_RedChineseCharacters(in vec2 p, in float isGate, inout vec3 col) {
    if (abs(p.x) < 0.6 && p.y > -0.65 && p.y < 0.65) {
        if (p.y > -0.2 && p.y < 0.2) {
            float isChar = 0.0;
            vec2 cp = p;
            cp.x = fract(p.x * 2.0) - 0.5; 
            
            if (abs(cp.y) < 0.15 && abs(cp.x) < 0.15) {
                if (abs(abs(cp.x) - 0.15) < 0.02) isChar = 1.0;
                if (abs(abs(cp.y) - 0.15) < 0.02) isChar = 1.0;
                if (abs(cp.y) < 0.02) isChar = 1.0;
                if (abs(cp.x) < 0.02) isChar = 1.0;
            }
            
            if (isChar > 0.0) {
                col = vec3(0.7, 0.2, 0.2); 
            }
        }
    }
}

void layer_WhitePaperSign(in vec2 p, inout vec3 col) {
    if (abs(p.x) < 0.6 && p.y > -0.65 && p.y < 0.65) {
        float dSign = max(abs(p.x - 0.15) - 0.1, abs(p.y - 0.0) - 0.08);
        if (dSign < 0.0) {
            col = vec3(0.95); 
            if (fract(p.y * 20.0) < 0.3 && abs(p.y) < 0.06 && abs(p.x - 0.15) < 0.08) {
                col = vec3(0.1); 
            }
        }
    }
}

void layer_Vignette(in vec2 p, inout vec3 col) {
    col *= 1.0 - 0.1 * length(p);
}

vec4 layer_BackgroundCourtyard(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_BackgroundCourtyard(p, iTime, col);
    
    float isGate;
    


  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

vec4 layer_TempleGateHeader(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_TempleGateHeader(p, iTime, col);
    
    float isGate;
    


  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

vec4 layer_TempleGatePillars(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_TempleGatePillars(p, col);
    
    float isGate;
    


  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

vec4 layer_TempleGateGrid(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    
    float isGate;
    layer_TempleGateGrid(p, iTime, col, isGate);
    


  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

vec4 layer_RedChineseCharacters(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    
    float isGate;
    layer_RedChineseCharacters(p, isGate, col);
    


  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

vec4 layer_WhitePaperSign(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    
    float isGate;
    layer_WhitePaperSign(p, col);
    


  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

vec4 layer_Vignette(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    
    float isGate;
    
    layer_Vignette(p, col);


  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

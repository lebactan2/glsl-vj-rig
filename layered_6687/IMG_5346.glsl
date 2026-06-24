void layer_Banner(in vec2 p, in float iTime, inout vec3 col) {
    if (p.y > 0.2) {
        col = vec3(0.8, 0.15, 0.15);
        
        vec3 yellow = vec3(0.95, 0.8, 0.2);
        float highlight = 0.0;
        
        if (p.y > 0.6) {
            float x1 = max(abs(p.x + p.y*0.5 + 0.4) - 0.05, abs(p.y - 0.8) - 0.15);
            float x2 = max(abs(p.x - p.y*0.5 + 0.4) - 0.05, abs(p.y - 0.8) - 0.15);
            float i1 = max(abs(p.x - 0.1) - 0.04, abs(p.y - 0.8) - 0.15);
            float i2 = max(abs(p.x - 0.3) - 0.04, abs(p.y - 0.8) - 0.15);
            float i3 = max(abs(p.x - 0.5) - 0.04, abs(p.y - 0.8) - 0.15);
            
            float numerals = min(min(x1, x2), min(min(i1, i2), i3));
            if (numerals < 0.0) highlight = 1.0;
        }
        
        if (p.y > 0.3 && p.y < 0.5) {
            float letters = fract(p.x * 8.0);
            if (letters < 0.6 && abs(p.x) < 1.2) {
                if (fract(p.x * 24.0 + p.y*10.0) > 0.3) {
                    highlight = 1.0;
                }
            }
        }
        
        if (highlight > 0.0) {
            col = yellow;
            float glint = smoothstep(0.1, 0.0, abs(p.x + p.y - mod(iTime * 1.5, 4.0) + 1.0));
            col += vec3(0.5) * glint;
        }
    }
}

void layer_Background(in vec2 p, inout vec3 col) {
    if (p.y <= 0.2 && p.y > -0.25) {
        col = vec3(0.5, 0.45, 0.4);
        if (p.y > 0.18) col = vec3(0.6, 0.55, 0.5);
    } else if (p.y <= -0.25) {
        col = vec3(0.5, 0.35, 0.3);
        vec2 floorP = vec2(p.x / (p.y - 0.1), p.y);
        float pattern = sin(floorP.x * 20.0 + floorP.y * 30.0) * sin(floorP.x * 20.0 - floorP.y * 30.0);
        if (pattern > 0.5) col = vec3(0.6, 0.45, 0.4);
        if (abs(pattern) < 0.1) col = vec3(0.3, 0.25, 0.2);
    }
}

void layer_Plants(in vec2 p, in float iTime, inout vec3 col) {
    float cellWidth = 0.6;
    float potIdx = floor((p.x + cellWidth*2.5) / cellWidth);
    
    if (potIdx >= 0.0 && potIdx <= 4.0) {
        vec2 pp = vec2(mod(p.x + cellWidth*2.5, cellWidth) - cellWidth*0.5, p.y);
        
        float potBase = -0.25;
        float potTop = 0.0;
        float potW = 0.1 + (pp.y) * 0.12; 
        
        if (pp.y > potBase && pp.y < potTop && abs(pp.x) < potW) {
            col = vec3(0.9);
            col *= 0.7 + 0.3 * smoothstep(0.0, potW, pp.x + 0.05);
        }
        
        if (pp.y > -0.05 && pp.y < 0.4 && abs(pp.x) < 0.3) {
            float sway = sin(iTime * 1.5 + potIdx) * (pp.y + 0.05) * 0.2;
            vec2 ppp = pp - vec2(sway, 0.0);
            
            float dCenter = length(ppp - vec2(0.0, 0.15));
            float leafShape = dCenter - 0.15 - sin(atan(ppp.y-0.15, ppp.x)*10.0 + potIdx)*0.08;
            
            if (leafShape < 0.0) {
                col = vec3(0.1, 0.25, 0.1);
                col *= 0.8 + 0.2 * sin(ppp.x*50.0 + potIdx);
            }
            
            for(int i=0; i<3; i++) {
                float fi = float(i) + potIdx;
                vec2 fPos = vec2(sin(fi*7.3)*0.15, 0.2 + cos(fi*4.1)*0.1);
                vec2 fp = ppp - fPos;
                
                float a = atan(fPos.x, fPos.y);
                mat2 rot = mat2(cos(a), -sin(a), sin(a), cos(a));
                fp = rot * fp;
                
                float flower = length(vec2(fp.x, max(0.0, fp.y) + min(0.0, fp.y)*2.0)) - 0.03;
                
                if (flower < 0.0) {
                    col = vec3(0.95);
                    if (abs(fp.x) < 0.005 && fp.y > -0.02 && fp.y < 0.02) {
                        col = vec3(0.8, 0.8, 0.2);
                    }
                }
            }
        }
    }
}

vec4 layer_Banner(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_Banner(p, iTime, col);


  return vec4(clamp(col,0.0,1.0), step(0.0, max(col.r, max(col.g, col.b))));
}

vec4 layer_Background(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_Background(p, col);


  return vec4(clamp(col,0.0,1.0), step(0.0, max(col.r, max(col.g, col.b))));
}

vec4 layer_Plants(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_Plants(p, iTime, col);


  return vec4(clamp(col,0.0,1.0), step(0.0, max(col.r, max(col.g, col.b))));
}

void layer_Background(in vec2 p, inout vec3 col) {
    col = vec3(0.9, 0.9, 0.9);
}

void layer_Casing(in vec2 p, inout vec2 bp, out float dCasing, out float boxW, out float boxH) {
    boxW = 1.3;
    boxH = 0.5;
    
    bp = p;
    bp.y *= 1.0 + (bp.x + 1.0) * 0.05;
    
    dCasing = max(abs(bp.x) - boxW, abs(bp.y) - boxH);
}

void layer_ScrollingContent(in vec2 scrollP, in float iTime, inout vec3 ledCol) {
    vec2 logoP = scrollP - vec2(-0.7, 0.0);
    float dLogo = length(logoP) - 0.25;
    if (dLogo < 0.0) {
        float a = atan(logoP.y, logoP.x) + iTime * 2.0;
        ledCol = vec3(1.0, 0.1, 0.1); 
        if (sin(a * 8.0) > 0.5 && length(logoP) > 0.15) ledCol = vec3(0.0);
        if (length(logoP) < 0.1) ledCol = vec3(0.0); 
    }
    
    if (scrollP.x > -0.2 && scrollP.y > 0.15 && scrollP.y < 0.35) {
        if (fract(scrollP.x * 15.0) > 0.2 && fract(scrollP.y * 10.0) > 0.2) {
            ledCol = vec3(0.8, 1.0, 0.2); 
        }
    }
    
    if (scrollP.x > -0.2 && scrollP.y > -0.1 && scrollP.y < 0.1) {
        if (fract(scrollP.x * 12.0) > 0.2 && fract(scrollP.y * 8.0) > 0.2) {
            ledCol = mix(vec3(1.0, 0.2, 0.8), vec3(0.2, 0.8, 1.0), sin(iTime*5.0)*0.5+0.5); 
        }
    }
    
    if (scrollP.x > -0.8 && scrollP.y > -0.35 && scrollP.y < -0.15) {
        if (fract(scrollP.x * 20.0) > 0.2 && fract(scrollP.y * 12.0) > 0.2) {
            ledCol = vec3(0.1, 1.0, 0.3); 
        }
    }
}

void layer_Screen(in vec2 bp, in float boxW, in float boxH, in float iTime, inout vec3 col) {
    float sW = boxW - 0.12;
    float sH = boxH - 0.08;
    float dScreen = max(abs(bp.x + 0.05) - sW, abs(bp.y) - sH);
    
    if (dScreen < 0.0) {
        vec3 screenCol = vec3(0.05, 0.0, 0.0);
        
        vec2 gridP = bp * vec2(60.0, 30.0);
        vec2 fGrid = fract(gridP) - 0.5;
        float isDot = smoothstep(0.45, 0.35, length(fGrid));
        
        if (isDot > 0.0) {
            vec3 ledCol = vec3(0.0); 
            
            float bx = abs(bp.x + 0.05);
            float by = abs(bp.y);
            if (bx > sW - 0.03 || by > sH - 0.04) {
                float cId = mod(floor(gridP.x) + floor(gridP.y) - iTime*10.0, 3.0);
                if (cId < 1.0) ledCol = vec3(1.0, 0.0, 0.0);
                else if (cId < 2.0) ledCol = vec3(0.0, 1.0, 0.0);
                else ledCol = vec3(0.0, 0.0, 1.0);
            } else {
                vec2 scrollP = bp;
                scrollP.x += fract(iTime * 0.3) * 3.0 - 1.5; 
                scrollP.x = mod(scrollP.x + 1.5, 3.0) - 1.5;
                
                layer_ScrollingContent(scrollP, iTime, ledCol);
            }
            
            screenCol = mix(screenCol, ledCol * 1.5, isDot * (ledCol.r + ledCol.g + ledCol.b > 0.0 ? 1.0 : 0.0));
        }
        
        col = screenCol;
        col += vec3(0.1, 0.2, 0.1) * (1.0 - length(bp));
    }
}

vec4 layer_Background(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_Background(p, col);
    
    vec2 bp;
    float dCasing, boxW, boxH;
    
    if (dCasing < 0.0) {
        col *= 0.8 + 0.2 * bp.y;
        
        if (bp.x < -boxW + 0.1) {
        } else {
        }
    }

    col *= 1.0 - 0.1 * length(p);
    

  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

vec4 layer_Casing(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    
    vec2 bp;
    float dCasing, boxW, boxH;
    layer_Casing(p, bp, dCasing, boxW, boxH);
    
    if (dCasing < 0.0) {
        col *= 0.8 + 0.2 * bp.y;
        
        if (bp.x < -boxW + 0.1) {
        } else {
        }
    }

    col *= 1.0 - 0.1 * length(p);
    

  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

vec4 layer_Screen(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    
    vec2 bp;
    float dCasing, boxW, boxH;
    
    if (dCasing < 0.0) {
        col *= 0.8 + 0.2 * bp.y;
        
        if (bp.x < -boxW + 0.1) {
        } else {
        }
    }

    col *= 1.0 - 0.1 * length(p);
    

  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

vec4 layer_ScrollingContent(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    
    vec2 bp;
    float dCasing, boxW, boxH;
    
    if (dCasing < 0.0) {
        col *= 0.8 + 0.2 * bp.y;
        
        if (bp.x < -boxW + 0.1) {
        } else {
            layer_Screen(bp, boxW, boxH, iTime, col);
        }
    }

    col *= 1.0 - 0.1 * length(p);
    

  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

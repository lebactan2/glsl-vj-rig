void layer_Background(in vec2 p, in float iTime, inout vec3 col) {
    col = vec3(0.8, 0.8, 0.82); 
    
    if (p.y > 0.7 && p.x > -0.5 && p.x < 0.6) {
        col = vec3(0.6, 0.75, 0.4); 
        if (p.y > 0.85 && p.y < 0.95) {
            col = vec3(0.6, 0.75, 0.4); 
            if (fract(p.x * 6.0) < 0.5 && p.x > -0.4 && p.x < 0.5) col = vec3(0.8, 0.2, 0.2);
        }
        if (p.y > 0.75 && p.y < 0.85) {
            if (abs(p.x) < 0.2) col = vec3(0.2, 0.3, 0.5);
        }
    }
    
    if (p.y > 0.6 && p.y <= 0.7) {
        col = vec3(0.5, 0.2, 0.2); 
        if (p.x < -0.4 || p.x > 0.5) col = vec3(0.8, 0.8, 0.82); 
        if (p.y > 0.65 && p.x < -0.1) {
            if (fract(p.x * 10.0 + sin(p.x*20.0 + iTime)*0.5) < 0.3) col = vec3(0.3, 0.5, 0.4);
        }
    }
}

void layer_Facade(in vec2 p, in float iTime, inout vec3 col) {
    if (p.y > -0.6 && p.y <= 0.6) {
        col = vec3(0.4, 0.65, 0.65); 
        
        if (p.x > 0.8) col = vec3(0.4, 0.2, 0.2); 
        
        float dFrame = max(abs(p.x) - 0.5, abs(p.y) - 0.3);
        if (dFrame < 0.0) {
            col = vec3(0.15, 0.1, 0.1); 
            
            vec3 grateCol = vec3(0.8, 0.7, 0.3); 
            float isGrate = 0.0;
            
            if (dFrame > -0.05) isGrate = 1.0;
            
            vec2 gridP = p;
            gridP.x += sin(iTime + p.y * 5.0) * 0.02;
            
            if (fract(gridP.x * 5.0) < 0.05) isGrate = 1.0;
            if (fract(gridP.y * 5.0) < 0.05) isGrate = 1.0;
            vec2 gp = fract(gridP * 5.0);
            if (abs(gp.x - 0.5) < 0.05 || abs(gp.y - 0.5) < 0.05) isGrate = 0.5;
            
            if (isGrate > 0.0) col = mix(col, grateCol, isGrate);
            
            if (abs(p.y) < 0.12 && abs(p.x) < 0.4) {
                col = vec3(0.8, 0.7, 0.2); 
                
                if (abs(p.x - (-0.25)) < 0.06 || abs(p.x) < 0.06 || abs(p.x - 0.25) < 0.06) {
                    if (abs(p.y) < 0.08) {
                        if (fract(p.y * 15.0) < 0.5 || fract(p.x * 20.0) < 0.5) {
                            col = vec3(0.7, 0.2, 0.2); 
                        }
                    }
                }
            }
        }
        
        vec3 goldCol = vec3(0.75, 0.65, 0.2);
        
        vec2 lp = p - vec2(-0.7, 0.0);
        float dL = length(max(abs(lp) - vec2(0.1, 0.3), 0.0)) - 0.05;
        dL = min(dL, abs(length(lp - vec2(0.1, 0.2)) - 0.15) - 0.05); 
        dL = min(dL, abs(length(lp - vec2(0.1, -0.2)) - 0.1) - 0.04); 
        
        vec2 rp = p - vec2(0.65, 0.0);
        float dR = length(max(abs(rp) - vec2(0.1, 0.3), 0.0)) - 0.05;
        dR = min(dR, abs(length(rp - vec2(-0.1, 0.2)) - 0.15) - 0.05);
        dR = min(dR, abs(length(rp - vec2(-0.1, -0.2)) - 0.1) - 0.04);
        
        if (dL < 0.0 || dR < 0.0) {
            col = goldCol;
            col *= 0.7 + 0.3 * sin(p.x * 50.0 + p.y * 50.0 + iTime * 5.0);
            if (p.y < 0.0) col *= 0.8;
        }
        
        if (abs(p.x) < 0.15 && p.y > 0.3 && p.y < 0.5) {
            if (length(p - vec2(0.0, 0.4)) < 0.1) col = goldCol;
        }
    }
}

void layer_BottomRoof(in vec2 p, inout vec3 col) {
    if (p.y <= -0.6) {
        vec2 tp = p;
        tp.x = fract(tp.x * 10.0) - 0.5;
        col = vec3(0.6, 0.3, 0.25); 
        
        float arc = length(tp - vec2(0.0, 0.5)) - 0.5;
        if (arc < 0.0) col *= 0.8;
        if (abs(arc) < 0.05) col *= 0.6;
        
        if (p.y > -0.65) col = vec3(0.2, 0.4, 0.3);
        
        if (p.x < -0.8 && p.y > -0.8) col = vec3(0.9);
        if (p.x > 0.8 && p.y > -0.8) {
            col = vec3(0.2, 0.4, 0.3);
            if (fract(p.x * 10.0 + p.y * 10.0) < 0.5) col = vec3(0.8, 0.7, 0.2);
        }
    }
}

void layer_Vignette(in vec2 p, inout vec3 col) {
    col *= 1.0 - 0.1 * length(p);
}

vec4 layer_Background(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_Background(p, iTime, col);


  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

vec4 layer_Facade(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_Facade(p, iTime, col);


  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

vec4 layer_BottomRoof(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_BottomRoof(p, col);


  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

vec4 layer_Vignette(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_Vignette(p, col);


  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

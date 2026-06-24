void layer_BackgroundWall(in vec2 p, in float iTime, inout vec3 col) {
    col = vec3(0.8, 0.65, 0.55); 
    
    if (p.y > 0.6) {
        col = vec3(0.4, 0.15, 0.15); 
        if (p.y < 0.62) col *= 0.5; 
    }
    
    if (p.x < -0.6 && p.y > 0.2) {
        col = vec3(0.8, 0.8, 0.8); 
        if (p.x + 0.6 > p.y - 0.2) {
            col = vec3(0.3, 0.3, 0.3); 
        }
    }
    
    if (p.x > 0.8) {
        col = vec3(0.6, 0.6, 0.55); 
        col *= 0.8 + 0.2 * fract(sin(p.x*100.0)*40.0 + iTime);
        if (abs(p.x - 0.9) < 0.02) col *= 0.6;
    }
}

void layer_CenterWindow(in vec2 p, inout vec3 col) {
    float dCircle = length(p - vec2(0.0, 0.0)) - 0.25;
    if (dCircle < 0.0) {
        col = vec3(0.3, 0.1, 0.1); 
        
        if (dCircle < -0.05) {
            col = vec3(0.85); 
            vec2 cp = p;
            if (abs(cp.x) < 0.15 && abs(cp.y) < 0.15) {
                if (abs(cp.y) < 0.02 || abs(cp.x) < 0.02 || abs(cp.x + cp.y) < 0.03 || abs(cp.x - cp.y) < 0.03) {
                    
                } else {
                    col = vec3(0.15); 
                }
            } else if (dCircle < -0.06) {
                col = vec3(0.15);
            }
        }
    }
}

void layer_BalconyRailing(in vec2 p, in float iTime, inout vec3 col) {
    if (p.y > -0.4 && p.y < 0.2) {
        vec3 railCol = vec3(0.6, 0.5, 0.4); 
        float isRail = 0.0;
        
        if (abs(p.y - 0.2) < 0.01) isRail = 1.0;
        if (abs(p.y - (-0.4)) < 0.01) isRail = 1.0;
        
        if (abs(p.x - (-0.8)) < 0.01) isRail = 1.0;
        if (abs(p.x - 0.8) < 0.01) isRail = 1.0;
        if (abs(p.x - (-0.3)) < 0.01) isRail = 1.0;
        if (abs(p.x - 0.3) < 0.01) isRail = 1.0;
        
        if (max(abs(p.x) - 0.3, abs(p.y + 0.1) - 0.3) > 0.0 && max(abs(p.x) - 0.3, abs(p.y + 0.1) - 0.3) < 0.01) isRail = 1.0;
        
        vec2 lp = p;
        lp.x = abs(p.x); 
        if (lp.x > 0.3 && lp.x < 0.8) {
            vec2 lpc = lp - vec2(0.55, -0.2);
            float breath = sin(iTime * 2.0 + lp.x * 5.0) * 0.02;
            if (length(lpc) < 0.15 + breath && lpc.y > 0.0) {
                if (fract(length(lpc)*10.0 - iTime*2.0) < 0.2) {
                    col = mix(col, vec3(0.3, 0.5, 0.4), 0.8);
                    isRail = 0.5;
                }
            }
            if (abs(lpc.x) < 0.01 && lpc.y < 0.0) isRail = 1.0; 
        }
        
        if (isRail > 0.9) col = railCol;
    }
}

void layer_BottomRedSection(in vec2 p, inout vec3 col) {
    if (p.y < -0.4) {
        col = vec3(0.4, 0.15, 0.15); 
        if (p.y > -0.45) col *= 0.5; 
        
        if (abs(p.x) < 0.15) col *= 0.8;
    }
}

void layer_CenterPost(in vec2 p, inout vec3 col) {
    if (p.y < -0.4 && p.y > -1.0) {
        float dPost = max(abs(p.x) - 0.1, abs(p.y + 0.7) - 0.3);
        if (dPost < 0.0) {
            col = vec3(0.8, 0.8, 0.8); 
            if (abs(abs(p.x) - 0.1) < 0.01) col *= 0.5;
            
            if (p.y > -0.6) {
                col = vec3(0.7, 0.6, 0.2); 
                if (p.y > -0.5) col = vec3(0.2, 0.4, 0.3); 
                if (p.y > -0.45) col = vec3(0.8, 0.7, 0.2); 
                
                col *= 0.5 + 0.5 * cos(p.x * 20.0);
            }
            
            if (length(p - vec2(0.0, -0.8)) < 0.05) col = vec3(0.2);
        }
    }
}

void layer_Vignette(in vec2 p, inout vec3 col) {
    col *= 1.0 - 0.1 * length(p);
}

vec4 layer_BackgroundWall(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_BackgroundWall(p, iTime, col);


  return vec4(clamp(col,0.0,1.0), step(0.0, max(col.r, max(col.g, col.b))));
}

vec4 layer_CenterWindow(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_CenterWindow(p, col);


  return vec4(clamp(col,0.0,1.0), step(0.0, max(col.r, max(col.g, col.b))));
}

vec4 layer_BalconyRailing(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_BalconyRailing(p, iTime, col);


  return vec4(clamp(col,0.0,1.0), step(0.0, max(col.r, max(col.g, col.b))));
}

vec4 layer_BottomRedSection(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_BottomRedSection(p, col);


  return vec4(clamp(col,0.0,1.0), step(0.0, max(col.r, max(col.g, col.b))));
}

vec4 layer_CenterPost(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_CenterPost(p, col);


  return vec4(clamp(col,0.0,1.0), step(0.0, max(col.r, max(col.g, col.b))));
}

vec4 layer_Vignette(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_Vignette(p, col);


  return vec4(clamp(col,0.0,1.0), step(0.0, max(col.r, max(col.g, col.b))));
}

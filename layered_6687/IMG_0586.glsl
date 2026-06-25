void layer_InstagramUI(in vec2 p, inout vec3 col, out bool isUI) {
    isUI = false;
    if (p.y > 0.8) {
        isUI = true;
        col = vec3(0.08);
        if (p.y > 0.85 && p.y < 0.95) {
            float sx = fract(p.x * 2.0) - 0.5;
            if (length(vec2(sx, (p.y - 0.9)*5.0)) < 0.2) col = vec3(0.4);
        }
    } else if (p.y < -0.8) {
        isUI = true;
        col = vec3(0.05);
    } else if (p.y < -0.65 && p.y >= -0.8) {
        isUI = true;
        col = vec3(0.9, 0.15, 0.25);
    }
}

void layer_BackgroundWall(inout vec3 col) {
    col = vec3(0.85, 0.88, 0.85);
}

void layer_PerforatedTable(in vec2 p, inout vec3 col) {
    if (p.y < -0.15) {
        col = vec3(0.6, 0.65, 0.65);
        vec2 tp = p;
        tp.y = tp.y + 0.15;
        tp.x = tp.x / (1.0 - tp.y * 0.5);
        
        vec2 grid = fract(tp * vec2(20.0, 30.0)) - 0.5;
        if (length(grid) < 0.25) {
            col = vec3(0.1);
        }
        col *= 0.7 - tp.y * 0.5;
    }
}

void layer_RedBook(in vec2 p, inout vec3 col) {
    float bookLeft = -0.4;
    float bookRight = 0.5;
    float bookBottom = -0.25;
    float bookTop = 0.6;
    
    if (p.x > -0.35 && p.x < 0.55 && p.y > 0.6 && p.y < 0.75) {
        col = vec3(0.7, 0.1, 0.2);
        if (fract(p.y * 20.0) < 0.1) col *= 0.5;
    }
    
    if (p.x > bookLeft && p.x < bookRight && p.y > bookBottom && p.y < bookTop) {
        col = vec3(0.75, 0.1, 0.2);
        
        if (p.x < bookLeft + 0.05) {
            col = vec3(0.9, 0.9, 0.9);
            if (fract(p.y * 10.0) < 0.5 && p.x > bookLeft + 0.02) col = vec3(0.1);
        }
        
        if (p.x > -0.1 && p.x < 0.3 && p.y > 0.2 && p.y < 0.4) {
            float textPat = fract(p.x * 10.0);
            if (textPat > 0.2 && textPat < 0.8) {
                if (p.y > 0.31 || p.y < 0.29) {
                    col = vec3(0.95);
                }
            }
        }
        
        if (p.x > -0.1 && p.x < 0.25 && p.y > 0.12 && p.y < 0.15) {
            if (fract(p.x * 30.0) > 0.3) col = vec3(0.9);
        }
        
        if (length(p - vec2(0.1, -0.15)) < 0.04) {
            col = vec3(0.9);
        }
        
        col *= 0.9 + 0.1 * p.x;
    }
}

vec4 layer_InstagramUI(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;
    
    vec3 col = vec3(-1.0);
    bool isUI;
    
    layer_InstagramUI(p, col, isUI);
    
    if (!isUI) {
    }
    

  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

vec4 layer_BackgroundWall(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;
    
    vec3 col = vec3(-1.0);
    bool isUI;
    
    
    if (!isUI) {
        layer_BackgroundWall(col);
    }
    

  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

vec4 layer_PerforatedTable(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;
    
    vec3 col = vec3(-1.0);
    bool isUI;
    
    
    if (!isUI) {
        layer_PerforatedTable(p, col);
    }
    

  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

vec4 layer_RedBook(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;
    
    vec3 col = vec3(-1.0);
    bool isUI;
    
    
    if (!isUI) {
        layer_RedBook(p, col);
    }
    

  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

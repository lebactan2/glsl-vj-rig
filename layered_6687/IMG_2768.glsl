void layer_AltarCloth(in vec2 p, in float iTime, inout vec3 col) {
    if (p.y > 0.4) {
        col = vec3(0.85, 0.75, 0.2); 
        
        float shimmer = sin(p.x * 20.0 + p.y * 30.0 + iTime * 2.0) * 0.1;
        col += shimmer;
        
        float folds = sin(p.x * 10.0) * 0.1;
        col *= 1.0 + folds;
        
        if (p.y > 0.5) {
            vec2 fP = vec2(fract(p.x * 5.0 + iTime*0.2), p.y);
            if (length(fP - vec2(0.5, 0.7)) < 0.1) col = vec3(0.9, 0.2, 0.4); 
            
            if (abs(p.y - 0.6) < 0.15 && fract(p.x * 3.0 - iTime*0.1) < 0.4) {
                if (sin(p.x * 40.0) * cos(p.y * 50.0) > 0.3) col = vec3(0.8, 0.1, 0.1); 
            }
            
            if (abs(p.x) < 0.6 && p.y > 0.45 && p.y < 0.75) {
                vec2 charGrid = fract(vec2(p.x * 4.0, p.y * 5.0));
                if (charGrid.x > 0.2 && charGrid.x < 0.8 && charGrid.y > 0.2 && charGrid.y < 0.8) {
                    if (fract(p.x * 20.0 + sin(p.y * 30.0)) < 0.3) col = vec3(0.8, 0.1, 0.1);
                }
            }
        }
        
        if (p.y > 0.4 && p.y < 0.43) {
            if (fract(p.x * 30.0) < 0.4) col = vec3(0.8, 0.2, 0.2); 
            else col = vec3(0.7, 0.6, 0.2); 
        }
    }
}

void layer_Floor(in vec2 p, in float iTime, inout vec3 col) {
    if (!(p.y > 0.4)) {
        float floorDepth = 0.4 - p.y;
        vec2 floorP = vec2(p.x / floorDepth, 1.0 / floorDepth);
        
        floorP.y -= iTime * 0.5;
        
        vec2 grid = floorP * 3.0; 
        vec2 f = fract(grid);
        vec2 id = floor(grid);
        
        vec3 tileCol = vec3(0.5, 0.35, 0.25); 
        
        vec2 center = vec2(0.5);
        float dist = abs(f.x - center.x) + abs(f.y - center.y); 
        
        if (dist < 0.3) {
            tileCol = vec3(0.3, 0.45, 0.3); 
            float starDist = max(abs(f.x - center.x)*1.5, abs(f.y - center.y)*1.5);
            if (starDist < 0.15) tileCol = vec3(0.2, 0.3, 0.2); 
        } else if (dist > 0.45) {
            tileCol = vec3(0.4, 0.5, 0.35); 
            if (abs(f.x - 0.5) < 0.48 && abs(f.y - 0.5) < 0.48) {
                if (abs(f.x - f.y) < 0.05) tileCol = vec3(0.8, 0.8, 0.7); 
            }
        }
        
        if (f.x < 0.02 || f.y < 0.02) tileCol = vec3(0.2); 
        
        col = tileCol;
        
        if (floorP.x > -1.5 && floorP.x < 1.5 && floorP.y > -1.0 && floorP.y < 1.0) {
            vec2 matGrid = floorP * 5.0;
            vec2 mf = fract(matGrid);
            
            col = vec3(0.6); 
            if (mf.x > 0.5) col = vec3(0.8); 
            if (mf.y > 0.5) col = vec3(0.4); 
            if (mf.x > 0.5 && mf.y > 0.5) col = vec3(0.7);
            
            float rnd = fract(sin(dot(floor(matGrid), vec2(12.9898, 78.233))) * 43758.5453);
            if (rnd < 0.3) col *= 0.8; 
            if (rnd > 0.7) col *= 1.2; 
        }
        
        float flash = 1.0 / (length(vec2(p.x, p.y + 0.2)) * 5.0);
        float pulse = 0.5 + 0.5 * sin(iTime * 3.0);
        col += vec3(0.9, 0.9, 0.8) * clamp(flash * 0.3 * pulse, 0.0, 0.3);
        
        col *= clamp((0.4 - p.y) * 2.0, 0.0, 1.0);
    }
}

void layer_Feet(in vec2 p, in float iTime, inout vec3 col) {
    if (p.y < -0.8) {
        float bob = sin(iTime * 2.0) * 0.02;
        if (abs(p.x + 0.2) < 0.1 || abs(p.x - 0.2) < 0.1) {
            if (p.y > -0.95 + bob) {
                col = vec3(0.7, 0.5, 0.4); 
                if (fract(p.x * 40.0) < 0.2 && p.y > -0.85 + bob) col *= 0.8; 
            }
        }
        if (p.y < -0.95 + bob) {
            col = vec3(0.1); 
            if (abs(p.x) < 0.1) col = vec3(0.6, 0.8, 0.2); 
        }
    }
}

vec4 layer_AltarCloth(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_AltarCloth(p, iTime, col);


  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

vec4 layer_Floor(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_Floor(p, iTime, col);


  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

vec4 layer_Feet(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_Feet(p, iTime, col);


  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

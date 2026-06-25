void layer_WallBase(in vec2 p, in float iTime, inout vec3 col) {
    col = vec3(0.5, 0.1, 0.15); 
    vec2 wallGrid = vec2(p.x * 5.0, p.y * 10.0);
    if (fract(wallGrid.x) < 0.03 || fract(wallGrid.y) < 0.05) {
        col = vec3(0.8); 
    }
    
    float wallNoise = fract(sin(dot(p + iTime*0.05, vec2(12.9898, 78.233))) * 43758.5453);
    col -= wallNoise * 0.05;
}

void layer_Awning(in vec2 p, in float iTime, inout vec3 col) {
    if (p.y < -0.4) {
        float awX = p.x + p.y * 0.5; 
        
        float stripe = fract(awX * 15.0 - iTime);
        if (stripe < 0.3) col = vec3(0.8, 0.7, 0.2); 
        else if (stripe < 0.6) col = vec3(0.7, 0.2, 0.2); 
        else if (stripe < 0.8) col = vec3(0.3, 0.6, 0.3); 
        else col = vec3(0.8, 0.7, 0.2); 
        
        col *= clamp((p.y + 1.0) * 1.5, 0.2, 1.0);
    }
}

void layer_Symbol(in vec2 p, in float iTime, inout vec3 col) {
    vec2 center = vec2(-0.2, 0.1); 
    vec2 symP = p - center;
    float r = length(symP);
    float angle = atan(symP.y, symP.x);
    
    if (r < 0.45) {
        col = vec3(0.85, 0.7, 0.3); 
        
        if (r < 0.1) {
            col = vec3(0.9); 
            if (symP.x > 0.0) col = vec3(0.1); 
        }
        
        if (r > 0.12 && r < 0.25) {
            float seg = fract(angle / 6.28318 * 8.0);
            if (seg > 0.1 && seg < 0.9) {
                float ringDist = (r - 0.12) / 0.13;
                if (fract(ringDist * 4.0) < 0.6) col = vec3(0.6, 0.2, 0.2); 
            }
        }
        
        if (r > 0.28 && r < 0.4) {
            float aId = floor(angle / 6.28318 * 8.0 + 0.5);
            vec2 dotPos = vec2(cos(aId * 6.28318 / 8.0), sin(aId * 6.28318 / 8.0)) * 0.35;
            float d2 = length(symP - dotPos);
            
            float dotScale = 1.0 + 0.2 * sin(iTime * 3.0 + aId);
            
            if (d2 < 0.05 * dotScale) {
                if (mod(aId, 2.0) < 1.0) col = vec3(0.1);
                else col = vec3(0.8);
            }
            if (r > 0.33 && r < 0.37 && fract(angle * 4.0) < 0.1) col = vec3(0.1);
        }
        
        if (r > 0.43) col *= 0.6;
        col *= 0.8 + 0.2 * sin(r * 30.0 + iTime); 
    }
}

void layer_LeavesOverlay(in vec2 p, in float iTime, inout vec3 col) {
    float leafDensity = 0.0;
    
    vec2 wind = vec2(sin(iTime*0.5)*0.1, cos(iTime*0.3)*0.05);
    vec2 lP = p + wind;
    
    leafDensity += sin(lP.x * 20.0 + sin(lP.y * 15.0 + iTime)) * 0.5 + 0.5;
    leafDensity += cos(lP.x * 35.0 - lP.y * 40.0 - iTime*1.5) * 0.5 + 0.5;
    
    float leafMask = smoothstep(-0.2, 1.0, p.y + p.x);
    leafDensity *= leafMask;
    
    if (leafDensity > 1.0) {
        vec3 leafCol = vec3(0.2, 0.4, 0.2); 
        if (fract(lP.x * 12.0) < 0.5) leafCol = vec3(0.3, 0.5, 0.25); 
        
        vec2 grid = fract(lP * 15.0);
        if (length(grid - vec2(0.5)) < 0.4) {
            col = leafCol;
            if (grid.x > 0.5 && grid.y > 0.5) col += vec3(0.1);
        }
    }
    
    if (leafDensity > 0.5 && leafDensity <= 1.0) {
        col *= 0.7; 
    }
}

vec4 layer_WallBase(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_WallBase(p, iTime, col);


  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

vec4 layer_Awning(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_Awning(p, iTime, col);


  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

vec4 layer_Symbol(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_Symbol(p, iTime, col);


  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

vec4 layer_LeavesOverlay(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_LeavesOverlay(p, iTime, col);


  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

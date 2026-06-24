void layer_Wall(in vec2 p, inout vec3 col) {
    col = vec3(0.95); 
    if (p.x > 0.6) col = vec3(0.85, 0.9, 0.95); 
}

void layer_Floor(in vec2 p, in float iTime, inout vec3 col) {
    if (p.y < -0.4) {
        col = vec3(0.8, 0.85, 0.9); 
        if (fract(p.x * 4.0) < 0.05 || fract(p.y * 4.0) < 0.05) col = vec3(0.6);
        col += vec3(0.1) * max(0.0, sin(p.x*5.0 - p.y*10.0 + iTime*2.0));
    }
}

void layer_TV(in vec2 p, in float iTime, inout vec3 col) {
    float tv = max(abs(p.x - 0.2) - 0.25, abs(p.y - 0.3) - 0.15);
    if (tv < 0.0) {
        col = vec3(0.2, 0.3, 0.5);
        col += vec3(0.0, 0.1, 0.2) * sin(p.y * 50.0 - iTime * 10.0);
    }
}

void layer_Plant(in vec2 p, in float iTime, inout vec3 col) {
    if (p.x < -0.7 && p.y < -0.3) col = vec3(0.8); 
    if (p.x < -0.65 && p.y > -0.3 && p.y < 0.1) {
        col = vec3(0.2, 0.6, 0.2); 
        if (fract(p.y*10.0+p.x*5.0 + sin(iTime)*0.5) > 0.5) col *= 0.8;
    }
}

void layer_Furniture(in vec2 p, inout vec3 col) {
    float f = 0.0;
    f = max(f, 1.0 - smoothstep(0.0, 0.05, max(abs(p.x - 0.2) - 0.2, abs(p.y + 0.2) - 0.15)));
    f = max(f, 1.0 - smoothstep(0.0, 0.05, max(abs(p.x - 0.05) - 0.05, abs(p.y + 0.3) - 0.15)));
    f = max(f, 1.0 - smoothstep(0.0, 0.05, max(abs(p.x - 0.35) - 0.05, abs(p.y + 0.3) - 0.15)));
    
    if (f > 0.5) col = vec3(0.05); 
    
    if (max(abs(p.x - 0.2) - 0.15, abs(p.y + 0.1) - 0.1) < 0.0) col = vec3(0.9);
}

void layer_Figure(in vec2 p, in float iTime, inout vec3 col) {
    vec3 figCol = vec3(0.1);
    float goldNoise = fract(sin(p.x*50.0 + p.y*30.0)*43758.5);
    if (goldNoise > 0.7) {
        figCol = vec3(0.8, 0.6, 0.1); 
        figCol += vec3(0.4) * pow(abs(sin(p.x*20.0 + p.y*20.0 - iTime*4.0)), 4.0); 
    }
    
    if (length(p - vec2(-0.3, 0.2)) < 0.1) col = figCol;
    float body = max(abs(p.x + 0.3) - 0.12, abs(p.y + 0.05) - 0.25);
    if (body < 0.0) col = figCol;
}

void layer_GridBorders(in vec2 gridUV, inout vec3 col) {
    if (max(abs(fract(gridUV.x)-0.5), abs(fract(gridUV.y)-0.5)) > 0.49) col = vec3(1.0);
}

vec4 layer_Wall(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    
    vec2 gridUV = uv * vec2(2.0, 2.0);
    vec2 cell = floor(gridUV);
    vec2 p = fract(gridUV) * 2.0 - 1.0;
    p.x *= (iResolution.x/2.0) / (iResolution.y/2.0);
    
    vec3 col = vec3(-1.0);
    
    layer_Wall(p, col);


  return vec4(clamp(col,0.0,1.0), step(0.0, max(col.r, max(col.g, col.b))));
}

vec4 layer_Floor(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    
    vec2 gridUV = uv * vec2(2.0, 2.0);
    vec2 cell = floor(gridUV);
    vec2 p = fract(gridUV) * 2.0 - 1.0;
    p.x *= (iResolution.x/2.0) / (iResolution.y/2.0);
    
    vec3 col = vec3(-1.0);
    
    layer_Floor(p, iTime, col);


  return vec4(clamp(col,0.0,1.0), step(0.0, max(col.r, max(col.g, col.b))));
}

vec4 layer_TV(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    
    vec2 gridUV = uv * vec2(2.0, 2.0);
    vec2 cell = floor(gridUV);
    vec2 p = fract(gridUV) * 2.0 - 1.0;
    p.x *= (iResolution.x/2.0) / (iResolution.y/2.0);
    
    vec3 col = vec3(-1.0);
    
    layer_TV(p, iTime, col);


  return vec4(clamp(col,0.0,1.0), step(0.0, max(col.r, max(col.g, col.b))));
}

vec4 layer_Plant(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    
    vec2 gridUV = uv * vec2(2.0, 2.0);
    vec2 cell = floor(gridUV);
    vec2 p = fract(gridUV) * 2.0 - 1.0;
    p.x *= (iResolution.x/2.0) / (iResolution.y/2.0);
    
    vec3 col = vec3(-1.0);
    
    layer_Plant(p, iTime, col);


  return vec4(clamp(col,0.0,1.0), step(0.0, max(col.r, max(col.g, col.b))));
}

vec4 layer_Furniture(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    
    vec2 gridUV = uv * vec2(2.0, 2.0);
    vec2 cell = floor(gridUV);
    vec2 p = fract(gridUV) * 2.0 - 1.0;
    p.x *= (iResolution.x/2.0) / (iResolution.y/2.0);
    
    vec3 col = vec3(-1.0);
    
    layer_Furniture(p, col);


  return vec4(clamp(col,0.0,1.0), step(0.0, max(col.r, max(col.g, col.b))));
}

vec4 layer_Figure(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    
    vec2 gridUV = uv * vec2(2.0, 2.0);
    vec2 cell = floor(gridUV);
    vec2 p = fract(gridUV) * 2.0 - 1.0;
    p.x *= (iResolution.x/2.0) / (iResolution.y/2.0);
    
    vec3 col = vec3(-1.0);
    
    layer_Figure(p, iTime, col);


  return vec4(clamp(col,0.0,1.0), step(0.0, max(col.r, max(col.g, col.b))));
}

vec4 layer_GridBorders(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    
    vec2 gridUV = uv * vec2(2.0, 2.0);
    vec2 cell = floor(gridUV);
    vec2 p = fract(gridUV) * 2.0 - 1.0;
    p.x *= (iResolution.x/2.0) / (iResolution.y/2.0);
    
    vec3 col = vec3(-1.0);
    
    layer_GridBorders(gridUV, col);


  return vec4(clamp(col,0.0,1.0), step(0.0, max(col.r, max(col.g, col.b))));
}

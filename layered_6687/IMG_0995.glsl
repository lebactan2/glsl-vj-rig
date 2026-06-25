#define segment(p, a, b) length(p - a - (b - a) * clamp(dot(p - a, b - a) / dot(b - a, b - a), 0.0, 1.0))

void layer_Background(in vec2 p, inout vec3 col) {
    col = vec3(0.72, 0.72, 0.74);
    float plaster = fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
    col += (plaster - 0.5) * 0.04;
}

void layer_BalconyWall(in vec2 p, inout vec3 col) {
    if (p.y > -0.2 && p.y < 0.55 && abs(p.x) < 0.9) {
        col = vec3(0.25, 0.45, 0.5);
        col *= 0.8 + 0.2 * p.y;
    }
}

void layer_Clothesline(in vec2 p, in float iTime, inout vec3 col) {
    float sag = 0.25 - p.x * p.x * 0.05;
    if (abs(p.y - sag) < 0.003 && abs(p.x) < 0.85) col = vec3(0.1);
    
    for (float i = 0.0; i < 10.0; i++) {
        float cx = -0.7 + i * 0.15;
        float cw = 0.05 + sin(i * 10.0) * 0.01;
        float ch = 0.15 + cos(i * 20.0) * 0.05;
        
        vec2 cp = p - vec2(cx, sag);
        float sway = sin(iTime * 2.0 + i) * 0.05;
        cp.x -= cp.y * sway;
        
        float shirt = max(abs(cp.x) - cw, cp.y);
        shirt = max(shirt, -cp.y - ch);
        float sleeves = segment(cp, vec2(-cw, 0.0), vec2(-cw - 0.04, -0.05)) - 0.015;
        sleeves = min(sleeves, segment(cp, vec2(cw, 0.0), vec2(cw + 0.04, -0.05)) - 0.015);
        shirt = min(shirt, sleeves);
        
        if (shirt < 0.0) {
            vec3 cCol = mix(vec3(0.8, 0.2, 0.2), vec3(0.2, 0.3, 0.8), fract(i * 0.3));
            if (fract(i * 0.7) > 0.5) cCol = vec3(0.9, 0.8, 0.2); 
            
            cCol *= 0.8 + 0.2 * smoothstep(-cw, cw, cp.x);
            cCol -= 0.1 * sin(cp.x * 50.0) * smoothstep(0.0, -ch, cp.y);
            col = cCol;
        }
    }
}

void layer_BirdCage(in vec2 p, inout vec3 col) {
    vec2 cageP = p - vec2(0.4, 0.3);
    float cageBody = length(vec2(cageP.x, max(0.0, cageP.y))) - 0.08;
    cageBody = max(cageBody, -cageP.y - 0.1);
    if (cageBody < 0.0) {
        col = vec3(0.2); 
        float bars = abs(fract(cageP.x * 25.0) - 0.5);
        if (bars < 0.1) col = vec3(0.6, 0.45, 0.2);
        if (abs(cageP.y) < 0.005 || abs(cageP.y + 0.05) < 0.005 || abs(cageP.y + 0.09) < 0.005) {
            col = vec3(0.7, 0.55, 0.3);
        }
    }
    float hook = abs(length(cageP - vec2(0.0, 0.09)) - 0.01);
    if (hook < 0.003 && cageP.y > 0.09) col = vec3(0.3);
}

void layer_Plant(in vec2 p, inout vec3 col) {
    vec2 potP = p - vec2(-0.4, -0.2);
    float pot = max(abs(potP.x) - 0.04 + potP.y * 0.1, abs(potP.y) - 0.05);
    if (pot < 0.0) col = vec3(0.6, 0.3, 0.2); 
    
    for(float i=0.0; i<3.0; i++) {
        float vx = sin(potP.y * 10.0 + i) * 0.02;
        float vine = segment(potP, vec2(0.0, 0.0), vec2(vx, -0.3 + i*0.05));
        if (vine < 0.005) col = vec3(0.1, 0.3, 0.1);
        float lDist = length(vec2(potP.x - vx - sin(potP.y*30.0)*0.02, fract(potP.y * 10.0) - 0.5));
        if (lDist < 0.2 && potP.y < 0.0 && potP.y > -0.3) col = vec3(0.2, 0.45, 0.15);
    }
}

vec4 layer_Background(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;
    
    vec3 col = vec3(-1.0);
    
    layer_Background(p, col);
    

  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

vec4 layer_BalconyWall(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;
    
    vec3 col = vec3(-1.0);
    
    layer_BalconyWall(p, col);
    

  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

vec4 layer_Clothesline(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;
    
    vec3 col = vec3(-1.0);
    
    layer_Clothesline(p, iTime, col);
    

  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

vec4 layer_BirdCage(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;
    
    vec3 col = vec3(-1.0);
    
    layer_BirdCage(p, col);
    

  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

vec4 layer_Plant(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;
    
    vec3 col = vec3(-1.0);
    
    layer_Plant(p, col);
    

  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

#define segment(p, a, b) length(p - a - (b - a) * clamp(dot(p - a, b - a) / dot(b - a, b - a), 0.0, 1.0))

void layer_BackgroundWall(in vec2 p, inout vec3 col) {
    col = vec3(0.9, 0.88, 0.85);
    float siding = fract(p.y * 30.0);
    if (siding > 0.9) col *= 0.9;
}

void layer_BottomStone(in vec2 p, inout vec3 col) {
    if (p.y < -0.6) {
        col = vec3(0.2, 0.18, 0.15); 
        vec2 stoneP = fract(p * vec2(10.0, 5.0) + vec2(sin(p.y*10.0), 0.0)) - 0.5;
        if (length(stoneP) < 0.4) col = vec3(0.3, 0.25, 0.2);
    }
}

void layer_TopTrim(in vec2 p, in float iTime, inout vec3 col) {
    if (p.y > 0.8) {
        col = vec3(0.1, 0.08, 0.05); 
        if (fract(p.x * 20.0 + iTime) < 0.3) col = vec3(0.05); 
    }
}

void layer_StrepText(in vec2 p, inout vec3 col) {
    if (p.y > 0.5 && p.x > 0.3) {
        vec2 tp = p - vec2(0.5, 0.55);
        float dText = 1.0;
        
        dText = min(dText, segment(tp, vec2(0.05, 0.1), vec2(0.0, 0.1)));
        dText = min(dText, segment(tp, vec2(0.0, 0.1), vec2(0.0, 0.05)));
        dText = min(dText, segment(tp, vec2(0.0, 0.05), vec2(0.05, 0.05)));
        dText = min(dText, segment(tp, vec2(0.05, 0.05), vec2(0.05, 0.0)));
        dText = min(dText, segment(tp, vec2(0.05, 0.0), vec2(0.0, 0.0)));
        
        dText = min(dText, segment(tp, vec2(0.1, 0.15), vec2(0.1, 0.0)));
        dText = min(dText, segment(tp, vec2(0.08, 0.08), vec2(0.12, 0.08)));
        
        dText = min(dText, segment(tp, vec2(0.18, 0.0), vec2(0.18, 0.1)));
        dText = min(dText, segment(tp, vec2(0.18, 0.08), vec2(0.22, 0.1)));
        
        dText = min(dText, abs(length(tp - vec2(0.3, 0.05)) - 0.04));
        dText = min(dText, segment(tp, vec2(0.26, 0.05), vec2(0.34, 0.05)));
        
        dText = min(dText, segment(tp, vec2(0.4, -0.1), vec2(0.4, 0.1)));
        dText = min(dText, abs(length(tp - vec2(0.45, 0.05)) - 0.04));
        
        if (dText < 0.01) col = vec3(0.1);
    }
}

void layer_CartoonCharacter(in vec2 p, in float iTime, inout vec3 col) {
    vec2 cP = p - vec2(-0.3, 0.1);
    
    float body = segment(cP, vec2(-0.05, 0.2), vec2(-0.05, -0.3));
    body = min(body, segment(cP, vec2(-0.05, 0.2), vec2(0.15, 0.2)));
    body = min(body, segment(cP, vec2(0.15, 0.2), vec2(0.15, -0.3)));
    body = min(body, segment(cP, vec2(-0.05, -0.3), vec2(0.15, -0.3)));
    
    if (cP.x > -0.05 && cP.x < 0.15 && cP.y > -0.3 && cP.y < 0.2) col = vec3(0.9, 0.4, 0.4); 
    if (body < 0.01) col = vec3(0.1); 
    
    float headMask = length(max(abs(cP - vec2(0.05, 0.35)) - vec2(0.15, 0.12), 0.0));
    if (headMask < 0.05) col = vec3(1.0, 0.8, 0.7); 
    if (abs(headMask - 0.05) < 0.01) col = vec3(0.1);
    
    float e1 = length(cP - vec2(0.0, 0.4));
    if (e1 < 0.04) col = vec3(1.0);
    if (abs(e1 - 0.04) < 0.01) col = vec3(0.1);
    if (e1 < 0.015) col = vec3(0.1);
    
    vec2 eye2P = cP - vec2(0.12, 0.4);
    eye2P.y += sin(iTime*3.0)*0.02; 
    float e2 = length(eye2P);
    if (e2 < 0.04) col = vec3(1.0);
    if (abs(e2 - 0.04) < 0.01) col = vec3(0.1);
    if (e2 < 0.015) col = vec3(0.1);

    if (length(cP - vec2(0.05, 0.28)) < 0.05 && cP.y < 0.28) col = vec3(0.1);

    float armL = segment(cP, vec2(-0.05, 0.1), vec2(-0.25, 0.1 + sin(iTime*4.0)*0.1));
    if (armL < 0.02) col = vec3(0.9, 0.4, 0.4);
    if (abs(armL - 0.02) < 0.01) col = vec3(0.1);

    float armR = segment(cP, vec2(0.15, 0.1), vec2(0.3, 0.15));
    if (armR < 0.02) col = vec3(0.9, 0.4, 0.4);
    if (abs(armR - 0.02) < 0.01) col = vec3(0.1);
}

vec4 layer_BackgroundWall(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_BackgroundWall(p, col);


  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

vec4 layer_BottomStone(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_BottomStone(p, col);


  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

vec4 layer_TopTrim(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_TopTrim(p, iTime, col);


  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

vec4 layer_StrepText(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_StrepText(p, col);


  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

vec4 layer_CartoonCharacter(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_CartoonCharacter(p, iTime, col);


  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

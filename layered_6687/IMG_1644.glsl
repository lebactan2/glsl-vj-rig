void layer_Background(inout vec3 col) {
    col = vec3(0.95, 0.96, 0.98); 
}

void layer_TextElements(in vec2 p, in float iTime, inout vec3 col) {
    if (p.x > 0.8 && p.x < 1.1) {
        float textY = p.y + iTime*0.2;
        if (fract(textY * 10.0) < 0.6 && abs(p.x - 0.9) < 0.05) col = vec3(0.8, 0.2, 0.2); 
        if (fract(textY * 15.0) < 0.5 && abs(p.x - 1.0) < 0.04) col = vec3(0.2, 0.6, 0.2); 
    }
}

void layer_TopImpact(in vec2 p, in float iTime, inout vec3 col) {
    vec2 impP = p - vec2(-0.8, 0.3);
    float ang = atan(impP.y, impP.x);
    float burstAnim1 = iTime * 5.0;
    float rad = 0.4 + 0.1 * sin(ang * 8.0 - burstAnim1) + 0.15 * cos(ang * 5.0 + burstAnim1);
    if (length(impP) < rad) {
        col = vec3(0.8, 0.25, 0.25); 
        if (length(impP) > rad - 0.02) col = vec3(0.1);
    }
    
    if (length(max(abs(p - vec2(-0.8, 0.4)) - vec2(0.2, 0.05), 0.0)) - 0.02 < 0.0) {
        col = vec3(0.9, 0.8, 0.4); 
    }
    if (length(max(abs(p - vec2(-0.6, 0.4)) - vec2(0.05, 0.15), 0.0)) - 0.02 < 0.0) {
        col = vec3(0.2); 
    }
    
    if (p.x < -0.9 && p.y > 0.3 && p.y < 0.5) {
        if (fract(p.y*20.0 - iTime*10.0) < 0.2) col = vec3(0.2);
    }
}

void layer_BottomImpact(in vec2 p, in float iTime, inout vec3 col) {
    vec2 imp2 = p - vec2(-0.6, -0.4);
    float ang2 = atan(imp2.y, imp2.x);
    float burstAnim2 = iTime * 4.0;
    float rad2 = 0.35 + 0.1 * sin(ang2 * 6.0 + burstAnim2);
    if (length(imp2) < rad2) {
        col = vec3(0.8, 0.25, 0.25); 
        if (length(imp2) > rad2 - 0.02) col = vec3(0.1);
    }
    
    if (length(max(abs(p - vec2(-0.6, -0.4)) - vec2(0.15, 0.05), 0.0)) - 0.02 < 0.0) {
        col = vec3(0.9, 0.9, 0.5); 
    }
    
    if (p.x < -0.7 && p.y > -0.5 && p.y < -0.3) {
        if (fract(p.y*20.0 - iTime*12.0) < 0.2) col = vec3(0.2);
    }
}

void layer_Hardhat(in vec2 p, inout vec3 col) {
    float hatRadius = 0.6;
    vec2 hatP = p - vec2(-0.2, -0.5);
    if (length(hatP) < hatRadius && hatP.y > 0.0) {
        col = vec3(0.9, 0.85, 0.2); 
        if (hatP.y < 0.05 && abs(hatP.x) < 0.65) col = vec3(0.9, 0.85, 0.2);
        if (hatP.y > 0.4 && abs(hatP.x) < 0.3 && fract(hatP.x*10.0) < 0.2) col = vec3(0.1);
    }
    if (abs(length(hatP) - hatRadius) < 0.01 && hatP.y > 0.0) col = vec3(0.1);
}

void layer_FamilyGroup(in vec2 p, inout vec3 col) {
    vec2 famP = p - vec2(0.3, -0.2);
    
    if (length(famP - vec2(-0.15, -0.2)) < 0.2) {
        col = vec3(0.2, 0.4, 0.8); 
    }
    if (length(famP - vec2(-0.15, -0.1)) < 0.15) {
        col = vec3(0.9, 0.8, 0.2); 
        if (length(max(abs(famP - vec2(-0.15, -0.1)) - vec2(0.04, 0.01), 0.0)) < 0.01) col = vec3(0.2, 0.6, 0.2); 
        if (length(max(abs(famP - vec2(-0.15, -0.1)) - vec2(0.01, 0.04), 0.0)) < 0.01) col = vec3(0.2, 0.6, 0.2); 
    }
    if (length(famP - vec2(-0.05, -0.25)) < 0.1) col = vec3(1.0); 
    
    if (length(famP - vec2(0.2, 0.0)) < 0.2) col = vec3(0.8, 0.2, 0.2); 
    if (length(famP - vec2(0.1, 0.2)) < 0.12) col = vec3(1.0); 
    if (length(famP - vec2(0.1, 0.3)) < 0.14) {
        col = vec3(0.1); 
        if (length(famP - vec2(0.05, 0.35)) < 0.03) col = vec3(1.0);
    }
    
    if (length(famP - vec2(0.0, 0.0)) < 0.15) col = vec3(0.9, 0.9, 0.2); 
    if (length(famP - vec2(-0.05, 0.1)) < 0.1) col = vec3(1.0); 
    if (length(famP - vec2(-0.05, 0.18)) < 0.08) col = vec3(0.1); 
}

vec4 layer_Background(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_Background(col);


  return vec4(clamp(col,0.0,1.0), step(0.0, max(col.r, max(col.g, col.b))));
}

vec4 layer_TextElements(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_TextElements(p, iTime, col);


  return vec4(clamp(col,0.0,1.0), step(0.0, max(col.r, max(col.g, col.b))));
}

vec4 layer_TopImpact(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_TopImpact(p, iTime, col);


  return vec4(clamp(col,0.0,1.0), step(0.0, max(col.r, max(col.g, col.b))));
}

vec4 layer_BottomImpact(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_BottomImpact(p, iTime, col);


  return vec4(clamp(col,0.0,1.0), step(0.0, max(col.r, max(col.g, col.b))));
}

vec4 layer_Hardhat(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_Hardhat(p, col);


  return vec4(clamp(col,0.0,1.0), step(0.0, max(col.r, max(col.g, col.b))));
}

vec4 layer_FamilyGroup(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_FamilyGroup(p, col);


  return vec4(clamp(col,0.0,1.0), step(0.0, max(col.r, max(col.g, col.b))));
}

void layer_Background(in vec2 p, inout vec3 col) {
    col = vec3(0.8, 0.65, 0.55); 
    if (p.y > 0.4) col = vec3(0.4, 0.15, 0.15);
    if (p.y > 0.8) col = vec3(0.7);
}

void layer_LotusGrate(in vec2 p, in float iTime, inout vec3 col) {
    if (p.x > 0.5 && p.y > 0.4) {
        vec2 gp = p - vec2(0.8, 0.7);
        float isGrate = 0.0;
        float pulse = sin(iTime * 3.0 + length(gp)*10.0) * 0.02;
        if (abs(length(gp - vec2(0.0, -0.2)) - 0.3 + pulse) < 0.02 && gp.y > 0.0) isGrate = 1.0;
        if (abs(length(gp - vec2(-0.2, -0.1)) - 0.2 + pulse) < 0.02) isGrate = 1.0;
        if (abs(length(gp - vec2(0.2, -0.1)) - 0.2 + pulse) < 0.02) isGrate = 1.0;
        
        if (isGrate > 0.0) col = vec3(0.2, 0.4, 0.3); 
    }
}

void layer_ForegroundRoof(in vec2 p, inout vec3 col, out float roofLine) {
    roofLine = -0.5 + p.x * 0.4;
    if (p.y < roofLine) {
        col = vec3(0.6, 0.3, 0.2); 
        
        float tx = p.x * 10.0 - p.y * 5.0; 
        if (fract(tx) < 0.2) col *= 0.5; 
        else {
            float fx = fract(tx) - 0.5;
            col *= 1.0 - fx*fx*2.0;
        }
        
        if (p.y > roofLine - 0.05) col *= 0.8;
    }
}

void layer_CentralOrnateFeature(in vec2 p, in float iTime, in float roofLine, inout vec3 col) {
    float dBase = 1.0;
    dBase = min(dBase, abs(length(p - vec2(-0.4, -0.6)) - 0.2) - 0.05);
    dBase = min(dBase, abs(length(p - vec2(0.4, -0.3)) - 0.15) - 0.05);
    dBase = min(dBase, max(abs(p.x - 0.1) - 0.2, abs(p.y - (-0.3)) - 0.15));
    
    if (p.y < roofLine - 0.1) dBase = 1.0;
    
    if (dBase < 0.0) {
        col = vec3(0.9); 
        col *= 0.8 + 0.2 * sin(p.y * 20.0 - iTime * 2.0);
        if (dBase > -0.02) col *= 0.6;
    }
    
    vec2 fp = p - vec2(0.1, -0.1);
    float dFinial = max(abs(fp.x) - 0.15, abs(fp.y) - 0.1); 
    dFinial = min(dFinial, length(fp - vec2(0.0, 0.15)) - 0.15); 
    dFinial = min(dFinial, length(fp - vec2(0.0, 0.35)) - 0.05); 
    
    dFinial = min(dFinial, max(abs(fp.x) - 0.2, abs(fp.y - 0.15) - 0.05));
    
    if (dFinial < 0.0) {
        col = vec3(0.2, 0.3, 0.2); 
        
        if (fp.y < -0.05 || fp.y > 0.25 || abs(fp.x) > 0.12) {
            col = vec3(0.8, 0.6, 0.2); 
            if (abs(fp.x) < 0.02) col = vec3(0.9, 0.8, 0.4); 
            if (abs(fp.y - (-0.08)) < 0.02) col *= 0.5; 
        } else {
            col = vec3(0.2, 0.4, 0.3);
            col *= 1.0 - length(fp - vec2(0.0, 0.15)) * 4.0;
            if (length(fp - vec2(-0.05, 0.2)) < 0.03) col = vec3(0.6, 0.8, 0.7);
        }
        
        if (fp.y < 0.0 && fp.y > -0.1 && abs(fp.x) < 0.1) {
            float rotTime = iTime * 1.5;
            if (abs(length(fp - vec2(0.0, -0.05)) - 0.04) < 0.01) col = vec3(0.8, 0.7, 0.2);
            if (fract(atan(fp.x, fp.y + 0.05) * 1.27 + rotTime) < 0.1 && length(fp - vec2(0.0, -0.05)) < 0.04) col = vec3(0.8, 0.7, 0.2);
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
    
    layer_Background(p, col);
    
    float roofLine;


  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

vec4 layer_LotusGrate(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_LotusGrate(p, iTime, col);
    
    float roofLine;


  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

vec4 layer_ForegroundRoof(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    
    float roofLine;
    layer_ForegroundRoof(p, col, roofLine);


  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

vec4 layer_CentralOrnateFeature(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    
    float roofLine;
    layer_CentralOrnateFeature(p, iTime, roofLine, col);


  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

vec4 layer_Vignette(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    
    float roofLine;
    layer_Vignette(p, col);


  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

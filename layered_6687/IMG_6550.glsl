#define BOX(px, py, bw, bh) (abs(sp.x - (px)) < (bw) && abs(sp.y - (py)) < (bh))

void layer_Background(in vec2 p, inout vec3 col) {
    vec3 wallPink = vec3(0.88, 0.7, 0.72);
    vec3 maroonTrim = vec3(0.45, 0.15, 0.2);
    
    col = wallPink;
    
    if (p.y < -0.8) col = maroonTrim;
    if (p.x > -0.9 && p.x < -0.7 && p.y > -0.8) col = maroonTrim;
    if (p.x > 0.3 && p.x < 0.5 && p.y > -0.8) col = maroonTrim;
}

void layer_Roof(in vec2 p, in float iTime, inout vec3 col) {
    if (p.y > 0.5) {
        col = vec3(0.8, 0.3, 0.2); 
        float shimmer = sin(iTime + p.x * 20.0) * 0.1;
        if (fract(p.x * 10.0 + shimmer) < 0.1) col *= 0.8;
        if (fract(p.y * 20.0) < 0.1) col *= 0.9;
        
        if (p.y < 0.55) col = vec3(0.2, 0.3, 0.2); 
    }
}

void layer_Symbols(in vec2 p, inout vec3 col) {
    vec3 maroonTrim = vec3(0.45, 0.15, 0.2);
    vec2 sp1 = p - vec2(-0.4, -0.3);
    vec2 sp2 = p - vec2(0.1, -0.3);
    
    for (int i=0; i<2; i++) {
        vec2 sp = (i == 0) ? sp1 : sp2;
        bool inSymbol = false;
        
        inSymbol = inSymbol || BOX(0.0, 0.0, 0.03, 0.2);
        inSymbol = inSymbol || BOX(0.0, 0.18, 0.15, 0.03);
        inSymbol = inSymbol || BOX(0.0, 0.05, 0.1, 0.03);
        inSymbol = inSymbol || BOX(0.0, -0.05, 0.1, 0.03);
        inSymbol = inSymbol || BOX(0.0, -0.15, 0.18, 0.03);
        inSymbol = inSymbol || BOX(-0.15, -0.22, 0.03, 0.08);
        inSymbol = inSymbol || BOX(0.15, -0.22, 0.03, 0.08);
        inSymbol = inSymbol || BOX(-0.08, -0.22, 0.03, 0.08);
        inSymbol = inSymbol || BOX(0.08, -0.22, 0.03, 0.08);

        if (inSymbol) col = maroonTrim;
    }
}

void layer_Gate(in vec2 p, in float iTime, inout vec3 col) {
    vec3 maroonTrim = vec3(0.45, 0.15, 0.2);
    vec3 gateYellow = vec3(0.85, 0.7, 0.2);
    
    if (p.x > 0.5 && p.y > -0.8 && p.y < 0.3) {
        col = maroonTrim; 
        
        vec2 gp = p - vec2(0.5, -0.8); 
        bool isGate = false;
        if (gp.x < 0.05 || gp.x > 0.95 || gp.y < 0.05 || gp.y > 1.05) isGate = true;
        
        vec2 innerP = gp - vec2(0.5, 0.55);
        
        float gA = iTime * 0.5;
        mat2 gRot = mat2(cos(gA), -sin(gA), sin(gA), cos(gA));
        vec2 rotP = gRot * innerP;
        
        float r = length(innerP);
        if (abs(r - 0.2) < 0.03) isGate = true;
        if (abs(r - 0.4) < 0.03) isGate = true;
        
        if (abs(rotP.x) < 0.03) isGate = true;
        if (abs(rotP.y) < 0.03) isGate = true;
        if (abs(rotP.x - rotP.y) < 0.04) isGate = true;
        if (abs(rotP.x + rotP.y) < 0.04) isGate = true;
        
        if (isGate) {
            col = gateYellow;
            col *= 0.8 + 0.2 * sin(p.x * 50.0 + p.y * 30.0 + iTime * 5.0); 
        } else {
            col = vec3(0.1, 0.15, 0.1); 
        }
    }
}

void layer_Fence(in vec2 p, in float iTime, inout vec3 col) {
    vec3 fenceGreen = vec3(0.1, 0.4, 0.3);
    if (p.x < -0.9 && p.y > -0.8 && p.y < 0.3) {
        col = vec3(0.1, 0.4, 0.4); 
        
        if (p.x < -1.1 && p.y > -0.2 && p.y < 0.2) {
            col = vec3(0.95); 
            if (fract(p.x * 20.0 + sin(p.y*10.0)) < 0.2) col *= 0.8;
        }
        
        if (fract(p.x * 10.0 + iTime * 0.2) < 0.2) { 
            col = fenceGreen;
            col *= 0.8 + 0.2 * sin(p.x * 100.0);
        }
        if (abs(p.y - 0.2) < 0.02) col = fenceGreen;
    }
}

void layer_Noise(in vec2 p, in float iTime, inout vec3 col) {
    col *= 0.95 + 0.05 * fract(sin(dot(p + iTime*0.05, vec2(12.9898, 78.233))) * 43758.5453);
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

vec4 layer_Roof(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;
    
    vec3 col = vec3(-1.0);
    
    layer_Roof(p, iTime, col);


  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

vec4 layer_Symbols(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;
    
    vec3 col = vec3(-1.0);
    
    layer_Symbols(p, col);


  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

vec4 layer_Gate(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;
    
    vec3 col = vec3(-1.0);
    
    layer_Gate(p, iTime, col);


  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

vec4 layer_Fence(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;
    
    vec3 col = vec3(-1.0);
    
    layer_Fence(p, iTime, col);


  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

vec4 layer_Noise(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;
    
    vec3 col = vec3(-1.0);
    
    layer_Noise(p, iTime, col);


  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

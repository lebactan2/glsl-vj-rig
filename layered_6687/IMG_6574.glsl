void layer_Sky(in vec2 p, inout vec3 col) {
    col = mix(vec3(0.8, 0.9, 0.95), vec3(0.5, 0.7, 0.9), p.y * 0.5 + 0.5);
}

void layer_Trees(in vec2 p, in float iTime, inout vec3 col) {
    float treeNoise = fract(sin(dot(p * 5.0 + iTime*0.05, vec2(12.9898, 78.233))) * 43758.5453);
    float treeNoise2 = fract(sin(dot(p * 15.0, vec2(39.346, 11.135))) * 43758.5453);
    float treeSway = sin(iTime + p.x * 5.0) * 0.05;
    float treeShape = sin(p.x * 3.0 + treeSway) * 0.2 + cos(p.x * 7.0 - treeSway) * 0.1 + 0.2;
    if (p.y > treeShape - treeNoise * 0.3) {
        vec3 treeCol = mix(vec3(0.1, 0.25, 0.15), vec3(0.15, 0.3, 0.2), treeNoise2);
        col = mix(col, treeCol, 0.9); 
    }
}

void layer_Ground(in vec2 p, in float iTime, inout vec3 col) {
    if (p.y < -0.7) {
        col = vec3(0.15, 0.15, 0.18);
        vec2 grid = fract(p * 20.0 - vec2(iTime*2.0, 0.0)) - 0.5;
        if (length(grid) < 0.2) col *= 0.8;
    }
}

void layer_Poles(in vec2 p, inout vec3 col) {
    float dPole1 = abs(p.x + 0.9) - 0.05; 
    float dPole2 = abs(p.x - 0.7) - 0.05; 
    
    if (dPole1 < 0.0 || dPole2 < 0.0) {
        col = vec3(0.15, 0.1, 0.1);
        float poleX = dPole1 < 0.0 ? (p.x + 0.9)/0.05 : (p.x - 0.7)/0.05;
        col += vec3(0.1) * pow(max(0.0, sin(poleX * 3.14159 + 1.5)), 4.0);
    }
}

void layer_Windows(in vec2 p, inout vec3 col) {
    if (p.x < -0.95 && p.y > -0.6 && p.y < 0.2) {
        col = vec3(0.1, 0.3, 0.7);
        col *= 0.8 + 0.2 * cos(p.y * 20.0); 
    }
    if (p.x > 0.65 && p.y > 0.6) {
        col = vec3(0.1, 0.3, 0.7);
    }
}

void layer_Moto(in vec2 p, in float iTime, inout vec3 col) {
    vec3 motoOrange = vec3(0.9, 0.4, 0.1);
    float dMoto = 1.0;
    
    vec2 mp = p - vec2(-0.1, -0.2) - vec2(0.0, sin(iTime * 10.0) * 0.005); 
    
    float wheelFront = length(mp - vec2(0.5, -0.2)) - 0.25;
    float wheelRear  = length(mp - vec2(-0.5, -0.2)) - 0.25;
    dMoto = min(wheelFront, wheelRear);
    
    vec2 bp = mp - vec2(0.0, 0.0);
    float body1 = max(abs(bp.x) - 0.4, abs(bp.y) - 0.15);
    
    vec2 fp = mp - vec2(0.4, 0.2);
    float c = cos(0.5); float s = sin(0.5);
    mat2 rot1 = mat2(c, -s, s, c);
    fp = rot1 * fp;
    float fairing = max(abs(fp.x) - 0.2, abs(fp.y) - 0.15);
    
    vec2 tp = mp - vec2(-0.4, 0.1);
    float c2 = cos(-0.2); float s2 = sin(-0.2);
    mat2 rot2 = mat2(c2, -s2, s2, c2);
    tp = rot2 * tp;
    float tail = max(abs(tp.x) - 0.25, abs(tp.y) - 0.1);
    
    float seatDip = length(mp - vec2(-0.1, 0.3)) - 0.2;
    
    float bodyShape = min(min(body1, fairing), tail);
    bodyShape = max(bodyShape, -seatDip);
    
    dMoto = min(dMoto, bodyShape);
    
    float pipe = max(abs(mp.x) - 0.3, abs(mp.y + 0.4)) - 0.05;
    dMoto = min(dMoto, pipe);

    if (dMoto < 0.0) {
        col = motoOrange;
        
        if (wheelFront < 0.0) {
            float a = atan(mp.y + 0.2, mp.x - 0.5) + iTime * 5.0;
            if (sin(a * 5.0) > 0.8) col *= 0.8; 
            if (length(mp - vec2(0.5, -0.2)) < 0.08) col *= 0.8; 
            if (length(mp - vec2(0.5, -0.2)) > 0.2) col *= 0.9; 
        }
        if (wheelRear < 0.0) {
            float a = atan(mp.y + 0.2, mp.x + 0.5) + iTime * 5.0;
            if (sin(a * 5.0) > 0.8) col *= 0.8;
            if (length(mp - vec2(-0.5, -0.2)) < 0.08) col *= 0.8;
            if (length(mp - vec2(-0.5, -0.2)) > 0.2) col *= 0.9;
        }
        
        if (length(mp - vec2(0.1, -0.1)) < 0.15) col *= 0.9; 
        if (abs(mp.x - 0.4) < 0.05 && mp.y > 0.1) col *= 0.85; 
        if (length(mp - vec2(0.4, 0.25)) < 0.03) col *= 0.7; 
        
        col *= 0.8 + 0.3 * smoothstep(-0.02, 0.0, dMoto); 
        col *= 0.6 + 0.4 * smoothstep(-0.5, 0.5, mp.y + mp.x*0.2);
    }
}

void layer_Noise(in vec2 p, in float iTime, inout vec3 col) {
    col *= 0.95 + 0.05 * fract(sin(dot(p + iTime*0.05, vec2(12.9898, 78.233))) * 43758.5453);
}

vec4 layer_Sky(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;
    
    vec3 col = vec3(-1.0);
    
    layer_Sky(p, col);


  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

vec4 layer_Trees(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;
    
    vec3 col = vec3(-1.0);
    
    layer_Trees(p, iTime, col);


  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

vec4 layer_Ground(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;
    
    vec3 col = vec3(-1.0);
    
    layer_Ground(p, iTime, col);


  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

vec4 layer_Poles(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;
    
    vec3 col = vec3(-1.0);
    
    layer_Poles(p, col);


  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

vec4 layer_Windows(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;
    
    vec3 col = vec3(-1.0);
    
    layer_Windows(p, col);


  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

vec4 layer_Moto(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;
    
    vec3 col = vec3(-1.0);
    
    layer_Moto(p, iTime, col);


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

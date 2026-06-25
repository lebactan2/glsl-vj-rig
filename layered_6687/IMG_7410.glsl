#define segment(p, a, b) length(p - a - (b - a) * clamp(dot(p - a, b - a) / dot(b - a, b - a), 0.0, 1.0))

void layer_Background(in vec2 p, inout vec3 col) {
    col = vec3(0.78, 0.78, 0.8);
    if (p.y < -0.3) {
        col = vec3(0.45, 0.45, 0.47); 
        vec2 bUV = p * vec2(10.0, 20.0);
        bUV.x += step(1.0, mod(floor(bUV.y), 2.0)) * 0.5;
        if (min(fract(bUV.x), fract(bUV.y)) < 0.05) col = vec3(0.35); 
    }
}

void layer_Shelves(in vec2 p, inout vec3 col) {
    if (p.y > 0.4 && p.x > 0.1) {
        col = vec3(0.4, 0.4, 0.45); 
        if (fract(p.y * 5.0) < 0.05) col = vec3(0.2);
        
        vec2 bootP = vec2(fract(p.x * 6.0) - 0.5, fract(p.y * 5.0) - 0.5);
        float bootShape = max(abs(bootP.x) - 0.15, abs(bootP.y + 0.1) - 0.3);
        bootShape = min(bootShape, length(max(abs(bootP - vec2(0.1, -0.4)) - vec2(0.15, 0.05), 0.0)) - 0.05);
        
        if (bootShape < 0.0) {
            col = vec3(0.05, 0.05, 0.08); 
            if (length(bootP - vec2(-0.05, 0.1)) < 0.05) col += 0.1;
        }
    }
}

void layer_Mannequin(in vec2 p, inout vec3 col) {
    vec2 mp = p - vec2(-0.1, -0.1);
    float body = 1.0;
    body = min(body, length(max(abs(mp) - vec2(0.15, 0.3), 0.0)) - 0.05);
    body = min(body, segment(mp, vec2(-0.08, -0.3), vec2(-0.08, -0.7)) - 0.08);
    body = min(body, segment(mp, vec2(0.08, -0.3), vec2(0.08, -0.7)) - 0.08);
    body = min(body, segment(mp, vec2(-0.2, 0.25), vec2(-0.3, -0.1)) - 0.06);
    body = min(body, segment(mp, vec2(0.2, 0.25), vec2(0.3, -0.1)) - 0.06);
    
    if (body < 0.0) {
        vec3 mCol = vec3(0.3, 0.4, 0.2); 
        mCol *= 0.8 + 0.2 * smoothstep(0.15, 0.0, abs(mp.x));
        mCol += sin(mp.x * 40.0 + mp.y * 20.0) * 0.02; 
        
        if (abs(mp.y + 0.3) < 0.03 && abs(mp.x) < 0.2) {
            mCol = vec3(0.1);
            if (abs(mp.x) < 0.03) mCol = vec3(0.8, 0.7, 0.2); 
        }
        
        if (abs(mp.x) < 0.015 && fract(mp.y * 10.0) < 0.2 && mp.y > -0.3 && mp.y < 0.3) {
            mCol = vec3(0.2, 0.25, 0.1);
        }
        col = mCol;
    } else if (body < 0.02) {
        col *= 0.6; 
    }
    
    vec2 hp = mp - vec2(0.0, 0.45);
    float cap = length(max(abs(hp) - vec2(0.08, 0.05), 0.0)) - 0.02;
    float brim = segment(hp, vec2(-0.1, -0.05), vec2(0.12, -0.07)) - 0.01;
    if (min(cap, brim) < 0.0) {
        col = vec3(0.28, 0.35, 0.18);
        if (length(hp - vec2(0.0, 0.02)) < 0.02) col = vec3(0.8, 0.1, 0.1); 
    }
    
    float lShoe = length(max(abs(mp - vec2(-0.08, -0.75)) - vec2(0.06, 0.04), 0.0)) - 0.02;
    float rShoe = length(max(abs(mp - vec2(0.08, -0.75)) - vec2(0.06, 0.04), 0.0)) - 0.02;
    if (min(lShoe, rShoe) < 0.0) col = vec3(0.1);
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

vec4 layer_Shelves(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_Shelves(p, col);


  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

vec4 layer_Mannequin(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_Mannequin(p, col);


  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

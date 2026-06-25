void layer_Background(inout vec3 col) {
    col = vec3(0.9, 0.9, 0.9); 
}

void layer_VestBody(in vec2 p, in float vestBase, in float neck, in float iTime, inout vec3 col) {
    if (vestBase < 0.0 && neck > 0.0) {
        col = vec3(0.1, 0.1, 0.12); 
        
        float fabric = fract(sin(p.x * 200.0) * cos(p.y * 200.0) * 10.0);
        col *= 0.9 + 0.1 * fabric;
        
        float molle = fract(p.y * 15.0);
        if (molle < 0.2 && p.y < 0.3 && p.y > -0.5 && abs(p.x) < 0.35) {
            col = vec3(0.05); 
            float shine = sin(p.x * 10.0 + iTime * 2.0) * 0.5 + 0.5;
            col += vec3(0.05) * shine;
        }
        
        float padL = length(max(abs(p - vec2(-0.35, 0.5)) - vec2(0.1, 0.05), 0.0)) - 0.02;
        float padR = length(max(abs(p - vec2(0.35, 0.5)) - vec2(0.1, 0.05), 0.0)) - 0.02;
        if (padL < 0.0 || padR < 0.0) col = vec3(0.15);
        
        float lowerFlap = length(max(abs(p - vec2(0.0, -0.8)) - vec2(0.2, 0.1), 0.0)) - 0.05;
        if (lowerFlap < 0.0 && p.y < -0.7) col = vec3(0.1);
    }
}

void layer_Pouches(in vec2 p, in float vestBase, in float neck, inout vec3 col) {
    if (vestBase < 0.0 && neck > 0.0) {
        float pouch1 = length(max(abs(p - vec2(-0.25, -0.2)) - vec2(0.08, 0.15), 0.0)) - 0.02;
        if (pouch1 < 0.0) {
            col = vec3(0.12);
            if (p.y > -0.1) col = vec3(0.08);
        }
        float pouch2 = length(max(abs(p - vec2(-0.1, -0.2)) - vec2(0.08, 0.15), 0.0)) - 0.02;
        if (pouch2 < 0.0) col = vec3(0.12);
        
        float pouch3 = length(max(abs(p - vec2(0.25, -0.6)) - vec2(0.15, 0.15), 0.0)) - 0.03;
        if (pouch3 < 0.0) {
            col = vec3(0.1);
            if (abs(p.x - 0.25) < 0.01) col = vec3(0.05);
        }
        
        float pouch4 = length(max(abs(p - vec2(0.3, 0.1)) - vec2(0.08, 0.06), 0.0)) - 0.02;
        if (pouch4 < 0.0) col = vec3(0.13);
    }
}

void layer_ArmAttachments(in vec2 p, inout vec3 col) {
    float armL = length(max(abs(p - vec2(-0.6, 0.2)) - vec2(0.1, 0.2), 0.0)) - 0.05;
    if (armL < 0.0) {
        col = vec3(0.1);
        if (abs(p.y - 0.2) < 0.02) col = vec3(0.05); 
    }
    
    float armR = length(max(abs(p - vec2(0.6, 0.2)) - vec2(0.1, 0.2), 0.0)) - 0.05;
    if (armR < 0.0) {
        col = vec3(0.1);
        if (abs(p.y - 0.2) < 0.02) col = vec3(0.05); 
    }
}

void layer_Collar(in vec2 p, inout vec3 col) {
    float collar = length(max(abs(p - vec2(0.0, 0.65)) - vec2(0.2, 0.15), 0.0)) - 0.05;
    if (collar < 0.0 - p.y * 0.1) {
        col = vec3(0.08);
        float fold = sin(p.x * 20.0) * 0.02;
        col += vec3(fold);
    }
}

void layer_Shadows(in vec2 p, inout vec3 col) {
    col *= 1.0 - 0.3 * length(p - vec2(0.0, -0.2));
}

vec4 layer_Background(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_Background(col);
    
    float vestBase = length(max(abs(p - vec2(0.0, -0.1)) - vec2(0.4, 0.6), 0.0)) - 0.1;
    float neck = length(p - vec2(0.0, 0.6)) - 0.25;
    


  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

vec4 layer_VestBody(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    
    float vestBase = length(max(abs(p - vec2(0.0, -0.1)) - vec2(0.4, 0.6), 0.0)) - 0.1;
    float neck = length(p - vec2(0.0, 0.6)) - 0.25;
    
    layer_VestBody(p, vestBase, neck, iTime, col);


  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

vec4 layer_Pouches(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    
    float vestBase = length(max(abs(p - vec2(0.0, -0.1)) - vec2(0.4, 0.6), 0.0)) - 0.1;
    float neck = length(p - vec2(0.0, 0.6)) - 0.25;
    
    layer_Pouches(p, vestBase, neck, col);


  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

vec4 layer_ArmAttachments(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    
    float vestBase = length(max(abs(p - vec2(0.0, -0.1)) - vec2(0.4, 0.6), 0.0)) - 0.1;
    float neck = length(p - vec2(0.0, 0.6)) - 0.25;
    
    layer_ArmAttachments(p, col);


  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

vec4 layer_Collar(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    
    float vestBase = length(max(abs(p - vec2(0.0, -0.1)) - vec2(0.4, 0.6), 0.0)) - 0.1;
    float neck = length(p - vec2(0.0, 0.6)) - 0.25;
    
    layer_Collar(p, col);


  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

vec4 layer_Shadows(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    
    float vestBase = length(max(abs(p - vec2(0.0, -0.1)) - vec2(0.4, 0.6), 0.0)) - 0.1;
    float neck = length(p - vec2(0.0, 0.6)) - 0.25;
    
    layer_Shadows(p, col);


  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

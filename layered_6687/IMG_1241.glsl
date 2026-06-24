void layer_Ground(in vec2 p, inout vec3 col) {
    col = vec3(0.55, 0.5, 0.45); 
    float dirt = fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
    col *= 0.8 + 0.2 * dirt;
}

void layer_Chair(in vec2 p, inout vec3 col) {
    float seat = length(max(abs(p - vec2(0.0, -0.1)) - vec2(0.4, 0.2), 0.0)) - 0.05;
    float backrest = length(max(abs(p - vec2(0.0, 0.4)) - vec2(0.35, 0.3), 0.0)) - 0.05;
    float legs = length(max(abs(vec2(abs(p.x) - 0.35, p.y + 0.6)) - vec2(0.05, 0.3), 0.0)) - 0.02;

    if (seat < 0.0) {
        col = vec3(0.7, 0.7, 0.7); 
        col *= 0.9 + 0.1 * fract(sin(p.x * 50.0) * 43758.5);
    }
    
    if (backrest < 0.0) {
        col = vec3(0.7, 0.7, 0.7);
        if (abs(fract(p.y * 5.0) - 0.5) > 0.4 && abs(p.x) < 0.25) col = vec3(0.55, 0.5, 0.45);
    }

    if (legs < 0.0) {
        col = vec3(0.65, 0.65, 0.65);
    }
    
    if (seat < 0.0 || backrest < 0.0) {
         float wear = smoothstep(0.4, 0.6, fract(sin(p.x * 12.0 + p.y * 34.0) * 43758.5));
         col *= 1.0 - 0.2 * wear;
    }
}

void layer_LicensePlate(in vec2 p, in float iTime, inout vec3 col) {
    float a = -0.2;
    vec2 rp = vec2(p.x * cos(a) - p.y * sin(a), p.x * sin(a) + p.y * cos(a));
    
    float plate = length(max(abs(rp - vec2(-0.2, 0.1)) - vec2(0.3, 0.15), 0.0)) - 0.02;
    if (plate < 0.0) {
        col = vec3(0.1, 0.2, 0.7); 
        
        float border = length(max(abs(rp - vec2(-0.2, 0.1)) - vec2(0.28, 0.13), 0.0)) - 0.01;
        if (border > 0.0) col = vec3(0.9);
        
        float textLine1 = length(max(abs(rp - vec2(-0.2, 0.15)) - vec2(0.2, 0.03), 0.0));
        float textLine2 = length(max(abs(rp - vec2(-0.2, 0.05)) - vec2(0.2, 0.03), 0.0));
        
        if (textLine1 < 0.01 || textLine2 < 0.01) {
            col = vec3(0.9); 
            
            float shimmer = sin(rp.x * 20.0 - iTime * 3.0) * 0.5 + 0.5;
            col += vec3(0.2) * shimmer;
        }
        
        float string1 = length(max(abs(p - vec2(-0.4, 0.2)) - vec2(0.01, 0.1), 0.0));
        if(string1 < 0.005) col = vec3(0.2, 0.5, 0.8);
    }
}

void layer_Vignette(in vec2 p, inout vec3 col) {
    col *= 1.0 - 0.3 * length(p);
}

vec4 layer_Ground(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_Ground(p, col);


  return vec4(clamp(col,0.0,1.0), step(0.0, max(col.r, max(col.g, col.b))));
}

vec4 layer_Chair(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_Chair(p, col);


  return vec4(clamp(col,0.0,1.0), step(0.0, max(col.r, max(col.g, col.b))));
}

vec4 layer_LicensePlate(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_LicensePlate(p, iTime, col);


  return vec4(clamp(col,0.0,1.0), step(0.0, max(col.r, max(col.g, col.b))));
}

vec4 layer_Vignette(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_Vignette(p, col);


  return vec4(clamp(col,0.0,1.0), step(0.0, max(col.r, max(col.g, col.b))));
}

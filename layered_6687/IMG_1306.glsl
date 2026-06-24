void layer_BackgroundRoad(in vec2 p, in float iTime, inout vec3 col) {
    col = vec3(0.5, 0.5, 0.52); 
    
    float roadNoise = fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
    col *= 0.9 + 0.1 * roadNoise;
    
    if (p.y > 0.2) {
        float bldg = sin(p.x * 10.0) * 0.1 + sin(p.x * 3.0) * 0.2;
        if (p.y < 0.5 + bldg) col = mix(col, vec3(0.3, 0.3, 0.35), 0.5); 
        
        float trees = sin(p.x * 20.0) * 0.05 + sin(p.x * 5.0) * 0.1;
        if (p.y < 0.4 + trees) col = mix(col, vec3(0.2, 0.3, 0.2), 0.6); 
        
        if (abs(p.y - 0.25) < 0.05 && fract(p.x * 5.0 + iTime) < 0.1) col += vec3(0.8, 0.1, 0.1);
        if (abs(p.y - 0.25) < 0.05 && fract(p.x * 5.0 - iTime + 0.5) < 0.1) col += vec3(0.9, 0.9, 0.7);
    }
}

void layer_MetalFrame(in vec2 p, inout vec3 col) {
    float barH1 = length(max(abs(p - vec2(0.0, 0.3)) - vec2(0.6, 0.02), 0.0)) - 0.01;
    float barH2 = length(max(abs(p - vec2(0.0, -0.4)) - vec2(0.6, 0.02), 0.0)) - 0.01;
    float barV1 = length(max(abs(p - vec2(-0.6, -0.05)) - vec2(0.02, 0.35), 0.0)) - 0.01;
    float barV2 = length(max(abs(p - vec2(0.6, -0.05)) - vec2(0.02, 0.35), 0.0)) - 0.01;
    float barV3 = length(max(abs(p - vec2(-0.4, -0.05)) - vec2(0.02, 0.35), 0.0)) - 0.01;
    float barV4 = length(max(abs(p - vec2(0.4, -0.05)) - vec2(0.02, 0.35), 0.0)) - 0.01;
    
    float foot1 = length(max(abs(p - vec2(-0.4, -0.5)) - vec2(0.05, 0.1), 0.0)) - 0.01;
    float foot2 = length(max(abs(p - vec2(0.4, -0.5)) - vec2(0.05, 0.1), 0.0)) - 0.01;
    
    float frame = min(min(barH1, barH2), min(min(barV1, barV2), min(barV3, barV4)));
    frame = min(frame, min(foot1, foot2));

    if (frame < 0.0) {
        col = vec3(0.6); 
        float rust = fract(sin(p.x * 50.0 + p.y * 50.0) * 123.45);
        if (rust > 0.7) col = vec3(0.4, 0.3, 0.2);
    }
}

void layer_BlueCloth(in vec2 p, in float iTime, inout vec3 col) {
    float clothBase = length(max(abs(p - vec2(0.0, 0.0)) - vec2(0.5, 0.45), 0.0)) - 0.02;
    float edgeWave = sin(p.y * 20.0) * 0.01;
    
    if (clothBase + edgeWave < 0.0) {
        col = vec3(0.1, 0.4, 0.8); 
        
        float windX = sin(p.x * 5.0 + p.y * 2.0 + iTime * 2.0) * 0.1;
        float windY = cos(p.x * 3.0 + p.y * 4.0 - iTime * 1.5) * 0.1;
        
        float seams = abs(sin(p.x * 10.0 + windX));
        col *= 0.8 + 0.2 * smoothstep(0.0, 0.2, seams);
        
        col += vec3(0.1) * windX;
        col -= vec3(0.1) * windY;
        
        float knot = length(max(abs(p - vec2(0.0, 0.2)) - vec2(0.05, 0.15), 0.0)) - 0.03;
        if (knot < 0.0) {
            col = vec3(0.05, 0.3, 0.6); 
            float kFolds = sin((p.x + p.y) * 40.0);
            col *= 0.8 + 0.2 * kFolds;
        }
    }
}

void layer_PlasticBags(in vec2 p, in float iTime, inout vec3 col) {
    float bagL = length(max(abs(p - vec2(-0.65, 0.2)) - vec2(0.08, 0.12), 0.0)) - 0.03;
    float bagLWind = sin(p.y * 10.0 + iTime * 4.0) * 0.02;
    if (bagL + bagLWind < 0.0) {
        col = vec3(0.85, 0.85, 0.85); 
        col *= 0.9 + 0.1 * fract(sin(p.x * 100.0) * 43758.5);
    }
    
    float bagR = length(max(abs(p - vec2(0.65, 0.2)) - vec2(0.05, 0.1), 0.0)) - 0.02;
    float bagRWind = cos(p.y * 15.0 + iTime * 5.0) * 0.02;
    if (bagR + bagRWind < 0.0) {
        col = vec3(0.85, 0.85, 0.85);
        col *= 0.9 + 0.1 * fract(sin(p.x * 100.0 + 10.0) * 43758.5);
    }
}

void layer_Shadows(in vec2 p, inout vec3 col) {
    float shadow = exp(-10.0 * length(max(abs(p - vec2(0.0, -0.6)) - vec2(0.6, 0.1), 0.0)));
    col *= 1.0 - 0.4 * shadow;
}

vec4 layer_BackgroundRoad(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_BackgroundRoad(p, iTime, col);


  return vec4(clamp(col,0.0,1.0), step(0.0, max(col.r, max(col.g, col.b))));
}

vec4 layer_MetalFrame(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_MetalFrame(p, col);


  return vec4(clamp(col,0.0,1.0), step(0.0, max(col.r, max(col.g, col.b))));
}

vec4 layer_BlueCloth(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_BlueCloth(p, iTime, col);


  return vec4(clamp(col,0.0,1.0), step(0.0, max(col.r, max(col.g, col.b))));
}

vec4 layer_PlasticBags(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_PlasticBags(p, iTime, col);


  return vec4(clamp(col,0.0,1.0), step(0.0, max(col.r, max(col.g, col.b))));
}

vec4 layer_Shadows(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_Shadows(p, col);


  return vec4(clamp(col,0.0,1.0), step(0.0, max(col.r, max(col.g, col.b))));
}

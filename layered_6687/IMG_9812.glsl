void layer_BackgroundWoodPanels(in vec2 p, in float iTime, inout vec3 col) {
    col = vec3(0.45, 0.35, 0.25); 
    
    float planks = fract(p.x * 2.0);
    if (planks < 0.02) col *= 0.5; 
    
    float grain = fract(sin(p.x * 50.0 + iTime * 0.1) * 43758.5453 + p.y * 2.0 - iTime * 0.5);
    col *= 0.8 + 0.2 * grain;
}

void layer_LeftObjects(in vec2 p, inout vec3 col) {
    if (p.x < -0.6 && p.y > 0.2) {
        col = vec3(0.85, 0.85, 0.8); 
        if (p.x < -0.9 || p.y < 0.25) col = vec3(0.4, 0.3, 0.2); 
        if (p.x > -0.85 && p.x < -0.65 && p.y > 0.6 && p.y < 0.8) {
            col = vec3(0.6); 
        }
    }
    
    if (p.x < -0.4 && p.y < 0.2) {
        col = vec3(0.4, 0.25, 0.15); 
        if (p.y > 0.15) col = vec3(0.3, 0.2, 0.1);
        if (p.x > -0.45) col = vec3(0.3, 0.2, 0.1);
        if (length(vec2(p.x + 0.5, p.y + 0.1)) < 0.02) col = vec3(0.8, 0.7, 0.5); 
        if (length(vec2(p.x + 0.5, p.y - 0.1)) < 0.02) col = vec3(0.8, 0.7, 0.5);
    }
}

void layer_BottomSurface(in vec2 p, inout vec3 col) {
    if (p.y < -0.6) {
        col = vec3(0.2, 0.25, 0.25); 
        if (p.y > -0.65 && p.y < -0.6) {
            col = vec3(0.15); 
            if (fract(p.x * 5.0) < 0.1) col = vec3(0.7, 0.7, 0.75); 
        }
    }
}

void layer_CenterWoodWheelObject(in vec2 p, in float iTime, inout vec3 col) {
    float dBase = max(abs(p.x) - 0.25, abs(p.y + 0.4) - 0.1);
    if (dBase < 0.0) {
        col = vec3(0.25, 0.15, 0.1); 
        col *= 0.8 + 0.2 * fract(sin(p.x * 20.0)*10.0 + iTime*0.5); 
        
        if (p.y > -0.32) col = mix(col, vec3(0.5, 0.4, 0.3), 0.5);
    }
    
    if (abs(p.x) < 0.02 && p.y > -0.3 && p.y < -0.15) {
        col = vec3(0.5, 0.5, 0.5); 
    }
    
    float wheelDist = length(p - vec2(0.0, 0.1));
    if (wheelDist < 0.35) {
        float edgeNoise = sin(atan(p.y - 0.1, p.x) * 10.0) * 0.02 + sin(atan(p.y - 0.1, p.x) * 3.0) * 0.03;
        if (wheelDist <= 0.35 + edgeNoise) {
            if (wheelDist < 0.04) {
                col = vec3(0.1); 
            } else {
                col = vec3(0.4, 0.3, 0.2); 
                
                float grain2 = fract(sin(p.y * 30.0 + iTime * 0.5) * 43758.5453 + p.x * 2.0 - iTime);
                col *= 0.7 + 0.3 * grain2;
                
                if (fract(p.y * 12.0 + sin(p.x*5.0 - iTime)*0.1) < 0.05) col *= 0.4;
                if (abs(p.y - 0.1) < 0.01 && abs(p.x) > 0.1) col *= 0.3; 
                
                col *= 0.5 + 0.5 * smoothstep(0.35, 0.0, wheelDist); 
                col += vec3(0.1, 0.1, 0.0) * max(0.0, p.y - 0.1);
            }
        }
    }
}

void layer_Vignette(in vec2 p, inout vec3 col) {
    col *= 1.0 - 0.2 * length(p);
}

vec4 layer_BackgroundWoodPanels(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_BackgroundWoodPanels(p, iTime, col);


  return vec4(clamp(col,0.0,1.0), step(0.0, max(col.r, max(col.g, col.b))));
}

vec4 layer_LeftObjects(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_LeftObjects(p, col);


  return vec4(clamp(col,0.0,1.0), step(0.0, max(col.r, max(col.g, col.b))));
}

vec4 layer_BottomSurface(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_BottomSurface(p, col);


  return vec4(clamp(col,0.0,1.0), step(0.0, max(col.r, max(col.g, col.b))));
}

vec4 layer_CenterWoodWheelObject(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_CenterWoodWheelObject(p, iTime, col);


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

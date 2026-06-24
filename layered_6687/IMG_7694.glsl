void layer_Background(in vec2 p, in float iTime, inout vec3 col) {
    col = vec3(0.5, 0.5, 0.5); 
    
    vec2 gp = p * 8.0;
    float pattern = abs(sin(length(fract(gp) - 0.5) * 10.0 - iTime * 2.0));
    pattern = min(pattern, abs(sin((gp.x + gp.y)*5.0 + iTime)));
    col *= 0.8 + 0.2 * pattern;
    
    if (p.x < -0.4) {
        col = vec3(0.65, 0.6, 0.55); 
        col *= 0.8 + 0.2 * sin(p.y * 10.0);
    }
}

void layer_GreenDoor(in vec2 p, inout vec3 col) {
    if (p.x < -0.6) {
        col = vec3(0.1, 0.3, 0.15); 
        if (abs(p.x - (-0.8)) < 0.15) {
            float py = fract(p.y * 2.0) - 0.5;
            if (abs(py) < 0.4) {
                col = vec3(0.15, 0.35, 0.2);
                if (abs(abs(py) - 0.4) < 0.02 || abs(abs(p.x - (-0.8)) - 0.15) < 0.02) {
                    col = vec3(0.8);
                }
            }
        }
    }
}

void layer_RedTable(in vec2 p, inout vec3 col) {
    if (p.x > 0.1 && p.y > -0.3 && p.y < 0.8) {
        float dTable = max(abs(p.x - 0.6) - 0.4, abs(p.y - 0.25) - 0.45);
        dTable = length(max(abs(vec2(p.x - 0.6, p.y - 0.25)) - vec2(0.3, 0.35), 0.0)) - 0.1;
        
        if (dTable < 0.0) {
            col = vec3(0.7, 0.2, 0.2); 
            col += 0.2 * smoothstep(0.0, -0.2, dTable) * sin(p.y * 5.0 + p.x * 10.0);
            
            if (p.x > 0.8 && p.y > -0.5 && p.y < -0.3) col = vec3(0.6, 0.15, 0.15); 
            if (p.x > 0.8 && p.y > 0.8 && p.y < 0.9) col = vec3(0.6, 0.15, 0.15); 
        }
    }
}

void layer_Chairs(in vec2 p, in float iTime, inout vec3 col) {
    vec2 cPos[4];
    cPos[0] = vec2(-0.1, 0.5); 
    cPos[1] = vec2(-0.2, 0.0); 
    cPos[2] = vec2(-0.25, -0.5); 
    cPos[3] = vec2(-0.5, -0.7); 
    
    vec3 cCol[4];
    cCol[0] = vec3(0.1, 0.3, 0.8); 
    cCol[1] = vec3(0.1, 0.3, 0.8); 
    cCol[2] = vec3(0.1, 0.3, 0.8); 
    cCol[3] = vec3(0.8, 0.2, 0.2); 
    
    for (int i = 0; i < 4; i++) {
        vec2 cp = p - cPos[i];
        
        float dBack = length(max(abs(cp - vec2(-0.1, 0.0)) - vec2(0.15, 0.15), 0.0)) - 0.05;
        float dSeat = length(max(abs(cp - vec2(0.2, 0.0)) - vec2(0.1, 0.15), 0.0)) - 0.05;
        
        float dChair = min(dBack, dSeat);
        float dConn = length(max(abs(cp - vec2(0.05, 0.0)) - vec2(0.05, 0.15), 0.0)) - 0.02;
        dChair = min(dChair, dConn);
        
        if (dChair < 0.0) {
            col = cCol[i];
            
            if (cp.x < 0.0 && cp.x > -0.2 && abs(cp.y) < 0.1) {
                col = vec3(0.9);
                float pulse = sin(iTime * 3.0 + float(i) * 1.0) * 0.005;
                if (length(cp - vec2(-0.1, 0.0)) < 0.02 + pulse) col = vec3(0.1);
                if (length(cp - vec2(-0.1, 0.05)) < 0.015 + pulse) col = vec3(0.1);
                if (length(cp - vec2(-0.1, -0.05)) < 0.015 + pulse) col = vec3(0.1);
                if (length(cp - vec2(-0.15, 0.0)) < 0.015 + pulse) col = vec3(0.1);
            }
            
            col *= 0.7 + 0.3 * smoothstep(0.0, -0.05, dChair);
            if (cp.x > 0.2) col *= 0.8; 
        }
        
        if (cp.x > 0.1 && cp.x < 0.4 && abs(cp.y + 0.25) < 0.02) col = cCol[i] * 0.7;
        if (cp.x > 0.1 && cp.x < 0.4 && abs(cp.y - 0.25) < 0.02) col = cCol[i] * 0.7;
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
    
    layer_Background(p, iTime, col);


  return vec4(clamp(col,0.0,1.0), step(0.0, max(col.r, max(col.g, col.b))));
}

vec4 layer_GreenDoor(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_GreenDoor(p, col);


  return vec4(clamp(col,0.0,1.0), step(0.0, max(col.r, max(col.g, col.b))));
}

vec4 layer_RedTable(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_RedTable(p, col);


  return vec4(clamp(col,0.0,1.0), step(0.0, max(col.r, max(col.g, col.b))));
}

vec4 layer_Chairs(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_Chairs(p, iTime, col);


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

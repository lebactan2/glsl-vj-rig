void layer_BrickWall(in vec2 p, inout vec3 col) {
    col = vec3(0.8, 0.5, 0.3);
    vec2 brickUv = vec2(p.x * 5.0, p.y * 10.0);
    brickUv.x += floor(brickUv.y) * 0.5;
    vec2 fBrick = fract(brickUv);
    float brickEdge = max(step(0.9, fBrick.x), step(0.85, fBrick.y));
    col *= 0.5 + 0.5 * (1.0 - brickEdge);
    col -= 0.1 * fract(sin(dot(p*100.0, vec2(12.9898,78.233))) * 43758.5453);
}

void layer_WindowSlats(in vec2 p, in float iTime, inout vec3 col) {
    if (abs(p.x) < 0.8) {
        float lightMove = sin(iTime * 0.5) * 0.5 + 0.5;
        col = vec3(0.1); 
        
        float slatsPhase = p.y * 30.0 + sin(p.x * 2.0 + iTime) * 0.5; 
        float slats = fract(slatsPhase);
        
        if (slats > 0.3) {
            vec3 slatCol = vec3(0.5, 0.5, 0.55);
            slatCol *= 0.6 + 0.8 * slats; 
            float highlight = smoothstep(0.8, 1.0, slats) * lightMove;
            slatCol += vec3(0.2) * highlight;
            col = slatCol;
        }
    }
}

void layer_WindowFrames(in vec2 p, inout vec3 col) {
    if (abs(p.x) < 0.8) {
        float vFrames = abs(fract(p.x * 3.0) - 0.5);
        if (vFrames < 0.02) {
            col = vec3(0.4) + 0.1 * sin(p.y * 10.0);
        }
        
        if (abs(p.x) < 0.05 && abs(p.y) < 0.1) col = vec3(0.7);
    }
}

void layer_Vignette(in vec2 uv, inout vec3 col) {
    col *= 1.0 - 0.3 * length(uv - 0.5);
}

vec4 layer_BrickWall(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;
    
    vec3 col = vec3(-1.0);
    
    layer_BrickWall(p, col);
    

  return vec4(clamp(col,0.0,1.0), step(0.0, max(col.r, max(col.g, col.b))));
}

vec4 layer_WindowSlats(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;
    
    vec3 col = vec3(-1.0);
    
    layer_WindowSlats(p, iTime, col);
    

  return vec4(clamp(col,0.0,1.0), step(0.0, max(col.r, max(col.g, col.b))));
}

vec4 layer_WindowFrames(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;
    
    vec3 col = vec3(-1.0);
    
    layer_WindowFrames(p, col);
    

  return vec4(clamp(col,0.0,1.0), step(0.0, max(col.r, max(col.g, col.b))));
}

vec4 layer_Vignette(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;
    
    vec3 col = vec3(-1.0);
    
    layer_Vignette(uv, col);
    

  return vec4(clamp(col,0.0,1.0), step(0.0, max(col.r, max(col.g, col.b))));
}

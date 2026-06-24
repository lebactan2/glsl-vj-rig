void layer_Wall(in vec2 p, inout vec3 col) {
    col = vec3(0.85, 0.9, 0.9);
}

void layer_Floor(in vec2 p, inout vec3 col) {
    if (p.y < -0.3) {
        vec2 floorUV = vec2(p.x / (p.y + 0.6), 1.0 / (p.y + 0.6));
        floorUV *= 6.0;
        
        vec2 id = floor(floorUV);
        if (mod(id.y, 2.0) > 0.5) floorUV.x += 0.5;
        vec2 f = fract(floorUV);
        float hole = smoothstep(0.35, 0.25, length(f - 0.5));
        
        vec3 fCol = vec3(0.55, 0.6, 0.55); 
        fCol = mix(fCol, vec3(0.1), hole);
        
        float shadow = smoothstep(-0.1, 0.4, abs(p.x - 0.1));
        shadow *= smoothstep(-0.3, -0.6, p.y);
        fCol *= 0.4 + 0.6 * shadow;
        
        col = fCol;
    }
}

void layer_RedBook(in vec2 p, inout vec3 col) {
    float coverX = 0.3;
    float coverY = 0.5;
    float skew = 0.05;
    
    float cover = smoothstep(0.01, 0.0, max(abs(p.x - 0.1) - coverX, abs(p.y - 0.1) - coverY));
    
    float skewX = p.x - (p.y - 0.1) * skew;
    float spine = smoothstep(0.01, 0.0, max(abs(skewX + 0.25) - 0.05, abs(p.y - 0.12) - coverY));
    
    float backEdge = smoothstep(0.01, 0.0, max(abs(skewX + 0.28) - 0.08, abs(p.y - 0.14) - coverY));

    if (backEdge > 0.5) {
        col = vec3(0.5, 0.05, 0.1); 
    }
    if (spine > 0.5) {
        col = vec3(0.95);
        col *= 0.8 + 0.2 * smoothstep(-0.3, -0.2, skewX); 
        if (mod(p.y * 10.0, 1.0) < 0.1 && abs(p.y) < 0.3) col *= 0.5;
    }
    if (cover > 0.5) {
        col = vec3(0.85, 0.1, 0.2); 
        
        float tY1 = abs(p.y - 0.0);
        float tX1 = abs(p.x - 0.1);
        if (tY1 < 0.05 && tX1 < 0.2) {
            if (mod(p.x * 15.0, 1.0) < 0.75) col = vec3(1.0); 
        }
        float tY2 = abs(p.y + 0.1);
        float tX2 = abs(p.x - 0.05);
        if (tY2 < 0.05 && tX2 < 0.15) {
            if (mod(p.x * 15.0, 1.0) < 0.75) col = vec3(1.0); 
        }
        
        if (abs(p.y + 0.18) < 0.005 && abs(p.x - 0.1) < 0.18) {
            col = vec3(1.0);
        }
    }
}

vec4 layer_Wall(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);

    layer_Wall(p, col);


  return vec4(clamp(col,0.0,1.0), step(0.0, max(col.r, max(col.g, col.b))));
}

vec4 layer_Floor(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);

    layer_Floor(p, col);


  return vec4(clamp(col,0.0,1.0), step(0.0, max(col.r, max(col.g, col.b))));
}

vec4 layer_RedBook(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);

    layer_RedBook(p, col);


  return vec4(clamp(col,0.0,1.0), step(0.0, max(col.r, max(col.g, col.b))));
}

void layer_Wall(in vec2 p, inout vec3 col) {
    col = vec3(0.7, 0.65, 0.6);
    col -= 0.1 * p.y;
}

void layer_Floor(in vec2 p, in float iTime, inout vec3 col) {
    if (p.x > 0.0 && p.y < 0.0) {
        vec2 st = vec2(p.x / (p.y - 0.1), 1.0 / (p.y - 0.1));
        st.x += iTime * 0.2;
        float tile = max(step(0.1, fract(st.x * 5.0)), step(0.1, fract(st.y * 5.0)));
        col = mix(vec3(0.8), vec3(0.6), tile);
    }
}

void layer_Shelves(in vec2 p, in float iTime, inout vec3 col) {
    if (p.y > -0.4 && p.y < 0.5 && p.x < 0.2) {
        float sId = floor((p.y + p.x) * 10.0);
        vec2 sp = vec2(fract((p.y + p.x) * 10.0) - 0.5, p.x);
        
        if (abs(sp.y) < 0.2 && sp.x > -0.3 && sp.x < 0.3) {
            float rnd = fract(sId * 0.123);
            if (rnd < 0.3) col = vec3(0.1); 
            else if (rnd < 0.6) col = vec3(0.8, 0.1, 0.1); 
            else col = vec3(0.9); 
            
            col += 0.1 * sin(iTime * 3.0 + sId);
        }
        
        if (length(vec2(sp.x, sp.y + 0.2)) < 0.1) col = vec3(0.05);
    }
}

void layer_FloatingObjects(in vec2 p, in float iTime, inout vec3 col) {
    vec2 bp = p - vec2(-0.5, 0.0);
    bp.y += sin(iTime * 2.0) * 0.05;
    if (length(bp * vec2(1.0, 0.8)) < 0.2 + 0.05*sin(bp.y*20.0 + iTime*5.0)) {
        vec3 objCol = vec3(0.9, 0.4, 0.8); 
        objCol *= 0.5 + 0.5 * smoothstep(0.2, 0.0, length(bp));
        col = objCol;
    }
    
    vec2 gp = p - vec2(-0.1, -0.1);
    gp.x += cos(iTime * 1.5) * 0.05;
    if (length(gp * vec2(1.0, 0.7)) < 0.15 + 0.05*cos(gp.x*20.0 - iTime*4.0)) {
        vec3 objCol = vec3(0.2, 0.8, 0.6); 
        objCol *= 0.5 + 0.5 * smoothstep(0.15, 0.0, length(gp));
        col = objCol;
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
    
    layer_Floor(p, iTime, col);


  return vec4(clamp(col,0.0,1.0), step(0.0, max(col.r, max(col.g, col.b))));
}

vec4 layer_Shelves(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;
    
    vec3 col = vec3(-1.0);
    
    layer_Shelves(p, iTime, col);


  return vec4(clamp(col,0.0,1.0), step(0.0, max(col.r, max(col.g, col.b))));
}

vec4 layer_FloatingObjects(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;
    
    vec3 col = vec3(-1.0);
    
    layer_FloatingObjects(p, iTime, col);


  return vec4(clamp(col,0.0,1.0), step(0.0, max(col.r, max(col.g, col.b))));
}

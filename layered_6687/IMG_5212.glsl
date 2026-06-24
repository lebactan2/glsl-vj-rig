void layer_Sky(in vec2 p, in float iTime, inout vec3 col) {
    col = vec3(0.3, 0.5, 0.7); 
    float clouds = sin(p.x * 3.0 + iTime*0.5 + sin(p.y*5.0)) * cos(p.y*4.0 - iTime*0.2);
    if (p.y > 0.0) col += max(0.0, clouds)*0.2 * smoothstep(0.0, 1.0, p.y);
}

void layer_GreenBuilding(in vec2 p, inout vec3 col) {
    float b1 = max(abs(p.x + 0.6) - 1.0, abs(p.y - 0.5) - 0.4);
    if (b1 < 0.0) {
        col = vec3(0.2, 0.5, 0.3); 
        if (fract(p.x * 50.0) < 0.1 || fract(p.y * 50.0) < 0.1) col *= 0.8;
    }
}

void layer_Crane(in vec2 p, in float iTime, inout vec3 col) {
    float craneSway = sin(iTime * 0.5) * 0.1;
    if (p.x > -0.5 && p.x < -0.4 && p.y > 0.9 && p.y < 1.2) col = vec3(0.9, 0.7, 0.1);
    
    vec2 cp = p - vec2(-0.45, 0.95);
    float a = craneSway;
    mat2 rotC = mat2(cos(a), -sin(a), sin(a), cos(a));
    vec2 cpr = rotC * cp;
    if (cpr.x > -0.3 && cpr.x < 0.2 && abs(cpr.y) < 0.01) col = vec3(0.9, 0.7, 0.1);
}

void layer_WhiteBuilding(in vec2 p, in float iTime, inout vec3 col) {
    float b2 = max(abs(p.x - 1.2) - 0.4, abs(p.y - 0.4) - 0.5);
    if (b2 < 0.0) {
        col = vec3(0.9); 
        if (fract(p.x * 10.0) < 0.3 && fract(p.y * 10.0) < 0.4 && p.y < 0.8) {
            col = vec3(0.2, 0.3, 0.4); 
            col += max(0.0, sin(p.x*100.0 + iTime*2.0))*0.2;
        }
        if (p.y > 0.8 && p.y < 0.85) col = vec3(0.8, 0.2, 0.2);
    }
}

void layer_Roof(in vec2 p, inout vec3 col) {
    float roof = max(abs(p.x) - 2.0, abs(p.y - 0.05) - 0.05);
    if (roof < 0.0) {
        col = vec3(0.6, 0.3, 0.2); 
        if (fract(p.x * 30.0) < 0.1) col *= 0.8;
    }
}

void layer_TerraceWalls(in vec2 p, inout vec3 col) {
    float wall1 = max(abs(p.x) - 2.0, abs(p.y + 0.2) - 0.2);
    if (wall1 < 0.0) {
        col = vec3(0.9, 0.88, 0.8); 
        
        if (p.x > -0.5 && p.x < -0.2 && p.y > -0.3 && p.y < -0.1) col = vec3(0.4, 0.5, 0.6);
        
        if (p.x > 0.5) {
            if (fract(p.x * 5.0) > 0.8) col = vec3(0.2); 
        }
    }
}

void layer_TerraceFloor(in vec2 p, in float iTime, inout vec3 col) {
    if (p.y < -0.4 && p.y > -0.7) {
        col = vec3(0.8, 0.8, 0.8); 
        float floorUvX = p.x / (1.0 + (p.y + 0.4) * 0.5);
        if (fract(floorUvX * 5.0) < 0.02 || fract(p.y * 20.0) < 0.05) col *= 0.95;
        
        float shadow = sin(p.x * 5.0 + p.y * 10.0 + iTime);
        if (shadow > 0.5) col *= 0.9;
    }
}

void layer_Balustrade(in vec2 p, in float iTime, inout vec3 col) {
    if (p.y < -0.7) {
        col = vec3(0.85, 0.83, 0.75); 
        
        if (p.y > -0.72) col *= 0.8;
        
        if (p.y < -0.75 && p.y > -0.9) {
            float pillar = fract(p.x * 12.0);
            if (pillar > 0.4) {
                col = vec3(0.6, 0.6, 0.6);
            } else {
                col *= 0.8 + 0.4 * sin(pillar * 3.14 / 0.4 + sin(iTime)*0.1);
            }
        }
        
        if (p.y < -0.92 && p.y > -0.98) {
            col = vec3(0.2, 0.25, 0.3); 
            float pattern = fract(p.x * 20.0 - iTime*0.5) + fract(p.x * 20.0 + p.y*100.0);
            if (pattern > 0.5 && pattern < 1.5) col = vec3(0.8, 0.6, 0.3); 
        }
    }
}

vec4 layer_Sky(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_Sky(p, iTime, col);


  return vec4(clamp(col,0.0,1.0), step(0.0, max(col.r, max(col.g, col.b))));
}

vec4 layer_GreenBuilding(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_GreenBuilding(p, col);


  return vec4(clamp(col,0.0,1.0), step(0.0, max(col.r, max(col.g, col.b))));
}

vec4 layer_Crane(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_Crane(p, iTime, col);


  return vec4(clamp(col,0.0,1.0), step(0.0, max(col.r, max(col.g, col.b))));
}

vec4 layer_WhiteBuilding(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_WhiteBuilding(p, iTime, col);


  return vec4(clamp(col,0.0,1.0), step(0.0, max(col.r, max(col.g, col.b))));
}

vec4 layer_Roof(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_Roof(p, col);


  return vec4(clamp(col,0.0,1.0), step(0.0, max(col.r, max(col.g, col.b))));
}

vec4 layer_TerraceWalls(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_TerraceWalls(p, col);


  return vec4(clamp(col,0.0,1.0), step(0.0, max(col.r, max(col.g, col.b))));
}

vec4 layer_TerraceFloor(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_TerraceFloor(p, iTime, col);


  return vec4(clamp(col,0.0,1.0), step(0.0, max(col.r, max(col.g, col.b))));
}

vec4 layer_Balustrade(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_Balustrade(p, iTime, col);


  return vec4(clamp(col,0.0,1.0), step(0.0, max(col.r, max(col.g, col.b))));
}

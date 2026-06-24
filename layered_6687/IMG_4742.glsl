void layer_Street(in vec2 sp, inout vec3 col) {
    col = vec3(0.3, 0.3, 0.32);
    float noise = fract(sin(dot(sp * 100.0, vec2(12.9898, 78.233))) * 43758.5453);
    col += (noise - 0.5) * 0.05;
}

void layer_Person(in vec2 p, in float iTime, in float bob, in float legSway, inout vec3 col) {
    vec2 pCenter = vec2(-0.1, 0.0 + bob);
    vec2 pp = p - pCenter;

    float body = max(abs(pp.x) - 0.3, abs(pp.y) - 0.15);
    
    float leg1 = length(max(abs(p - vec2(0.2 - legSway, -0.2 + bob)) - vec2(0.05, 0.2), 0.0));
    float leg2 = length(max(abs(p - vec2(0.4 + legSway, -0.25 + bob)) - vec2(0.05, 0.2), 0.0));
    
    vec3 clothesBase = vec3(0.05, 0.1, 0.15); 
    vec3 dotColor = vec3(0.2, 0.8, 0.3); 
    float clothPattern = fract(sin(pp.x * 20.0 + iTime) * cos(pp.y * 20.0) * 10.0);
    vec3 clothesCol = mix(clothesBase, dotColor, step(0.7, clothPattern));
    
    vec2 hp = p - vec2(-0.5, 0.0 + bob);
    float hA = sin(iTime*2.0)*0.1;
    mat2 rotH = mat2(cos(hA), -sin(hA), sin(hA), cos(hA));
    vec2 rotHp = hp * rotH;
    
    float hat = max(abs(rotHp.x) - 0.25, abs(rotHp.y) - 0.3);
    hat = max(hat, -rotHp.x - rotHp.y*1.5 - 0.4);
    hat = max(hat, rotHp.x - rotHp.y*1.5 - 0.4);
    
    float shoe1 = length(max(abs(p - vec2(0.25 - legSway, -0.45 + bob)) - vec2(0.06, 0.03), 0.0));
    float shoe2 = length(max(abs(p - vec2(0.45 + legSway, -0.5 + bob)) - vec2(0.06, 0.03), 0.0));
    
    if (body < 0.0 || min(leg1, leg2) < 0.05) {
        col = clothesCol;
    }
    
    if (hat < 0.0) {
        col = vec3(0.3, 0.9, 0.1); 
        vec2 hGrid = fract(rotHp * 8.0);
        if (length(hGrid - 0.5) < 0.2) col = vec3(0.05);
    }
    
    if (min(shoe1, shoe2) < 0.02) col = vec3(0.8, 0.2, 0.2);
}

void layer_Bags(in vec2 p, in float iTime, in float bob, inout vec3 col) {
    vec2 bP = p - vec2(0.1, -0.3 + bob);
    float bSway = sin(iTime*4.0 + 1.0)*0.05;
    bP.x += bSway;
    float basket = max(abs(bP.x) - 0.15, abs(bP.y) - 0.1);
    
    vec2 rp = p - vec2(-0.1, -0.25 + bob);
    rp.x -= bSway*0.5;
    float rBag = max(abs(rp.x) - 0.1, abs(rp.y) - 0.08);
    
    if (basket < 0.0) {
        col = vec3(0.2, 0.6, 0.2);
        if (fract(bP.x * 30.0) < 0.1 || fract(bP.y * 30.0) < 0.1) col *= 0.5;
    }
    
    if (rBag < 0.0) {
        col = vec3(0.7, 0.1, 0.1);
        if (fract(rp.x * 20.0) < 0.2 || fract(rp.y * 20.0) < 0.2) col = vec3(0.1);
    }
}

void layer_Motorcycle(in vec2 sp, inout vec3 col) {
    vec2 mp = sp - vec2(-0.6, -0.8);
    float moto = max(abs(mp.x) - 0.3, abs(mp.y) - 0.3);
    if (moto < 0.0) {
        col = vec3(0.1);
        if (length(mp - vec2(0.2, 0.2)) < 0.05) col = vec3(0.9, 0.9, 0.8);
    }
}

vec4 layer_Street(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec2 sp = p;
    sp.y += iTime * 0.5;
    
    vec3 col = vec3(-1.0);
    
    layer_Street(sp, col);
    
    float bob = abs(sin(iTime * 4.0)) * 0.05;
    float legSway = sin(iTime * 4.0) * 0.1;
    


  return vec4(clamp(col,0.0,1.0), step(0.0, max(col.r, max(col.g, col.b))));
}

vec4 layer_Person(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec2 sp = p;
    sp.y += iTime * 0.5;
    
    vec3 col = vec3(-1.0);
    
    
    float bob = abs(sin(iTime * 4.0)) * 0.05;
    float legSway = sin(iTime * 4.0) * 0.1;
    
    layer_Person(p, iTime, bob, legSway, col);


  return vec4(clamp(col,0.0,1.0), step(0.0, max(col.r, max(col.g, col.b))));
}

vec4 layer_Bags(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec2 sp = p;
    sp.y += iTime * 0.5;
    
    vec3 col = vec3(-1.0);
    
    
    float bob = abs(sin(iTime * 4.0)) * 0.05;
    float legSway = sin(iTime * 4.0) * 0.1;
    
    layer_Bags(p, iTime, bob, col);


  return vec4(clamp(col,0.0,1.0), step(0.0, max(col.r, max(col.g, col.b))));
}

vec4 layer_Motorcycle(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec2 sp = p;
    sp.y += iTime * 0.5;
    
    vec3 col = vec3(-1.0);
    
    
    float bob = abs(sin(iTime * 4.0)) * 0.05;
    float legSway = sin(iTime * 4.0) * 0.1;
    
    layer_Motorcycle(sp, col);


  return vec4(clamp(col,0.0,1.0), step(0.0, max(col.r, max(col.g, col.b))));
}

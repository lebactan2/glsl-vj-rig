void layer_Background(in vec2 p, in float iTime, inout vec3 col) {
    col = vec3(0.85, 0.85, 0.85); 
    
    if (p.x < -0.2 && p.y > 0.0) {
        float leafDensity = fract(sin(dot(floor(p*20.0), vec2(12.9898, 78.233))) * 43758.5453);
        if (leafDensity > 0.4) {
            float anim = sin(iTime*2.0 + p.y*10.0)*0.02;
            vec2 leafP = fract(p*20.0 + vec2(anim, 0.0)) - 0.5;
            if (length(leafP) < 0.3) {
                col = vec3(0.2, 0.4 + 0.1*leafDensity, 0.2);
            }
        }
    }
}

void layer_Floor(in vec2 p, in float iTime, inout vec3 col) {
    if (p.y < 0.0) {
        vec2 floorUV = vec2(p.x / (abs(p.y) + 0.5), 1.0 / (abs(p.y) + 0.5));
        floorUV.y -= iTime * 0.1; 
        float tileX = fract(floorUV.x * 5.0);
        float tileY = fract(floorUV.y * 5.0);
        float lines = step(0.9, tileX) + step(0.9, tileY);
        col = vec3(0.3, 0.3, 0.35) - 0.1*lines;
    }
}

void layer_WoodRack(in vec2 p, in float iTime, inout vec3 col) {
    if (p.x > 0.1 && p.x < 0.8 && p.y > -0.2 && p.y < 0.9) {
        col = vec3(0.5, 0.35, 0.2); 
        
        vec2 wP = fract(p * vec2(6.0, 6.0)) - 0.5;
        float dist = length(wP);
        float angle = atan(wP.y, wP.x);
        float star = cos(angle*4.0 + iTime)*0.1 + 0.2;
        
        if (dist < star) {
            col = vec3(0.6, 0.45, 0.25); 
        } else if (dist > 0.4) {
            col = vec3(0.4, 0.25, 0.1); 
        }
        
        if (abs(p.x - 0.15) < 0.02 || abs(p.x - 0.75) < 0.02) col = vec3(0.3, 0.2, 0.1);
    }
}

void layer_ChairTable(in vec2 p, inout vec3 col) {
    if (p.x > -0.4 && p.x < -0.1 && p.y > -0.1 && p.y < 0.2) {
        float chairBody = length(max(abs(p - vec2(-0.25, 0.05)) - vec2(0.1, 0.1), 0.0));
        if (chairBody < 0.02) col = vec3(0.4, 0.6, 0.4); 
    }
}

void layer_Motorcycle(in vec2 p, in float iTime, inout vec3 col) {
    vec2 mcP = p - vec2(0.2, -0.4);
    
    float wheelL = length(p - vec2(-0.6, -0.5));
    float wheelR = length(p - vec2(0.8, -0.5));
    
    float spokeAngle = iTime * 2.0;
    
    if (wheelL < 0.3) {
        if (wheelL > 0.25) col = vec3(0.15); 
        else {
            col = vec3(0.7); 
            if (fract((atan(p.y + 0.5, p.x + 0.6) + spokeAngle)*8.0 / 6.28) < 0.1) col = vec3(0.4); 
        }
    }
    if (wheelR < 0.3) {
        if (wheelR > 0.25) col = vec3(0.15); 
        else {
            col = vec3(0.7); 
            if (fract((atan(p.y + 0.5, p.x - 0.8) + spokeAngle)*8.0 / 6.28) < 0.1) col = vec3(0.4); 
        }
    }
    
    float body1 = length(max(abs(mcP - vec2(-0.1, 0.0)) - vec2(0.3, 0.15), 0.0)) - 0.05;
    if (body1 < 0.0) {
        col = vec3(0.8, 0.15, 0.15);
        if (mcP.y > 0.1) col += 0.1; 
    }
    
    float sidePanel = length(max(abs(mcP - vec2(0.4, 0.05)) - vec2(0.15, 0.08), 0.0)) - 0.02;
    if (sidePanel < 0.0) {
        col = vec3(0.8);
        if (fract(mcP.x*30.0) < 0.5 && mcP.y > 0.0) col *= 0.5;
    }
    
    float seat = length(max(abs(mcP - vec2(-0.2, 0.25)) - vec2(0.3, 0.05), 0.0)) - 0.03;
    if (seat < 0.0) {
        col = vec3(0.1);
        col += 0.05 * fract(sin(dot(mcP*50.0, vec2(12.9898, 78.233))) * 43758.5453);
    }
    
    float pipe = length(max(abs(p - vec2(0.0, -0.4)) - vec2(0.6, 0.03), 0.0)) - 0.03;
    if (pipe < 0.0) {
        col = vec3(0.7, 0.7, 0.7); 
        if (fract(p.x * 15.0) < 0.4 && p.x > -0.2 && p.x < 0.4) col = vec3(0.3);
    }
    
    float engine = length(max(abs(p - vec2(0.2, -0.55)) - vec2(0.15, 0.1), 0.0)) - 0.02;
    if (engine < 0.0 && pipe > 0.0) {
        col = vec3(0.6);
        if (fract(p.y * 30.0) < 0.3) col *= 0.5;
    }
}

vec4 layer_Background(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_Background(p, iTime, col);


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

vec4 layer_WoodRack(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_WoodRack(p, iTime, col);


  return vec4(clamp(col,0.0,1.0), step(0.0, max(col.r, max(col.g, col.b))));
}

vec4 layer_ChairTable(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_ChairTable(p, col);


  return vec4(clamp(col,0.0,1.0), step(0.0, max(col.r, max(col.g, col.b))));
}

vec4 layer_Motorcycle(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_Motorcycle(p, iTime, col);


  return vec4(clamp(col,0.0,1.0), step(0.0, max(col.r, max(col.g, col.b))));
}

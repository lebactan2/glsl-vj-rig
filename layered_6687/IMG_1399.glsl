void layer_StoreInterior(in vec2 p, inout vec3 col) {
    if (p.y > 0.6) {
        col = vec3(0.9, 0.85, 0.8); 
        float brickW = fract(p.x * 10.0);
        float brickH = fract(p.y * 15.0);
        if (fract(p.y * 15.0 * 0.5) > 0.5) brickW = fract(p.x * 10.0 + 0.5);
        
        float mortar = step(0.95, brickW) + step(0.9, brickH);
        if (mortar > 0.0) col = vec3(0.7, 0.65, 0.6); 
    }
    
    if (p.y > 0.0 && p.y < 0.6) {
        col = vec3(0.15); 
        
        float racks = step(0.98, fract(p.x * 5.0)) + step(abs(p.y - 0.4), 0.01) + step(abs(p.y - 0.1), 0.01);
        if (racks > 0.0) col = vec3(0.05);
        
        vec2 cp = fract(p * vec2(15.0, 5.0)) - 0.5;
        if (length(cp * vec2(0.5, 1.0)) < 0.4) {
            float rnd = fract(floor(p.x * 15.0) * 12.3 + floor(p.y * 5.0) * 45.6);
            if (rnd < 0.2) col = vec3(0.8, 0.2, 0.2); 
            else if (rnd < 0.4) col = vec3(0.2, 0.3, 0.8); 
            else if (rnd < 0.6) col = vec3(0.9, 0.9, 0.2); 
            else col = vec3(0.9); 
            
            col *= 0.8 + 0.2 * sin(cp.x * 20.0);
        }
        
        if (p.x < -0.4 && p.y < 0.2) {
             col = vec3(0.4, 0.4, 0.45); 
             float folds = fract(p.y * 40.0);
             if (folds < 0.1) col = vec3(0.2); 
        }
    }
}

void layer_CheckeredFloor(in vec2 p, inout vec3 col) {
    if (p.y <= 0.0) {
        vec2 floorUV = vec2(p.x / (p.y + 0.5), 1.0 / (p.y + 0.5));
        
        float checkers = step(0.5, fract(floorUV.x * 3.0)) == step(0.5, fract(floorUV.y * 3.0)) ? 1.0 : 0.0;
        col = mix(vec3(0.1), vec3(0.9), checkers);
        
        col *= smoothstep(-0.2, 0.2, -p.y);
    }
}

void layer_MainSubjectTorso(in vec2 p, in float iTime, inout vec3 col) {
    vec2 torsoP = p - vec2(0.0, 0.0);
    float torso = length(max(abs(torsoP) - vec2(0.25, 0.35), 0.0)) - 0.05;
    
    float armL = length(max(abs(torsoP - vec2(-0.3, -0.1)) - vec2(0.06, 0.2), 0.0)) - 0.02;
    float armR1 = length(max(abs(torsoP - vec2(0.35, 0.1)) - vec2(0.05, 0.15), 0.0)) - 0.02; 
    float armR2 = length(max(abs(torsoP - vec2(0.2, 0.3)) - vec2(0.15, 0.04), 0.0)) - 0.02; 
    
    if (torso < 0.0 || armL < 0.0 || armR1 < 0.0 || armR2 < 0.0) {
        col = vec3(0.9, 0.9, 0.95);
        
        vec2 clothUV = torsoP;
        if (armL < 0.0 && torso > 0.0) clothUV.x -= 0.1; 
        
        float stripeAnim = sin(clothUV.y * 5.0 + iTime * 2.0) * 0.02;
        float stripes = step(0.5, fract((clothUV.x + stripeAnim) * 12.0));
        
        vec3 stripeCol = vec3(0.3, 0.35, 0.4);
        col = mix(col, stripeCol, stripes);
        
        float collarL = length(max(abs(torsoP - vec2(-0.15, 0.35)) - vec2(0.05, 0.08), 0.0));
        float collarR = length(max(abs(torsoP - vec2(0.15, 0.35)) - vec2(0.05, 0.08), 0.0));
        if (collarL < 0.01 || collarR < 0.01) {
            col = stripeCol;
        }
        
        float pocket = length(max(abs(torsoP - vec2(-0.12, 0.15)) - vec2(0.06, 0.07), 0.0));
        if (pocket < 0.01) {
            if (pocket > 0.005) col = vec3(0.2);
            else {
                col = mix(vec3(0.9,0.9,0.95), stripeCol, step(0.5, fract((clothUV.x + stripeAnim)*12.0)));
                
                float snoopyHead = length(max(abs(torsoP - vec2(-0.12, 0.15)) - vec2(0.03, 0.02), 0.0)) - 0.01;
                float snoopyEar = length(max(abs(torsoP - vec2(-0.08, 0.13)) - vec2(0.01, 0.03), 0.0)) - 0.005;
                float snoopyNose = length(torsoP - vec2(-0.16, 0.15)) - 0.01;
                
                if (snoopyHead < 0.0) col = vec3(0.95); 
                if (snoopyEar < 0.0 || snoopyNose < 0.0) col = vec3(0.1); 
            }
        }
        
        float seam = abs(torsoP.x - 0.02);
        if (seam < 0.01 && torsoP.y < 0.35) {
            col = mix(col, vec3(0.2), 0.3); 
            if (fract(torsoP.y * 5.0) < 0.1) col = vec3(0.1); 
        }
        
        float folds = sin(torsoP.x * 15.0 + torsoP.y * 10.0);
        col *= 0.8 + 0.2 * smoothstep(-1.0, 1.0, folds);
    }
}

void layer_SkinArmsNeck(in vec2 p, inout vec3 col) {
    vec2 torsoP = p - vec2(0.0, 0.0);
    float neck = length(max(abs(torsoP - vec2(0.0, 0.4)) - vec2(0.05, 0.05), 0.0));
    float bareArmL = length(max(abs(torsoP - vec2(-0.35, -0.35)) - vec2(0.03, 0.15), 0.0)) - 0.02; 
    float handL = length(max(abs(torsoP - vec2(-0.2, -0.4)) - vec2(0.05, 0.04), 0.0)) - 0.01; 
    float handR = length(max(abs(torsoP - vec2(0.05, 0.35)) - vec2(0.04, 0.05), 0.0)) - 0.02; 
    
    if (neck < 0.02 || bareArmL < 0.0 || handL < 0.0 || handR < 0.0) {
        col = vec3(0.9, 0.7, 0.6); 
        if (bareArmL < 0.0) col *= 0.8 + 0.2 * sin(torsoP.x * 40.0);
    }
}

void layer_Shorts(in vec2 p, in float iTime, inout vec3 col) {
    vec2 shortsP = p - vec2(0.0, -0.6);
    float shortsL = length(max(abs(shortsP - vec2(-0.15, 0.0)) - vec2(0.1, 0.2), 0.0)) - 0.02;
    float shortsR = length(max(abs(shortsP - vec2(0.15, 0.0)) - vec2(0.1, 0.2), 0.0)) - 0.02;
    
    if (shortsL < 0.0 || shortsR < 0.0) {
        vec3 stripeCol = vec3(0.3, 0.35, 0.4);
        
        float stripeAnim = sin(shortsP.y * 5.0 - iTime * 2.0) * 0.02;
        float stripes = step(0.5, fract((shortsP.x + stripeAnim) * 12.0));
        
        col = mix(vec3(0.9, 0.9, 0.95), stripeCol, stripes);
        
        if (abs(shortsP.x) < 0.05 && shortsP.y > -0.1) col *= 0.5;
        col *= 0.8 + 0.2 * sin(shortsP.x * 20.0);
    }
}

void layer_BareLegs(in vec2 p, inout vec3 col) {
    vec2 shortsP = p - vec2(0.0, -0.6);
    float legL = length(max(abs(shortsP - vec2(-0.15, -0.3)) - vec2(0.04, 0.1), 0.0)) - 0.02;
    float legR = length(max(abs(shortsP - vec2(0.15, -0.3)) - vec2(0.04, 0.1), 0.0)) - 0.02;
    if (legL < 0.0 || legR < 0.0) {
        col = vec3(0.9, 0.7, 0.6); 
        col *= 0.7 + 0.3 * sin(shortsP.x * 40.0); 
    }
}

void layer_Head(in vec2 p, inout vec3 col) {
    float head = length(p - vec2(0.0, 0.55)) - 0.12;
    if (head < 0.0) {
        col = vec3(0.9, 0.7, 0.6); 
        
        float hair = length(max(abs(p - vec2(0.0, 0.62)) - vec2(0.1, 0.05), 0.0)) - 0.03;
        if (hair < 0.0) col = vec3(0.1, 0.1, 0.1);
        
        if (abs(p.x) > 0.1 && head < -0.05) col = vec3(0.8, 0.6, 0.5);
    }
}

void layer_Phone(in vec2 p, inout vec3 col) {
    float phone = length(max(abs(p - vec2(0.05, 0.45)) - vec2(0.06, 0.12), 0.0)) - 0.02;
    if (phone < 0.0) {
        col = vec3(0.15); 
        float lens = length(p - vec2(0.02, 0.52)) - 0.02;
        if (lens < 0.0) col = vec3(0.05);
        float flash = exp(-50.0 * pow(p.x - 0.05 + p.y - 0.45, 2.0));
        col += vec3(0.5) * flash;
    }
}

vec4 layer_StoreInterior(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_StoreInterior(p, col);


  return vec4(clamp(col,0.0,1.0), step(0.0, max(col.r, max(col.g, col.b))));
}

vec4 layer_CheckeredFloor(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_CheckeredFloor(p, col);


  return vec4(clamp(col,0.0,1.0), step(0.0, max(col.r, max(col.g, col.b))));
}

vec4 layer_MainSubjectTorso(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_MainSubjectTorso(p, iTime, col);


  return vec4(clamp(col,0.0,1.0), step(0.0, max(col.r, max(col.g, col.b))));
}

vec4 layer_SkinArmsNeck(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_SkinArmsNeck(p, col);


  return vec4(clamp(col,0.0,1.0), step(0.0, max(col.r, max(col.g, col.b))));
}

vec4 layer_Shorts(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_Shorts(p, iTime, col);


  return vec4(clamp(col,0.0,1.0), step(0.0, max(col.r, max(col.g, col.b))));
}

vec4 layer_BareLegs(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_BareLegs(p, col);


  return vec4(clamp(col,0.0,1.0), step(0.0, max(col.r, max(col.g, col.b))));
}

vec4 layer_Head(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_Head(p, col);


  return vec4(clamp(col,0.0,1.0), step(0.0, max(col.r, max(col.g, col.b))));
}

vec4 layer_Phone(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_Phone(p, col);


  return vec4(clamp(col,0.0,1.0), step(0.0, max(col.r, max(col.g, col.b))));
}

void layer_Background(in vec2 p, inout vec3 col) {
    col = vec3(0.95, 0.95, 0.95); 
    float vignette = length(p);
    col *= 1.0 - 0.1 * vignette;
}

void layer_Hood(in vec2 p, in float iTime, inout vec3 col) {
    vec2 headP = p - vec2(0.0, 0.65);
    float hoodOut = length(max(abs(headP) - vec2(0.12, 0.18), 0.0)) - 0.05; 
    float faceCutout = length(max(abs(headP - vec2(0.0, -0.05)) - vec2(0.08, 0.1), 0.0)) - 0.02; 
    
    if (hoodOut < 0.0) {
        if (faceCutout < 0.0) {
            col = vec3(0.9, 0.7, 0.6); 
            float hat = length(max(abs(headP - vec2(0.0, 0.1)) - vec2(0.08, 0.02), 0.0));
            if (hat < 0.01) col = vec3(0.6, 0.2, 0.2); 
            float hatBrim = length(max(abs(headP - vec2(0.0, 0.05)) - vec2(0.09, 0.01), 0.0));
            if (hatBrim < 0.01) col = vec3(0.2); 
        } else {
            col = vec3(0.2, 0.5, 0.25); 
            float hFolds = sin(headP.x * 30.0 + headP.y * 20.0);
            col *= 0.8 + 0.2 * hFolds;
            float wind = sin(iTime * 3.0 + headP.y * 10.0) * 0.05;
            col *= 1.0 + wind;
        }
    }
}

void layer_Raincoat(in vec2 p, in float iTime, inout vec3 col) {
    vec2 bodyP = p - vec2(0.0, 0.05);
    float jacket = length(max(abs(bodyP) - vec2(0.25, 0.4), 0.0)) - 0.05;
    
    float epauletL = length(max(abs(bodyP - vec2(-0.25, 0.38)) - vec2(0.08, 0.02), 0.0)) - 0.01;
    float epauletR = length(max(abs(bodyP - vec2(0.25, 0.38)) - vec2(0.08, 0.02), 0.0)) - 0.01;
    
    float collarL = length(max(abs(bodyP - vec2(-0.1, 0.35)) - vec2(0.03, 0.04), 0.0));
    float collarR = length(max(abs(bodyP - vec2(0.1, 0.35)) - vec2(0.03, 0.04), 0.0));

    float armL = length(max(abs(bodyP - vec2(-0.35, 0.0)) - vec2(0.06, 0.35), 0.0)) - 0.02;
    float armR = length(max(abs(bodyP - vec2(0.35, 0.0)) - vec2(0.06, 0.35), 0.0)) - 0.02;
    
    float belt = length(max(abs(bodyP - vec2(0.0, -0.1)) - vec2(0.28, 0.03), 0.0));
    float buckle = length(max(abs(bodyP - vec2(0.0, -0.1)) - vec2(0.04, 0.05), 0.0));

    vec2 pantsP = p - vec2(0.0, -0.65);
    float legL = length(max(abs(pantsP - vec2(-0.12, 0.0)) - vec2(0.08, 0.25), 0.0)) - 0.02;
    float legR = length(max(abs(pantsP - vec2(0.12, 0.0)) - vec2(0.08, 0.25), 0.0)) - 0.02;

    float raincoat = min(min(jacket, min(armL, armR)), min(legL, legR));

    if (raincoat < 0.0) {
        col = vec3(0.2, 0.5, 0.25); 
        
        float wrinkleX = sin(p.x * 20.0 + p.y * 10.0 + sin(p.y * 5.0) * 2.0);
        float wrinkleY = cos(p.y * 30.0 - p.x * 15.0);
        
        float shine = smoothstep(0.8, 1.0, wrinkleX * wrinkleY);
        
        col *= 0.7 + 0.3 * (wrinkleX + wrinkleY) * 0.5;
        col += vec3(0.2) * shine;
        
        float flutter = sin(p.x * 5.0 + p.y * 10.0 + iTime * 4.0) * 0.05;
        col *= 1.0 + flutter;

        if (abs(bodyP.x) < 0.01 && bodyP.y > -0.4 && bodyP.y < 0.4) {
            col *= 0.5; 
        }
        if (abs(bodyP.x) < 0.02) {
            float b1 = length(bodyP - vec2(0.0, 0.2)) - 0.015;
            float b2 = length(bodyP - vec2(0.0, 0.05)) - 0.015;
            float b3 = length(bodyP - vec2(0.0, -0.25)) - 0.015;
            if (min(min(b1, b2), b3) < 0.0) col = vec3(0.8, 0.7, 0.2); 
        }

        if (belt < 0.01) {
            col = vec3(0.15, 0.4, 0.2); 
            if (buckle < 0.01) {
                col = vec3(0.8, 0.7, 0.2); 
                if (length(max(abs(bodyP - vec2(0.0, -0.1)) - vec2(0.02, 0.03), 0.0)) < 0.005) {
                    col = vec3(0.2, 0.5, 0.25);
                }
            }
        }
        
        if (epauletL < 0.0 || epauletR < 0.0) {
            col = vec3(0.9, 0.2, 0.2); 
            if (fract(p.x * 20.0) < 0.2) col = vec3(0.9); 
        }
        
        if (collarL < 0.01 || collarR < 0.01) {
             col = vec3(0.9, 0.1, 0.1); 
             if (length(bodyP - vec2(-0.1, 0.35)) < 0.01 || length(bodyP - vec2(0.1, 0.35)) < 0.01) {
                 col = vec3(0.9, 0.8, 0.2);
             }
        }
    }
}

void layer_Hands(in vec2 p, inout vec3 col) {
    vec2 bodyP = p - vec2(0.0, 0.05);
    float handL = length(max(abs(bodyP - vec2(-0.35, -0.4)) - vec2(0.03, 0.05), 0.0)) - 0.02;
    float handR = length(max(abs(bodyP - vec2(0.35, -0.4)) - vec2(0.03, 0.05), 0.0)) - 0.02;
    if (handL < 0.0 || handR < 0.0) col = vec3(0.9, 0.7, 0.6);
}

void layer_Shoes(in vec2 p, inout vec3 col) {
    vec2 pantsP = p - vec2(0.0, -0.65);
    float shoeL = length(max(abs(pantsP - vec2(-0.15, -0.3)) - vec2(0.06, 0.04), 0.0)) - 0.02;
    float shoeR = length(max(abs(pantsP - vec2(0.15, -0.3)) - vec2(0.06, 0.04), 0.0)) - 0.02;
    if (shoeL < 0.0 || shoeR < 0.0) {
        col = vec3(0.1); 
        if (pantsP.y > -0.28 && abs(pantsP.x) > 0.12 && abs(pantsP.x) < 0.16) col += vec3(0.2);
    }
}

void layer_Floor(in vec2 p, inout vec3 col) {
    if (p.y < -0.9) {
        col = mix(col, vec3(0.8, 0.8, 0.85), 0.5); 
        if (fract(p.x * 5.0) < 0.02) col = vec3(0.6);
    }
    float shadow = exp(-15.0 * length(max(abs(p - vec2(0.0, -0.95)) - vec2(0.3, 0.05), 0.0)));
    col *= 1.0 - 0.4 * shadow;
}

vec4 layer_Background(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_Background(p, col);


  return vec4(clamp(col,0.0,1.0), step(0.0, max(col.r, max(col.g, col.b))));
}

vec4 layer_Hood(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_Hood(p, iTime, col);


  return vec4(clamp(col,0.0,1.0), step(0.0, max(col.r, max(col.g, col.b))));
}

vec4 layer_Raincoat(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_Raincoat(p, iTime, col);


  return vec4(clamp(col,0.0,1.0), step(0.0, max(col.r, max(col.g, col.b))));
}

vec4 layer_Hands(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_Hands(p, col);


  return vec4(clamp(col,0.0,1.0), step(0.0, max(col.r, max(col.g, col.b))));
}

vec4 layer_Shoes(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_Shoes(p, col);


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

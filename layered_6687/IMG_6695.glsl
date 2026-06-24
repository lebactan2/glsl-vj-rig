void layer_Background(in vec2 p, in float iTime, inout vec3 col) {
    if (p.y < -0.2) {
        col = vec3(0.8, 0.75, 0.65); 
    } else {
        col = mix(vec3(0.7, 0.7, 0.6), vec3(0.85, 0.85, 0.8), p.y);
        if (p.x < -0.3 && p.y > 0.4) col = mix(col, vec3(0.8, 0.7, 0.3), 0.5);
    }
    
    float bgNoise = sin(p.x * 5.0 + iTime) * cos(p.y * 4.0 + iTime*0.5);
    col *= 0.95 + 0.05 * bgNoise;
}

void layer_Hat(in vec2 p, inout vec3 col, out bool isFigureHat) {
    isFigureHat = false;
    vec3 hatWhite = vec3(0.95);
    float dHat = length(p - vec2(0.0, 0.7));
    if (dHat < 0.18 && p.y > 0.65) {
        col = hatWhite;
        col *= 0.7 + 0.3 * smoothstep(0.18, 0.0, dHat);
        if (abs(p.y - 0.65) < 0.02 && abs(p.x) < 0.2) col = vec3(0.9);
        isFigureHat = true;
    }
}

void layer_Face(in vec2 p, inout vec3 col, out bool isFigureFace) {
    isFigureFace = false;
    vec3 skinTone = vec3(0.85, 0.65, 0.5);
    float dFace = length(vec2(p.x, (p.y - 0.55) * 1.2)); 
    if (dFace < 0.12 && p.y <= 0.65 && p.y > 0.4) {
        col = skinTone;
        col *= 0.8 + 0.2 * (p.y - 0.4)/0.25;
        if (abs(p.y - 0.58) < 0.01 && abs(abs(p.x) - 0.05) < 0.02) col = vec3(0.1);
        if (abs(p.y - 0.48) < 0.005 && abs(p.x) < 0.04) col = vec3(0.3, 0.2, 0.2);
        if (abs(p.x) < 0.12 && abs(p.y - 0.42 - abs(p.x)*0.5) < 0.01) col = vec3(0.1); 
        if (abs(p.y - 0.4) < 0.01 && abs(p.x) < 0.05) col = vec3(0.1); 
        isFigureFace = true;
    }
}

void layer_Torso(in vec2 p, in float iTime, inout vec3 col, out bool isFigureTorso) {
    isFigureTorso = false;
    vec3 uniformBlue = vec3(0.1, 0.15, 0.35); 
    vec3 accentOrange = vec3(0.95, 0.4, 0.1); 
    float torsoWidth = 0.35 - (p.y) * -0.02;
    if (p.y < 0.4 && p.y > -0.2 && abs(p.x) < torsoWidth) {
        col = uniformBlue;
        isFigureTorso = true;
        
        if (p.y > 0.25 && p.y < 0.4) {
            float collarLine = 0.4 - abs(p.x) * 1.5;
            if (p.y < collarLine && abs(p.x) > 0.02) {
                col = accentOrange;
            }
        }
        
        if (p.y > 0.15 && p.y < 0.22) {
            col = vec3(0.7); 
            float sweep = smoothstep(0.05, 0.0, abs(fract(p.x * 2.0 - iTime * 1.5) - 0.5));
            col += vec3(0.5) * sweep;
            
            if (p.y > 0.2) col = accentOrange; 
            if (p.y < 0.17) col = accentOrange; 
        }
        
        if (abs(p.x) < 0.005) col = accentOrange;
        
        if (abs(abs(p.x) - 0.18) < 0.08 && p.y > 0.0 && p.y < 0.12) {
            col *= 0.9;
            if (p.y > 0.1) col = accentOrange;
        }
        
        col *= 0.8 + 0.2 * cos(p.x * 10.0);
        if (p.y < -0.18) col *= 0.8;
    }
}

void layer_Arms(in vec2 p, in bool isFigurePrev, inout vec3 col, out bool isFigureArms) {
    isFigureArms = false;
    vec3 uniformBlue = vec3(0.1, 0.15, 0.35); 
    vec3 accentOrange = vec3(0.95, 0.4, 0.1); 
    vec3 skinTone = vec3(0.85, 0.65, 0.5);
    
    float dArmLeft = max(abs(p.x + 0.4) - 0.08, abs(p.y - 0.0) - 0.3);
    if (dArmLeft < 0.0 && p.y < 0.3 && !isFigurePrev) {
        col = uniformBlue;
        isFigureArms = true;
        if (p.y < -0.22) col = accentOrange;
        col *= 0.9;
    }
    float dArmRight = max(abs(p.x - 0.4) - 0.08, abs(p.y - 0.0) - 0.3);
    if (dArmRight < 0.0 && p.y < 0.3 && !isFigurePrev) {
        col = uniformBlue;
        isFigureArms = true;
        if (p.y < -0.22) col = accentOrange;
        col *= 0.9;
    }
    
    if (length(p - vec2(-0.4, -0.35)) < 0.05) { col = skinTone; isFigureArms = true; }
    if (length(p - vec2(0.4, -0.35)) < 0.05) { col = skinTone; isFigureArms = true; }
}

void layer_Pants(in vec2 p, inout vec3 col, out bool isFigurePants) {
    isFigurePants = false;
    vec3 uniformBlue = vec3(0.1, 0.15, 0.35); 
    vec3 accentOrange = vec3(0.95, 0.4, 0.1); 
    
    if (p.y < -0.2 && abs(p.x) < 0.25) {
        col = uniformBlue;
        if (abs(p.x) < 0.02 && p.y < -0.4) col = vec3(0.05, 0.08, 0.2); 
        if (p.y < -0.4 && p.y > -0.7) {
            if (p.x < -0.2) col = accentOrange;
            if (p.x > 0.2) col = accentOrange;
            if (abs(abs(p.x) - 0.23) < 0.01) col = uniformBlue;
        }
        col *= 0.85 + 0.15 * cos(p.x * 20.0);
        isFigurePants = true;
    }
}

void layer_Shadow(in vec2 p, in bool isFigure, inout vec3 col) {
    if (!isFigure) {
        float shadow = max(abs(p.x) - 0.4, abs(p.y) - 0.8);
        if (shadow < 0.0) col *= 0.9;
    }
}

vec4 layer_Background(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_Background(p, iTime, col);
    
    bool isFigureHat, isFigureFace, isFigureTorso, isFigureArms, isFigurePants;
    
    
    bool isFigurePrev = isFigureHat || isFigureFace || isFigureTorso;
    
    bool isFigure = isFigureHat || isFigureFace || isFigureTorso || isFigureArms || isFigurePants;
    


  return vec4(clamp(col,0.0,1.0), step(0.0, max(col.r, max(col.g, col.b))));
}

vec4 layer_Hat(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    
    bool isFigureHat, isFigureFace, isFigureTorso, isFigureArms, isFigurePants;
    
    layer_Hat(p, col, isFigureHat);
    
    bool isFigurePrev = isFigureHat || isFigureFace || isFigureTorso;
    
    bool isFigure = isFigureHat || isFigureFace || isFigureTorso || isFigureArms || isFigurePants;
    


  return vec4(clamp(col,0.0,1.0), step(0.0, max(col.r, max(col.g, col.b))));
}

vec4 layer_Face(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    
    bool isFigureHat, isFigureFace, isFigureTorso, isFigureArms, isFigurePants;
    
    layer_Face(p, col, isFigureFace);
    
    bool isFigurePrev = isFigureHat || isFigureFace || isFigureTorso;
    
    bool isFigure = isFigureHat || isFigureFace || isFigureTorso || isFigureArms || isFigurePants;
    


  return vec4(clamp(col,0.0,1.0), step(0.0, max(col.r, max(col.g, col.b))));
}

vec4 layer_Torso(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    
    bool isFigureHat, isFigureFace, isFigureTorso, isFigureArms, isFigurePants;
    
    layer_Torso(p, iTime, col, isFigureTorso);
    
    bool isFigurePrev = isFigureHat || isFigureFace || isFigureTorso;
    
    bool isFigure = isFigureHat || isFigureFace || isFigureTorso || isFigureArms || isFigurePants;
    


  return vec4(clamp(col,0.0,1.0), step(0.0, max(col.r, max(col.g, col.b))));
}

vec4 layer_Arms(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    
    bool isFigureHat, isFigureFace, isFigureTorso, isFigureArms, isFigurePants;
    
    
    bool isFigurePrev = isFigureHat || isFigureFace || isFigureTorso;
    layer_Arms(p, isFigurePrev, col, isFigureArms);
    
    bool isFigure = isFigureHat || isFigureFace || isFigureTorso || isFigureArms || isFigurePants;
    


  return vec4(clamp(col,0.0,1.0), step(0.0, max(col.r, max(col.g, col.b))));
}

vec4 layer_Pants(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    
    bool isFigureHat, isFigureFace, isFigureTorso, isFigureArms, isFigurePants;
    
    
    bool isFigurePrev = isFigureHat || isFigureFace || isFigureTorso;
    layer_Pants(p, col, isFigurePants);
    
    bool isFigure = isFigureHat || isFigureFace || isFigureTorso || isFigureArms || isFigurePants;
    


  return vec4(clamp(col,0.0,1.0), step(0.0, max(col.r, max(col.g, col.b))));
}

vec4 layer_Shadow(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    
    bool isFigureHat, isFigureFace, isFigureTorso, isFigureArms, isFigurePants;
    
    
    bool isFigurePrev = isFigureHat || isFigureFace || isFigureTorso;
    
    bool isFigure = isFigureHat || isFigureFace || isFigureTorso || isFigureArms || isFigurePants;
    
    layer_Shadow(p, isFigure, col);


  return vec4(clamp(col,0.0,1.0), step(0.0, max(col.r, max(col.g, col.b))));
}

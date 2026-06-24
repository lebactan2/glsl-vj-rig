void layer_StorefrontStructure(inout vec3 col) {
    col = vec3(0.2, 0.15, 0.1); 
}

void layer_LeftDisplayPanel(in vec2 p, in float iTime, inout vec3 col) {
    if (p.x < -0.7 && p.y < 0.8 && p.y > -0.5) {
        col = vec3(0.85, 0.88, 0.88); 
        
        float textAnim = sin(iTime + p.y*10.0);
        if (abs(p.x + 0.9) < 0.05 && fract(p.y*4.0) < 0.5) {
            col = vec3(0.7, 0.2, 0.2); 
            if (textAnim > 0.5) col *= 0.8; 
        }
        if (abs(p.x + 0.8) < 0.05 && fract(p.y*6.0 + 0.5) < 0.5) {
            col = vec3(0.2, 0.5, 0.3);
            if (textAnim < -0.5) col *= 0.8;
        }
        if (abs(p.x + 0.85) < 0.15 && p.y > -0.4 && p.y < -0.2 && fract(p.y*20.0) < 0.4) {
            col = vec3(0.2, 0.4, 0.6);
        }
        
        if (p.x > -0.72 || p.y < -0.48 || p.y > 0.78) col = vec3(0.3, 0.2, 0.1);
    }
}

void layer_UpperDisplayCase(in vec2 p, in float iTime, inout vec3 col) {
    if (p.x > -0.5 && p.x < 1.0 && p.y > 0.05 && p.y < 0.8) {
        col = vec3(0.5, 0.7, 0.8); 
        
        if (p.y < 0.3) {
            col = vec3(0.2, 0.4, 0.7);
            float wave = sin(p.x*20.0 - iTime*3.0)*sin(p.y*50.0);
            if (wave > 0.5) col = vec3(0.8, 0.9, 1.0); 
        }
        
        if (p.y > 0.3 && p.y < 0.4) {
            float mt = sin(p.x*10.0)*0.05 + 0.35;
            if (p.y < mt) col = vec3(0.4, 0.5, 0.4);
        }
        
        vec2 hP = p - vec2(0.2, 0.4);
        
        float horse = length(max(abs(hP) - vec2(0.12, 0.08), 0.0));
        if (horse < 0.05) col = vec3(0.3, 0.2, 0.15); 
        if (length(hP - vec2(0.15, 0.15)) < 0.06) col = vec3(0.3, 0.2, 0.15);
        float legAnim = sin(iTime*8.0)*0.05;
        if (length(hP - vec2(-0.1 + legAnim, -0.15)) < 0.03) col = vec3(0.2, 0.1, 0.05);
        if (length(hP - vec2(0.1 - legAnim, -0.15)) < 0.03) col = vec3(0.2, 0.1, 0.05);
        
        if (length(hP - vec2(-0.05, 0.15)) < 0.06) col = vec3(0.7, 0.3, 0.3); 
        if (length(hP - vec2(-0.05, 0.25)) < 0.04) col = vec3(0.9, 0.8, 0.7); 
        
        if (length(p - vec2(0.7, 0.4)) < 0.15) {
            col = vec3(0.2, 0.5, 0.3); 
            if (abs(p.x - 0.7) < 0.02 && p.y < 0.4 && p.y > 0.3) col = vec3(0.3, 0.2, 0.1);
        }
        
        if (p.x < -0.48 || p.x > 0.98 || p.y < 0.07 || p.y > 0.78) col = vec3(0.3, 0.2, 0.1);
    }
}

void layer_LowerDisplayCase(in vec2 p, in float iTime, inout vec3 col) {
    if (p.x > -0.5 && p.x < 1.0 && p.y < -0.05 && p.y > -0.7) {
        col = vec3(0.6, 0.55, 0.5); 
        
        if (p.y < -0.5) col = vec3(0.4, 0.35, 0.3);
        
        vec2 fP = p - vec2(0.2, -0.3);
        
        if (length(max(abs(fP - vec2(-0.1, 0.05)) - vec2(0.05, 0.1), 0.0)) < 0.02) col = vec3(0.8, 0.2, 0.3); 
        if (length(fP - vec2(-0.1, 0.2)) < 0.03) col = vec3(0.9, 0.8, 0.7); 
        
        if (length(max(abs(fP - vec2(0.1, -0.1)) - vec2(0.08, 0.05), 0.0)) < 0.02) col = vec3(0.2, 0.5, 0.8); 
        if (length(fP - vec2(0.1, 0.0)) < 0.03) col = vec3(0.9, 0.8, 0.7); 
        
        if (length(p - vec2(0.75, -0.45)) < 0.15) {
            col = vec3(0.1, 0.3, 0.2); 
            if (fract(p.x*20.0 + p.y*15.0 - iTime) < 0.3) col = vec3(0.8, 0.8, 0.4); 
        }
        
        if (p.x < -0.48 || p.x > 0.98 || p.y < -0.68 || p.y > -0.07) col = vec3(0.3, 0.2, 0.1);
    }
}

void layer_CurvyWoodenDividers(in vec2 p, inout vec3 col) {
    if (abs(p.y - 0.0) < 0.05 && p.x > -0.5) {
        col = vec3(0.4, 0.25, 0.15); 
        float wave = sin(p.x * 10.0)*0.02;
        if (abs(p.y - wave) < 0.01) col = vec3(0.2, 0.1, 0.05); 
    }
}

void layer_LowerItems(in vec2 p, inout vec3 col) {
    if (p.y < -0.7) {
        if (length(max(abs(p - vec2(0.1, -0.9)) - vec2(0.15, 0.1), 0.0)) < 0.05 && p.y < -0.8) {
            col = vec3(0.2, 0.4, 0.8);
            if (fract((p.x + p.y)*20.0) < 0.2 || fract((p.x - p.y)*20.0) < 0.2) col *= 0.8;
        }
        
        if (length(max(abs(p - vec2(0.6, -0.9)) - vec2(0.1, 0.05), 0.0)) < 0.05 && p.y < -0.85) {
            col = vec3(0.8, 0.8, 0.8);
            if (p.y > -0.88 && abs(p.x - 0.6) < 0.12) col = vec3(0.4);
        }
    }
}

vec4 layer_StorefrontStructure(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_StorefrontStructure(col);


  return vec4(clamp(col,0.0,1.0), step(0.0, max(col.r, max(col.g, col.b))));
}

vec4 layer_LeftDisplayPanel(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_LeftDisplayPanel(p, iTime, col);


  return vec4(clamp(col,0.0,1.0), step(0.0, max(col.r, max(col.g, col.b))));
}

vec4 layer_UpperDisplayCase(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_UpperDisplayCase(p, iTime, col);


  return vec4(clamp(col,0.0,1.0), step(0.0, max(col.r, max(col.g, col.b))));
}

vec4 layer_LowerDisplayCase(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_LowerDisplayCase(p, iTime, col);


  return vec4(clamp(col,0.0,1.0), step(0.0, max(col.r, max(col.g, col.b))));
}

vec4 layer_CurvyWoodenDividers(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_CurvyWoodenDividers(p, col);


  return vec4(clamp(col,0.0,1.0), step(0.0, max(col.r, max(col.g, col.b))));
}

vec4 layer_LowerItems(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_LowerItems(p, col);


  return vec4(clamp(col,0.0,1.0), step(0.0, max(col.r, max(col.g, col.b))));
}

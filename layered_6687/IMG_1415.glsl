void layer_RunwayBackground(in vec2 p, inout vec3 col) {
    col = mix(vec3(0.95, 0.95, 0.95), vec3(0.7, 0.7, 0.75), smoothstep(0.0, -1.0, p.y));
    float panel = fract(p.x * 1.5);
    if (abs(panel) < 0.02) col = vec3(0.8);
}

void layer_ModelSharedFeatures(in vec2 localP, in int modelId, inout vec3 col) {
    float head = length(localP - vec2(0.0, 0.75)) - 0.1;
    float neck = length(max(abs(localP - vec2(0.0, 0.6)) - vec2(0.03, 0.05), 0.0));
    
    if (head < 0.0 || neck < 0.01) {
        col = vec3(0.9, 0.75, 0.65); 
        if (modelId == 2) col = vec3(0.7, 0.5, 0.4); 
        
        if (localP.y > 0.8) {
             if (modelId == 0) col = vec3(0.4, 0.2, 0.1); 
             if (modelId == 1) col = vec3(0.9, 0.7, 0.2); 
             if (modelId == 2) col = vec3(0.2, 0.1, 0.1); 
             
             float hTex = sin(localP.x * 100.0);
             col *= 0.8 + 0.2 * hTex;
        }
        
        float glasses = length(max(abs(localP - vec2(0.0, 0.75)) - vec2(0.07, 0.02), 0.0));
        if (glasses < 0.01) {
            if (modelId == 0 || modelId == 1) {
                col = vec3(0.8, 0.1, 0.1); 
                if (localP.y > 0.75 && localP.x > -0.05) col += vec3(0.3);
            }
            if (modelId == 2) {
                col = vec3(0.1); 
            }
        }
        
        float lips = length(max(abs(localP - vec2(0.0, 0.68)) - vec2(0.02, 0.005), 0.0));
        if (lips < 0.005) col = vec3(0.8, 0.4, 0.4);
    }
    
    float armL = length(max(abs(localP - vec2(-0.3, 0.0)) - vec2(0.03, 0.3), 0.0)) - 0.02;
    float armR = length(max(abs(localP - vec2(0.3, 0.0)) - vec2(0.03, 0.3), 0.0)) - 0.02;
    if ((armL < 0.0 || armR < 0.0) && localP.y < 0.4 && modelId != 2) {
        col = vec3(0.9, 0.75, 0.65); 
        col *= 0.8 + 0.2 * sin(localP.x * 40.0); 
    }
}

void layer_ModelLeft(in vec2 localP, in int modelId, in float iTime, inout vec3 col) {
    if (modelId == 0) {
        float top = length(max(abs(localP - vec2(0.0, 0.2)) - vec2(0.2, 0.25), 0.0)) - 0.1;
        float sleeveL = length(max(abs(localP - vec2(-0.35, 0.25)) - vec2(0.05, 0.15), 0.0)) - 0.08;
        float sleeveR = length(max(abs(localP - vec2(0.35, 0.25)) - vec2(0.05, 0.15), 0.0)) - 0.08;
        
        if (top < 0.0 || sleeveL < 0.0 || sleeveR < 0.0) {
            col = vec3(0.95); 
            
            float folds = sin(localP.x * 20.0 + localP.y * 10.0) * cos(localP.x * 15.0);
            float puffAnim = sin(iTime * 3.0 + localP.y * 5.0) * 0.05;
            
            col *= 0.8 + 0.2 * smoothstep(-1.0, 1.0, folds + puffAnim);
            
            float neckHole = length(localP - vec2(0.0, 0.55)) - 0.1;
            if (neckHole < 0.0) col = vec3(0.9, 0.75, 0.65); 
        }
        
        float pants = length(max(abs(localP - vec2(0.0, -0.6)) - vec2(0.3, 0.5), 0.0)) - 0.05;
        if (pants < 0.0 && localP.y < -0.1) {
             col = vec3(0.1, 0.15, 0.3); 
             
             float pleats = abs(sin(localP.x * 15.0));
             float sway = sin(localP.y * 5.0 - iTime * 4.0) * 0.1;
             float pAnim = abs(sin((localP.x + sway) * 15.0));
             
             col *= 0.6 + 0.4 * pAnim;
             if (abs(localP.x) < 0.05 && localP.y > -0.3) col *= 0.5;
        }
        
        float belt = length(max(abs(localP - vec2(0.0, -0.05)) - vec2(0.25, 0.08), 0.0)) - 0.02;
        if (belt < 0.0) {
            col = vec3(0.15); 
            float bag = length(max(abs(localP - vec2(0.0, -0.05)) - vec2(0.15, 0.06), 0.0)) - 0.01;
            if (bag < 0.0) {
                col = vec3(0.2);
                col += vec3(0.1) * sin(localP.x * 30.0); 
                if (abs(localP.y - 0.0) < 0.005 && abs(localP.x) < 0.15) col = vec3(0.8);
            }
        }
    }
}

void layer_ModelCenter(in vec2 localP, in int modelId, in float iTime, inout vec3 col) {
    if (modelId == 1) {
        float dress = length(max(abs(localP - vec2(0.0, 0.0)) - vec2(0.2, 0.5), 0.0)) - 0.15;
        float billowingL = length(localP - vec2(-0.25, 0.0)) - 0.25;
        float billowingR = length(localP - vec2(0.25, 0.0)) - 0.25;
        
        if (dress < 0.0 || billowingL < 0.0 || billowingR < 0.0) {
            col = vec3(0.92, 0.92, 0.95); 
            
            float folds1 = sin(localP.x * 25.0 + localP.y * 10.0);
            float folds2 = cos(localP.x * 15.0 - localP.y * 20.0);
            
            float windX = sin(localP.x * 5.0 + iTime * 3.0) * 0.05;
            float windY = cos(localP.y * 5.0 - iTime * 2.0) * 0.05;
            float flow = sin((localP.x + windX) * 30.0 + (localP.y + windY) * 20.0);
            
            float shadow = smoothstep(-1.0, 1.0, folds1) * smoothstep(-1.0, 1.0, flow);
            float shine = smoothstep(0.8, 1.0, flow * folds2);
            
            col *= 0.6 + 0.4 * shadow;
            col += vec3(0.1) * shine;
            
            float centerFold = abs(localP.x - sin(localP.y * 2.0) * 0.05);
            if (centerFold < 0.02) col *= 0.5; 
            
            float scoop = length(localP - vec2(0.0, 0.6)) - 0.08;
            if (scoop < 0.0) col = vec3(0.9, 0.75, 0.65); 
        }
    }
}

void layer_ModelRight(in vec2 localP, in int modelId, in float iTime, inout vec3 col) {
    if (modelId == 2) {
        float cape = length(max(abs(localP - vec2(0.0, 0.1)) - vec2(0.35, 0.4), 0.0)) - 0.05;
        cape = max(cape, localP.y - 0.55 + abs(localP.x) * 0.5);
        
        float skirt = length(max(abs(localP - vec2(0.0, -0.6)) - vec2(0.2, 0.4), 0.0)) - 0.05;

        if (cape < 0.0 || skirt < 0.0) {
            col = vec3(0.75, 0.7, 0.6); 
            
            float tex = sin(localP.x * 20.0) * cos(localP.y * 30.0);
            float sway = sin(localP.y * 3.0 - iTime * 5.0) * 0.03;
            float vFolds = abs(sin((localP.x + sway) * 15.0));
            
            col *= 0.8 + 0.2 * tex + 0.1 * vFolds;
            
            float armDrape = abs(abs(localP.x) - 0.25);
            if (armDrape < 0.05 && localP.y > -0.3) col *= 0.7;
            
            if (localP.y < -0.25 && localP.y > -0.35 && skirt < 0.0) {
                float dropShad = exp(-20.0 * (0.35 + localP.y));
                col *= 1.0 - 0.4 * dropShad;
            }
            
            float collar = length(max(abs(localP - vec2(0.0, 0.55)) - vec2(0.08, 0.04), 0.0));
            if (collar < 0.01) col = vec3(0.65, 0.6, 0.5); 
            
            if (abs(localP.y - (-0.3)) < 0.02 && cape < 0.0) {
                if (fract(localP.x * 40.0) < 0.5) col = vec3(0.5, 0.45, 0.4);
            }
        }
        
        float bag = length(max(abs(localP - vec2(0.0, -0.15)) - vec2(0.18, 0.08), 0.0)) - 0.02;
        if (bag < 0.0) {
            col = vec3(0.9, 0.8, 0.7); 
            
            float edgeDist = length(max(abs(localP - vec2(0.0, -0.15)) - vec2(0.15, 0.05), 0.0));
            col *= 0.8 + 0.2 * smoothstep(0.05, 0.0, edgeDist);
            
            float clasp = length(localP - vec2(0.1, -0.15)) - 0.02;
            if (clasp < 0.0) {
                col = vec3(0.2); 
                if (clasp > -0.005) col = vec3(0.5); 
            }
            
            float flap = abs(localP.y - (-0.1));
            if (flap < 0.005 && abs(localP.x) < 0.16) col *= 0.6;
        }
    }
}

vec4 layer_RunwayBackground(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_RunwayBackground(p, col);
    
    vec2 localP = vec2(fract(p.x * 1.5 + 0.5) * 2.0 - 1.0, p.y);
    int modelId = int(floor(p.x * 1.5 + 1.5)); 
    


  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

vec4 layer_ModelSharedFeatures(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    
    vec2 localP = vec2(fract(p.x * 1.5 + 0.5) * 2.0 - 1.0, p.y);
    int modelId = int(floor(p.x * 1.5 + 1.5)); 
    
    layer_ModelSharedFeatures(localP, modelId, col);


  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

vec4 layer_ModelLeft(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    
    vec2 localP = vec2(fract(p.x * 1.5 + 0.5) * 2.0 - 1.0, p.y);
    int modelId = int(floor(p.x * 1.5 + 1.5)); 
    
    layer_ModelLeft(localP, modelId, iTime, col);


  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

vec4 layer_ModelCenter(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    
    vec2 localP = vec2(fract(p.x * 1.5 + 0.5) * 2.0 - 1.0, p.y);
    int modelId = int(floor(p.x * 1.5 + 1.5)); 
    
    layer_ModelCenter(localP, modelId, iTime, col);


  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

vec4 layer_ModelRight(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    
    vec2 localP = vec2(fract(p.x * 1.5 + 0.5) * 2.0 - 1.0, p.y);
    int modelId = int(floor(p.x * 1.5 + 1.5)); 
    
    layer_ModelRight(localP, modelId, iTime, col);


  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

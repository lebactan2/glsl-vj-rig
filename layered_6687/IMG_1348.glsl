void layer_BackgroundWalls(inout vec3 col) {
    col = vec3(0.9, 0.9, 0.92);
}

void layer_GodRays(in vec2 p, in float iTime, inout vec3 col) {
    if (p.x < 0.5) {
        float rayAngle = atan(p.y - 0.6, p.x - (-0.8));
        float rays = sin(rayAngle * 20.0 + iTime * 0.5) * sin(rayAngle * 10.0 - iTime * 0.2);
        rays = max(0.0, rays);
        float mask = smoothstep(1.0, 0.0, length(p - vec2(-0.8, 0.6))); 
        col += vec3(0.2, 0.25, 0.3) * rays * mask;
    }
}

void layer_Pillar(in vec2 p, inout vec3 col) {
    float column = abs(p.x - 0.7);
    if (column < 0.2) {
        col = vec3(0.25, 0.5, 0.7); 
        col *= 0.5 + 0.5 * cos((p.x - 0.7) * 7.85); 
        
        float rY = fract(p.y * 5.0 + sin(p.x * 10.0)*0.2);
        float rX = (p.x - 0.7) * 5.0;
        float cloud = sin(rY * 10.0 + rX * 10.0) * cos(rY * 10.0 - rX * 10.0);
        
        if (cloud > 0.3) {
            col = mix(col, vec3(0.8, 0.2, 0.2), 0.7); 
            if (cloud > 0.7) col = mix(col, vec3(0.9, 0.8, 0.2), 0.8); 
            col *= 1.0 - 0.3 * smoothstep(0.3, 0.4, cloud); 
        }
    }
}

void layer_Headpiece(in vec2 p, inout vec3 col) {
    vec2 hpP = p - vec2(0.0, 0.65);
    float hpCurve = length(max(abs(hpP - vec2(0.0, 0.1)) - vec2(0.15, 0.05), 0.0)) - 0.04;
    hpCurve = max(hpCurve, -(length(hpP - vec2(0.0, 0.2)) - 0.15));
    
    if (hpCurve < 0.0) {
        col = vec3(0.4, 0.2, 0.1); 
        float grain = sin(hpP.x * 80.0 + hpP.y * 30.0 + sin(hpP.x * 20.0)*5.0);
        col *= 0.7 + 0.3 * grain;
        col += vec3(0.1) * exp(-50.0 * pow(hpP.y - 0.12, 2.0)); 
    }
}

void layer_VeilAndEmblem(in vec2 p, in float iTime, inout vec3 col) {
    float veilTop = p.y - (0.8 - abs(p.x) * 1.5);
    float drapeL = -0.3 - (0.1 * (0.5 - p.y));
    float drapeR = 0.3 + (0.1 * (0.5 - p.y));
    float faceMask = length(max(abs(p - vec2(0.0, 0.4)) - vec2(0.08, 0.12), 0.0)) - 0.05;

    if (veilTop < 0.0 && p.y > -1.0 && p.x > drapeL && p.x < drapeR) {
        if (faceMask < 0.0) {
            col = vec3(0.8, 0.6, 0.45); 
            float wrinkles = sin(p.y * 150.0) * 0.03 + sin(p.x * 100.0) * 0.03;
            col *= 0.9 + wrinkles;
            
            float eyeL = length(p - vec2(-0.05, 0.45));
            float eyeR = length(p - vec2(0.05, 0.45));
            
            float blink = smoothstep(0.95, 1.0, sin(iTime * 2.0)); 
            if (min(eyeL, eyeR) < 0.015 && abs(p.y - 0.45) > blink * 0.015) {
                col = vec3(0.1); 
            }
            if (length(max(abs(p - vec2(0.0, 0.32)) - vec2(0.03, 0.005), 0.0)) < 0.01) col = vec3(0.3, 0.1, 0.1);
            
        } else {
            col = vec3(0.95, 0.95, 1.0); 
            float sway = sin(p.y * 5.0 - iTime * 2.0) * 0.05; 
            float folds = sin((p.x + sway) * 20.0);
            col *= 0.85 + 0.15 * smoothstep(-1.0, 1.0, folds);
            
            if (abs(p.x + sway*0.5) < 0.005 && p.y < 0.2) col *= 0.8;
            
            vec2 embP = p - vec2(0.0, -0.3);
            
            embP.y += sin(iTime * 1.5) * 0.02;
            
            float emblemBase = length(embP) - 0.15;
            float emblemTop = length(max(abs(embP - vec2(0.0, 0.18)) - vec2(0.05, 0.05), 0.0)) - 0.02; 
            float fCut1 = length(embP - vec2(-0.08, 0.2)) - 0.06;
            float fCut2 = length(embP - vec2(0.08, 0.2)) - 0.06;
            
            if (emblemBase < 0.0 || (emblemTop < 0.0 && fCut1 > 0.0 && fCut2 > 0.0)) {
                col = mix(vec3(0.2, 0.6, 0.8), vec3(0.8, 0.7, 0.2), smoothstep(0.12, 0.15, length(embP)));
                
                float eyeShape = length(vec2(embP.x, embP.y * 1.5)) - 0.1;
                if (eyeShape < 0.0) {
                    col = vec3(1.0); 
                    
                    vec2 pupilP = embP - vec2(sin(iTime * 0.8) * 0.04, 0.0);
                    float iris = length(pupilP) - 0.05;
                    
                    if (iris < 0.0) {
                        col = vec3(0.5, 0.2, 0.1); 
                        col += sin(atan(pupilP.y, pupilP.x)*30.0)*0.1;
                        if (length(pupilP) < 0.02) col = vec3(0.0);
                        if (length(pupilP - vec2(-0.01, 0.01)) < 0.01) col = vec3(1.0);
                    }
                }
            }
            
            float gripMove = sin(iTime * 1.5) * 0.01;
            float handL = length(max(abs(p - vec2(-0.12 + gripMove, -0.4)) - vec2(0.04, 0.06), 0.0)) - 0.02;
            float handR = length(max(abs(p - vec2(0.12 - gripMove, -0.4)) - vec2(0.04, 0.06), 0.0)) - 0.02;
            if (handL < 0.0 || handR < 0.0) {
                col = vec3(0.8, 0.6, 0.45); 
                if (fract(p.x * 40.0) < 0.1) col *= 0.8; 
            }
        }
    }
}

vec4 layer_BackgroundWalls(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_BackgroundWalls(col);


  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

vec4 layer_GodRays(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_GodRays(p, iTime, col);


  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

vec4 layer_Pillar(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_Pillar(p, col);


  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

vec4 layer_Headpiece(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_Headpiece(p, col);


  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

vec4 layer_VeilAndEmblem(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_VeilAndEmblem(p, iTime, col);


  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

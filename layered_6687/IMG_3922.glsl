void layer_Background(in vec2 p, in float iTime, inout vec3 col) {
    col = vec3(0.8, 0.85, 0.2);
    
    float sweep = sin(p.x * 2.0 - p.y * 3.0 + iTime) * 0.5 + 0.5;
    col += vec3(0.1, 0.1, 0.0) * sweep;
    
    if (p.x < -0.8) {
        col = vec3(0.2, 0.2, 0.5); 
        if (fract(p.y * 10.0 + iTime*0.5) > 0.5 && p.x > -0.9) col = vec3(1.0);
    }
}

void layer_TextLetters(in vec2 p, in float iTime, inout vec3 col) {
    vec3 red = vec3(0.8, 0.1, 0.1);
    float pulse = 1.0 + 0.1 * sin(iTime * 3.0);
    
    float dP = max(abs(p.x + 0.4) - 0.05*pulse, abs(p.y - 0.5) - 0.2*pulse);
    dP = min(dP, max(abs(p.x + 0.25) - 0.15*pulse, abs(p.y - 0.6) - 0.1*pulse));
    dP = max(dP, -max(abs(p.x + 0.25) - 0.05*pulse, abs(p.y - 0.6) - 0.05*pulse));
    if (dP < 0.0) col = red;
    
    float dH = max(abs(abs(p.x + 0.4) - 0.1*pulse) - 0.03*pulse, abs(p.y - 0.0) - 0.15*pulse);
    dH = min(dH, max(abs(p.x + 0.4) - 0.1*pulse, abs(p.y - 0.0) - 0.03*pulse));
    if (dH < 0.0) col = red;

    float dO = max(abs(p.x + 0.4) - 0.15*pulse, abs(p.y + 0.4) - 0.15*pulse);
    dO = max(dO, -(max(abs(p.x + 0.4) - 0.05*pulse, abs(p.y + 0.4) - 0.05*pulse)));
    if (dO < 0.0) col = red;
    
    float dC = max(abs(p.x - 0.2) - 0.15*pulse, abs(p.y - 0.6) - 0.15*pulse);
    dC = max(dC, -(max(abs(p.x - 0.2) - 0.05*pulse, abs(p.y - 0.6) - 0.05*pulse)));
    dC = max(dC, -(p.x - 0.2));
    if (dC < 0.0) col = red;
    
    float dA = max(abs(p.x - 0.2) - 0.15*pulse, abs(p.y - 0.2) - 0.15*pulse);
    dA = max(dA, -(max(abs(p.x - 0.2) - 0.05*pulse, abs(p.y - 0.2) - 0.05*pulse)));
    if (dA < 0.0 && p.y < 0.3) col = red;

    float dY = max(abs(abs(p.x - 0.2) - 0.1*pulse) - 0.03*pulse, abs(p.y + 0.2) - 0.15*pulse);
    if (dY < 0.0) col = red;
    
    if (p.x > 0.4 && p.x < 0.7 && fract(p.y * 15.0) > 0.8) {
        col = red;
    }
}

void layer_FoodPicture(in vec2 p, in float iTime, inout vec3 col) {
    if (p.x > -0.1 && p.x < 0.8 && p.y > 0.5 && p.y < 0.95) {
        col = vec3(0.7, 0.6, 0.5); 
        
        vec2 center = vec2(0.35, 0.72);
        float dBowl = length(p - center);
        if (dBowl < 0.2) {
            col = vec3(0.9, 0.9, 0.9); 
            if (dBowl < 0.18) {
                col = vec3(0.8, 0.7, 0.6); 
                float f = fract(sin(dot(p * 50.0 + iTime*0.05, vec2(12.9898, 78.233))) * 43758.5453);
                if (f > 0.7) col = vec3(0.4, 0.2, 0.1); 
                if (f < 0.2) col = vec3(0.2, 0.5, 0.1); 
            }
        }
        
        float steamDist = p.y - 0.72;
        if (steamDist > 0.0 && steamDist < 0.2) {
            float steamPhase = p.x * 20.0 - iTime * 3.0 + sin(p.y * 20.0 + iTime);
            float steamDensity = sin(steamPhase) * 0.5 + 0.5;
            steamDensity *= smoothstep(0.2, 0.0, steamDist) * smoothstep(0.2, 0.0, abs(p.x - 0.35));
            col = mix(col, vec3(0.9, 0.95, 1.0), steamDensity * 0.6);
        }
    }
}

vec4 layer_Background(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_Background(p, iTime, col);


  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

vec4 layer_TextLetters(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_TextLetters(p, iTime, col);


  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

vec4 layer_FoodPicture(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_FoodPicture(p, iTime, col);


  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

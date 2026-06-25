void layer_Background(inout vec3 col) {
    col = vec3(1.0); 
}

void layer_Kite(in vec2 p, in vec2 rp, in float diamond, in float iTime, inout vec3 col) {
    if (diamond < 0.01) {
        col = vec3(0.3, 0.7, 0.5); 
        
        if (p.x < 0.0 && p.y > 0.2) col = vec3(0.9, 0.5, 0.1);
        if (p.x > 0.0 && p.y > 0.2) col = vec3(0.95, 0.85, 0.1);
        
        if (p.y > abs(p.x) * 0.8 + 0.2 && p.y > 0.4) {
             col = vec3(0.9, 0.8, 0.1); 
             if(p.y > 0.6) col = vec3(0.9, 0.5, 0.1); 
        }
        
        float paper1 = sin(rp.x * 50.0 + rp.y * 30.0) * 0.02;
        float paper2 = cos(rp.x * 20.0 - rp.y * 40.0) * 0.03;
        float crinkle = abs(paper1 * paper2) * 50.0;
        
        float wind = sin(p.x * 10.0 + p.y * 5.0 + iTime * 4.0) * 0.05;
        col *= 0.9 + crinkle + wind;
        
        float stickV = abs(p.x);
        if (stickV < 0.01 && p.y > -0.6 && p.y < 0.8) {
            col = vec3(0.8, 0.7, 0.5); 
            col *= 0.8 + 0.2 * sin(p.y * 100.0); 
        }
        
        float arcY = -0.8 * (p.x * p.x) + 0.6;
        float stickH = abs(p.y - arcY);
        if (stickH < 0.01 && abs(p.x) < 0.6) {
            col = vec3(0.8, 0.7, 0.5);
            col *= 0.8 + 0.2 * sin(p.x * 100.0);
        }
    }
}

void layer_KiteTail(in vec2 p, in float iTime, inout vec3 col) {
    float tailV1 = abs(p.x) * 1.5 - 0.2; 
    float tailY = p.y + 0.8; 
    float tailTop = p.y + 0.6; 
    
    if (tailV1 < tailY && tailY > 0.0 && tailTop < 0.0) {
        col = vec3(0.35, 0.25, 0.25); 
        
        float tailFolds = sin(p.x * 40.0) * 0.1;
        float flap = sin(p.x * 20.0 + iTime * 10.0) * 0.1;
        col *= 0.8 + tailFolds + flap;
    }
}

void layer_Shadows(in vec2 p, in vec2 rp, in float diamond, inout vec3 col) {
    float shadow = length(max(abs(rp - vec2(-0.02, 0.18)) - vec2(0.6, 0.6), 0.0));
    if (shadow < 0.05 && diamond > 0.01) {
        col = mix(col, vec3(0.8), 0.5 * (1.0 - shadow / 0.05));
    }
}

vec4 layer_Background(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_Background(col);
    
    float a = 3.14159 / 4.0;
    vec2 rp = vec2(p.x * cos(a) - p.y * sin(a), p.x * sin(a) + p.y * cos(a));
    float diamond = length(max(abs(rp - vec2(0.0, 0.2)) - vec2(0.6, 0.6), 0.0));
    


  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

vec4 layer_Kite(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    
    float a = 3.14159 / 4.0;
    vec2 rp = vec2(p.x * cos(a) - p.y * sin(a), p.x * sin(a) + p.y * cos(a));
    float diamond = length(max(abs(rp - vec2(0.0, 0.2)) - vec2(0.6, 0.6), 0.0));
    
    layer_Kite(p, rp, diamond, iTime, col);


  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

vec4 layer_KiteTail(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    
    float a = 3.14159 / 4.0;
    vec2 rp = vec2(p.x * cos(a) - p.y * sin(a), p.x * sin(a) + p.y * cos(a));
    float diamond = length(max(abs(rp - vec2(0.0, 0.2)) - vec2(0.6, 0.6), 0.0));
    
    layer_KiteTail(p, iTime, col);


  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

vec4 layer_Shadows(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    
    float a = 3.14159 / 4.0;
    vec2 rp = vec2(p.x * cos(a) - p.y * sin(a), p.x * sin(a) + p.y * cos(a));
    float diamond = length(max(abs(rp - vec2(0.0, 0.2)) - vec2(0.6, 0.6), 0.0));
    
    layer_Shadows(p, rp, diamond, col);


  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

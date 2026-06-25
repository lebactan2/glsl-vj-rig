void layer_Background(in vec2 p, in float iTime, inout vec3 col) {
    col = vec3(0.65, 0.65, 0.68);
    
    float brush = fract(sin(p.x * 500.0 + iTime * 0.5) * 43758.5453);
    brush += fract(sin(p.x * 300.0 + p.y * 10.0 + iTime * 0.5) * 43758.5453) * 0.5;
    col *= 0.9 + 0.1 * brush;
    
    float lightPulse = sin(iTime * 1.0) * 0.1;
    col += vec3(0.2) * smoothstep(0.5 + lightPulse, 1.0 + lightPulse, p.y);
    col += vec3(0.3, 0.25, 0.1) * smoothstep(0.4, 0.0, abs(p.y - 0.2 - lightPulse*0.5));
    col -= vec3(0.1, 0.0, 0.1) * smoothstep(0.5, 0.0, abs(p.y + 0.3 - lightPulse));
    col += vec3(0.0, 0.15, 0.0) * smoothstep(0.4, 0.0, abs(p.y + 0.1 - lightPulse*0.8));
}

void layer_MainGraphics(in vec2 p, in float iTime, inout vec3 col) {
    if (p.y > -0.1 && p.y < 0.6) {
        float spacing = 0.6;
        float x_idx = floor((p.x + spacing * 1.5) / spacing);
        
        if (x_idx >= 0.0 && x_idx < 3.0) {
            vec2 char_p = p;
            char_p.x = mod(p.x + spacing * 0.5, spacing) - spacing * 0.5;
            char_p.y -= 0.25;
            char_p.y += sin(iTime * 2.0 + x_idx * 1.5) * 0.02;
            
            float dChar = 1.0;
            
            float dHat = length(vec2(char_p.x, (char_p.y - 0.2) * 2.5)) - 0.12;
            dChar = min(dChar, dHat);
            
            float dHeadTop = abs(length(vec2(char_p.x, char_p.y - 0.05)) - 0.2) - 0.04;
            if (char_p.y > 0.05) dChar = min(dChar, dHeadTop);
            
            float dEyeL = length(vec2(char_p.x + 0.08, char_p.y)) - 0.04;
            float dEyeR = length(vec2(char_p.x - 0.08, char_p.y)) - 0.04;
            float dEyes = min(dEyeL, dEyeR);
            dEyes = max(dEyes, -(length(vec2(char_p.x + 0.08, char_p.y + 0.01)) - 0.02));
            dEyes = max(dEyes, -(length(vec2(char_p.x - 0.08, char_p.y + 0.01)) - 0.02));
            dChar = min(dChar, dEyes);
            
            float dSwoop = abs(sin(char_p.x * 10.0) * 0.1 - (char_p.y + 0.15)) - 0.04;
            if (char_p.y < 0.0 && char_p.x > -0.25 && char_p.x < 0.25) {
                dChar = min(dChar, dSwoop);
            }
            
            if (length(vec2(char_p.x, char_p.y + 0.1)) < 0.15 && char_p.y > -0.1) dChar = min(dChar, 0.0);
            
            if (char_p.y < -0.25) dChar = 1.0;
            
            if (dChar < 0.0) {
                col = vec3(0.08); 
            }
        }
    }
}

void layer_TextOpeningHours(in vec2 p, inout vec3 col) {
    if (abs(p.y + 0.3) < 0.05 && abs(p.x) < 0.4) {
        float textPat = sin(p.x * 200.0);
        if (textPat > 0.5 && abs(p.y + 0.28) < 0.015) col = vec3(0.1);
        
        float numPat = sin(p.x * 150.0);
        if (numPat > 0.3 && abs(p.y + 0.35) < 0.025) {
            if (abs(p.x) > 0.05) col = vec3(0.1); 
        }
        if (abs(p.x) < 0.02 && abs(p.y + 0.35) < 0.01) col = vec3(0.1); 
    }
}

void layer_BottomTextLogos(in vec2 p, in float iTime, inout vec3 col) {
    if (abs(p.y + 0.6) < 0.1 && abs(p.x) < 0.3) {
        float textPat = sin(p.x * 250.0);
        if (textPat > 0.5 && abs(p.y + 0.58) < 0.01) col = vec3(0.1);
        
        if (abs(p.y + 0.65) < 0.04) {
            float spacing = 0.12;
            float x_idx = floor((p.x + spacing * 1.5) / spacing);
            if (x_idx >= 0.0 && x_idx < 3.0) {
                vec2 lp = p;
                lp.x = mod(p.x + spacing * 0.5, spacing) - spacing * 0.5;
                lp.y += 0.65;
                lp.y += sin(iTime * 3.0 + x_idx * 2.0) * 0.005;
                
                float dLogo = length(max(abs(lp) - vec2(0.02, 0.01), 0.0)) - 0.02;
                if (dLogo < 0.0) col = vec3(0.1);
                
                if (length(lp) < 0.015) col = vec3(0.65); 
            }
        }
    }
}

void layer_Vignette(in vec2 p, inout vec3 col) {
    col *= 1.0 - 0.2 * length(p);
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

vec4 layer_MainGraphics(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_MainGraphics(p, iTime, col);


  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

vec4 layer_TextOpeningHours(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_TextOpeningHours(p, col);


  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

vec4 layer_BottomTextLogos(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_BottomTextLogos(p, iTime, col);


  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

vec4 layer_Vignette(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_Vignette(p, col);


  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

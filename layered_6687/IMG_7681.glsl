void layer_Background(in vec2 p, in float iTime, inout vec3 col) {
    col = vec3(0.4, 0.7, 0.9);
    col += 0.1 * sin(p.x * 5.0 + iTime * 0.2) * sin(p.y * 3.0);
}

void layer_TempleRoof(in vec2 p, in float iTime, inout vec3 col) {
    if (p.x + p.y < -0.2) {
        col = vec3(0.7, 0.3, 0.2); 
        vec2 tileP = p + vec2(iTime*0.05, 0.0);
        if (fract(tileP.x * 10.0 - tileP.y * 10.0) < 0.1) col *= 0.8; 
        if (fract(tileP.x * 5.0 + tileP.y * 5.0) < 0.05) col *= 0.7;
    }
}

void layer_Dragon(in vec2 p, in float iTime, inout vec3 col) {
    vec3 dragonCol = vec3(0.9, 0.75, 0.2); 
    float isDragon = 0.0;
    
    vec2 dp = p;
    dp.y += sin(dp.x * 4.0 + iTime * 2.0) * 0.05;
    
    float bodyCurve = sin(dp.x * 3.0) * 0.3;
    if (abs(dp.y - bodyCurve - 0.1) < 0.1 && dp.x > -0.6 && dp.x < 0.8) {
        isDragon = 1.0;
        if (fract(dp.x * 20.0) < 0.2 || fract(dp.y * 20.0) < 0.2) {
            dragonCol *= 0.8;
        }
    }
    
    vec2 headP = p - vec2(0.7, sin(0.7 * 3.0) * 0.3 + 0.1 + sin(0.7 * 4.0 + iTime * 2.0) * 0.05);
    if (length(headP) < 0.15) {
        isDragon = 1.0;
        dragonCol = vec3(0.8, 0.6, 0.1);
        if (length(headP - vec2(-0.05, 0.05)) < 0.03) dragonCol = vec3(1.0, 0.0, 0.0); 
        if (headP.y > 0.1 && headP.x > 0.0) dragonCol = vec3(0.6, 0.8, 0.3); 
    }
    
    if (abs(p.x - 0.2) < 0.05 && p.y > bodyCurve - 0.1 && p.y < bodyCurve + 0.1) {
        isDragon = 1.0; 
    }
    if (abs(p.x - (-0.3)) < 0.05 && p.y > bodyCurve - 0.1 && p.y < bodyCurve + 0.1) {
        isDragon = 1.0; 
    }
    
    if (isDragon > 0.0 && fract(p.x * 8.0) < 0.15 && p.y > bodyCurve + 0.1) {
        dragonCol = vec3(0.2, 0.6, 0.5); 
    }
    
    if (isDragon > 0.0) {
        col = dragonCol;
        col *= 0.8 + 0.4 * p.y;
    }
}

void layer_Vignette(in vec2 p, inout vec3 col) {
    col *= 1.0 - 0.1 * length(p);
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

vec4 layer_TempleRoof(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_TempleRoof(p, iTime, col);


  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

vec4 layer_Dragon(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_Dragon(p, iTime, col);


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

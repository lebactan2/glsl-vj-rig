void layer_BlueTiles(in vec2 p, inout vec3 col) {
    col = vec3(0.2, 0.6, 0.8);
    vec2 tileUV = p * vec2(10.0, 15.0);
    float tileX = fract(tileUV.x);
    float tileY = fract(tileUV.y);
    if (tileX < 0.05 || tileY < 0.05) {
        col = vec3(0.1, 0.4, 0.6);
    }
}

void layer_Bird(in vec2 p, in vec2 parallax, inout vec3 col) {
    vec2 bp = p - vec2(-0.5, 0.4);
    float birdShadow = length(max(abs(bp - parallax) - vec2(0.3, 0.2), 0.0));
    if (birdShadow < 0.05) col = mix(col, vec3(0.1, 0.3, 0.4), 0.5);
    
    float birdBody = length(bp * vec2(1.2, 2.5));
    float birdWing1 = length((bp - vec2(-0.1, 0.2)) * vec2(3.0, 1.0));
    float birdWing2 = length((bp - vec2(0.2, -0.1)) * vec2(1.0, 3.0));
    
    if (birdBody < 0.15 || birdWing1 < 0.2 || birdWing2 < 0.2) {
        col = vec3(0.95, 0.95, 0.98);
        if (fract(bp.x * 20.0 + bp.y * 30.0) < 0.3 && bp.x < 0.0) col = vec3(0.2, 0.3, 0.6);
    }
}

void layer_Flowers(in vec2 p, in vec2 parallax, inout vec3 col) {
    vec2 fp = p - vec2(0.6, -0.2);
    float flowerShadow = length(fp - parallax) - 0.3 - 0.1 * sin(atan(fp.y, fp.x) * 5.0);
    if (flowerShadow < 0.0) col = mix(col, vec3(0.1, 0.3, 0.4), 0.5);
    
    float flower = length(fp) - 0.3 - 0.1 * sin(atan(fp.y, fp.x) * 5.0);
    if (flower < 0.0) {
        col = vec3(0.95, 0.98, 0.95);
        float detail = sin(fp.x * 30.0) * cos(fp.y * 30.0);
        if (detail > 0.5) col = vec3(0.3, 0.6, 0.5);
        if (length(fp - vec2(0.1, 0.1)) < 0.05) col = vec3(0.8, 0.7, 0.2);
    }
}

void layer_SmallCloud(in vec2 p, inout vec3 col) {
    vec2 cp = p - vec2(-0.2, -0.6);
    float cloud = length(cp) - 0.15 - 0.05 * cos(atan(cp.y, cp.x) * 4.0);
    if (cloud < 0.0) {
        col = vec3(1.0);
    }
}

vec4 layer_BlueTiles(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;
    
    vec3 col = vec3(-1.0);
    layer_BlueTiles(p, col);
    
    vec2 parallax = vec2(sin(iTime*1.5), cos(iTime*1.2)) * 0.02;
    
    

  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

vec4 layer_Bird(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;
    
    vec3 col = vec3(-1.0);
    
    vec2 parallax = vec2(sin(iTime*1.5), cos(iTime*1.2)) * 0.02;
    
    layer_Bird(p, parallax, col);
    

  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

vec4 layer_Flowers(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;
    
    vec3 col = vec3(-1.0);
    
    vec2 parallax = vec2(sin(iTime*1.5), cos(iTime*1.2)) * 0.02;
    
    layer_Flowers(p, parallax, col);
    

  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

vec4 layer_SmallCloud(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;
    
    vec3 col = vec3(-1.0);
    
    vec2 parallax = vec2(sin(iTime*1.5), cos(iTime*1.2)) * 0.02;
    
    layer_SmallCloud(p, col);
    

  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

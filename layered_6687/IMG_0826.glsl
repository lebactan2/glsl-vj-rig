void layer_SurroundingWall(inout vec3 col) {
    col = vec3(0.8, 0.8, 0.8);
}

void layer_BlueTiles(in vec2 p, inout vec3 col) {
    if (p.y > 0.3 && abs(p.x) < 0.6) {
        col = vec3(0.6, 0.8, 0.9);
        if (fract(p.x * 20.0) < 0.1 || fract(p.y * 20.0) < 0.1) {
            col = vec3(0.5, 0.7, 0.8);
        }
    }
}

void layer_ScissorGate(in vec2 p, in float iTime, inout vec3 col) {
    if (p.y < 0.3 && abs(p.x) < 0.6) {
        col = vec3(0.05, 0.05, 0.05); 
        
        float stretch = 1.0 + 0.1 * sin(iTime * 2.0);
        vec2 gp = p;
        gp.x *= stretch;
        
        float diag1 = abs(fract(gp.x * 5.0 + gp.y * 5.0) - 0.5);
        float diag2 = abs(fract(gp.x * 5.0 - gp.y * 5.0) - 0.5);
        float vertical = abs(fract(gp.x * 5.0) - 0.5);
        
        if (diag1 < 0.05 || diag2 < 0.05 || vertical < 0.03) {
            col = vec3(0.85, 0.8, 0.75);
            col *= 0.8 + 0.2 * sin(gp.x * 50.0);
        }
    }
}

void layer_RightPillar(in vec2 p, inout vec3 col) {
    if (p.x > 0.6) {
        col = vec3(0.2, 0.2, 0.2);
        float cable1 = abs(p.x - 0.7 - 0.05 * sin(p.y * 5.0));
        float cable2 = abs(p.x - 0.8 + 0.08 * cos(p.y * 7.0));
        if (cable1 < 0.02 || cable2 < 0.015) {
            col = vec3(0.1);
        }
    }
}

vec4 layer_SurroundingWall(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;
    
    vec3 col = vec3(-1.0);
    
    layer_SurroundingWall(col);
    

  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

vec4 layer_BlueTiles(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;
    
    vec3 col = vec3(-1.0);
    
    layer_BlueTiles(p, col);
    

  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

vec4 layer_ScissorGate(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;
    
    vec3 col = vec3(-1.0);
    
    layer_ScissorGate(p, iTime, col);
    

  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

vec4 layer_RightPillar(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;
    
    vec3 col = vec3(-1.0);
    
    layer_RightPillar(p, col);
    

  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

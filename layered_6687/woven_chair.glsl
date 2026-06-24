void layer_BackgroundFloor(in vec2 uv, inout vec3 col) {
    col = vec3(0.6, 0.55, 0.45) * (0.8 + 0.2 * fract(sin(floor(uv.x*20.0)*13.0 + floor(uv.y*20.0)*37.0)*43758.0));
}

void layer_WeaveStructure(in vec2 id, in vec2 f, out float isVerticalTop, out float vStrap, out float hStrap) {
    isVerticalTop = mod(id.x + id.y, 2.0);
    float gap = 0.05;
    vStrap = step(gap, f.x) * step(f.x, 1.0 - gap);
    hStrap = step(gap, f.y) * step(f.y, 1.0 - gap);
}

void layer_WeaveMaterial(in vec2 f, in float isVerticalTop, in float vStrap, in float hStrap, inout vec3 col) {
    vec3 blueStrap = vec3(0.15, 0.3, 0.6);
    vec3 darkBlue = vec3(0.05, 0.15, 0.4);
    
    float vTex = sin(f.y * 50.0) * 0.5 + 0.5;
    float hTex = sin(f.x * 50.0) * 0.5 + 0.5;
    
    if (isVerticalTop > 0.5) {
        if (vStrap > 0.0) {
            col = mix(darkBlue, blueStrap, vTex) * (0.6 + 0.4 * sin(f.x * 3.1415));
        } else if (hStrap > 0.0) {
            col = mix(darkBlue, blueStrap, hTex) * (0.6 + 0.4 * sin(f.y * 3.1415)) * 0.6;
        }
    } else {
        if (hStrap > 0.0) {
            col = mix(darkBlue, blueStrap, hTex) * (0.6 + 0.4 * sin(f.y * 3.1415));
        } else if (vStrap > 0.0) {
            col = mix(darkBlue, blueStrap, vTex) * (0.6 + 0.4 * sin(f.x * 3.1415)) * 0.6;
        }
    }
    
    if (isVerticalTop > 0.5 && vStrap > 0.0 && hStrap > 0.0) {
        col *= smoothstep(0.0, 0.2, f.y) * smoothstep(1.0, 0.8, f.y);
    } else if (isVerticalTop < 0.5 && hStrap > 0.0 && vStrap > 0.0) {
        col *= smoothstep(0.0, 0.2, f.x) * smoothstep(1.0, 0.8, f.x);
    }
}

vec4 layer_BackgroundFloor(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 10.0;
    p.x *= iResolution.x / iResolution.y;
    
    vec2 id = floor(p);
    vec2 f = fract(p);
    
    vec3 col = vec3(-1.0);
    
    layer_BackgroundFloor(uv, col);
    
    float isVerticalTop, vStrap, hStrap;
    
    

  return vec4(clamp(col,0.0,1.0), step(0.0, max(col.r, max(col.g, col.b))));
}

vec4 layer_WeaveStructure(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 10.0;
    p.x *= iResolution.x / iResolution.y;
    
    vec2 id = floor(p);
    vec2 f = fract(p);
    
    vec3 col = vec3(-1.0);
    
    
    float isVerticalTop, vStrap, hStrap;
    layer_WeaveStructure(id, f, isVerticalTop, vStrap, hStrap);
    
    

  return vec4(clamp(col,0.0,1.0), step(0.0, max(col.r, max(col.g, col.b))));
}

vec4 layer_WeaveMaterial(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 10.0;
    p.x *= iResolution.x / iResolution.y;
    
    vec2 id = floor(p);
    vec2 f = fract(p);
    
    vec3 col = vec3(-1.0);
    
    
    float isVerticalTop, vStrap, hStrap;
    
    layer_WeaveMaterial(f, isVerticalTop, vStrap, hStrap, col);
    

  return vec4(clamp(col,0.0,1.0), step(0.0, max(col.r, max(col.g, col.b))));
}

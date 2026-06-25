void layer_Background(inout vec3 col) {
    col = vec3(0.05, 0.05, 0.05); 
}

void layer_ChromeExhaust(in vec2 p, in float iTime, inout vec3 col) {
    if (p.x > 0.1 && p.x < 0.8 && p.y > -0.8 && p.y < 0.5) {
        float exhaustDist = abs((p.x - 0.4) - (p.y + 0.1) * 0.5);
        if (exhaustDist < 0.2) {
            col = vec3(0.7, 0.75, 0.8); 
            
            float reflection = sin(p.x * 20.0 + p.y * 10.0) * 0.2 + 0.8;
            col *= reflection;
            
            float shine = smoothstep(0.4, 0.6, sin(p.y * 5.0 - iTime * 4.0));
            col += shine * 0.3;
            
            if (abs(p.y - 0.2) < 0.05 || abs(p.y + 0.3) < 0.05) {
                col = vec3(0.1);
            }
        }
    }
}

void layer_SuspensionSpring(in vec2 p, inout vec3 col) {
    if (p.x > -0.4 && p.x < 0.1 && p.y > -0.2 && p.y < 0.4) {
        float springDist = abs(p.x + 0.15);
        if (springDist < 0.1) {
            col = vec3(0.1, 0.1, 0.1); 
            
            float coil = fract(p.y * 12.0) - 0.5;
            if (abs(coil) < 0.15) {
                col = vec3(0.3, 0.3, 0.35); 
                float highlight = smoothstep(0.0, 0.1, abs(coil));
                col += highlight * 0.2;
            }
        }
    }
}

void layer_CarbonFiberPlates(in vec2 p, in float iTime, inout vec3 col) {
    if (p.x > -0.2 && p.x < 0.2 && p.y > 0.2 && p.y < 0.6) {
        col = vec3(0.6, 0.6, 0.65); 
        
        float cfPattern = step(0.5, fract(p.x * 40.0 + p.y * 40.0)) * step(0.5, fract(p.x * 40.0 - p.y * 40.0));
        cfPattern += step(0.5, fract(p.x * 40.0 + p.y * 40.0 + 0.5)) * step(0.5, fract(p.x * 40.0 - p.y * 40.0 + 0.5));
        
        col *= mix(0.7, 1.0, cfPattern);
        
        float plateAnim = sin(p.x * 10.0 + p.y * 10.0 + iTime) * 0.05;
        col += plateAnim;
    }
}

vec4 layer_Background(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_Background(col);


  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

vec4 layer_ChromeExhaust(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_ChromeExhaust(p, iTime, col);


  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

vec4 layer_SuspensionSpring(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_SuspensionSpring(p, col);


  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

vec4 layer_CarbonFiberPlates(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_CarbonFiberPlates(p, iTime, col);


  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

void layer_WoodenFloor(in vec2 p, inout vec3 col) {
    col = vec3(0.6, 0.45, 0.3); 
    
    float planks = fract(p.x * 5.0 + p.y * 2.0);
    if (planks < 0.05) col *= 0.6; 
    
    float grain = sin(p.x * 50.0 + sin(p.y * 20.0) * 10.0);
    col *= mix(0.9, 1.1, grain * 0.1 + 0.5);
}

void layer_MainBodyWrapped(in vec2 p, in float iTime, inout vec3 col) {
    if (p.x > -0.4 && p.x < 0.6 && p.y > -0.5 && p.y < 0.4) {
        col = vec3(0.75, 0.6, 0.45); 
        
        float corrugation = abs(fract((p.x + p.y) * 20.0) - 0.5);
        if (corrugation < 0.1) col *= 0.9;
        
        float tape = smoothstep(0.4, 0.5, sin(p.x * 30.0 - p.y * 20.0 + iTime));
        col += tape * 0.15; 
        
        if (p.x > -0.1 && p.x < 0.2 && p.y > -0.1 && p.y < 0.1) {
            float text = step(0.5, fract(p.x * 15.0)) * step(0.5, fract(p.y * 10.0));
            col = mix(col, vec3(0.8, 0.2, 0.2), text * 0.8); 
        }
        if (p.x > 0.2 && p.x < 0.5 && p.y > 0.1 && p.y < 0.3) {
            float text = step(0.5, fract(p.x * 20.0)) * step(0.5, fract(p.y * 15.0));
            col = mix(col, vec3(0.1, 0.4, 0.8), text * 0.8); 
        }
    }
}

void layer_FrontWheel(in vec2 p, inout vec3 col) {
    float wheelDist = length(p - vec2(0.6, -0.4));
    if (wheelDist < 0.2) {
        col = vec3(0.1); 
        float rimDist = length(p - vec2(0.6, -0.4));
        if (rimDist < 0.12) {
            col = vec3(0.5); 
            float angle = atan(p.y + 0.4, p.x - 0.6);
            float spokes = sin(angle * 5.0);
            if (spokes > 0.8) col = vec3(0.3);
        }
    }
}

void layer_BackPartWrapping(in vec2 p, in float iTime, inout vec3 col) {
    if (p.x > -0.8 && p.x < -0.3 && p.y > 0.0 && p.y < 0.5) {
        col = vec3(0.9, 0.9, 0.9); 
        float pattern = step(0.5, fract(p.x * 10.0 + p.y * 10.0));
        col *= mix(vec3(1.0), vec3(0.2, 0.4, 0.8), pattern * 0.5); 
        
        float tape = smoothstep(0.4, 0.5, sin(p.x * 20.0 - p.y * 10.0 + iTime * 1.5));
        col += tape * 0.2;
    }
}

vec4 layer_WoodenFloor(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_WoodenFloor(p, col);


  return vec4(clamp(col,0.0,1.0), step(0.0, max(col.r, max(col.g, col.b))));
}

vec4 layer_MainBodyWrapped(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_MainBodyWrapped(p, iTime, col);


  return vec4(clamp(col,0.0,1.0), step(0.0, max(col.r, max(col.g, col.b))));
}

vec4 layer_FrontWheel(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_FrontWheel(p, col);


  return vec4(clamp(col,0.0,1.0), step(0.0, max(col.r, max(col.g, col.b))));
}

vec4 layer_BackPartWrapping(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_BackPartWrapping(p, iTime, col);


  return vec4(clamp(col,0.0,1.0), step(0.0, max(col.r, max(col.g, col.b))));
}

void layer_Road(in vec2 p, inout vec3 col) {
    col = vec3(0.45, 0.45, 0.45); 
    float roadNoise = fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
    col -= roadNoise * 0.1;
}

void layer_MotorcycleParts(in vec2 p, in float iTime, inout vec3 col) {
    if (p.x > 0.3 && p.y > 0.2) {
        col = vec3(0.1); 
        
        if (p.x > 0.4 && p.x < 0.6 && p.y > 0.3 && p.y < 0.8) {
            col = vec3(0.7, 0.1, 0.1); 
            float reflector = step(0.5, fract(p.x * 15.0)) * step(0.5, fract(p.y * 15.0));
            col *= mix(0.7, 1.2, reflector);
            
            float pulse = sin(iTime * 2.0) * 0.1 + 0.9;
            col *= pulse;
        }
        
        if (p.x > 0.6 && p.x < 0.9 && p.y > 0.3 && p.y < 0.9) {
            col = vec3(0.9, 0.9, 0.95); 
            
            float textMask = step(0.8, fract(p.x * 8.0)) * step(0.2, fract(p.y * 5.0));
            if (textMask > 0.5 && p.x > 0.65 && p.x < 0.85 && p.y > 0.4 && p.y < 0.8) {
                col = vec3(0.1);
            }
        }
    }
}

void layer_TrousersLeg(in vec2 p, in float iTime, inout vec3 col) {
    if (p.x > -0.8 && p.x < 0.4 && p.y > -0.8 && p.y < 0.9) {
        float legDist = abs(p.x + 0.2 + sin(p.y * 2.0) * 0.2);
        if (legDist < 0.3) {
            col = vec3(0.4, 0.25, 0.15); 
            
            float leafX = fract(p.x * 8.0 + sin(p.y * 5.0));
            float leafY = fract(p.y * 10.0 + cos(p.x * 5.0));
            
            if (leafX < 0.3 && leafY < 0.3) {
                col = vec3(0.8, 0.8, 0.85); 
            } else if (leafX > 0.7 && leafY > 0.7) {
                col = vec3(0.8, 0.5, 0.2); 
            }
            
            float foldAnim = sin(p.x * 10.0 + p.y * 5.0 + iTime) * 0.1;
            col += foldAnim;
            
            col *= smoothstep(0.3, 0.1, legDist);
        }
    }
}

void layer_FootAndShoe(in vec2 p, inout vec3 col) {
    if (p.x > 0.1 && p.x < 0.6 && p.y > -0.9 && p.y < -0.4) {
        col = vec3(0.6, 0.4, 0.2); 
        float shoeShine = smoothstep(0.4, 0.5, sin(p.x * 5.0 + p.y * 5.0));
        col += shoeShine * 0.1;
    }
}

vec4 layer_Road(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_Road(p, col);


  return vec4(clamp(col,0.0,1.0), step(0.0, max(col.r, max(col.g, col.b))));
}

vec4 layer_MotorcycleParts(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_MotorcycleParts(p, iTime, col);


  return vec4(clamp(col,0.0,1.0), step(0.0, max(col.r, max(col.g, col.b))));
}

vec4 layer_TrousersLeg(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_TrousersLeg(p, iTime, col);


  return vec4(clamp(col,0.0,1.0), step(0.0, max(col.r, max(col.g, col.b))));
}

vec4 layer_FootAndShoe(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_FootAndShoe(p, col);


  return vec4(clamp(col,0.0,1.0), step(0.0, max(col.r, max(col.g, col.b))));
}

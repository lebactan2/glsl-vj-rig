void layer_Background(in vec2 p, in float iTime, inout vec3 col) {
    col = vec3(0.85, 0.85, 0.88); 
    
    if (p.x > 0.4) {
        col = vec3(0.6, 0.4, 0.2); 
        float weave = abs(sin((p.x + p.y) * 50.0 + iTime)) * abs(sin((p.x - p.y) * 50.0 - iTime));
        col *= 0.5 + 0.5 * weave;
        if (p.x < 0.45) col = vec3(0.1); 
    }
}

void layer_LeftSign(in vec2 p, in float iTime, inout vec3 col) {
    float signBox = max(abs(p.x + 0.5) - 0.15, abs(p.y) - 0.5);
    if (signBox < 0.0) {
        col = vec3(0.3); 
        
        float signRefl = pow(max(0.0, sin(p.x*10.0 + p.y*10.0 + iTime*3.0)), 4.0);
        col += signRefl * 0.2;
        
        if (abs(p.x + 0.5) < 0.1 && p.y > 0.0 && p.y < 0.4) {
            if (fract(p.y * 20.0) < 0.3) col = vec3(0.8, 0.6, 0.3);
        }
        if (abs(p.x + 0.5) < 0.1 && p.y < 0.0 && p.y > -0.4) {
            if (fract(p.y * 25.0) < 0.3) col = vec3(0.9);
        }
        
        vec2 rp = abs(p - vec2(-0.5, 0.0));
        if (length(rp - vec2(0.12, 0.45)) < 0.015) col = vec3(0.8); 
    }
}

void layer_GoldenBat(in vec2 p, in float iTime, inout vec3 col) {
    vec2 bp = p - vec2(0.2, 0.0);
    bp *= 1.0 + 0.02 * sin(iTime * 2.0);
    
    float body = max(abs(bp.x) - 0.2, abs(bp.y) - 0.2);
    body = length(vec2(bp.x, bp.y*1.5)) - 0.2;
    
    float wing1 = max(length(bp - vec2(-0.25, 0.2)) - 0.3, -(length(bp - vec2(-0.1, 0.4)) - 0.25)); 
    float wing2 = max(length(bp - vec2(0.25, 0.2)) - 0.3, -(length(bp - vec2(0.1, 0.4)) - 0.25));  
    
    float wing3 = max(length(bp - vec2(-0.25, -0.2)) - 0.3, -(length(bp - vec2(-0.1, -0.4)) - 0.25)); 
    float wing4 = max(length(bp - vec2(0.25, -0.2)) - 0.3, -(length(bp - vec2(0.1, -0.4)) - 0.25));  
    
    float head = length(bp - vec2(0.0, 0.25)) - 0.1;
    float ear1 = max(abs(bp.x + 0.08) - 0.03, abs(bp.y - 0.35) - 0.05); 
    float ear2 = max(abs(bp.x - 0.08) - 0.03, abs(bp.y - 0.35) - 0.05); 
    
    float batShape = min(body, min(min(wing1, wing2), min(wing3, wing4)));
    batShape = min(batShape, min(head, min(ear1, ear2)));
    
    if (batShape < 0.0) {
        col = vec3(0.8, 0.6, 0.2); 
        col *= 0.6 + 0.4 * cos(bp.y * 10.0); 
        
        float highlight = pow(max(0.0, sin(bp.x * 20.0 + bp.y * 20.0 - iTime * 4.0)), 4.0);
        col += vec3(0.5, 0.4, 0.1) * highlight;
        
        float innerCirc = abs(length(bp) - 0.1) - 0.01;
        if (innerCirc < 0.0) col = vec3(0.4, 0.3, 0.1); 
        
        float eyeL = length(bp - vec2(-0.04, 0.25));
        float eyeR = length(bp - vec2(0.04, 0.25));
        if (min(eyeL, eyeR) < 0.02) {
            col = vec3(1.0); 
            if (min(length(bp - vec2(-0.04, 0.25)), length(bp - vec2(0.04, 0.25))) < 0.01) col = vec3(0.0); 
            col += vec3(1.0, 0.0, 0.0) * (sin(iTime*5.0)*0.5 + 0.5); 
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

vec4 layer_LeftSign(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_LeftSign(p, iTime, col);


  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

vec4 layer_GoldenBat(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_GoldenBat(p, iTime, col);


  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

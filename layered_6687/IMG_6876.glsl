void layer_Background(in vec2 p, inout vec3 col) {
    col = vec3(1.0); 
    
    if (p.y > 0.85 && p.x > -1.2 && p.x < 0.2) {
        if (fract(p.y * 30.0) > 0.3) col = vec3(0.2); 
    }
    if (p.y > 0.75 && p.y <= 0.85 && p.x > -1.2 && p.x < 0.5) {
        if (fract(p.y * 40.0) > 0.4) col = vec3(0.4);
    }
    
    vec2 t1 = p - vec2(-0.8, 0.2);
    if (abs(t1.x) < 0.3 && abs(t1.y) < 0.1) if (fract(t1.y * 35.0) > 0.3) col = vec3(0.4);
    vec2 t2 = p - vec2(-0.8, -0.2);
    if (abs(t2.x) < 0.3 && abs(t2.y) < 0.08) if (fract(t2.y * 35.0) > 0.3) col = vec3(0.4);
    vec2 t3 = p - vec2(-0.6, -0.6);
    if (abs(t3.x) < 0.3 && abs(t3.y) < 0.1) if (fract(t3.y * 35.0) > 0.3) col = vec3(0.4);
    vec2 t4 = p - vec2(0.9, 0.6);
    if (abs(t4.x) < 0.3 && abs(t4.y) < 0.1) if (fract(t4.y * 35.0) > 0.3) col = vec3(0.4);
    vec2 t5 = p - vec2(0.9, -0.5);
    if (abs(t5.x) < 0.25 && abs(t5.y) < 0.1) if (fract(t5.y * 35.0) > 0.3) col = vec3(0.4);
}

void layer_Protein(in vec2 p, in float iTime, inout vec3 col) {
    float pulse = sin(iTime * 2.0) * 0.05;
    float rot = iTime * 0.2;
    mat2 rMat = mat2(cos(rot), -sin(rot), sin(rot), cos(rot));
    vec2 pRot = rMat * (p - vec2(0.1, -0.1));
    
    float dProtein = length(pRot) - 0.5 + pulse;
    
    float noiseBase = sin(pRot.x * 10.0 + sin(pRot.y * 15.0 + iTime)) * cos(pRot.y * 12.0) * 0.1;
    float noiseDetail = sin(pRot.x * 40.0) * cos(pRot.y * 35.0) * 0.03;
    dProtein += noiseBase + noiseDetail;
    
    if (dProtein < 0.0) {
        col = vec3(0.85, 0.85, 0.88);
        float strands = abs(sin(pRot.x * 30.0 + sin(pRot.y * 20.0 + iTime*2.0)) * cos(pRot.y * 25.0));
        col += vec3(0.15) * strands;
        
        col *= 0.6 + 0.4 * smoothstep(-0.2, 0.0, dProtein);
        
        vec2 grid = fract(pRot * 15.0 + vec2(0.0, iTime*0.5)) - 0.5;
        vec2 id = floor(pRot * 15.0 + vec2(0.0, iTime*0.5));
        float rand = fract(sin(dot(id, vec2(12.9898, 78.233))) * 43758.5453);
        if (rand > 0.85 && dProtein < -0.05) {
            float dDot = length(grid);
            if (dDot < 0.15) {
                if (rand > 0.95) col = vec3(0.9, 0.2, 0.2); 
                else col = vec3(0.2, 0.3, 0.8); 
            }
        }
    }
}

void layer_ZoomCircles(in vec2 p, in float iTime, inout vec3 col) {
    vec3 pinkCol = vec3(0.95, 0.6, 0.7);
    
    vec2 c1 = p - vec2(0.3 + sin(iTime)*0.02, 0.4 + cos(iTime)*0.02);
    float dC1 = length(c1) - 0.3;
    if (abs(dC1) < 0.015) col = pinkCol;
    if (dC1 < 0.0) {
        col = vec3(0.9, 0.85, 0.85); 
        float strands = abs(sin(c1.x * 40.0 + sin(c1.y * 30.0 - iTime)) * cos(c1.y * 35.0));
        col += vec3(0.1) * strands;
        vec2 grid = fract(c1 * 20.0 - vec2(iTime*0.5)) - 0.5;
        vec2 id = floor(c1 * 20.0 - vec2(iTime*0.5));
        float rand = fract(sin(dot(id, vec2(12.9898, 78.233))) * 43758.5453);
        if (rand > 0.7 && length(grid) < 0.2) col = vec3(0.2, 0.3, 0.8); 
    }
    
    vec2 c2 = p - vec2(-0.25 + cos(iTime*1.2)*0.02, 0.3 + sin(iTime*1.2)*0.02);
    float dC2 = length(c2) - 0.15;
    if (abs(dC2) < 0.01) col = pinkCol;
    if (dC2 < 0.0) {
        col = vec3(0.85);
        if (length(c2 + vec2(0.05*cos(iTime))) < 0.03) col = vec3(0.2, 0.3, 0.8);
        if (length(c2 - vec2(0.05*sin(iTime))) < 0.03) col = vec3(0.2, 0.3, 0.8);
    }
    
    vec2 c3 = p - vec2(-0.35 + sin(iTime*0.8)*0.02, 0.0 + cos(iTime*0.8)*0.02);
    float dC3 = length(c3) - 0.18;
    if (abs(dC3) < 0.01) col = pinkCol;
    if (dC3 < 0.0) {
        col = vec3(0.85);
        if (length(c3 + vec2(0.08, 0.02)*cos(iTime)) < 0.04) col = vec3(0.9, 0.2, 0.2); 
        if (length(c3 - vec2(0.02, 0.08)*sin(iTime)) < 0.04) col = vec3(0.2, 0.3, 0.8); 
    }

    vec2 c4 = p - vec2(-0.15 + cos(iTime)*0.02, -0.3 + sin(iTime)*0.02);
    float dC4 = length(c4) - 0.12;
    if (abs(dC4) < 0.01) col = pinkCol;
    if (dC4 < 0.0) {
        col = vec3(0.85);
        if (length(c4) < 0.03) col = vec3(0.2, 0.3, 0.8);
    }
}

void layer_Lines(in vec2 p, in float iTime, inout vec3 col) {
    vec3 pinkCol = vec3(0.95, 0.6, 0.7);
    if (p.y > 0.6 && p.y < 0.605 && p.x > 0.4 && p.x < 0.6) {
        col = mix(vec3(0.7), pinkCol, fract(p.x*10.0 - iTime*5.0));
    }
    if (p.x > -0.5 && p.x < -0.4 && p.y > 0.2 && p.y < 0.205) {
        col = mix(vec3(0.7), pinkCol, fract(p.x*10.0 + iTime*5.0));
    }
}

void layer_Vignette(in vec2 p, inout vec3 col) {
    col *= 1.0 - 0.05 * length(p);
}

vec4 layer_Background(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_Background(p, col);


  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

vec4 layer_Protein(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_Protein(p, iTime, col);


  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

vec4 layer_ZoomCircles(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_ZoomCircles(p, iTime, col);


  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

vec4 layer_Lines(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_Lines(p, iTime, col);


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

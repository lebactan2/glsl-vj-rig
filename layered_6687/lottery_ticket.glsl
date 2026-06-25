float smin(float a, float b, float k) { 
    float h = clamp(0.5+0.5*(b-a)/k, 0.0, 1.0); 
    return mix(b, a, h) - k*h*(1.0-h); 
}

void layer_Background(in vec2 p, inout vec3 col) {
    vec3 pinkCol = mix(vec3(1.0, 0.6, 0.7), vec3(1.0, 0.8, 0.9), p.y);
    pinkCol += 0.05 * sin(p.x * 200.0) * cos(p.y * 200.0);
    col = pinkCol;
}

void layer_BlueEdges(in vec2 p, inout vec3 col, out bool isEdge) {
    isEdge = false;
    if (p.x < 0.1 || p.x > 0.9) {
        isEdge = true;
        vec3 edgeCol = vec3(0.1, 0.4, 0.8);
        float dots = step(0.8, sin(p.y * 200.0)) * step(0.8, sin(p.x * 400.0));
        col = mix(edgeCol, vec3(1.0, 0.9, 0.2), dots);
    }
}

void layer_RedNumbers(in vec2 p, inout vec3 col) {
    if (p.x > 0.15 && p.x < 0.35) {
        float numStack = fract(p.y * 6.0);
        float block = step(0.2, numStack) * step(numStack, 0.8) * step(0.2, p.x) * step(p.x, 0.3);
        float hole = step(0.4, numStack) * step(numStack, 0.6) * step(0.22, p.x) * step(p.x, 0.28);
        col = mix(col, vec3(0.9, 0.1, 0.1), clamp(block - hole, 0.0, 1.0));
    }
}

void layer_DeityFigure(in vec2 p, inout vec3 col) {
    vec2 center = p - vec2(0.6, 0.4);
    float r = length(center);
    float a = atan(center.y, center.x);
    
    float halo = smoothstep(0.3, 0.2, r + 0.05 * sin(a * 15.0));
    vec3 gold = vec3(0.9, 0.8, 0.1);
    col = mix(col, gold, halo * 0.5);
    
    float robes = smoothstep(0.2, 0.18, length(center + vec2(0.0, 0.1)) + 0.05 * sin(a * 5.0));
    col = mix(col, vec3(0.8, 0.1, 0.1), robes);
    
    float details = smoothstep(0.1, 0.08, length(center - vec2(0.1, -0.1))) + 
                    smoothstep(0.08, 0.06, length(center - vec2(-0.15, 0.05)));
    col = mix(col, gold, clamp(details, 0.0, 1.0));
}

void layer_TextOverlay(in vec2 p, inout vec3 col) {
    if (p.x > 0.75 && p.x < 0.85) {
        float textBar = step(0.2, p.y) * step(p.y, 0.8);
        float letters = step(0.5, sin(p.y * 150.0));
        col = mix(col, vec3(0.85, 0.1, 0.2), textBar * letters);
    }
}

void layer_TopSection(in vec2 p, inout vec3 col) {
    if (p.y > 0.8) {
        col = mix(col, vec3(0.95, 0.9, 0.8), 0.5);
        float logo = smoothstep(0.1, 0.08, length(p - vec2(0.5, 0.9)));
        float innerLogo = smoothstep(0.08, 0.06, length(p - vec2(0.5, 0.9)));
        col = mix(col, vec3(0.8, 0.1, 0.1), logo - innerLogo);
    }
}

vec4 layer_Background(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv;
    
    vec3 col = vec3(-1.0);
    bool isEdge = false;
    
    layer_Background(p, col);
    
    if (!isEdge) {
    }
    

  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

vec4 layer_BlueEdges(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv;
    
    vec3 col = vec3(-1.0);
    bool isEdge = false;
    
    layer_BlueEdges(p, col, isEdge);
    
    if (!isEdge) {
    }
    

  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

vec4 layer_RedNumbers(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv;
    
    vec3 col = vec3(-1.0);
    bool isEdge = false;
    
    
    if (!isEdge) {
        layer_RedNumbers(p, col);
    }
    

  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

vec4 layer_DeityFigure(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv;
    
    vec3 col = vec3(-1.0);
    bool isEdge = false;
    
    
    if (!isEdge) {
        layer_DeityFigure(p, col);
    }
    

  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

vec4 layer_TextOverlay(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv;
    
    vec3 col = vec3(-1.0);
    bool isEdge = false;
    
    
    if (!isEdge) {
        layer_TextOverlay(p, col);
    }
    

  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

vec4 layer_TopSection(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv;
    
    vec3 col = vec3(-1.0);
    bool isEdge = false;
    
    
    if (!isEdge) {
        layer_TopSection(p, col);
    }
    

  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

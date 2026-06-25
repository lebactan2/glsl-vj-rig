void layer_Background(in vec2 p, in float iTime, inout vec3 col) {
    vec3 bgGreen = vec3(0.45, 0.6, 0.5);
    col = bgGreen;
    
    float corrugation = sin(p.x * 60.0 + iTime * 2.0);
    col *= 0.8 + 0.2 * corrugation;
    col *= 0.6 + 0.4 * smoothstep(-1.0, 0.0, p.y);
    
    if (p.y < -0.8) {
        col = vec3(0.3, 0.3, 0.28); 
        col *= 0.8 + 0.4 * fract(sin(dot(p * 10.0 + iTime*0.05, vec2(12.9898, 78.233))) * 43758.5453);
    }
}

void layer_LatticePanels(in vec2 p, in float iTime, in int panel, inout vec3 col, in vec3 bgGreen, in vec3 framePurple) {
    if (panel == 1 || panel == 3) {
        vec2 lp = (panel == 1) ? (p - vec2(-0.55, 0.0)) : (p - vec2(0.55, 0.0));
        vec2 grid = lp * vec2(4.0, 3.5); 
        
        grid.y += sin(iTime + lp.x * 5.0) * 0.2;
        
        vec2 fGrid = fract(grid) - 0.5;
        
        float r1 = length(fGrid - vec2(0.15, 0.0));
        float r2 = length(fGrid - vec2(-0.15, 0.0));
        float r3 = length(fGrid - vec2(0.0, 0.15));
        float r4 = length(fGrid - vec2(0.0, -0.15));
        
        float clover = min(min(r1, r2), min(r3, r4));
        float diamond = abs(fGrid.x) + abs(fGrid.y);
        
        if (clover < 0.2 || diamond < 0.15) {
            col = bgGreen * (0.6 + 0.2 * sin(p.x * 60.0 + iTime*2.0));
            col *= 0.5; 
        } else {
            col *= 0.9 + 0.1 * smoothstep(0.2, 0.22, clover);
        }
        
        if (abs(lp.x) > 0.21 || abs(lp.y) > 0.65) {
            col = framePurple; 
        }
    }
}

void layer_CenterPanel(in vec2 p, in float iTime, in int panel, inout vec3 col, in vec3 framePurple) {
    if (panel == 2) {
        if (abs(p.x) < 0.27 && abs(p.y) < 0.65) {
            vec3 paintCol = vec3(0.6, 0.6, 0.5);
            
            vec2 bp = p - vec2(-0.3, -0.7);
            if (fract(bp.x * 8.0) < 0.05 || fract(bp.y * 10.0) < 0.05) paintCol *= 0.8;
            
            float archDist = length(p - vec2(-0.1, 0.2));
            if (archDist < 0.2 && p.y < 0.2) paintCol = vec3(0.2); 
            if (abs(archDist - 0.2) < 0.03 && p.x < -0.1 && p.y < 0.2) paintCol = vec3(0.5, 0.5, 0.4); 
            
            if (p.x > 0.15 && p.y > -0.1) paintCol = vec3(0.7, 0.7, 0.6); 
            
            float horseBody = length(p - vec2(-0.05, -0.3));
            if (horseBody < 0.25) paintCol = vec3(0.2, 0.1, 0.1); 
            
            if (length(p - vec2(-0.15, -0.15)) < 0.1) paintCol = vec3(0.9);
            
            vec3 skinCol = vec3(0.9, 0.75, 0.65);
            if (length(p - vec2(0.0, -0.15)) < 0.08) paintCol = skinCol; 
            if (length(p - vec2(0.05, -0.25)) < 0.06) paintCol = skinCol; 
            
            float hairFlow = sin(p.y * 20.0 - iTime * 3.0) * 0.01;
            if (length(p - vec2(0.05 + hairFlow, -0.1)) < 0.05) paintCol = vec3(0.1);
            
            float clothFlow = sin(p.y * 15.0 - iTime * 2.0) * 0.02;
            if (abs(p.x - 0.1 - clothFlow) < 0.05 && p.y > -0.4 && p.y < -0.2) paintCol = vec3(0.85);

            col = paintCol;
        } else {
            col = framePurple; 
        }
    }
}

vec4 layer_Background(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    vec3 bgGreen = vec3(0.45, 0.6, 0.5);
    vec3 framePurple = vec3(0.65, 0.55, 0.75); 
    
    layer_Background(p, iTime, col);

    bool inFrame = false;
    int panel = 0; 
    
    if (p.y > -0.7 && p.y < 0.7) {
        if (p.x > -0.8 && p.x < -0.3) { inFrame = true; panel = 1; }
        if (p.x >= -0.3 && p.x <= 0.3) { inFrame = true; panel = 2; }
        if (p.x > 0.3 && p.x < 0.8) { inFrame = true; panel = 3; }
    }
    
    if (inFrame) {
        col = framePurple;
        
        
        if (col == framePurple) {
            col *= 0.8 + 0.2 * (p.x + p.y + 1.0);
        }
    }

    col *= 1.0 - 0.3 * length(p);
    

  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

vec4 layer_LatticePanels(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    vec3 bgGreen = vec3(0.45, 0.6, 0.5);
    vec3 framePurple = vec3(0.65, 0.55, 0.75); 
    

    bool inFrame = false;
    int panel = 0; 
    
    if (p.y > -0.7 && p.y < 0.7) {
        if (p.x > -0.8 && p.x < -0.3) { inFrame = true; panel = 1; }
        if (p.x >= -0.3 && p.x <= 0.3) { inFrame = true; panel = 2; }
        if (p.x > 0.3 && p.x < 0.8) { inFrame = true; panel = 3; }
    }
    
    if (inFrame) {
        col = framePurple;
        
        layer_LatticePanels(p, iTime, panel, col, bgGreen, framePurple);
        
        if (col == framePurple) {
            col *= 0.8 + 0.2 * (p.x + p.y + 1.0);
        }
    }

    col *= 1.0 - 0.3 * length(p);
    

  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

vec4 layer_CenterPanel(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    vec3 bgGreen = vec3(0.45, 0.6, 0.5);
    vec3 framePurple = vec3(0.65, 0.55, 0.75); 
    

    bool inFrame = false;
    int panel = 0; 
    
    if (p.y > -0.7 && p.y < 0.7) {
        if (p.x > -0.8 && p.x < -0.3) { inFrame = true; panel = 1; }
        if (p.x >= -0.3 && p.x <= 0.3) { inFrame = true; panel = 2; }
        if (p.x > 0.3 && p.x < 0.8) { inFrame = true; panel = 3; }
    }
    
    if (inFrame) {
        col = framePurple;
        
        layer_CenterPanel(p, iTime, panel, col, framePurple);
        
        if (col == framePurple) {
            col *= 0.8 + 0.2 * (p.x + p.y + 1.0);
        }
    }

    col *= 1.0 - 0.3 * length(p);
    

  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

void layer_Shelves(in vec2 p, in float iTime, inout vec3 col) {
    col = vec3(0.85, 0.85, 0.85); 
    
    vec2 sp = p;
    float shelfY = fract(sp.y * 3.0); 
    float shelfX = fract(sp.x * 2.0); 
    
    if (shelfY < 0.05 || shelfX < 0.05) {
        col = vec3(0.9); 
    } else {
        vec2 cellId = floor(vec2(sp.x * 2.0, sp.y * 3.0));
        float rand = fract(sin(dot(cellId, vec2(12.9898, 78.233))) * 43758.5453 + iTime * 0.2);
        
        if (rand < 0.3) col = vec3(0.9, 0.8, 0.2); 
        else if (rand < 0.5) col = vec3(0.8, 0.2, 0.2); 
        else if (rand < 0.7) col = vec3(0.2, 0.6, 0.3); 
        else if (rand < 0.8) col = vec3(0.3, 0.3, 0.3); 
        else col = vec3(0.7); 
        
        col *= 0.8 + 0.2 * fract(sin(p.x * 50.0 + p.y * 50.0 + iTime)*100.0);
        col *= 0.6 + 0.4 * shelfY; 
    }
}

void layer_SideObject(in vec2 p, inout vec3 col) {
    if (p.x > 0.6 && p.y > -0.5 && p.y < 0.5) {
        col = vec3(0.5, 0.5, 0.55); 
        if (abs(p.x - 0.8) < 0.02) col = vec3(0.9, 0.4, 0.1); 
    }
}

void layer_Figure(in vec2 p, in float iTime, inout vec3 col, out bool isFigure) {
    float breath = sin(iTime * 2.0) * 0.01;
    vec2 fp = p;
    fp.y -= breath;

    vec3 shirtBlue = vec3(0.15, 0.25, 0.7);
    vec3 pantsBlue = vec3(0.2, 0.3, 0.4);
    vec3 silhouetteBlack = vec3(0.0);
    
    isFigure = false;
    
    float dHead = length(fp - vec2(0.0, 0.65)) - 0.18;
    if (dHead < 0.0) {
        col = silhouetteBlack;
        isFigure = true;
    }
    
    if (abs(fp.x) < 0.1 && fp.y > 0.4 && fp.y < 0.5) {
        col = shirtBlue * 0.8; 
        isFigure = true;
    }
    
    float dTorso = max(abs(fp.x) - 0.3 - breath, abs(fp.y - 0.05) - 0.45);
    float torsoWidth = 0.3 + breath - (fp.y - 0.05) * -0.05;
    if (fp.y < 0.5 && fp.y > -0.4 && abs(fp.x) < torsoWidth) {
        col = shirtBlue;
        isFigure = true;
        
        if (abs(fp.x) < 0.01) col *= 0.8;
        if (fract(fp.y * 5.0) < 0.1 && abs(fp.x) < 0.015) col = vec3(0.1);
        
        if (abs(abs(fp.x) - 0.15) < 0.08 && fp.y > 0.15 && fp.y < 0.3) {
            col *= 0.9; 
            if (fp.y > 0.26) col *= 0.95;
            if (abs(abs(fp.x) - 0.15) < 0.01 && abs(fp.y - 0.28) < 0.01) col = vec3(0.1);
        }
        
        col *= 0.8 + 0.2 * cos(fp.x * 20.0 + fp.y * 10.0 + iTime*3.0);
    }
    
    float dArmLeft = max(abs(fp.x + 0.35 + breath) - 0.08, abs(fp.y - 0.0) - 0.3);
    if (dArmLeft < 0.0 && fp.y < 0.4) {
        col = shirtBlue * 0.9; 
        isFigure = true;
    }
    float dArmRight = max(abs(fp.x - 0.35 - breath) - 0.08, abs(fp.y - 0.0) - 0.3);
    if (dArmRight < 0.0 && fp.y < 0.4) {
        col = shirtBlue * 0.9;
        isFigure = true;
    }
    
    if (length(fp - vec2(-0.35 - breath, -0.35)) < 0.06) {
        col = silhouetteBlack;
        isFigure = true;
    }
    if (length(fp - vec2(0.35 + breath, -0.35)) < 0.06) {
        col = silhouetteBlack;
        isFigure = true;
    }
    
    if (p.y < -0.4 && abs(p.x) < 0.28) {
        col = pantsBlue;
        if (abs(p.x) < 0.02) col = vec3(0.1, 0.15, 0.2);
        col *= 0.9 + 0.1 * fract(sin(p.x*100.0 + p.y*100.0)*10.0);
        isFigure = true;
    }
}

void layer_Shadow(in vec2 p, in bool isFigure, inout vec3 col) {
    if (!isFigure) {
        float shadow = length(p - vec2(0.0, 0.0)) - 0.5;
        if (shadow < 0.0) col *= 0.8;
    }
}

vec4 layer_Shelves(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_Shelves(p, iTime, col);
    
    bool isFigure;


  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

vec4 layer_SideObject(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_SideObject(p, col);
    
    bool isFigure;


  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

vec4 layer_Figure(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    
    bool isFigure;
    layer_Figure(p, iTime, col, isFigure);


  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

vec4 layer_Shadow(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    
    bool isFigure;
    layer_Shadow(p, isFigure, col);


  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

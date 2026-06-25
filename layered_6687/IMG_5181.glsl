void layer_ConcreteBackground(in vec2 p, in float iTime, inout vec3 col) {
    col = vec3(0.5, 0.52, 0.5);
    float noise = fract(sin(dot(p * 200.0 + iTime*0.05, vec2(12.9898, 78.233))) * 43758.5453);
    col += (noise - 0.5) * 0.1;
    col *= 0.8 + 0.2 * sin(p.x * 2.0 - iTime);
}

void layer_Card(in vec2 pr, in vec2 cardSize, in float iTime, inout vec3 col) {
    float card = max(abs(pr.x) - cardSize.x, abs(pr.y) - cardSize.y);
    
    if (card < 0.0) {
        col = vec3(0.95); 
        
        if (max(abs(pr.x) - cardSize.x + 0.02, abs(pr.y) - cardSize.y + 0.02) > 0.0) {
            float dotPattern = fract(pr.x * 30.0 - iTime) * fract(pr.y * 20.0 - iTime);
            if (dotPattern < 0.25) {
                col = vec3(0.9, 0.6, 0.2);
            }
        } else {
            vec2 gridArea = pr;
            vec2 gUv = (gridArea + cardSize - 0.05) / (cardSize * 2.0 - 0.1);
            
            if (gUv.x > 0.0 && gUv.x < 1.0 && gUv.y > 0.0 && gUv.y < 1.0) {
                vec2 grid = gUv * vec2(9.0, 3.0);
                vec2 cell = floor(grid);
                vec2 cellP = fract(grid);
                
                if (cellP.x < 0.05 || cellP.y < 0.05) {
                    col = vec3(0.0); 
                } else {
                    float hash = fract(sin(dot(cell, vec2(12.9898, 78.233))) * 43758.5453);
                    bool isOrange = hash > 0.3; 
                    
                    float flash = 0.0;
                    if (fract(hash * 123.456 + iTime * 0.5) > 0.95) flash = 0.5;

                    if (isOrange) col = vec3(0.9, 0.6 + flash, 0.1 + flash);
                    else col = vec3(0.95 + flash);
                    
                    if (isOrange && length(cellP - 0.5) < 0.2) {
                        col = vec3(0.1); 
                    }
                }
            }
        }
        
        float scanner = abs(pr.x - sin(iTime * 2.0) * 0.8);
        if (scanner < 0.01) col = mix(col, vec3(1.0, 0.0, 0.0), 0.5); 
    }
}

vec4 layer_ConcreteBackground(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;
    
    float angle = 0.1 + sin(iTime * 0.5) * 0.02; 
    mat2 rot = mat2(cos(angle), -sin(angle), sin(angle), cos(angle));
    vec2 pr = rot * p;
    
    vec3 col = vec3(-1.0);
    vec2 cardSize = vec2(0.8, 0.5);
    
    layer_ConcreteBackground(p, iTime, col);


  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

vec4 layer_Card(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;
    
    float angle = 0.1 + sin(iTime * 0.5) * 0.02; 
    mat2 rot = mat2(cos(angle), -sin(angle), sin(angle), cos(angle));
    vec2 pr = rot * p;
    
    vec3 col = vec3(-1.0);
    vec2 cardSize = vec2(0.8, 0.5);
    
    layer_Card(pr, cardSize, iTime, col);


  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

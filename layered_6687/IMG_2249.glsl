void layer_Ceiling(in vec2 p, inout vec3 col) {
    if (p.y > 0.6 - p.x*p.x*0.1) {
        col = vec3(0.8, 0.8, 0.8); 
        float noise = fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
        col -= noise * 0.1;
    } 
}

void layer_LatticeStructure(in vec2 p, in float iTime, inout vec3 col) {
    if (!(p.y > 0.6 - p.x*p.x*0.1) && !(p.x < -0.8 || p.x > 0.8)) {
        vec2 gridP = p;
        
        float warp = 1.0 - (gridP.y * 0.2); 
        gridP.x /= warp;
        gridP.y = gridP.y * 1.2 - iTime*0.1; 
        
        col = vec3(0.5, 0.6, 0.7); 
        
        float numCols = 15.0;
        float numRows = 20.0;
        
        vec2 cell = fract(gridP * vec2(numCols, numRows));
        vec2 cellId = floor(gridP * vec2(numCols, numRows));
        
        vec3 brickCol = vec3(0.7, 0.3, 0.2);
        brickCol *= 0.8 + 0.2 * sin(cellId.x * 12.3 + cellId.y * 45.6); 
        
        float isBrick = 0.0;
        
        if (cell.x < 0.08 || cell.x > 0.92 || cell.y < 0.08 || cell.y > 0.92) {
            col = vec3(0.8); 
        } else {
            isBrick = 1.0;
            vec2 holeP = cell - vec2(0.5);
            float holeDist = max(abs(holeP.x) - 0.3, abs(holeP.y) - 0.2);
            holeDist = max(holeDist, abs(holeP.x) + abs(holeP.y) - 0.45); 
            
            if (holeDist < 0.0) {
                isBrick = 0.0; 
                col = vec3(0.5, 0.6, 0.7);
                if (sin(gridP.x*5.0 + gridP.y*5.0) > 0.5) col += 0.2;
            }
        }
        
        if (isBrick > 0.0) {
            col = brickCol;
            if (cell.y > 0.8) col *= 1.2; 
            if (cell.y < 0.2) col *= 0.7; 
            if (cell.x > 0.8) col *= 0.8; 
            
            float light = sin(p.x * 3.0 + p.y * 3.0 - iTime * 2.0);
            if (light > 0.8) col += 0.2;
        }
    }
}

void layer_SideWalls(in vec2 p, inout vec3 col) {
    if (!(p.y > 0.6 - p.x*p.x*0.1) && (p.x < -0.8 || p.x > 0.8)) {
        col = vec3(0.7, 0.7, 0.7); 
        col -= fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453) * 0.1;
    }
}

vec4 layer_Ceiling(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_Ceiling(p, col);


  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

vec4 layer_LatticeStructure(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_LatticeStructure(p, iTime, col);


  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

vec4 layer_SideWalls(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_SideWalls(p, col);


  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

void layer_Ceiling(in vec2 p, inout vec3 col) {
    if (p.y > 0.7) {
        col = vec3(0.8, 0.8, 0.8); 
    }
}

void layer_StoneBase(in vec2 p, inout vec3 col) {
    if (p.y < -0.4 && !(p.y > 0.7)) {
        col = vec3(0.6, 0.6, 0.55); 
        
        vec2 grid = floor(p * vec2(8.0, 10.0));
        vec2 f = fract(p * vec2(8.0, 10.0));
        if (f.x < 0.05 || f.y < 0.05) col = vec3(0.3); 
        
        float blockVal = fract(sin(dot(grid, vec2(12.9898, 78.233))) * 43758.5453);
        col += (blockVal - 0.5) * 0.1; 
        
        if (p.y > -0.43 && p.y < -0.4) col = vec3(0.9);
        
        if (p.y < -0.8) {
            col = vec3(0.7); 
            if (abs(p.x) < 0.02) col *= 0.8; 
        }
    }
}

void layer_LatticeWall(in vec2 p, in float iTime, inout vec3 col) {
    if (!(p.y < -0.4) && !(p.y > 0.7)) {
        vec2 gridP = p;
        float curve = cos(p.x * 1.5) * 0.1;
        gridP.y += curve; 
        
        col = vec3(0.6, 0.7, 0.8);
        
        float numCols = 12.0;
        float numRows = 12.0;
        
        float row = floor((gridP.y + 0.4) * numRows);
        if (mod(row, 2.0) == 0.0) gridP.x += 0.5 / numCols;
        
        vec2 cell = fract(vec2(gridP.x, gridP.y + 0.4) * vec2(numCols, numRows));
        vec2 cellId = floor(vec2(gridP.x, gridP.y + 0.4) * vec2(numCols, numRows));
        
        vec3 brickCol = vec3(0.75, 0.35, 0.25); 
        brickCol *= 0.8 + 0.2 * fract(sin(dot(cellId, vec2(12.9898, 78.233))) * 43758.5453);
        
        float isBrick = 0.0;
        
        if (cell.x < 0.05 || cell.x > 0.95 || cell.y < 0.05 || cell.y > 0.95) {
            if (cell.y < 0.05 || cell.y > 0.95) {
                col = vec3(0.85); 
            } else {
                col = vec3(0.7); 
            }
        } 
        else {
            isBrick = 1.0;
            vec2 holeP = cell - vec2(0.5);
            float holeDist = max(abs(holeP.x) - 0.35, abs(holeP.y) - 0.25);
            holeDist = max(holeDist, abs(holeP.x) + abs(holeP.y) - 0.5); 
            
            if (holeDist < 0.0) {
                isBrick = 0.0; 
                col = vec3(0.6, 0.7, 0.8);
                float bgAnim = sin(p.x*10.0 + iTime) * cos(p.y*10.0);
                if (bgAnim > 0.5) col = vec3(0.9); 
                if (holeP.y > 0.15 || holeP.x > 0.25) col *= 0.5; 
            }
        }
        
        if (isBrick > 0.0) {
            col = brickCol;
            if (cell.y > 0.8) col *= 1.2; 
            if (cell.y < 0.2) col *= 0.7; 
            if (cell.x > 0.8) col *= 0.8;
            
            col *= 1.0 - abs(p.x) * 0.3;
        }
    }
}

void layer_SidePillars(in vec2 p, inout vec3 col) {
    if (abs(p.x) > 0.9) {
        col = vec3(0.65, 0.65, 0.65);
        if (p.x > 0.9 && p.y < -0.4) {
            if (abs(fract((p.x - 0.9) * 15.0) - 0.5) < 0.2) col = vec3(0.2, 0.4, 0.7); 
            if (abs(p.y - (-0.45)) < 0.02) col = vec3(0.2, 0.4, 0.7); 
        }
    }
}

vec4 layer_Ceiling(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_Ceiling(p, col);


  return vec4(clamp(col,0.0,1.0), step(0.0, max(col.r, max(col.g, col.b))));
}

vec4 layer_StoneBase(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_StoneBase(p, col);


  return vec4(clamp(col,0.0,1.0), step(0.0, max(col.r, max(col.g, col.b))));
}

vec4 layer_LatticeWall(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_LatticeWall(p, iTime, col);


  return vec4(clamp(col,0.0,1.0), step(0.0, max(col.r, max(col.g, col.b))));
}

vec4 layer_SidePillars(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_SidePillars(p, col);


  return vec4(clamp(col,0.0,1.0), step(0.0, max(col.r, max(col.g, col.b))));
}

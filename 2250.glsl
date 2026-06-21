void main() {
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;
    
    vec3 col = vec3(0.0);
    
    // Ceiling
    if (p.y > 0.7) {
        col = vec3(0.8, 0.8, 0.8); 
    }
    // Stone base
    else if (p.y < -0.4) {
        col = vec3(0.6, 0.6, 0.55); 
        // Stone block pattern
        vec2 grid = floor(p * vec2(8.0, 10.0));
        vec2 f = fract(p * vec2(8.0, 10.0));
        if (f.x < 0.05 || f.y < 0.05) col = vec3(0.3); // Gaps
        
        float blockVal = fract(sin(dot(grid, vec2(12.9898, 78.233))) * 43758.5453);
        col += (blockVal - 0.5) * 0.1; // Random stone colors
        
        // Ledge
        if (p.y > -0.43 && p.y < -0.4) col = vec3(0.9);
        
        // Floor below base
        if (p.y < -0.8) {
            col = vec3(0.7); 
            if (abs(p.x) < 0.02) col *= 0.8; // Cracks/lines
        }
    }
    // Lattice wall
    else {
        vec2 gridP = p;
        // Curve effect
        float curve = cos(p.x * 1.5) * 0.1;
        gridP.y += curve; 
        
        // Background sky
        col = vec3(0.6, 0.7, 0.8);
        
        float numCols = 12.0;
        float numRows = 12.0;
        
        float row = floor((gridP.y + 0.4) * numRows);
        // Stagger every other row
        if (mod(row, 2.0) == 0.0) gridP.x += 0.5 / numCols;
        
        vec2 cell = fract(vec2(gridP.x, gridP.y + 0.4) * vec2(numCols, numRows));
        vec2 cellId = floor(vec2(gridP.x, gridP.y + 0.4) * vec2(numCols, numRows));
        
        vec3 brickCol = vec3(0.75, 0.35, 0.25); 
        brickCol *= 0.8 + 0.2 * fract(sin(dot(cellId, vec2(12.9898, 78.233))) * 43758.5453);
        
        float isBrick = 0.0;
        
        if (cell.x < 0.05 || cell.x > 0.95 || cell.y < 0.05 || cell.y > 0.95) {
            if (cell.y < 0.05 || cell.y > 0.95) {
                col = vec3(0.85); // White mortar horizontal
            } else {
                col = vec3(0.7); // White mortar vertical
            }
        } 
        else {
            isBrick = 1.0;
            vec2 holeP = cell - vec2(0.5);
            float holeDist = max(abs(holeP.x) - 0.35, abs(holeP.y) - 0.25);
            holeDist = max(holeDist, abs(holeP.x) + abs(holeP.y) - 0.5); 
            
            if (holeDist < 0.0) {
                isBrick = 0.0; 
                // Return to background
                col = vec3(0.6, 0.7, 0.8);
                // Background animation: clouds passing or trees
                float bgAnim = sin(p.x*10.0 + iTime) * cos(p.y*10.0);
                if (bgAnim > 0.5) col = vec3(0.9); // Cloud
                if (holeP.y > 0.15 || holeP.x > 0.25) col *= 0.5; // Inner shadow
            }
        }
        
        if (isBrick > 0.0) {
            col = brickCol;
            if (cell.y > 0.8) col *= 1.2; 
            if (cell.y < 0.2) col *= 0.7; 
            if (cell.x > 0.8) col *= 0.8;
            
            // Curve shading
            col *= 1.0 - abs(p.x) * 0.3;
        }
    }
    
    // Side pillars
    if (abs(p.x) > 0.9) {
        col = vec3(0.65, 0.65, 0.65);
        // Blue railing on the right
        if (p.x > 0.9 && p.y < -0.4) {
            if (abs(fract((p.x - 0.9) * 15.0) - 0.5) < 0.2) col = vec3(0.2, 0.4, 0.7); 
            if (abs(p.y - (-0.45)) < 0.02) col = vec3(0.2, 0.4, 0.7); 
        }
    }

    gl_FragColor = vec4(col, 1.0);
}
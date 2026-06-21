void main() {
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;
    
    // Rotate slightly because the photo is taken at an angle
    float angle = 0.1 + sin(iTime * 0.5) * 0.02; // Slight wobble
    mat2 rot = mat2(cos(angle), -sin(angle), sin(angle), cos(angle));
    vec2 pr = rot * p;
    
    // Concrete background
    vec3 col = vec3(0.5, 0.52, 0.5);
    float noise = fract(sin(dot(p * 200.0 + iTime*0.05, vec2(12.9898, 78.233))) * 43758.5453);
    col += (noise - 0.5) * 0.1;
    
    // Sweeping shadow on concrete
    col *= 0.8 + 0.2 * sin(p.x * 2.0 - iTime);

    // Card dimensions
    vec2 cardSize = vec2(0.8, 0.5);
    float card = max(abs(pr.x) - cardSize.x, abs(pr.y) - cardSize.y);
    
    if (card < 0.0) {
        col = vec3(0.95); // White card base
        
        // Border
        if (max(abs(pr.x) - cardSize.x + 0.02, abs(pr.y) - cardSize.y + 0.02) > 0.0) {
            // Little orange dots on border animated
            float dotPattern = fract(pr.x * 30.0 - iTime) * fract(pr.y * 20.0 - iTime);
            if (dotPattern < 0.25) {
                col = vec3(0.9, 0.6, 0.2);
            }
        } else {
            // Inner grid area
            vec2 gridArea = pr;
            // Map to 0-1 for grid
            vec2 gUv = (gridArea + cardSize - 0.05) / (cardSize * 2.0 - 0.1);
            
            if (gUv.x > 0.0 && gUv.x < 1.0 && gUv.y > 0.0 && gUv.y < 1.0) {
                // 9 cols, 3 rows
                vec2 grid = gUv * vec2(9.0, 3.0);
                vec2 cell = floor(grid);
                vec2 cellP = fract(grid);
                
                // Draw cell borders
                if (cellP.x < 0.05 || cellP.y < 0.05) {
                    col = vec3(0.0); // Black lines
                } else {
                    // Cell background (Orange or White)
                    float hash = fract(sin(dot(cell, vec2(12.9898, 78.233))) * 43758.5453);
                    bool isOrange = hash > 0.3; // Most cells are orange
                    
                    // Flash effect on some cells
                    float flash = 0.0;
                    if (fract(hash * 123.456 + iTime * 0.5) > 0.95) flash = 0.5;

                    if (isOrange) col = vec3(0.9, 0.6 + flash, 0.1 + flash);
                    else col = vec3(0.95 + flash);
                    
                    // Draw numbers (black blobs) inside orange cells usually
                    if (isOrange && length(cellP - 0.5) < 0.2) {
                        col = vec3(0.1); // Black text approximation
                    }
                }
            }
        }
        
        // Sweeping scanner line across the card
        float scanner = abs(pr.x - sin(iTime * 2.0) * 0.8);
        if (scanner < 0.01) col = mix(col, vec3(1.0, 0.0, 0.0), 0.5); // Red laser line
    }
    
    gl_FragColor = vec4(col, 1.0);
}
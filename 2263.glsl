void main() {
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;
    
    vec3 col = vec3(0.0);
    
    // Background (Trees and sky)
    if (p.y > 0.5) {
        col = vec3(0.6, 0.7, 0.8); // Sky
        float tree = sin(p.x*10.0)*0.1 + cos(p.x*20.0)*0.05 + 0.6;
        if (p.y < tree) col = vec3(0.2, 0.4, 0.2); // Distant trees
    } else {
        col = vec3(0.2, 0.4, 0.2); // Green foliage
        // Animated rustling leaves
        float leafAnim = sin(p.x * 20.0 + iTime*2.0) * cos(p.y * 15.0 + iTime);
        if (leafAnim > 0.5) col = vec3(0.3, 0.5, 0.2);
    }
    
    // Ground
    if (p.y < -0.6) {
        col = vec3(0.4, 0.4, 0.4); // Asphalt/ground
    }
    
    vec3 gateCol = vec3(0.3, 0.7, 0.85); // Light blue
    
    // Blue Pillar on the left
    if (p.x > -0.8 && p.x < -0.4 && p.y > -0.8) {
        col = vec3(0.3, 0.65, 0.85); // Pillar base color
        
        // Stone texture on pillar (irregular horizontal/vertical cuts)
        vec2 tile = fract(p * vec2(8.0, 20.0));
        if (tile.x < 0.05 || tile.y < 0.05) col *= 0.8; // Gaps
        
        // Pillar top feature
        if (p.y > 0.6) {
            col = vec3(0.2, 0.7, 0.5); // Greenish top
            // Horizontal slots
            if (fract((p.y - 0.6) * 15.0) < 0.4) col = vec3(0.1); 
        }
        
        // White sign attached to fence next to pillar
        if (p.x < -0.45 && p.y > -0.2 && p.y < 0.3) {
            col = vec3(0.95); // White board
            // Text simulation
            if (fract(p.y * 25.0) < 0.3 && abs(p.x + 0.62) < 0.14) col = vec3(0.1); 
        }
    }
    
    // Blue Gate Structure
    if (p.x > -0.4 && p.y > -0.8) {
        // Lower solid panel
        if (p.y < -0.45) {
            col = gateCol;
            // Frame lines on solid panel
            if (abs(p.y + 0.45) < 0.02 || abs(p.y + 0.75) < 0.02) col *= 0.8;
            // Wheel
            if (length(vec2(p.x, p.y + 0.78)) < 0.04) col = vec3(0.4); // Grey wheel
        } else {
            // Main gate frame borders
            if (abs(p.y - 0.8 + (p.x+0.4)*0.2) < 0.02) col = gateCol; // Top diagonal
            if (abs(p.x + 0.38) < 0.02) col = gateCol; // Left vertical
            if (abs(p.y + 0.45) < 0.02) col = gateCol; // Bottom horizontal
            
            // Circles pattern
            vec2 gP = vec2(p.x + 0.4, p.y + 0.45); 
            
            if (gP.x > 0.0 && gP.y > 0.0 && gP.y < 1.25 - gP.x*0.2) {
                vec2 grid = fract(gP * 10.0);
                vec2 cell = floor(gP * 10.0);
                
                vec2 center = vec2(0.5);
                float dist = length(grid - center);
                
                // Rings
                if (abs(dist - 0.4) < 0.05) {
                    col = gateCol;
                    // Animated shine on the rings
                    float shine = sin(cell.x*0.5 + cell.y*0.5 - iTime*3.0);
                    if (shine > 0.8) col = vec3(0.8, 0.9, 1.0);
                }
                
                // Connecting links (horizontal/vertical)
                if ((abs(grid.x - 0.5) < 0.02 && (grid.y < 0.1 || grid.y > 0.9)) ||
                    (abs(grid.y - 0.5) < 0.02 && (grid.x < 0.1 || grid.x > 0.9))) {
                    col = gateCol;
                }
            }
        }
    }
    
    // Fence on far left
    if (p.x < -0.8 && p.y > -0.5) {
        // Vertical bars
        if (fract(p.x * 10.0) < 0.1) col = vec3(0.5, 0.5, 0.4);
        // Diamond mesh pattern
        if (fract(p.x * 20.0 + p.y * 20.0) < 0.05 || fract(p.x * 20.0 - p.y * 20.0) < 0.05) col = vec3(0.4);
    }

    gl_FragColor = vec4(col, 1.0);
}
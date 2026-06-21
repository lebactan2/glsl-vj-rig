void main() {
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;
    
    vec3 col = vec3(0.0);
    
    // Background wall (grey stone/concrete)
    col = vec3(0.75, 0.73, 0.7);
    
    // Concrete noise texture
    float noise = fract(sin(dot(p + iTime*0.01, vec2(12.9898, 78.233))) * 43758.5453);
    col -= noise * 0.1;
    
    // Large recessed rectangular frame
    if (abs(p.x) < 0.7 && p.y < 0.8 && p.y > -0.7) {
        
        // Outer Frame Border
        if (abs(abs(p.x) - 0.65) < 0.05 || abs(p.y - 0.75) < 0.05 || abs(p.y + 0.65) < 0.05) {
            col = vec3(0.3, 0.3, 0.35); // Dark grey stone border
            col -= noise * 0.15;
            
            // Bevel effect
            if (abs(p.x) - 0.65 < 0.0 && p.x > 0.0) col += 0.05;
            if (p.y - 0.75 < 0.0 && p.y > 0.0) col -= 0.05;
        } 
        // Inner area (lighter stone)
        else {
            col = vec3(0.8, 0.78, 0.75);
            col -= noise * 0.05;
            
            // The Carved Symbol (Dark Grey/Black)
            vec2 sP = p; 
            float sym = 0.0;
            
            // Central vertical line
            if (abs(sP.x) < 0.04 && sP.y > -0.45 && sP.y < 0.4) sym = 1.0;
            
            // Top circle "O" shape
            if (abs(length(vec2(sP.x, sP.y - 0.55)) - 0.1) < 0.03) sym = 1.0;
            
            // Upper curved section (crown-like)
            if (sP.y > 0.2 && sP.y < 0.45) {
                // Outer bell shape
                float bell = 0.4 - sP.y;
                if (abs(abs(sP.x) - bell) < 0.03 && sP.y > 0.25) sym = 1.0;
                // Inner loops
                if (abs(length(vec2(abs(sP.x) - 0.15, sP.y - 0.3)) - 0.05) < 0.02) sym = 1.0;
            }
            
            // Horizontal lines with cross-bars
            // Top crossbar
            if (abs(sP.y - 0.1) < 0.03 && abs(sP.x) < 0.25) sym = 1.0;
            // Upright nubs on top crossbar
            if (abs(abs(sP.x) - 0.15) < 0.02 && sP.y > 0.1 && sP.y < 0.2) sym = 1.0;
            
            // Middle crossbar (widest)
            if (abs(sP.y + 0.1) < 0.03 && abs(sP.x) < 0.35) sym = 1.0;
            // Crosses on ends of middle bar
            if (abs(abs(sP.x) - 0.25) < 0.02 && abs(sP.y + 0.1) < 0.08) sym = 1.0;
            
            // Lower complex swirling section
            if (sP.y < -0.2 && sP.y > -0.6) {
                // Swirls pointing down and out
                float swirlR = length(vec2(abs(sP.x) - 0.2, sP.y + 0.35));
                if (abs(swirlR - 0.15) < 0.03 && sP.y < -0.3) sym = 1.0;
                
                // Small inner "U" shape
                if (abs(length(vec2(sP.x, sP.y + 0.5)) - 0.1) < 0.03 && sP.y < -0.5) sym = 1.0;
                
                // Small nubs
                if (abs(abs(sP.x) - 0.1) < 0.02 && sP.y < -0.25 && sP.y > -0.35) sym = 1.0;
            }
            
            // Draw the symbol
            if (sym > 0.0) {
                // Dark carved stone look
                col = vec3(0.3, 0.3, 0.35); 
                
                // Animated glossy highlight passing over the carving
                float highlight = sin(p.x * 5.0 + p.y * 5.0 + iTime * 2.0);
                if (highlight > 0.8) col += 0.2 * (highlight - 0.8) * 5.0;
                
                // Shadow inside carving
                col -= noise * 0.2;
            } else {
                // Drop shadow from carving onto inner stone
                // Shift the symbol logic slightly for shadow
                vec2 shadP = p + vec2(-0.01, 0.01);
                float shadow = 0.0;
                if (abs(shadP.x) < 0.04 && shadP.y > -0.45 && shadP.y < 0.4) shadow = 1.0;
                if (abs(length(vec2(shadP.x, shadP.y - 0.55)) - 0.1) < 0.03) shadow = 1.0;
                if (abs(shadP.y - 0.1) < 0.03 && abs(shadP.x) < 0.25) shadow = 1.0;
                if (abs(shadP.y + 0.1) < 0.03 && abs(shadP.x) < 0.35) shadow = 1.0;
                
                if (shadow > 0.0) col *= 0.8;
            }
        }
    }
    
    // Top louvers/vents
    if (p.y > 0.85) {
        col = vec3(0.9, 0.9, 0.9); // White vent structure
        // Black gaps
        if (fract(p.x * 5.0) < 0.8 && p.y > 0.9) col = vec3(0.1, 0.1, 0.15); 
    }
    
    // Bottom dark surface (shelf/table)
    if (p.y < -0.7) {
       if (p.y < -0.8) {
           // Dark brown speckled surface
           col = vec3(0.3, 0.15, 0.1);
           // Granite/speckle texture
           float speckle = fract(sin(dot(p*200.0, vec2(12.9898, 78.233))) * 43758.5453);
           col += 0.1 * speckle;
       } else {
           // Edge of surface
           col = vec3(0.4, 0.2, 0.15); 
       }
    }

    gl_FragColor = vec4(col, 1.0);
}
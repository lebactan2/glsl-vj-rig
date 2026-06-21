void main() {
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;
    
    vec3 col = vec3(0.0);
    
    // Altar cloth (Top)
    if (p.y > 0.4) {
        col = vec3(0.85, 0.75, 0.2); // Yellow silk base
        
        // Shimmering silk effect
        float shimmer = sin(p.x * 20.0 + p.y * 30.0 + iTime * 2.0) * 0.1;
        col += shimmer;
        
        // Folds in cloth
        float folds = sin(p.x * 10.0) * 0.1;
        col *= 1.0 + folds;
        
        // Red embroidered text/patterns
        if (p.y > 0.5) {
            // Animated floral patterns
            vec2 fP = vec2(fract(p.x * 5.0 + iTime*0.2), p.y);
            if (length(fP - vec2(0.5, 0.7)) < 0.1) col = vec3(0.9, 0.2, 0.4); // Pink flowers
            
            // Dragon/Bird motifs (abstract)
            if (abs(p.y - 0.6) < 0.15 && fract(p.x * 3.0 - iTime*0.1) < 0.4) {
                if (sin(p.x * 40.0) * cos(p.y * 50.0) > 0.3) col = vec3(0.8, 0.1, 0.1); // Red motifs
            }
            
            // Central Characters
            if (abs(p.x) < 0.6 && p.y > 0.45 && p.y < 0.75) {
                vec2 charGrid = fract(vec2(p.x * 4.0, p.y * 5.0));
                if (charGrid.x > 0.2 && charGrid.x < 0.8 && charGrid.y > 0.2 && charGrid.y < 0.8) {
                    if (fract(p.x * 20.0 + sin(p.y * 30.0)) < 0.3) col = vec3(0.8, 0.1, 0.1);
                }
            }
        }
        
        // Tassels at bottom of cloth
        if (p.y > 0.4 && p.y < 0.43) {
            if (fract(p.x * 30.0) < 0.4) col = vec3(0.8, 0.2, 0.2); // Red fringes
            else col = vec3(0.7, 0.6, 0.2); // Gold fringes
        }
    }
    else {
        // Floor perspective warp
        float floorDepth = 0.4 - p.y;
        vec2 floorP = vec2(p.x / floorDepth, 1.0 / floorDepth);
        
        // Scroll floor slowly
        floorP.y -= iTime * 0.5;
        
        // Tiled Pattern (Green/Brown)
        vec2 grid = floorP * 3.0; 
        vec2 f = fract(grid);
        vec2 id = floor(grid);
        
        vec3 tileCol = vec3(0.5, 0.35, 0.25); // Brown base
        
        vec2 center = vec2(0.5);
        float dist = abs(f.x - center.x) + abs(f.y - center.y); 
        
        if (dist < 0.3) {
            tileCol = vec3(0.3, 0.45, 0.3); // Green diamond
            // Star center
            float starDist = max(abs(f.x - center.x)*1.5, abs(f.y - center.y)*1.5);
            if (starDist < 0.15) tileCol = vec3(0.2, 0.3, 0.2); 
        } else if (dist > 0.45) {
            tileCol = vec3(0.4, 0.5, 0.35); // Green border
            if (abs(f.x - 0.5) < 0.48 && abs(f.y - 0.5) < 0.48) {
                if (abs(f.x - f.y) < 0.05) tileCol = vec3(0.8, 0.8, 0.7); // Light lines
            }
        }
        
        // Tile joints
        if (f.x < 0.02 || f.y < 0.02) tileCol = vec3(0.2); 
        
        col = tileCol;
        
        // Rectangular Grey Mat in the middle
        if (floorP.x > -1.5 && floorP.x < 1.5 && floorP.y > -1.0 && floorP.y < 1.0) {
            vec2 matGrid = floorP * 5.0;
            vec2 mf = fract(matGrid);
            
            col = vec3(0.6); // Grey base
            // 3D Block pattern
            if (mf.x > 0.5) col = vec3(0.8); 
            if (mf.y > 0.5) col = vec3(0.4); 
            if (mf.x > 0.5 && mf.y > 0.5) col = vec3(0.7);
            
            // Texture variation
            float rnd = fract(sin(dot(floor(matGrid), vec2(12.9898, 78.233))) * 43758.5453);
            if (rnd < 0.3) col *= 0.8; 
            if (rnd > 0.7) col *= 1.2; 
        }
        
        // Dynamic Lighting/Flash on the floor
        float flash = 1.0 / (length(vec2(p.x, p.y + 0.2)) * 5.0);
        float pulse = 0.5 + 0.5 * sin(iTime * 3.0);
        col += vec3(0.9, 0.9, 0.8) * clamp(flash * 0.3 * pulse, 0.0, 0.3);
        
        // Darken distance
        col *= clamp((0.4 - p.y) * 2.0, 0.0, 1.0);
    }
    
    // Bare feet at the bottom
    if (p.y < -0.8) {
        // Feet bobbing as if standing/shifting weight
        float bob = sin(iTime * 2.0) * 0.02;
        if (abs(p.x + 0.2) < 0.1 || abs(p.x - 0.2) < 0.1) {
            if (p.y > -0.95 + bob) {
                col = vec3(0.7, 0.5, 0.4); // Skin tone
                // Toes
                if (fract(p.x * 40.0) < 0.2 && p.y > -0.85 + bob) col *= 0.8; 
            }
        }
        // Black pants/shorts at very edge
        if (p.y < -0.95 + bob) {
            col = vec3(0.1); 
            if (abs(p.x) < 0.1) col = vec3(0.6, 0.8, 0.2); // Green fabric piece in photo
        }
    }

    gl_FragColor = vec4(col, 1.0);
}
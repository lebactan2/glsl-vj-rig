void main() {
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;
    
    vec3 col = vec3(0.0);
    
    // --- Instagram UI (Top and Bottom) ---
    if (p.y > 0.8) {
        col = vec3(0.08); // Dark header
        // Story circles
        if (p.y > 0.85 && p.y < 0.95) {
            float sx = fract(p.x * 2.0) - 0.5;
            if (length(vec2(sx, (p.y - 0.9)*5.0)) < 0.2) col = vec3(0.4); // circle
        }
    } else if (p.y < -0.8) {
        col = vec3(0.05); // Dark footer
    } else if (p.y < -0.65 && p.y >= -0.8) {
        col = vec3(0.9, 0.15, 0.25); // "Send message" red bar
    } else {
        
        // --- Main Scene ---
        // Background wall
        col = vec3(0.85, 0.88, 0.85); // Light greenish grey
        
        // Perforated Metal Table
        if (p.y < -0.15) {
            col = vec3(0.6, 0.65, 0.65); // Metal base
            
            // Perspective transform for table
            vec2 tp = p;
            tp.y = tp.y + 0.15; // anchor at top of table
            tp.x = tp.x / (1.0 - tp.y * 0.5); // perspective skew
            
            // Perforation pattern (grid of black holes)
            vec2 grid = fract(tp * vec2(20.0, 30.0)) - 0.5;
            if (length(grid) < 0.25) {
                col = vec3(0.1); // hole
            }
            // lighting gradient on table
            col *= 0.7 - tp.y * 0.5;
        }
        
        // --- Red Book ("LAYOUT NOW") ---
        float bookLeft = -0.4;
        float bookRight = 0.5;
        float bookBottom = -0.25;
        float bookTop = 0.6;
        
        // Background stacked books
        if (p.x > -0.35 && p.x < 0.55 && p.y > 0.6 && p.y < 0.75) {
            col = vec3(0.7, 0.1, 0.2); // dark red
            if (fract(p.y * 20.0) < 0.1) col *= 0.5; // page seams
        }
        
        // Main Book
        if (p.x > bookLeft && p.x < bookRight && p.y > bookBottom && p.y < bookTop) {
            col = vec3(0.75, 0.1, 0.2); // Bright Red cover
            
            // Book spine (white)
            if (p.x < bookLeft + 0.05) {
                col = vec3(0.9, 0.9, 0.9);
                // "LAYOUT NOW" text on spine (vertical)
                if (fract(p.y * 10.0) < 0.5 && p.x > bookLeft + 0.02) col = vec3(0.1);
            }
            
            // "LAYOUT NOW" large title
            if (p.x > -0.1 && p.x < 0.3 && p.y > 0.2 && p.y < 0.4) {
                // simple white text blocks
                float textPat = fract(p.x * 10.0);
                if (textPat > 0.2 && textPat < 0.8) {
                    if (p.y > 0.31 || p.y < 0.29) {
                        col = vec3(0.95);
                    }
                }
            }
            // Subtitle
            if (p.x > -0.1 && p.x < 0.25 && p.y > 0.12 && p.y < 0.15) {
                if (fract(p.x * 30.0) > 0.3) col = vec3(0.9);
            }
            
            // Bottom logo "SP"
            if (length(p - vec2(0.1, -0.15)) < 0.04) {
                col = vec3(0.9);
            }
            
            // Book shading
            col *= 0.9 + 0.1 * p.x;
        }
    }

    
    gl_FragColor = vec4(col, 1.0);
}
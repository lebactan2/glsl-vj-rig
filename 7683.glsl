void main() {
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;
    
    vec3 col = vec3(0.0);
    
    // --- Background Layer (Courtyard) ---
    // Lower half: tiled floor
    if (p.y < -0.4) {
        col = vec3(0.7, 0.6, 0.5); // tan floor
        // Floor grid
        vec2 tp = p * vec2(10.0, 5.0 / max(0.1, (p.y + 1.0)));
        if (fract(tp.x) < 0.05 || fract(tp.y) < 0.05) col = vec3(0.5, 0.4, 0.3);
    } 
    // Upper half: Blue wall and green plants
    else {
        col = vec3(0.5, 0.7, 0.75); // light blue wall
        
        // Teal doors/shutters
        if (abs(p.x) > 0.3 && p.y > -0.4 && p.y < 0.4) {
            col = vec3(0.3, 0.6, 0.55); // teal
            if (fract(p.x * 20.0) < 0.2) col *= 0.7; // shutter lines
        }
        
        // Green plants
        if (length(p - vec2(-0.2, -0.1)) < 0.2 || length(p - vec2(0.3, 0.0)) < 0.25) {
            col = vec3(0.2, 0.4, 0.2); // dark green leaves
            // sway plants
            col *= 0.8 + 0.2 * fract(sin(p.x*100.0 + iTime)*40.0); // noise
        }
    }

    // --- Foreground Temple Gate ---
    
    // 1. Top Header Sign
    if (p.y > 0.65) {
        col = vec3(0.4, 0.1, 0.1); // dark roof edge
        if (p.y < 0.95 && p.y > 0.7) {
            col = vec3(0.8, 0.7, 0.2); // Gold/Yellow background
            // Text "CHUA TRUONG THANH" (Red blocks)
            if (abs(p.y - 0.82) < 0.08) {
                if (fract(p.x * 5.0) < 0.7 && abs(p.x) < 0.8) {
                    col = vec3(0.7, 0.15, 0.15); // red letters
                }
            }
            // Add some gold speckles
            col *= 0.9 + 0.1 * fract(sin(dot(p + iTime*0.05, vec2(12.9898, 78.233))) * 43758.5453);
        }
    }
    
    // 2. Pillars (Left and Right)
    float dPillarL = max(abs(p.x - (-0.7)) - 0.1, abs(p.y) - 0.65);
    float dPillarR = max(abs(p.x - 0.7) - 0.1, abs(p.y) - 0.65);
    
    if (min(dPillarL, dPillarR) < 0.0) {
        col = vec3(0.3, 0.15, 0.15); // dark brick red
        // Brick lines
        if (fract(p.y * 30.0) < 0.1 || fract(p.x * 10.0 + (fract(p.y*15.0)>0.5?0.5:0.0)) < 0.1) {
            col = vec3(0.2, 0.1, 0.1);
        }
        
        // Vertical black signs on pillars
        if (abs(abs(p.x) - 0.7) < 0.06 && p.y < 0.6 && p.y > -0.6) {
            col = vec3(0.9, 0.9, 0.9); // White sign background
            // Black Chinese characters (vertical repeating dots/lines)
            if (fract(p.y * 5.0) < 0.6 && abs(abs(p.x) - 0.7) < 0.03) {
                // Character shape approx
                if (fract(p.y * 25.0) < 0.5 || abs(abs(p.x) - 0.7) < 0.01) {
                    col = vec3(0.05); // Black ink
                }
            }
        }
    }
    
    // 3. Yellow Metal Gate Main Grid
    if (abs(p.x) < 0.6 && p.y > -0.65 && p.y < 0.65) {
        vec3 gateCol = vec3(0.85, 0.75, 0.2); // yellow paint
        // Animate the gate color slightly (shimmer)
        gateCol += 0.1 * sin(p.y * 20.0 - iTime * 3.0) * sin(p.x * 20.0);
        
        float isGate = 0.0;
        
        // Frame/bars
        if (abs(p.x) > 0.58) isGate = 1.0; // outer edge
        if (abs(p.y) > 0.63) isGate = 1.0;
        if (abs(p.x) < 0.015) isGate = 1.0; // center split
        
        // Horizontal rails
        if (abs(p.y - 0.4) < 0.01) isGate = 1.0;
        if (abs(p.y - 0.2) < 0.01) isGate = 1.0;
        if (abs(p.y - (-0.3)) < 0.01) isGate = 1.0;
        if (abs(p.y - (-0.45)) < 0.01) isGate = 1.0;
        
        // Vertical thin bars
        if (fract(p.x * 15.0) < 0.1 && p.y > 0.4) isGate = 1.0;
        if (fract(p.x * 15.0) < 0.1 && p.y < -0.45) isGate = 1.0;
        
        // Decorative patterns (Lotus curves in the lower middle panel)
        if (p.y > -0.45 && p.y < -0.3) {
            vec2 lp = vec2(fract(p.x * 5.0), p.y);
            if (abs(length(lp - vec2(0.5, -0.4)) - 0.08) < 0.01) isGate = 1.0;
            if (abs(lp.x - 0.5) < 0.01) isGate = 1.0;
        }
        
        if (isGate > 0.0) col = gateCol;
        
        // 4. Large Red Chinese Characters in the center
        // Spanning the middle section
        if (p.y > -0.2 && p.y < 0.2) {
            float isChar = 0.0;
            vec2 cp = p;
            cp.x = fract(p.x * 2.0) - 0.5; // two main characters per door side
            
            // Approximate character with thick horizontal and vertical blocks
            if (abs(cp.y) < 0.15 && abs(cp.x) < 0.15) {
                // outer box
                if (abs(abs(cp.x) - 0.15) < 0.02) isChar = 1.0;
                if (abs(abs(cp.y) - 0.15) < 0.02) isChar = 1.0;
                // inner lines
                if (abs(cp.y) < 0.02) isChar = 1.0;
                if (abs(cp.x) < 0.02) isChar = 1.0;
            }
            
            if (isChar > 0.0) {
                // Dark red paint
                col = vec3(0.7, 0.2, 0.2); 
            }
        }
        
        // 5. White Paper Sign "DICH BENH COVID-19..."
        // Center right
        float dSign = max(abs(p.x - 0.15) - 0.1, abs(p.y - 0.0) - 0.08);
        if (dSign < 0.0) {
            col = vec3(0.95); // white paper
            // Text lines
            if (fract(p.y * 20.0) < 0.3 && abs(p.y) < 0.06 && abs(p.x - 0.15) < 0.08) {
                col = vec3(0.1); // black text
            }
        }
    }

    // Add vignette
    col *= 1.0 - 0.1 * length(p);

    
    gl_FragColor = vec4(col, 1.0);
}
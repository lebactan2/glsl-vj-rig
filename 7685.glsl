void main() {
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;
    
    vec3 col = vec3(0.0);
    
    // --- Background Wall ---
    col = vec3(0.8, 0.65, 0.55); // pinkish beige wall
    
    // Top dark red trim
    if (p.y > 0.6) {
        col = vec3(0.4, 0.15, 0.15); // dark red
        if (p.y < 0.62) col *= 0.5; // shadow
    }
    
    // Left sky / roof edge
    if (p.x < -0.6 && p.y > 0.2) {
        col = vec3(0.8, 0.8, 0.8); // white/grey sky
        // roof slope
        if (p.x + 0.6 > p.y - 0.2) {
            col = vec3(0.3, 0.3, 0.3); // dark underside
        }
    }
    
    // Right side grunge wall
    if (p.x > 0.8) {
        col = vec3(0.6, 0.6, 0.55); // grey wall
        col *= 0.8 + 0.2 * fract(sin(p.x*100.0)*40.0 + iTime);
        // pipes/lines
        if (abs(p.x - 0.9) < 0.02) col *= 0.6;
    }

    // --- Center Window/Vent ---
    float dCircle = length(p - vec2(0.0, 0.0)) - 0.25;
    if (dCircle < 0.0) {
        col = vec3(0.3, 0.1, 0.1); // dark red outer rim
        
        if (dCircle < -0.05) {
            col = vec3(0.85); // white inner background/character
            // Carved text (approximated with dark cutouts)
            vec2 cp = p;
            if (abs(cp.x) < 0.15 && abs(cp.y) < 0.15) {
                // strokes
                if (abs(cp.y) < 0.02 || abs(cp.x) < 0.02 || abs(cp.x + cp.y) < 0.03 || abs(cp.x - cp.y) < 0.03) {
                    // white stroke
                } else {
                    col = vec3(0.15); // dark interior
                }
            } else if (dCircle < -0.06) {
                col = vec3(0.15);
            }
        }
    }

    // --- Balcony Railing ---
    if (p.y > -0.4 && p.y < 0.2) {
        vec3 railCol = vec3(0.6, 0.5, 0.4); // brownish metal
        float isRail = 0.0;
        
        // Top and bottom bars
        if (abs(p.y - 0.2) < 0.01) isRail = 1.0;
        if (abs(p.y - (-0.4)) < 0.01) isRail = 1.0;
        
        // Vertical bars
        if (abs(p.x - (-0.8)) < 0.01) isRail = 1.0;
        if (abs(p.x - 0.8) < 0.01) isRail = 1.0;
        if (abs(p.x - (-0.3)) < 0.01) isRail = 1.0;
        if (abs(p.x - 0.3) < 0.01) isRail = 1.0;
        
        // Center box around circle
        if (max(abs(p.x) - 0.3, abs(p.y + 0.1) - 0.3) > 0.0 && max(abs(p.x) - 0.3, abs(p.y + 0.1) - 0.3) < 0.01) isRail = 1.0;
        
        // Lotus Patterns (Left and Right)
        vec2 lp = p;
        lp.x = abs(p.x); // symmetry for lotus
        if (lp.x > 0.3 && lp.x < 0.8) {
            vec2 lpc = lp - vec2(0.55, -0.2);
            // lotus petals (teal/green) - animated breathing
            float breath = sin(iTime * 2.0 + lp.x * 5.0) * 0.02;
            if (length(lpc) < 0.15 + breath && lpc.y > 0.0) {
                if (fract(length(lpc)*10.0 - iTime*2.0) < 0.2) {
                    col = mix(col, vec3(0.3, 0.5, 0.4), 0.8);
                    isRail = 0.5;
                }
            }
            // stems/leaves
            if (abs(lpc.x) < 0.01 && lpc.y < 0.0) isRail = 1.0; // stem
        }
        
        if (isRail > 0.9) col = railCol;
    }

    // --- Bottom Dark Red Section ---
    if (p.y < -0.4) {
        col = vec3(0.4, 0.15, 0.15); // dark red
        if (p.y > -0.45) col *= 0.5; // top edge shadow
        
        // Shadow from post
        if (abs(p.x) < 0.15) col *= 0.8;
    }

    // --- Center Ornate Post (Foreground) ---
    if (p.y < -0.4 && p.y > -1.0) {
        float dPost = max(abs(p.x) - 0.1, abs(p.y + 0.7) - 0.3);
        if (dPost < 0.0) {
            col = vec3(0.8, 0.8, 0.8); // white base
            // dark edges
            if (abs(abs(p.x) - 0.1) < 0.01) col *= 0.5;
            
            // Top part of post (finial)
            if (p.y > -0.6) {
                col = vec3(0.7, 0.6, 0.2); // gold
                if (p.y > -0.5) col = vec3(0.2, 0.4, 0.3); // green top sphere
                if (p.y > -0.45) col = vec3(0.8, 0.7, 0.2); // gold tip
                
                // shading
                col *= 0.5 + 0.5 * cos(p.x * 20.0);
            }
            
            // Decorative cutout in base
            if (length(p - vec2(0.0, -0.8)) < 0.05) col = vec3(0.2);
        }
    }

    // Add vignette
    col *= 1.0 - 0.1 * length(p);

    
    gl_FragColor = vec4(col, 1.0);
}
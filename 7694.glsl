void main() {
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;
    
    vec3 col = vec3(0.0);
    
    // The image is sideways, so we can either rotate the UVs or just draw it as is.
    // Let's draw it as seen (sideways).
    
    // --- Background (Ground) ---
    col = vec3(0.5, 0.5, 0.5); // grey concrete
    
    // Ground pattern (curved grid) - animated flow
    vec2 gp = p * 8.0;
    float pattern = abs(sin(length(fract(gp) - 0.5) * 10.0 - iTime * 2.0));
    pattern = min(pattern, abs(sin((gp.x + gp.y)*5.0 + iTime)));
    col *= 0.8 + 0.2 * pattern;
    
    // Wall on left
    if (p.x < -0.4) {
        col = vec3(0.65, 0.6, 0.55); // beige wall
        col *= 0.8 + 0.2 * sin(p.y * 10.0);
    }

    // --- Green Door ---
    if (p.x < -0.6) {
        col = vec3(0.1, 0.3, 0.15); // dark green
        // door panels
        if (abs(p.x - (-0.8)) < 0.15) {
            float py = fract(p.y * 2.0) - 0.5;
            if (abs(py) < 0.4) {
                // panel inner
                col = vec3(0.15, 0.35, 0.2);
                // white outline
                if (abs(abs(py) - 0.4) < 0.02 || abs(abs(p.x - (-0.8)) - 0.15) < 0.02) {
                    col = vec3(0.8);
                }
            }
        }
    }

    // --- Red Table ---
    // Right side, large red rectangle
    if (p.x > 0.1 && p.y > -0.3 && p.y < 0.8) {
        float dTable = max(abs(p.x - 0.6) - 0.4, abs(p.y - 0.25) - 0.45);
        // rounded corners
        dTable = length(max(abs(vec2(p.x - 0.6, p.y - 0.25)) - vec2(0.3, 0.35), 0.0)) - 0.1;
        
        if (dTable < 0.0) {
            col = vec3(0.7, 0.2, 0.2); // red table
            // table lighting/reflection
            col += 0.2 * smoothstep(0.0, -0.2, dTable) * sin(p.y * 5.0 + p.x * 10.0);
            
            // table legs
            if (p.x > 0.8 && p.y > -0.5 && p.y < -0.3) col = vec3(0.6, 0.15, 0.15); // bottom right leg
            if (p.x > 0.8 && p.y > 0.8 && p.y < 0.9) col = vec3(0.6, 0.15, 0.15); // top right leg
        }
    }

    // --- Chairs ---
    // A function to draw a chair
    // chairs are sideways. Top of chair is pointing left.
    
    // 3 Blue Chairs, 1 Red Chair
    vec2 cPos[4];
    cPos[0] = vec2(-0.1, 0.5); // top blue
    cPos[1] = vec2(-0.2, 0.0); // middle blue
    cPos[2] = vec2(-0.25, -0.5); // bottom blue
    cPos[3] = vec2(-0.5, -0.7); // bottom red
    
    vec3 cCol[4];
    cCol[0] = vec3(0.1, 0.3, 0.8); // blue
    cCol[1] = vec3(0.1, 0.3, 0.8); // blue
    cCol[2] = vec3(0.1, 0.3, 0.8); // blue
    cCol[3] = vec3(0.8, 0.2, 0.2); // red
    
    for (int i = 0; i < 4; i++) {
        vec2 cp = p - cPos[i];
        
        // Chair back
        float dBack = length(max(abs(cp - vec2(-0.1, 0.0)) - vec2(0.15, 0.15), 0.0)) - 0.05;
        // Chair seat
        float dSeat = length(max(abs(cp - vec2(0.2, 0.0)) - vec2(0.1, 0.15), 0.0)) - 0.05;
        
        float dChair = min(dBack, dSeat);
        // Connect them
        float dConn = length(max(abs(cp - vec2(0.05, 0.0)) - vec2(0.05, 0.15), 0.0)) - 0.02;
        dChair = min(dChair, dConn);
        
        if (dChair < 0.0) {
            col = cCol[i];
            
            // White insert in back
            if (cp.x < 0.0 && cp.x > -0.2 && abs(cp.y) < 0.1) {
                col = vec3(0.9);
                // Simple flower pattern (dark dots) - animated pulsing
                float pulse = sin(iTime * 3.0 + float(i) * 1.0) * 0.005;
                if (length(cp - vec2(-0.1, 0.0)) < 0.02 + pulse) col = vec3(0.1);
                if (length(cp - vec2(-0.1, 0.05)) < 0.015 + pulse) col = vec3(0.1);
                if (length(cp - vec2(-0.1, -0.05)) < 0.015 + pulse) col = vec3(0.1);
                if (length(cp - vec2(-0.15, 0.0)) < 0.015 + pulse) col = vec3(0.1);
            }
            
            // Chair legs (extending right)
            if (cp.x > 0.2) {
                // simple lines for legs
            }
            
            // Shading
            col *= 0.7 + 0.3 * smoothstep(0.0, -0.05, dChair);
            if (cp.x > 0.2) col *= 0.8; // seat darker
        }
        
        // Front legs
        if (cp.x > 0.1 && cp.x < 0.4 && abs(cp.y + 0.25) < 0.02) col = cCol[i] * 0.7;
        if (cp.x > 0.1 && cp.x < 0.4 && abs(cp.y - 0.25) < 0.02) col = cCol[i] * 0.7;
    }

    // Add vignette
    col *= 1.0 - 0.1 * length(p);

    
    gl_FragColor = vec4(col, 1.0);
}
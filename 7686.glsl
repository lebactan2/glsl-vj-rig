void main() {
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;
    
    vec3 col = vec3(0.0);
    
    // --- Background ---
    col = vec3(0.8, 0.65, 0.55); // pinkish wall
    
    // Dark red trim at top
    if (p.y > 0.4) {
        col = vec3(0.4, 0.15, 0.15);
    }
    // Grey ceiling above it
    if (p.y > 0.8) {
        col = vec3(0.7);
    }
    
    // Lotus grate in top right
    if (p.x > 0.5 && p.y > 0.4) {
        vec2 gp = p - vec2(0.8, 0.7);
        float isGrate = 0.0;
        // petal curves animated
        float pulse = sin(iTime * 3.0 + length(gp)*10.0) * 0.02;
        if (abs(length(gp - vec2(0.0, -0.2)) - 0.3 + pulse) < 0.02 && gp.y > 0.0) isGrate = 1.0;
        if (abs(length(gp - vec2(-0.2, -0.1)) - 0.2 + pulse) < 0.02) isGrate = 1.0;
        if (abs(length(gp - vec2(0.2, -0.1)) - 0.2 + pulse) < 0.02) isGrate = 1.0;
        
        if (isGrate > 0.0) col = vec3(0.2, 0.4, 0.3); // green metal
    }

    // --- Foreground Roof (Red Tiles) ---
    // Slanted upwards to the right
    float roofLine = -0.5 + p.x * 0.4;
    if (p.y < roofLine) {
        col = vec3(0.6, 0.3, 0.2); // red clay
        
        // Cylinder shapes
        float tx = p.x * 10.0 - p.y * 5.0; // angled UV
        if (fract(tx) < 0.2) col *= 0.5; // gaps
        else {
            // curve shading
            float fx = fract(tx) - 0.5;
            col *= 1.0 - fx*fx*2.0;
        }
        
        // Edges
        if (p.y > roofLine - 0.05) col *= 0.8;
    }

    // --- Central Ornate Feature ---
    
    // White structural base
    float dBase = 1.0;
    // Left curl
    dBase = min(dBase, abs(length(p - vec2(-0.4, -0.6)) - 0.2) - 0.05);
    // Right curl
    dBase = min(dBase, abs(length(p - vec2(0.4, -0.3)) - 0.15) - 0.05);
    // Center block
    dBase = min(dBase, max(abs(p.x - 0.1) - 0.2, abs(p.y - (-0.3)) - 0.15));
    
    // Mask out bottom below roof line
    if (p.y < roofLine - 0.1) dBase = 1.0;
    
    if (dBase < 0.0) {
        col = vec3(0.9); // white plaster
        // shading
        col *= 0.8 + 0.2 * sin(p.y * 20.0 - iTime * 2.0);
        // dirt/ambient occlusion in crevices
        if (dBase > -0.02) col *= 0.6;
    }
    
    // Middle Finial (on top of white base)
    vec2 fp = p - vec2(0.1, -0.1);
    float dFinial = max(abs(fp.x) - 0.15, abs(fp.y) - 0.1); // square base
    dFinial = min(dFinial, length(fp - vec2(0.0, 0.15)) - 0.15); // main sphere
    dFinial = min(dFinial, length(fp - vec2(0.0, 0.35)) - 0.05); // top tip
    
    // left/right flourishes
    dFinial = min(dFinial, max(abs(fp.x) - 0.2, abs(fp.y - 0.15) - 0.05));
    
    if (dFinial < 0.0) {
        col = vec3(0.2, 0.3, 0.2); // dark green base color
        
        // Gold elements
        if (fp.y < -0.05 || fp.y > 0.25 || abs(fp.x) > 0.12) {
            col = vec3(0.8, 0.6, 0.2); // gold
            // Gold details
            if (abs(fp.x) < 0.02) col = vec3(0.9, 0.8, 0.4); // highlight
            if (abs(fp.y - (-0.08)) < 0.02) col *= 0.5; // dark line
        } else {
            // Green sphere shading
            col = vec3(0.2, 0.4, 0.3);
            col *= 1.0 - length(fp - vec2(0.0, 0.15)) * 4.0;
            // add a highlight
            if (length(fp - vec2(-0.05, 0.2)) < 0.03) col = vec3(0.6, 0.8, 0.7);
        }
        
        // Cutout wheel pattern in the square base - animated
        if (fp.y < 0.0 && fp.y > -0.1 && abs(fp.x) < 0.1) {
            float rotTime = iTime * 1.5;
            if (abs(length(fp - vec2(0.0, -0.05)) - 0.04) < 0.01) col = vec3(0.8, 0.7, 0.2);
            if (fract(atan(fp.x, fp.y + 0.05) * 1.27 + rotTime) < 0.1 && length(fp - vec2(0.0, -0.05)) < 0.04) col = vec3(0.8, 0.7, 0.2);
        }
    }

    // Add vignette
    col *= 1.0 - 0.1 * length(p);

    
    gl_FragColor = vec4(col, 1.0);
}
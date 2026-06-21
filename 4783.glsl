void main() {
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    
    // Grid 2 columns, 2 rows
    vec2 gridUV = uv * vec2(2.0, 2.0);
    vec2 cell = floor(gridUV);
    vec2 p = fract(gridUV) * 2.0 - 1.0;
    p.x *= (iResolution.x/2.0) / (iResolution.y/2.0);
    
    vec3 col = vec3(0.95); // White/light blue wall
    if (p.x > 0.6) col = vec3(0.85, 0.9, 0.95); // Right panel
    
    // Floor
    if (p.y < -0.4) {
        col = vec3(0.8, 0.85, 0.9); // Light tiled floor
        if (fract(p.x * 4.0) < 0.05 || fract(p.y * 4.0) < 0.05) col = vec3(0.6);
        // Sweeping reflection on floor
        col += vec3(0.1) * max(0.0, sin(p.x*5.0 - p.y*10.0 + iTime*2.0));
    }
    
    // TV / Painting
    float tv = max(abs(p.x - 0.2) - 0.25, abs(p.y - 0.3) - 0.15);
    if (tv < 0.0) {
        col = vec3(0.2, 0.3, 0.5);
        // Screen flicker/animation
        col += vec3(0.0, 0.1, 0.2) * sin(p.y * 50.0 - iTime * 10.0);
    }
    
    // Potted plant
    if (p.x < -0.7 && p.y < -0.3) col = vec3(0.8); // Pot
    if (p.x < -0.65 && p.y > -0.3 && p.y < 0.1) {
        col = vec3(0.2, 0.6, 0.2); // Leaves
        // Leaves swaying
        if (fract(p.y*10.0+p.x*5.0 + sin(iTime)*0.5) > 0.5) col *= 0.8;
    }
    
    // Furniture - similar black ornate style
    float f = 0.0;
    // Table
    f = max(f, 1.0 - smoothstep(0.0, 0.05, max(abs(p.x - 0.2) - 0.2, abs(p.y + 0.2) - 0.15)));
    // Legs
    f = max(f, 1.0 - smoothstep(0.0, 0.05, max(abs(p.x - 0.05) - 0.05, abs(p.y + 0.3) - 0.15)));
    f = max(f, 1.0 - smoothstep(0.0, 0.05, max(abs(p.x - 0.35) - 0.05, abs(p.y + 0.3) - 0.15)));
    
    if (f > 0.5) col = vec3(0.05); // Black furniture
    
    // White cloth
    if (max(abs(p.x - 0.2) - 0.15, abs(p.y + 0.1) - 0.1) < 0.0) col = vec3(0.9);
    
    // Figure (Black and Gold pattern)
    vec3 figCol = vec3(0.1);
    float goldNoise = fract(sin(p.x*50.0 + p.y*30.0)*43758.5);
    // Animated gold
    if (goldNoise > 0.7) {
        figCol = vec3(0.8, 0.6, 0.1); // Gold accents
        figCol += vec3(0.4) * pow(abs(sin(p.x*20.0 + p.y*20.0 - iTime*4.0)), 4.0); // Shine
    }
    
    // Head
    if (length(p - vec2(-0.3, 0.2)) < 0.1) col = figCol;
    // Body
    float body = max(abs(p.x + 0.3) - 0.12, abs(p.y + 0.05) - 0.25);
    if (body < 0.0) col = figCol;
    
    // Grid borders
    if (max(abs(fract(gridUV.x)-0.5), abs(fract(gridUV.y)-0.5)) > 0.49) col = vec3(1.0);
    
    gl_FragColor = vec4(col, 1.0);
}
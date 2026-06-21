void main() {
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;
    
    vec3 col = vec3(0.8, 0.8, 0.8); // surrounding wall
    
    // Light blue tile section above gate
    if (p.y > 0.3 && abs(p.x) < 0.6) {
        col = vec3(0.6, 0.8, 0.9); // light blue
        // Tiles
        if (fract(p.x * 20.0) < 0.1 || fract(p.y * 20.0) < 0.1) {
            col = vec3(0.5, 0.7, 0.8); // grout
        }
    }
    
    // Scissor Gate section
    if (p.y < 0.3 && abs(p.x) < 0.6) {
        // Dark background behind gate
        col = vec3(0.05, 0.05, 0.05); 
        
        // Gate animation (stretching)
        float stretch = 1.0 + 0.1 * sin(iTime * 2.0);
        vec2 gp = p;
        gp.x *= stretch;
        
        // Scissor lattice
        float diag1 = abs(fract(gp.x * 5.0 + gp.y * 5.0) - 0.5);
        float diag2 = abs(fract(gp.x * 5.0 - gp.y * 5.0) - 0.5);
        float vertical = abs(fract(gp.x * 5.0) - 0.5);
        
        if (diag1 < 0.05 || diag2 < 0.05 || vertical < 0.03) {
            col = vec3(0.85, 0.8, 0.75); // off-white painted metal
            
            // Add some shading to metal
            col *= 0.8 + 0.2 * sin(gp.x * 50.0);
        }
    }
    
    // Right side black pillar / cables
    if (p.x > 0.6) {
        col = vec3(0.2, 0.2, 0.2); // dark wall
        // Cables
        float cable1 = abs(p.x - 0.7 - 0.05 * sin(p.y * 5.0));
        float cable2 = abs(p.x - 0.8 + 0.08 * cos(p.y * 7.0));
        if (cable1 < 0.02 || cable2 < 0.015) {
            col = vec3(0.1);
        }
    }
    
    gl_FragColor = vec4(col, 1.0);
}

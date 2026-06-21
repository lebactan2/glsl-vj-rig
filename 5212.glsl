void main() {
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;
    
    // 1. Sky
    vec3 col = vec3(0.3, 0.5, 0.7); // Deep blue sky
    // Animated clouds
    float clouds = sin(p.x * 3.0 + iTime*0.5 + sin(p.y*5.0)) * cos(p.y*4.0 - iTime*0.2);
    if (p.y > 0.0) col += max(0.0, clouds)*0.2 * smoothstep(0.0, 1.0, p.y);
    
    // 2. Green Construction Building (Top Left)
    float b1 = max(abs(p.x + 0.6) - 1.0, abs(p.y - 0.5) - 0.4);
    if (b1 < 0.0) {
        col = vec3(0.2, 0.5, 0.3); // Green netting
        // Netting grid
        if (fract(p.x * 50.0) < 0.1 || fract(p.y * 50.0) < 0.1) col *= 0.8;
    }
    
    // Crane (Yellow lines above green building, slowly swaying)
    float craneSway = sin(iTime * 0.5) * 0.1;
    // Base
    if (p.x > -0.5 && p.x < -0.4 && p.y > 0.9 && p.y < 1.2) col = vec3(0.9, 0.7, 0.1);
    // Arm
    vec2 cp = p - vec2(-0.45, 0.95);
    float a = craneSway;
    mat2 rotC = mat2(cos(a), -sin(a), sin(a), cos(a));
    vec2 cpr = rotC * cp;
    if (cpr.x > -0.3 && cpr.x < 0.2 && abs(cpr.y) < 0.01) col = vec3(0.9, 0.7, 0.1);
    
    // 3. White Building (Top Right)
    float b2 = max(abs(p.x - 1.2) - 0.4, abs(p.y - 0.4) - 0.5);
    if (b2 < 0.0) {
        col = vec3(0.9); // White wall
        // Windows
        if (fract(p.x * 10.0) < 0.3 && fract(p.y * 10.0) < 0.4 && p.y < 0.8) {
            col = vec3(0.2, 0.3, 0.4); // Glass reflection
            // Window glimmer
            col += max(0.0, sin(p.x*100.0 + iTime*2.0))*0.2;
        }
        // Red sign at top
        if (p.y > 0.8 && p.y < 0.85) col = vec3(0.8, 0.2, 0.2);
    }
    
    // 4. Middle Roof (Brown tiles)
    float roof = max(abs(p.x) - 2.0, abs(p.y - 0.05) - 0.05);
    if (roof < 0.0) {
        col = vec3(0.6, 0.3, 0.2); // Tiled roof color
        // Tile texture
        if (fract(p.x * 30.0) < 0.1) col *= 0.8;
    }
    
    // 5. Beige Buildings / Terrace Walls
    float wall1 = max(abs(p.x) - 2.0, abs(p.y + 0.2) - 0.2);
    if (wall1 < 0.0) {
        col = vec3(0.9, 0.88, 0.8); // Warm beige
        
        // Dark window on the left
        if (p.x > -0.5 && p.x < -0.2 && p.y > -0.3 && p.y < -0.1) col = vec3(0.4, 0.5, 0.6);
        
        // Right side pergola columns
        if (p.x > 0.5) {
            if (fract(p.x * 5.0) > 0.8) col = vec3(0.2); // Dark gaps behind columns
        }
    }
    
    // 6. Terrace Floor (Perspective trapezoid)
    if (p.y < -0.4 && p.y > -0.7) {
        col = vec3(0.8, 0.8, 0.8); // Light concrete
        // Perspective lines
        float floorUvX = p.x / (1.0 + (p.y + 0.4) * 0.5);
        if (fract(floorUvX * 5.0) < 0.02 || fract(p.y * 20.0) < 0.05) col *= 0.95;
        
        // Moving shadows from clouds/sun
        float shadow = sin(p.x * 5.0 + p.y * 10.0 + iTime);
        if (shadow > 0.5) col *= 0.9;
    }
    
    // 7. Balustrade (Foreground wall)
    if (p.y < -0.7) {
        col = vec3(0.85, 0.83, 0.75); // Lighter beige
        
        // Top rail shadow
        if (p.y > -0.72) col *= 0.8;
        
        // Balusters (Pillars)
        if (p.y < -0.75 && p.y > -0.9) {
            float pillar = fract(p.x * 12.0);
            if (pillar > 0.4) {
                // Gap between pillars, show floor/shadow
                col = vec3(0.6, 0.6, 0.6);
            } else {
                // Pillar shading moving slightly
                col *= 0.8 + 0.4 * sin(pillar * 3.14 / 0.4 + sin(iTime)*0.1);
            }
        }
        
        // Bottom decorative band
        if (p.y < -0.92 && p.y > -0.98) {
            col = vec3(0.2, 0.25, 0.3); // Dark blue/grey background
            float pattern = fract(p.x * 20.0 - iTime*0.5) + fract(p.x * 20.0 + p.y*100.0);
            if (pattern > 0.5 && pattern < 1.5) col = vec3(0.8, 0.6, 0.3); // Gold pattern moving
        }
    }

    gl_FragColor = vec4(col, 1.0);
}
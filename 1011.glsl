void main() {
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    // Background: Floor tiles and wall tiles
    vec3 col = vec3(0.6, 0.6, 0.6); // Grey stone floor
    
    // Wall tiles (beige/brown patterned)
    if (p.x < 0.2) {
        col = vec3(0.7, 0.6, 0.4); 
        // Brick/tile pattern
        float tile = step(0.1, fract(p.y * 10.0)) * step(0.1, fract(p.x * 5.0 + step(0.5, fract(p.y * 5.0)) * 0.5));
        col *= mix(0.8, 1.0, tile);
        
        // Wall pattern animation
        float wallAnim = sin(p.x * 20.0 + iTime) * cos(p.y * 20.0 + iTime) * 0.05;
        col += wallAnim;
    } else {
        // Floor tiles (grey stone with arches)
        float floorTile = fract(p.x * 8.0 + p.y * 8.0);
        col *= mix(0.8, 1.0, step(0.1, floorTile));
        
        // Floor pattern animation
        float floorAnim = sin(length(p) * 20.0 - iTime * 2.0) * 0.05;
        col += floorAnim;
    }

    // Chair Shadow
    if (p.x > 0.1 && p.x < 0.8 && p.y > -0.8 && p.y < 0.2) {
        col *= 0.4;
    }

    // Woven blue folding chair
    if (p.x > -0.6 && p.x < 0.4 && p.y > -0.6 && p.y < 0.5) {
        // Metallic frame
        if (abs(p.x + 0.6) < 0.02 || abs(p.x - 0.4) < 0.02 || abs(p.y - 0.5) < 0.02 || abs(p.y + 0.6) < 0.02) {
            col = vec3(0.8, 0.8, 0.85); // Silver metal
            // Shine animation
            float shine = smoothstep(0.0, 0.1, sin((p.x + p.y) * 10.0 + iTime * 3.0));
            col += shine * 0.5;
        } else {
            // Blue woven fabric
            col = vec3(0.1, 0.2, 0.6); // Deep blue
            float weaveX = abs(fract(p.x * 15.0) - 0.5);
            float weaveY = abs(fract(p.y * 15.0) - 0.5);
            
            // Woven texture pattern
            if (weaveX > 0.1 ^^ weaveY > 0.1) {
                col *= 0.8; // Darker overlap
            }
            if (weaveX < 0.05 && weaveY < 0.05) {
                // Holes in the weave revealing background
                if (p.x < 0.2) col = vec3(0.6, 0.5, 0.3);
                else col = vec3(0.5);
            }
        }
    }

    gl_FragColor = vec4(col, 1.0);
}

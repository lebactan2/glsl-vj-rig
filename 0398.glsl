void main() {
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(0.0);
    
    // --- Floor ---
    if (p.y < -0.1) {
        vec2 floorUV = vec2(p.x / (p.y + 0.1), 1.0 / (p.y + 0.1));
        float noise = fract(sin(dot(floorUV, vec2(12.9, 78.2))) * 43758.0);
        float plank = smoothstep(0.4, 0.5, abs(fract(floorUV.x * 2.0) - 0.5));
        
        col = mix(vec3(0.3, 0.15, 0.05), vec3(0.4, 0.2, 0.1), noise*0.5 + plank*0.5);
        col *= smoothstep(-0.1, -0.8, p.y);
    } 
    // --- Ceiling Grid ---
    else if (p.y > 0.4) {
        col = vec3(0.15);
        vec2 ceilUV = vec2(p.x / (1.5 - p.y), 1.0 / (1.5 - p.y));
        if (fract(ceilUV.x * 5.0) < 0.05 || fract(ceilUV.y * 3.0) < 0.05) col = vec3(0.05);
    } 
    else {
        col = vec3(0.1); 
        
        // --- Forest Projection (Background Left) ---
        if (p.x < -0.1 && p.y > 0.1 && p.y < 0.4) {
            float forestNoise = fract(sin(p.x * 50.0 + iTime*0.05) * 43758.0); // Animate trees
            if (forestNoise < 0.3) col = vec3(0.2, 0.4, 0.2) * (0.5 + forestNoise);
            else col = vec3(0.15, 0.2, 0.15);
        }
        
        // --- Glowing Screens (Middle) ---
        if (p.y > -0.1 && p.y < 0.2 && p.x > -0.7 && p.x < 0.5) {
            float screenId = floor((p.x + 0.7) * 8.0);
            float screenLocalX = fract((p.x + 0.7) * 8.0);
            
            if (screenLocalX > 0.1 && screenLocalX < 0.9) {
                // Wave animation on screens
                float wave = sin(screenLocalX * 10.0 + iTime * (2.0 + iMid * 4.0) + screenId) * (0.05 + iBass * 0.25);
                if (p.y < 0.05 + wave) {
                    col = mix(vec3(0.2, 0.5, 0.8), vec3(0.6, 0.8, 0.9), p.y*10.0);
                } else {
                    col = vec3(0.1, 0.2, 0.4);
                }
                col += vec3(0.2) + iLevel * 0.6; // screen glow (audio-reactive)
            }
        }
        
        // --- Right Wooden Sculpture ---
        if (p.x > 0.5 && p.y > -0.2 && p.y < 0.3) {
            col = vec3(0.3, 0.15, 0.05);
            // wood grain
            float grain = fract(sin(p.x * 50.0 + p.y * 10.0) * 43758.0);
            col *= 0.8 + 0.2 * grain;
        }
    }
    
    gl_FragColor = vec4(col, 1.0);
}

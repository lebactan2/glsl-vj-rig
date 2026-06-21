void main() {
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    // Background: Dark motorcycle body
    vec3 col = vec3(0.05, 0.05, 0.05); 
    
    // Chrome exhaust
    if (p.x > 0.1 && p.x < 0.8 && p.y > -0.8 && p.y < 0.5) {
        // Angled exhaust shape
        float exhaustDist = abs((p.x - 0.4) - (p.y + 0.1) * 0.5);
        if (exhaustDist < 0.2) {
            col = vec3(0.7, 0.75, 0.8); // Chrome base
            
            // Chrome reflection bands
            float reflection = sin(p.x * 20.0 + p.y * 10.0) * 0.2 + 0.8;
            col *= reflection;
            
            // Chrome shine animation
            float shine = smoothstep(0.4, 0.6, sin(p.y * 5.0 - iTime * 4.0));
            col += shine * 0.3;
            
            // Exhaust dark holes/details
            if (abs(p.y - 0.2) < 0.05 || abs(p.y + 0.3) < 0.05) {
                col = vec3(0.1);
            }
        }
    }

    // Suspension spring
    if (p.x > -0.4 && p.x < 0.1 && p.y > -0.2 && p.y < 0.4) {
        float springDist = abs(p.x + 0.15);
        if (springDist < 0.1) {
            col = vec3(0.1, 0.1, 0.1); // Inner dark rod
            
            // The coiled spring
            float coil = fract(p.y * 12.0) - 0.5;
            if (abs(coil) < 0.15) {
                col = vec3(0.3, 0.3, 0.35); // Metal spring
                // Spring highlight
                float highlight = smoothstep(0.0, 0.1, abs(coil));
                col += highlight * 0.2;
            }
        }
    }

    // Carbon fiber texture plates
    if (p.x > -0.2 && p.x < 0.2 && p.y > 0.2 && p.y < 0.6) {
        col = vec3(0.6, 0.6, 0.65); // Silverish plate
        
        // Carbon fiber / checkered pattern
        float cfPattern = step(0.5, fract(p.x * 40.0 + p.y * 40.0)) * step(0.5, fract(p.x * 40.0 - p.y * 40.0));
        cfPattern += step(0.5, fract(p.x * 40.0 + p.y * 40.0 + 0.5)) * step(0.5, fract(p.x * 40.0 - p.y * 40.0 + 0.5));
        
        col *= mix(0.7, 1.0, cfPattern);
        
        // Plate animation
        float plateAnim = sin(p.x * 10.0 + p.y * 10.0 + iTime) * 0.05;
        col += plateAnim;
    }

    gl_FragColor = vec4(col, 1.0);
}

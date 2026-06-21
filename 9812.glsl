void main() {
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;
    
    vec3 col = vec3(0.0);
    
    // --- Background (Wood Panels) ---
    col = vec3(0.45, 0.35, 0.25); // brown wood
    
    // Vertical planks
    float planks = fract(p.x * 2.0);
    if (planks < 0.02) col *= 0.5; // gap between planks
    
    // Wood grain (vertical noise)
    float grain = fract(sin(p.x * 50.0 + iTime * 0.1) * 43758.5453 + p.y * 2.0 - iTime * 0.5);
    col *= 0.8 + 0.2 * grain;

    // --- Left Objects ---
    // Picture frame top left
    if (p.x < -0.6 && p.y > 0.2) {
        col = vec3(0.85, 0.85, 0.8); // off-white paper
        if (p.x < -0.9 || p.y < 0.25) col = vec3(0.4, 0.3, 0.2); // frame
        // shoe drawing
        if (p.x > -0.85 && p.x < -0.65 && p.y > 0.6 && p.y < 0.8) {
            col = vec3(0.6); // grey shoe
        }
    }
    
    // Leather trunks bottom left
    if (p.x < -0.4 && p.y < 0.2) {
        col = vec3(0.4, 0.25, 0.15); // brown leather
        // edges/straps
        if (p.y > 0.15) col = vec3(0.3, 0.2, 0.1);
        if (p.x > -0.45) col = vec3(0.3, 0.2, 0.1);
        // rivets
        if (length(vec2(p.x + 0.5, p.y + 0.1)) < 0.02) col = vec3(0.8, 0.7, 0.5); // gold rivet
        if (length(vec2(p.x + 0.5, p.y - 0.1)) < 0.02) col = vec3(0.8, 0.7, 0.5);
    }

    // --- Bottom Surface ---
    if (p.y < -0.6) {
        col = vec3(0.2, 0.25, 0.25); // dark grey/green trunk top
        // edge with rivets
        if (p.y > -0.65 && p.y < -0.6) {
            col = vec3(0.15); // black strap
            // rivets along edge
            if (fract(p.x * 5.0) < 0.1) col = vec3(0.7, 0.7, 0.75); // silver rivet
        }
    }

    // --- Center Wood Wheel Object ---
    
    // Base block
    float dBase = max(abs(p.x) - 0.25, abs(p.y + 0.4) - 0.1);
    if (dBase < 0.0) {
        col = vec3(0.25, 0.15, 0.1); // dark brown wood base
        col *= 0.8 + 0.2 * fract(sin(p.x * 20.0)*10.0 + iTime*0.5); // simple grain animated
        
        // Top reflection/highlight
        if (p.y > -0.32) col = mix(col, vec3(0.5, 0.4, 0.3), 0.5);
    }
    
    // Metal rod
    if (abs(p.x) < 0.02 && p.y > -0.3 && p.y < -0.15) {
        col = vec3(0.5, 0.5, 0.5); // silver/grey metal
    }
    
    // Wood Wheel
    float wheelDist = length(p - vec2(0.0, 0.1));
    if (wheelDist < 0.35) {
        // Central hole
        if (wheelDist < 0.04) {
            col = vec3(0.1); // dark hole
        } else {
            col = vec3(0.4, 0.3, 0.2); // aged wood color
            
            // Rough edge / uneven circle
            float edgeNoise = sin(atan(p.y - 0.1, p.x) * 10.0) * 0.02 + sin(atan(p.y - 0.1, p.x) * 3.0) * 0.03;
            if (wheelDist > 0.35 + edgeNoise) {
                // mask out to make rough
            } else {
                // Horizontal cracks and grain - animated
                float grain2 = fract(sin(p.y * 30.0 + iTime * 0.5) * 43758.5453 + p.x * 2.0 - iTime);
                col *= 0.7 + 0.3 * grain2;
                
                // Deep cracks - animated
                if (fract(p.y * 12.0 + sin(p.x*5.0 - iTime)*0.1) < 0.05) col *= 0.4;
                if (abs(p.y - 0.1) < 0.01 && abs(p.x) > 0.1) col *= 0.3; // major crack
                
                // Shading for volume
                col *= 0.5 + 0.5 * smoothstep(0.35, 0.0, wheelDist); // darker at edges
                // light from top
                col += vec3(0.1, 0.1, 0.0) * max(0.0, p.y - 0.1);
            }
        }
    }

    // Add vignette
    col *= 1.0 - 0.2 * length(p);

    
    gl_FragColor = vec4(col, 1.0);
}
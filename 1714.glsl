void main() {
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    // Background: Bright white wall and sunny street
    vec3 col = vec3(0.95, 0.95, 0.95); 
    
    // Left side: Storefront/Alley
    if (p.x < 0.0) {
        // Darker area
        col = vec3(0.6, 0.6, 0.6); 
        
        // Person walking/standing
        vec2 mcP = p - vec2(-0.5, -0.4);
        
        // Torso
        if (length(max(abs(mcP) - vec2(0.15, 0.2), 0.0)) < 0.05) col = vec3(0.6, 0.4, 0.2); // Brown shirt
        // Head
        if (length(mcP - vec2(0.0, 0.3)) < 0.1) {
            col = vec3(0.9, 0.8, 0.7); // Skin
            // Mask
            if (mcP.y < 0.28 && mcP.x > 0.0) col = vec3(0.9, 0.9, 0.95);
        }
        
        // Motorcycle parked
        vec2 bikeP = p - vec2(-0.2, -0.6);
        // Yellow body
        if (length(max(abs(bikeP) - vec2(0.2, 0.15), 0.0)) < 0.05) col = vec3(0.85, 0.85, 0.2);
        // Blue helmet
        if (length(bikeP - vec2(-0.15, 0.25)) < 0.1) {
            col = vec3(0.1, 0.3, 0.8);
            if (bikeP.y > 0.28 && abs(bikeP.x + 0.15) < 0.02) col = vec3(1.0); // Stripe
        }
        // Wheels
        if (length(bikeP - vec2(-0.2, -0.15)) < 0.12) col = vec3(0.1);
        if (length(bikeP - vec2(0.3, -0.15)) < 0.12) col = vec3(0.1);
        
        // Overhang shadow
        if (p.y > 0.6) col = mix(col, vec3(0.2, 0.2, 0.25), 0.6); 
    } 
    // Right side: White wall with patterned vent
    else {
        col = vec3(0.9, 0.9, 0.92); 
        
        // Grunge/Texture on wall
        float grunge = fract(sin(p.x*100.0)*cos(p.y*100.0)*437.5);
        if (grunge > 0.8) col *= 0.95;
        
        // Large vertical crack
        float crackX = 0.8 + sin(p.y*10.0)*0.02 + cos(p.y*30.0)*0.01;
        if (abs(p.x - crackX) < 0.01) col = vec3(0.2, 0.2, 0.2); 
        
        // Decorative Vent Block
        if (abs(p.x - 0.4) < 0.35 && abs(p.y) < 0.35) {
            // Shadow behind vent
            col = vec3(0.1, 0.1, 0.15); 
            
            // Grid for the 4 sections
            vec2 vP = fract((p - vec2(0.05, -0.35)) * vec2(1.428, 1.428)) - 0.5;
            
            // 4 semi-circles forming a petal/cross pattern in each cell
            float h1 = length(vP - vec2(-0.5, -0.5));
            float h2 = length(vP - vec2(0.5, -0.5));
            float h3 = length(vP - vec2(-0.5, 0.5));
            float h4 = length(vP - vec2(0.5, 0.5));
            
            // Animating the hole size slightly
            float holeSize = 0.4 + 0.05 * sin(iTime * 2.0);
            
            // Solid part of the block
            if (h1 > holeSize && h2 > holeSize && h3 > holeSize && h4 > holeSize) {
                col = vec3(0.9, 0.9, 0.9); // White painted concrete
                
                // Bevel/Shadows on the vent pattern
                float d1 = min(min(h1, h2), min(h3, h4));
                if (d1 < holeSize + 0.03) col *= 0.7; // Inner shadow
                
                // Cross indent lines
                if (abs(vP.x) < 0.02 || abs(vP.y) < 0.02) col *= 0.85;
            }
            
            // Outer frame of the vent
            if (max(abs(p.x - 0.4), abs(p.y)) > 0.33) {
                col = vec3(0.9, 0.9, 0.9);
                if (max(abs(p.x - 0.4), abs(p.y)) > 0.34) col *= 0.8; // Bevel
            }
        }
    }

    gl_FragColor = vec4(col, 1.0);
}
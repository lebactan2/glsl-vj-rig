void main() {
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(0.05, 0.05, 0.08); 
    
    float tilt = p.x * 0.1; 
    vec2 tp = vec2(p.x, p.y + tilt);
    float signBoxTilted = length(max(abs(tp) - vec2(0.7, 0.4), 0.0)) - 0.02;

    if (signBoxTilted < 0.0) {
        col = mix(vec3(0.9, 0.8, 0.1), vec3(1.0, 0.9, 0.3), tp.y + 0.4); 
        
        #define segment(p, a, b) length(p - a - (b - a) * clamp(dot(p - a, b - a) / dot(b - a, b - a), 0.0, 1.0))
        
        // Top text "A LỘC" (Red)
        vec2 rText = tp - vec2(-0.4, 0.2);
        float dR = 1.0;
        // A
        dR = min(dR, segment(rText, vec2(-0.1, -0.08), vec2(-0.05, 0.08)));
        dR = min(dR, segment(rText, vec2(-0.05, 0.08), vec2(0.0, -0.08)));
        dR = min(dR, segment(rText, vec2(-0.07, 0.0), vec2(-0.03, 0.0)));
        // L
        dR = min(dR, segment(rText, vec2(0.1, 0.08), vec2(0.1, -0.08)));
        dR = min(dR, segment(rText, vec2(0.1, -0.08), vec2(0.18, -0.08)));
        // O
        dR = min(dR, abs(length(rText - vec2(0.3, 0.0)) - 0.06));
        // C
        float cDist = length(rText - vec2(0.5, 0.0));
        if (cDist < 0.06 && rText.x < 0.52) dR = min(dR, abs(cDist - 0.06));
        
        if (dR < 0.015) {
            col = vec3(0.9, 0.1, 0.1);
            // Glowing core
            if (dR < 0.005) col = vec3(1.0, 0.5, 0.5);
        }

        // Bottom text "CHÁO LÒNG" (Blue)
        vec2 bText = tp - vec2(-0.4, -0.1);
        float dB = 1.0;
        // C
        float c2Dist = length(bText - vec2(-0.1, 0.0));
        if (c2Dist < 0.06 && bText.x < -0.08) dB = min(dB, abs(c2Dist - 0.06));
        // H
        dB = min(dB, segment(bText, vec2(0.05, 0.08), vec2(0.05, -0.08)));
        dB = min(dB, segment(bText, vec2(0.15, 0.08), vec2(0.15, -0.08)));
        dB = min(dB, segment(bText, vec2(0.05, 0.0), vec2(0.15, 0.0)));
        // A
        dB = min(dB, segment(bText, vec2(0.2, -0.08), vec2(0.25, 0.08)));
        dB = min(dB, segment(bText, vec2(0.25, 0.08), vec2(0.3, -0.08)));
        // O
        dB = min(dB, abs(length(bText - vec2(0.45, 0.0)) - 0.06));

        if (dB < 0.015) {
            col = vec3(0.1, 0.2, 0.8);
            if (dB < 0.005) col = vec3(0.4, 0.6, 1.0);
        }
        
        // Border of sign
        if (abs(signBoxTilted) < 0.01) col = vec3(0.8, 0.2, 0.2);
    }
    
    // Background Street Elements
    if (signBoxTilted > 0.0) {
        // Detailed Tree Bark
        if (p.x < -0.75) {
            col = vec3(0.15, 0.1, 0.05);
            float bark = sin(p.y * 60.0 + sin(p.x * 30.0)*15.0);
            col *= 0.7 + 0.3 * bark;
        }
        
        // Neon Sign Reflections in background
        float neonGlow = exp(-length(p - vec2(0.5, -0.7)) * 2.0);
        col += vec3(0.0, 0.5, 0.2) * neonGlow * (sin(iTime * 10.0) * 0.2 + 0.8);
        
        float neonGlow2 = exp(-length(p - vec2(-0.2, -0.8)) * 3.0);
        col += vec3(0.8, 0.2, 0.2) * neonGlow2;
    }

    gl_FragColor = vec4(col, 1.0);
}

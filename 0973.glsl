void main() {
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;
    
    vec3 col = vec3(0.0);
    
    if (p.x < -0.8 || p.x > 0.8 || p.y > 0.6) {
        col = vec3(0.6, 0.7, 0.7); 
        if (p.y > 0.6 && length(vec2(p.x, p.y - 0.6)) < 0.9) col = vec3(0.5, 0.6, 0.6);
        // Add subtle texture
        col += 0.05 * sin(p.x*100.0) * sin(p.y*100.0);
    } else {
        col = vec3(0.2, 0.2, 0.15); // dark background behind gate
        
        // Floor tile animation
        if (p.y < -0.6) {
            // Perspective floor
            vec2 st = vec2(p.x / (p.y + 0.61), 1.0 / (p.y + 0.61));
            st.y += iTime * 0.5; // moving floor
            float tile = step(0.1, fract(st.x * 2.0)) * step(0.1, fract(st.y * 2.0));
            col = mix(vec3(0.3), vec3(0.5, 0.55, 0.5), tile);
        }
        
        // Gate pattern
        if (p.y > -0.6 && p.y < 0.6) {
            // Animate gate bars slightly
            float sway = sin(p.y * 3.0 + iTime) * 0.02;
            float px = p.x + sway;
            
            float bars = abs(fract(px * 8.0) - 0.5);
            float hbars = abs(fract(p.y * 10.0) - 0.5);
            vec2 cell = vec2(fract(px * 4.0) - 0.5, fract(p.y * 4.0) - 0.5);
            
            // Animate circles size
            float circleSize = 0.3 + 0.05 * sin(iTime * 2.0 + p.y * 5.0);
            float circles = abs(length(cell) - circleSize);
            
            if (bars < 0.03 || hbars < 0.02 || circles < 0.04) {
                col = vec3(0.7, 0.7, 0.6); // gate color
                col *= 0.5 + 0.5 * sin(px * 50.0); // metallic shine
            }
        }
        
        // Objects (red and blue)
        float redPulse = 1.0 + 0.1 * sin(iTime * 5.0);
        if (length(p - vec2(-0.5, -0.7)) < 0.1 * redPulse) col = vec3(0.8, 0.1, 0.1);
        float bluePulse = 1.0 + 0.1 * cos(iTime * 4.0);
        if (length(p - vec2(0.3, -0.6)) < 0.08 * bluePulse) col = vec3(0.1, 0.2, 0.8);
    }
    
    gl_FragColor = vec4(col, 1.0);
}

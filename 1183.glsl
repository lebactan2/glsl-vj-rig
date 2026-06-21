void main() {
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    // Background: Roller door
    vec3 col = vec3(0.85, 0.85, 0.8); // Beige/light yellow metal
    
    // Vertical grooves of the roller door
    float grooves = fract(p.x * 20.0);
    if (grooves < 0.2) col *= 0.7; // Shadow in groove
    if (grooves > 0.8) col *= 1.1; // Highlight
    
    // Roller door aging/dirt
    float dirt = fract(sin(p.x * 50.0 + p.y * 30.0) * 43758.5);
    col *= mix(0.9, 1.0, dirt);

    // Posters
    // Poster 1
    if (p.x > -0.6 && p.x < -0.2 && p.y > 0.0 && p.y < 0.6) {
        col = vec3(0.95); // White paper
        // Text lines "CHO THUÊ NHÀ"
        float textY = fract(p.y * 10.0);
        if (textY > 0.2 && textY < 0.8 && p.x > -0.55 && p.x < -0.25) {
            float textX = fract(p.x * 20.0);
            if (textX > 0.2 && textX < 0.8) col = vec3(0.1); // Black text
        }
        // Torn edge animation
        float tear = sin(p.y * 50.0) * 0.02;
        if (p.x < -0.6 + tear || p.x > -0.2 - tear) col = vec3(0.85, 0.85, 0.8); // Reveal background
    }
    
    // Poster 2
    if (p.x > -0.1 && p.x < 0.3 && p.y > -0.3 && p.y < 0.2) {
        col = vec3(0.95);
        // Text lines
        float textY = fract(p.y * 8.0);
        if (textY > 0.2 && textY < 0.8 && p.x > -0.05 && p.x < 0.25) {
            float textX = fract(p.x * 15.0);
            if (textX > 0.2 && textX < 0.8) col = vec3(0.1);
        }
    }
    
    // Poster 3
    if (p.x > -0.7 && p.x < -0.3 && p.y > -0.8 && p.y < -0.2) {
        col = vec3(0.92);
        // Text lines
        float textY = fract(p.y * 12.0);
        if (textY > 0.2 && textY < 0.8 && p.x > -0.65 && p.x < -0.35) {
            float textX = fract(p.x * 25.0);
            if (textX > 0.2 && textX < 0.8) col = vec3(0.15);
        }
        // Paper flutter animation
        float flutter = sin(p.y * 10.0 + iTime * 2.0) * 0.05 + 0.95;
        col *= flutter;
    }

    // Scooter handle on the right
    if (p.x > 0.5 && p.y < -0.2) {
        // Scooter body
        float bodyDist = length(p - vec2(0.8, -0.6));
        if (bodyDist < 0.4) {
            col = vec3(0.15); // Black plastic
            float shine = smoothstep(0.3, 0.4, sin(p.x * 10.0 + p.y * 10.0));
            col += shine * 0.2;
        }
        
        // Handlebar
        float handleDist = abs(p.y - (-p.x * 0.5 + 0.1));
        if (handleDist < 0.05 && p.x > 0.6 && p.x < 0.9 && p.y > -0.4 && p.y < -0.1) {
            col = vec3(0.1); // Rubber grip
            float grip = fract(p.x * 40.0);
            if (grip < 0.5) col *= 0.8;
        }
    }

    gl_FragColor = vec4(col, 1.0);
}
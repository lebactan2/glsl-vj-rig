void main() {
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    // Background: Wooden floor
    vec3 col = vec3(0.6, 0.45, 0.3); 
    
    // Wood planks
    float planks = fract(p.x * 5.0 + p.y * 2.0);
    if (planks < 0.05) col *= 0.6; // Plank gap
    
    // Wood grain
    float grain = sin(p.x * 50.0 + sin(p.y * 20.0) * 10.0);
    col *= mix(0.9, 1.1, grain * 0.1 + 0.5);

    // Wrapped motorcycle
    // Main body wrapped in cardboard
    if (p.x > -0.4 && p.x < 0.6 && p.y > -0.5 && p.y < 0.4) {
        col = vec3(0.75, 0.6, 0.45); // Cardboard brown
        
        // Cardboard corrugation texture
        float corrugation = abs(fract((p.x + p.y) * 20.0) - 0.5);
        if (corrugation < 0.1) col *= 0.9;
        
        // Clear tape reflections
        float tape = smoothstep(0.4, 0.5, sin(p.x * 30.0 - p.y * 20.0 + iTime));
        col += tape * 0.15; // Shiny tape
        
        // Printed text on box (GROW / SAIGON LAGER abstract)
        if (p.x > -0.1 && p.x < 0.2 && p.y > -0.1 && p.y < 0.1) {
            float text = step(0.5, fract(p.x * 15.0)) * step(0.5, fract(p.y * 10.0));
            col = mix(col, vec3(0.8, 0.2, 0.2), text * 0.8); // Red text
        }
        if (p.x > 0.2 && p.x < 0.5 && p.y > 0.1 && p.y < 0.3) {
            float text = step(0.5, fract(p.x * 20.0)) * step(0.5, fract(p.y * 15.0));
            col = mix(col, vec3(0.1, 0.4, 0.8), text * 0.8); // Blue text
        }
    }
    
    // Front wheel sticking out
    float wheelDist = length(p - vec2(0.6, -0.4));
    if (wheelDist < 0.2) {
        col = vec3(0.1); // Black tire
        float rimDist = length(p - vec2(0.6, -0.4));
        if (rimDist < 0.12) {
            col = vec3(0.5); // Silver rim
            // Rim spokes
            float angle = atan(p.y + 0.4, p.x - 0.6);
            float spokes = sin(angle * 5.0);
            if (spokes > 0.8) col = vec3(0.3);
        }
    }
    
    // Back part wrapping
    if (p.x > -0.8 && p.x < -0.3 && p.y > 0.0 && p.y < 0.5) {
        col = vec3(0.9, 0.9, 0.9); // White/blue wrapping paper
        float pattern = step(0.5, fract(p.x * 10.0 + p.y * 10.0));
        col *= mix(vec3(1.0), vec3(0.2, 0.4, 0.8), pattern * 0.5); // Blue accents
        
        // Tape reflection
        float tape = smoothstep(0.4, 0.5, sin(p.x * 20.0 - p.y * 10.0 + iTime * 1.5));
        col += tape * 0.2;
    }

    gl_FragColor = vec4(col, 1.0);
}
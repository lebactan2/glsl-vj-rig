void main() {
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    // Background: Bright white/studio
    vec3 col = vec3(1.0); 
    
    // Kite shape definition
    // Rotate 45 degrees
    float a = 3.14159 / 4.0;
    vec2 rp = vec2(p.x * cos(a) - p.y * sin(a), p.x * sin(a) + p.y * cos(a));
    
    // Main square/diamond
    float diamond = length(max(abs(rp - vec2(0.0, 0.2)) - vec2(0.6, 0.6), 0.0));
    
    if (diamond < 0.01) {
        // Base color (Green)
        col = vec3(0.3, 0.7, 0.5); 
        
        // Color blocking
        // Top Left (Orange)
        if (p.x < 0.0 && p.y > 0.2) col = vec3(0.9, 0.5, 0.1);
        
        // Top Right (Yellow)
        if (p.x > 0.0 && p.y > 0.2) col = vec3(0.95, 0.85, 0.1);
        
        // Central Top Triangle (Yellow/Green mix area)
        // Adjusting boundaries to match image pattern
        if (p.y > abs(p.x) * 0.8 + 0.2 && p.y > 0.4) {
             col = vec3(0.9, 0.8, 0.1); // Inner yellow
             if(p.y > 0.6) col = vec3(0.9, 0.5, 0.1); // Tip orange
        }
        
        // Paper texture (crinkles and folds)
        float paper1 = sin(rp.x * 50.0 + rp.y * 30.0) * 0.02;
        float paper2 = cos(rp.x * 20.0 - rp.y * 40.0) * 0.03;
        float crinkle = abs(paper1 * paper2) * 50.0;
        
        // Animation: Wind causing paper to ripple
        float wind = sin(p.x * 10.0 + p.y * 5.0 + iTime * 4.0) * 0.05;
        
        col *= 0.9 + crinkle + wind;
        
        // Structure/Sticks
        // Center vertical stick
        float stickV = abs(p.x);
        if (stickV < 0.01 && p.y > -0.6 && p.y < 0.8) {
            col = vec3(0.8, 0.7, 0.5); // Bamboo color
            col *= 0.8 + 0.2 * sin(p.y * 100.0); // Bamboo nodes
        }
        
        // Curved horizontal stick (bow)
        // Equation of a downward opening parabola: y = -a*x^2 + k
        float arcY = -0.8 * (p.x * p.x) + 0.6;
        float stickH = abs(p.y - arcY);
        if (stickH < 0.01 && abs(p.x) < 0.6) {
            col = vec3(0.8, 0.7, 0.5);
            col *= 0.8 + 0.2 * sin(p.x * 100.0);
        }
    }
    
    // Bottom tail triangle (Brown)
    float tailV1 = abs(p.x) * 1.5 - 0.2; // side edges
    float tailY = p.y + 0.8; // bottom edge
    float tailTop = p.y + 0.6; // top connection to kite
    
    if (tailV1 < tailY && tailY > 0.0 && tailTop < 0.0) {
        col = vec3(0.35, 0.25, 0.25); // Dark brown
        
        // Folds in tail
        float tailFolds = sin(p.x * 40.0) * 0.1;
        // Animation: Tail flapping
        float flap = sin(p.x * 20.0 + iTime * 10.0) * 0.1;
        col *= 0.8 + tailFolds + flap;
    }

    // Subtle drop shadow
    float shadow = length(max(abs(rp - vec2(-0.02, 0.18)) - vec2(0.6, 0.6), 0.0));
    if (shadow < 0.05 && diamond > 0.01) {
        col = mix(col, vec3(0.8), 0.5 * (1.0 - shadow / 0.05));
    }

    gl_FragColor = vec4(col, 1.0);
}
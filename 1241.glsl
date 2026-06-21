void main() {
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    // Background: Ground/floor texture
    vec3 col = vec3(0.55, 0.5, 0.45); 
    
    // Add dirt/grime to floor
    float dirt = fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
    col *= 0.8 + 0.2 * dirt;

    // Chair structure
    // Seat
    float seat = length(max(abs(p - vec2(0.0, -0.1)) - vec2(0.4, 0.2), 0.0)) - 0.05;
    if (seat < 0.0) {
        col = vec3(0.7, 0.7, 0.7); // Light grey plastic
        // Plastic texture
        col *= 0.9 + 0.1 * fract(sin(p.x * 50.0) * 43758.5);
    }
    
    // Backrest
    float backrest = length(max(abs(p - vec2(0.0, 0.4)) - vec2(0.35, 0.3), 0.0)) - 0.05;
    if (backrest < 0.0) {
        col = vec3(0.7, 0.7, 0.7);
        // Slits in backrest
        if (abs(fract(p.y * 5.0) - 0.5) > 0.4 && abs(p.x) < 0.25) col = vec3(0.55, 0.5, 0.45);
    }

    // Legs
    float legs = length(max(abs(vec2(abs(p.x) - 0.35, p.y + 0.6)) - vec2(0.05, 0.3), 0.0)) - 0.02;
    if (legs < 0.0) {
        col = vec3(0.65, 0.65, 0.65);
    }

    // License Plate
    // Rotate plate
    float a = -0.2;
    vec2 rp = vec2(p.x * cos(a) - p.y * sin(a), p.x * sin(a) + p.y * cos(a));
    
    float plate = length(max(abs(rp - vec2(-0.2, 0.1)) - vec2(0.3, 0.15), 0.0)) - 0.02;
    if (plate < 0.0) {
        // Blue plate background
        col = vec3(0.1, 0.2, 0.7); 
        
        // White border
        float border = length(max(abs(rp - vec2(-0.2, 0.1)) - vec2(0.28, 0.13), 0.0)) - 0.01;
        if (border > 0.0) col = vec3(0.9);
        
        // Text animation on plate (flowing highlight)
        float textLine1 = length(max(abs(rp - vec2(-0.2, 0.15)) - vec2(0.2, 0.03), 0.0));
        float textLine2 = length(max(abs(rp - vec2(-0.2, 0.05)) - vec2(0.2, 0.03), 0.0));
        
        if (textLine1 < 0.01 || textLine2 < 0.01) {
            col = vec3(0.9); // White text
            
            // Animation: shimmering effect on text
            float shimmer = sin(rp.x * 20.0 - iTime * 3.0) * 0.5 + 0.5;
            col += vec3(0.2) * shimmer;
        }
        
        // String holding plate
        float string1 = length(max(abs(p - vec2(-0.4, 0.2)) - vec2(0.01, 0.1), 0.0));
        if(string1 < 0.005) col = vec3(0.2, 0.5, 0.8);
    }
    
    // Add overall dirt/wear to chair
    if (seat < 0.0 || backrest < 0.0) {
         float wear = smoothstep(0.4, 0.6, fract(sin(p.x * 12.0 + p.y * 34.0) * 43758.5));
         col *= 1.0 - 0.2 * wear;
    }

    // Vignette
    col *= 1.0 - 0.3 * length(p);

    gl_FragColor = vec4(col, 1.0);
}
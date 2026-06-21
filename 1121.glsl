void main() {
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    // Background: Dark poster with text
    vec3 col = vec3(0.1, 0.1, 0.15); // Dark blue/grey poster
    
    // Abstract poster content (red car)
    if (p.x < 0.0 && p.y > -0.4 && p.y < 0.4) {
        col = mix(col, vec3(0.6, 0.1, 0.1), smoothstep(0.4, 0.0, abs(p.y))); // Car gradient
    }

    // Abstract text lines on the poster
    if (p.x > 0.0 && p.x < 0.3 && p.y > -0.2 && p.y < 0.4) {
        float textLines = step(0.5, fract(p.y * 20.0));
        col = mix(col, vec3(0.8), textLines * 0.5);
    }

    // Street ground
    if (p.y < -0.4) {
        col = vec3(0.5, 0.5, 0.45); // Gravel/pavement
        float gravel = fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
        col -= gravel * 0.1;
    }

    // Red scooter and rider
    if (p.x > 0.0 && p.y < -0.2) {
        // Red scooter body
        if (p.y > -0.6 && p.y < -0.3 && p.x > 0.2 && p.x < 0.8) {
            col = vec3(0.7, 0.1, 0.1); 
            // Shiny reflection on scooter
            float shine = smoothstep(0.4, 0.5, sin(p.x * 10.0 + p.y * 10.0 + iTime * 3.0));
            col += shine * 0.2;
        }
        
        // Rider (grey shirt, white helmet, blue mask)
        if (p.x > 0.3 && p.x < 0.6 && p.y > -0.3 && p.y < 0.2) {
            col = vec3(0.4, 0.4, 0.42); // Grey shirt
            // Fabric folds animation
            float folds = sin(p.x * 15.0 - p.y * 10.0 + iTime) * 0.05;
            col += folds;
            
            // Helmet (white)
            if (p.y > 0.0 && length(p - vec2(0.45, 0.1)) < 0.1) {
                col = vec3(0.9);
            }
            // Mask (light blue)
            if (p.y > 0.0 && p.y < 0.1 && p.x > 0.45 && p.x < 0.55) {
                col = vec3(0.6, 0.8, 1.0);
            }
        }
    }

    gl_FragColor = vec4(col, 1.0);
}

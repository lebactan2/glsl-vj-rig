void main() {
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    // Background: Asphalt/Road
    vec3 col = vec3(0.45, 0.45, 0.45); 
    float roadNoise = fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
    col -= roadNoise * 0.1;

    // Motorcycle tail light and license plate
    if (p.x > 0.3 && p.y > 0.2) {
        col = vec3(0.1); // Black plastic
        
        // Red tail light
        if (p.x > 0.4 && p.x < 0.6 && p.y > 0.3 && p.y < 0.8) {
            col = vec3(0.7, 0.1, 0.1); // Red light
            // Faceted reflector pattern
            float reflector = step(0.5, fract(p.x * 15.0)) * step(0.5, fract(p.y * 15.0));
            col *= mix(0.7, 1.2, reflector);
            
            // Light pulsing animation
            float pulse = sin(iTime * 2.0) * 0.1 + 0.9;
            col *= pulse;
        }
        
        // License plate (white with black text)
        if (p.x > 0.6 && p.x < 0.9 && p.y > 0.3 && p.y < 0.9) {
            col = vec3(0.9, 0.9, 0.95); // White plate
            
            // Abstract text shapes
            float textMask = step(0.8, fract(p.x * 8.0)) * step(0.2, fract(p.y * 5.0));
            if (textMask > 0.5 && p.x > 0.65 && p.x < 0.85 && p.y > 0.4 && p.y < 0.8) {
                col = vec3(0.1);
            }
        }
    }

    // Patterned trousers leg
    if (p.x > -0.8 && p.x < 0.4 && p.y > -0.8 && p.y < 0.9) {
        // Leg shape masking
        float legDist = abs(p.x + 0.2 + sin(p.y * 2.0) * 0.2);
        if (legDist < 0.3) {
            col = vec3(0.4, 0.25, 0.15); // Brown fabric base
            
            // Floral / leaf pattern
            float leafX = fract(p.x * 8.0 + sin(p.y * 5.0));
            float leafY = fract(p.y * 10.0 + cos(p.x * 5.0));
            
            if (leafX < 0.3 && leafY < 0.3) {
                col = vec3(0.8, 0.8, 0.85); // White flowers
            } else if (leafX > 0.7 && leafY > 0.7) {
                col = vec3(0.8, 0.5, 0.2); // Orange/brown leaves
            }
            
            // Fabric folding and moving animation
            float foldAnim = sin(p.x * 10.0 + p.y * 5.0 + iTime) * 0.1;
            col += foldAnim;
            
            // Shadow on the edge
            col *= smoothstep(0.3, 0.1, legDist);
        }
    }
    
    // Foot and shoe
    if (p.x > 0.1 && p.x < 0.6 && p.y > -0.9 && p.y < -0.4) {
        col = vec3(0.6, 0.4, 0.2); // Brown leather shoe/foot
        float shoeShine = smoothstep(0.4, 0.5, sin(p.x * 5.0 + p.y * 5.0));
        col += shoeShine * 0.1;
    }

    gl_FragColor = vec4(col, 1.0);
}
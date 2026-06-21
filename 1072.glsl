void main() {
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    // Background: street and fence/gate
    vec3 col = vec3(0.5, 0.5, 0.5); // Grey street
    if (p.y > 0.0) {
        col = vec3(0.4, 0.4, 0.35); // Wall/gate
        // Yellow flowers
        float flowers = length(vec2(p.x + 0.5, p.y - 0.6));
        if (flowers < 0.3) {
            vec3 fCol = vec3(0.8, 0.8, 0.1);
            // Flower animation: wind blowing
            float wind = sin(p.x * 20.0 + p.y * 20.0 + iTime) * 0.05;
            fCol += wind;
            col = mix(col, fCol, smoothstep(0.3, 0.2, flowers + wind));
        }
    }

    // The cart (blue)
    if (p.y < -0.1 && p.y > -0.6 && p.x > -0.2 && p.x < 0.6) {
        col = vec3(0.2, 0.4, 0.8);
        // Cart pattern animation: shiny surface
        float shine = smoothstep(0.4, 0.5, sin(p.x * 5.0 - p.y * 5.0 + iTime * 2.0));
        col += shine * 0.1;
    }

    // Lottery tickets on the cart (white/pinkish rectangles)
    if (p.y < -0.2 && p.y > -0.5 && p.x > 0.0 && p.x < 0.5) {
        float grid = abs(fract(p.x * 8.0) - 0.5) * abs(fract(p.y * 8.0) - 0.5);
        if (grid < 0.1) {
            col = vec3(0.9, 0.8, 0.8);
        }
    }

    // Woman in green shirt
    if (p.x > -0.8 && p.x < -0.2 && p.y > -0.5 && p.y < 0.3) {
        col = vec3(0.1, 0.5, 0.2); // Green shirt
        // Fabric pattern/wrinkle animation
        float wrinkles = sin(p.x * 30.0 + p.y * 10.0 + iTime * 0.5) * 0.05;
        col += wrinkles;
        
        if (p.y < -0.2) {
            col = vec3(0.1, 0.1, 0.1); // Black pants
        }
    }

    // Man in dark shirt
    if (p.x > -0.1 && p.x < 0.3 && p.y > -0.1 && p.y < 0.5) {
        col = vec3(0.15, 0.15, 0.2); // Dark shirt
    }

    gl_FragColor = vec4(col, 1.0);
}

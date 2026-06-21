void main() {
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    // Background: City street/road
    vec3 col = vec3(0.5, 0.5, 0.52); 
    
    // Road texture
    float roadNoise = fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
    col *= 0.9 + 0.1 * roadNoise;
    
    // Background elements (trees, cars, buildings) - blurry to simulate depth
    if (p.y > 0.2) {
        float bldg = sin(p.x * 10.0) * 0.1 + sin(p.x * 3.0) * 0.2;
        if (p.y < 0.5 + bldg) col = mix(col, vec3(0.3, 0.3, 0.35), 0.5); // Buildings
        
        float trees = sin(p.x * 20.0) * 0.05 + sin(p.x * 5.0) * 0.1;
        if (p.y < 0.4 + trees) col = mix(col, vec3(0.2, 0.3, 0.2), 0.6); // Trees
        
        // Distant car lights
        if (abs(p.y - 0.25) < 0.05 && fract(p.x * 5.0 + iTime) < 0.1) col += vec3(0.8, 0.1, 0.1);
        if (abs(p.y - 0.25) < 0.05 && fract(p.x * 5.0 - iTime + 0.5) < 0.1) col += vec3(0.9, 0.9, 0.7);
    }

    // Metal Frame Structure
    // Horizontal bars
    float barH1 = length(max(abs(p - vec2(0.0, 0.3)) - vec2(0.6, 0.02), 0.0)) - 0.01;
    float barH2 = length(max(abs(p - vec2(0.0, -0.4)) - vec2(0.6, 0.02), 0.0)) - 0.01;
    // Vertical bars
    float barV1 = length(max(abs(p - vec2(-0.6, -0.05)) - vec2(0.02, 0.35), 0.0)) - 0.01;
    float barV2 = length(max(abs(p - vec2(0.6, -0.05)) - vec2(0.02, 0.35), 0.0)) - 0.01;
    float barV3 = length(max(abs(p - vec2(-0.4, -0.05)) - vec2(0.02, 0.35), 0.0)) - 0.01;
    float barV4 = length(max(abs(p - vec2(0.4, -0.05)) - vec2(0.02, 0.35), 0.0)) - 0.01;
    
    // Base/feet
    float foot1 = length(max(abs(p - vec2(-0.4, -0.5)) - vec2(0.05, 0.1), 0.0)) - 0.01;
    float foot2 = length(max(abs(p - vec2(0.4, -0.5)) - vec2(0.05, 0.1), 0.0)) - 0.01;
    
    float frame = min(min(barH1, barH2), min(min(barV1, barV2), min(barV3, barV4)));
    frame = min(frame, min(foot1, foot2));

    if (frame < 0.0) {
        col = vec3(0.6); // Rusty/grey metal
        // Metal texture/rust
        float rust = fract(sin(p.x * 50.0 + p.y * 50.0) * 123.45);
        if (rust > 0.7) col = vec3(0.4, 0.3, 0.2);
    }

    // Blue Cloth/Tarp
    float clothBase = length(max(abs(p - vec2(0.0, 0.0)) - vec2(0.5, 0.45), 0.0)) - 0.02;
    // Add some irregularities to cloth edge
    float edgeWave = sin(p.y * 20.0) * 0.01;
    
    if (clothBase + edgeWave < 0.0) {
        col = vec3(0.1, 0.4, 0.8); // Bright blue
        
        // Cloth folds and wind animation
        float windX = sin(p.x * 5.0 + p.y * 2.0 + iTime * 2.0) * 0.1;
        float windY = cos(p.x * 3.0 + p.y * 4.0 - iTime * 1.5) * 0.1;
        
        // Vertical seam/fold lines
        float seams = abs(sin(p.x * 10.0 + windX));
        col *= 0.8 + 0.2 * smoothstep(0.0, 0.2, seams);
        
        // Shadow/highlight from wind
        col += vec3(0.1) * windX;
        col -= vec3(0.1) * windY;
        
        // Knotted/tied part in middle
        float knot = length(max(abs(p - vec2(0.0, 0.2)) - vec2(0.05, 0.15), 0.0)) - 0.03;
        if (knot < 0.0) {
            col = vec3(0.05, 0.3, 0.6); // Darker blue for bundled cloth
            // Folds in knot
            float kFolds = sin((p.x + p.y) * 40.0);
            col *= 0.8 + 0.2 * kFolds;
        }
    }

    // White plastic bags tied to frame
    // Left bag
    float bagL = length(max(abs(p - vec2(-0.65, 0.2)) - vec2(0.08, 0.12), 0.0)) - 0.03;
    // Bag blowing in wind
    float bagLWind = sin(p.y * 10.0 + iTime * 4.0) * 0.02;
    if (bagL + bagLWind < 0.0) {
        col = vec3(0.85, 0.85, 0.85); // Translucent white
        // Crinkles
        col *= 0.9 + 0.1 * fract(sin(p.x * 100.0) * 43758.5);
    }
    
    // Right bag
    float bagR = length(max(abs(p - vec2(0.65, 0.2)) - vec2(0.05, 0.1), 0.0)) - 0.02;
    float bagRWind = cos(p.y * 15.0 + iTime * 5.0) * 0.02;
    if (bagR + bagRWind < 0.0) {
        col = vec3(0.85, 0.85, 0.85);
        col *= 0.9 + 0.1 * fract(sin(p.x * 100.0 + 10.0) * 43758.5);
    }

    // Shadow under structure
    float shadow = exp(-10.0 * length(max(abs(p - vec2(0.0, -0.6)) - vec2(0.6, 0.1), 0.0)));
    col *= 1.0 - 0.4 * shadow;

    gl_FragColor = vec4(col, 1.0);
}
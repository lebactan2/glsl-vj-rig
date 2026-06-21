void main() {
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;
    
    // Background walls and floors
    vec3 col = vec3(0.78, 0.78, 0.8);
    if (p.y < -0.3) {
        col = vec3(0.45, 0.45, 0.47); // floor
        vec2 bUV = p * vec2(10.0, 20.0);
        bUV.x += step(1.0, mod(floor(bUV.y), 2.0)) * 0.5;
        if (min(fract(bUV.x), fract(bUV.y)) < 0.05) col = vec3(0.35); // grout
    }
    
    #define segment(p, a, b) length(p - a - (b - a) * clamp(dot(p - a, b - a) / dot(b - a, b - a), 0.0, 1.0))
    
    // Shelves with boots
    if (p.y > 0.4 && p.x > 0.1) {
        col = vec3(0.4, 0.4, 0.45); // wall/shelf color
        // Horizontal shelves
        if (fract(p.y * 5.0) < 0.05) col = vec3(0.2);
        
        // Boots
        vec2 bootP = vec2(fract(p.x * 6.0) - 0.5, fract(p.y * 5.0) - 0.5);
        float bootShape = max(abs(bootP.x) - 0.15, abs(bootP.y + 0.1) - 0.3);
        // Boot toe
        bootShape = min(bootShape, length(max(abs(bootP - vec2(0.1, -0.4)) - vec2(0.15, 0.05), 0.0)) - 0.05);
        
        if (bootShape < 0.0) {
            col = vec3(0.05, 0.05, 0.08); // black leather
            // Shine
            if (length(bootP - vec2(-0.05, 0.1)) < 0.05) col += 0.1;
        }
    }
    
    // Central Mannequin
    vec2 mp = p - vec2(-0.1, -0.1);
    float body = 1.0;
    // Torso
    body = min(body, length(max(abs(mp) - vec2(0.15, 0.3), 0.0)) - 0.05);
    // Legs
    body = min(body, segment(mp, vec2(-0.08, -0.3), vec2(-0.08, -0.7)) - 0.08);
    body = min(body, segment(mp, vec2(0.08, -0.3), vec2(0.08, -0.7)) - 0.08);
    // Arms
    body = min(body, segment(mp, vec2(-0.2, 0.25), vec2(-0.3, -0.1)) - 0.06);
    body = min(body, segment(mp, vec2(0.2, 0.25), vec2(0.3, -0.1)) - 0.06);
    
    if (body < 0.0) {
        vec3 mCol = vec3(0.3, 0.4, 0.2); // Olive Green
        // Shading
        mCol *= 0.8 + 0.2 * smoothstep(0.15, 0.0, abs(mp.x));
        mCol += sin(mp.x * 40.0 + mp.y * 20.0) * 0.02; // fabric texture
        
        // Belt
        if (abs(mp.y + 0.3) < 0.03 && abs(mp.x) < 0.2) {
            mCol = vec3(0.1);
            if (abs(mp.x) < 0.03) mCol = vec3(0.8, 0.7, 0.2); // brass buckle
        }
        
        // Buttons
        if (abs(mp.x) < 0.015 && fract(mp.y * 10.0) < 0.2 && mp.y > -0.3 && mp.y < 0.3) {
            mCol = vec3(0.2, 0.25, 0.1);
        }
        col = mCol;
    } else if (body < 0.02) col *= 0.6; // shadow
    
    // Head / Cap
    vec2 hp = mp - vec2(0.0, 0.45);
    float cap = length(max(abs(hp) - vec2(0.08, 0.05), 0.0)) - 0.02;
    float brim = segment(hp, vec2(-0.1, -0.05), vec2(0.12, -0.07)) - 0.01;
    if (min(cap, brim) < 0.0) {
        col = vec3(0.28, 0.35, 0.18);
        if (length(hp - vec2(0.0, 0.02)) < 0.02) col = vec3(0.8, 0.1, 0.1); // red star
    }
    
    // Shoes
    float lShoe = length(max(abs(mp - vec2(-0.08, -0.75)) - vec2(0.06, 0.04), 0.0)) - 0.02;
    float rShoe = length(max(abs(mp - vec2(0.08, -0.75)) - vec2(0.06, 0.04), 0.0)) - 0.02;
    if (min(lShoe, rShoe) < 0.0) col = vec3(0.1);
    
    gl_FragColor = vec4(col, 1.0);
}

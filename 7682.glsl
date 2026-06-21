void main() {
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;
    
    vec3 col = vec3(0.0);
    
    #define segment(p, a, b) length(p - a - (b - a) * clamp(dot(p - a, b - a) / dot(b - a, b - a), 0.0, 1.0))
    
    // Weathered Wall with peeling paint texture
    if (p.y > -0.5) {
        col = vec3(0.85, 0.7, 0.55); // Peach wall
        if (p.y > 0.35) col = vec3(0.35, 0.33, 0.3); // Top grey section
        else if (p.y > 0.25) col = vec3(0.75, 0.45, 0.45); // Pink trim
        
        // Advanced peeling/weathered noise
        vec2 np = p * 10.0;
        float n1 = fract(sin(dot(floor(np), vec2(12.9, 78.2))) * 43758.0);
        float n2 = fract(sin(dot(floor(np*2.0), vec2(41.2, 13.5))) * 43758.0);
        float stain = smoothstep(0.4, 0.6, n1 * n2);
        col = mix(col, col * 0.7, stain * 0.5); // darken stains
    } else {
        col = vec3(0.45, 0.15, 0.15); // Dark red base
    }
    
    // Ornate Teal Window Grille
    if (p.x > -0.35 && p.x < 0.35 && p.y > -0.15 && p.y < 0.25) {
        vec3 grilleCol = vec3(0.1, 0.4, 0.4);
        
        // Inner shadow
        col = mix(col, vec3(0.1), 0.5);
        
        // Geometric lattice
        vec2 gp = fract(p * 15.0) - 0.5;
        float lattice = min(abs(gp.x + gp.y), abs(gp.x - gp.y));
        lattice = min(lattice, min(abs(gp.x), abs(gp.y)));
        
        if (lattice < 0.1) {
            col = grilleCol;
            // 3D bevel on grille
            if (lattice > 0.06) col *= 0.6;
        }
        
        // Frame
        float frame = max(abs(p.x) - 0.35, abs(p.y - 0.05) - 0.2);
        if (abs(frame) < 0.02) col = vec3(0.05, 0.3, 0.3);
    }
    
    // Ornate Railing with distinct Lotus Petals
    if (p.y > -0.55 && p.y < -0.25) {
        col = vec3(0.75, 0.7, 0.5); // Base gold/cream
        
        // Vertical bars
        if (abs(fract(p.x * 15.0) - 0.5) > 0.4) col = vec3(0.6, 0.55, 0.35);
        // Horizontal rails
        if (abs(p.y - (-0.28)) < 0.015 || abs(p.y - (-0.52)) < 0.015) col = vec3(0.8, 0.75, 0.55);
        
        // Detailed Lotus Panels
        vec2 lp = vec2(fract(p.x * 5.0) - 0.5, (p.y + 0.4) * 3.0);
        float lDist = length(lp);
        float lAngle = atan(lp.x, lp.y);
        
        // Layered petals
        float petal1 = abs(sin(lAngle * 2.0)) * 0.4;
        float petal2 = abs(cos(lAngle * 2.0)) * 0.3;
        
        if (lDist < petal1 || lDist < petal2) {
            col = vec3(0.15, 0.45, 0.4); // Teal lotus
            // Inner petal lines
            if (abs(lDist - petal1) < 0.02 || abs(lDist - petal2) < 0.02) col = vec3(0.1, 0.3, 0.25);
        }
    }
    
    // Detailed Dragon Silhouette
    vec2 dp = p - vec2(0.65, 0.5);
    float dragon = 1.0;
    
    // Serpentine body
    float bCurve = sin(dp.x * 15.0) * 0.1;
    dragon = min(dragon, segment(dp, vec2(-0.2, -0.1), vec2(0.2, 0.1 + bCurve)));
    dragon = min(dragon, segment(dp, vec2(0.2, 0.1 + bCurve), vec2(0.3, -0.05)));
    
    // Head & Horns
    vec2 headP = dp - vec2(-0.2, -0.1);
    float head = length(headP) - 0.05;
    head = min(head, segment(headP, vec2(0.0), vec2(-0.08, -0.02))); // Snout
    head = min(head, segment(headP, vec2(0.0), vec2(-0.05, 0.08))); // Horn
    dragon = min(dragon, head);
    
    // Spikes/Scales along back
    float scales = fract(dp.x * 30.0);
    if (scales < 0.5 && dp.y > bCurve + 0.02 && dp.y < bCurve + 0.06 && dp.x > -0.1 && dp.x < 0.2) {
        dragon = min(dragon, 0.0); 
    }
    
    if (dragon < 0.02) {
        col = vec3(0.1, 0.3, 0.3); // Dark teal
        if (dragon > 0.01) col = vec3(0.05, 0.2, 0.2); // Outline
    }
    
    gl_FragColor = vec4(col, 1.0);
}

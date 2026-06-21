void main() {
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;
    
    vec3 col = vec3(0.5, 0.5, 0.5); // background
    
    // Street & Sidewalk background
    if (p.x > 0.2) {
        col = vec3(0.7, 0.7, 0.65); // sidewalk tiles
        if (fract(p.x * 5.0) < 0.05 || fract(p.y * 5.0) < 0.05) col *= 0.8;
    } else {
        col = vec3(0.4, 0.45, 0.45); // street / barrier
        if (p.y > 0.2) col = vec3(0.6, 0.6, 0.6); // wall
        if (p.x < 0.0 && p.y > 0.2 && p.y < 0.3) col = vec3(0.2, 0.5, 0.3); // green stripe on wall
    }
    
    // Person (Center)
    vec2 personP = p - vec2(0.0, -0.1);
    
    // Pants (Purple with white/red patterns)
    if (personP.y > -0.7 && personP.y < -0.1 && abs(personP.x) < 0.15) {
        col = vec3(0.4, 0.1, 0.5); // base purple
        
        // Pattern on pants (animated)
        vec2 pantUV = personP * 15.0;
        pantUV.y += iTime * 0.5; // moving pattern
        float pantPattern = fract(sin(dot(floor(pantUV), vec2(12.9898, 78.233))) * 43758.5453);
        if (pantPattern > 0.7) col = vec3(0.9); // white spots
        else if (pantPattern > 0.5) col = vec3(0.8, 0.2, 0.3); // red spots
    }
    
    // High-vis shirt (Plaid orange/red with yellow stripes)
    if (personP.y > -0.1 && personP.y < 0.4 && abs(personP.x) < 0.2) {
        col = vec3(0.8, 0.4, 0.1); // orange base
        
        // Plaid pattern
        if (fract(personP.x * 20.0) < 0.2) col = vec3(0.5, 0.2, 0.1);
        if (fract(personP.y * 20.0) < 0.2) col = vec3(0.5, 0.2, 0.1);
        
        // Yellow reflective stripes
        if (abs(personP.y - 0.1) < 0.05 || abs(personP.y - 0.3) < 0.05) {
            col = vec3(0.9, 0.9, 0.1); // yellow stripe
        }
    }
    
    // Head / Yellow hard hat
    if (length(personP - vec2(0.0, 0.5)) < 0.12) {
        col = vec3(0.9, 0.7, 0.5); // face skin
    }
    if (length(personP - vec2(0.0, 0.55)) < 0.13 && personP.y > 0.5) {
        col = vec3(0.95, 0.85, 0.1); // yellow hat
    }
    
    // Motorcycle part (Left)
    if (length(p - vec2(-0.5, -0.4)) < 0.3) {
        col = vec3(0.15); // dark scooter body
    }
    if (length(p - vec2(-0.3, -0.2)) < 0.15) {
        col = vec3(0.8); // white part
    }
    
    // Green basket / bag on floor right
    if (length(p - vec2(0.4, -0.6)) < 0.1) {
        col = vec3(0.4, 0.8, 0.5);
    }
    
    gl_FragColor = vec4(col, 1.0);
}

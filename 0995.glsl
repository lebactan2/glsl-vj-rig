void main() {
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;
    
    // Background wall with plaster texture
    vec3 col = vec3(0.72, 0.72, 0.74);
    float plaster = fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
    col += (plaster - 0.5) * 0.04;
    
    // Teal balcony wall
    if (p.y > -0.2 && p.y < 0.55 && abs(p.x) < 0.9) {
        col = vec3(0.25, 0.45, 0.5);
        col *= 0.8 + 0.2 * p.y; // gradient
    }
    
    // Clothesline (sagging curve)
    float sag = 0.25 - p.x * p.x * 0.05;
    if (abs(p.y - sag) < 0.003 && abs(p.x) < 0.85) col = vec3(0.1);
    
    // Detailed clothes hanging
    #define segment(p, a, b) length(p - a - (b - a) * clamp(dot(p - a, b - a) / dot(b - a, b - a), 0.0, 1.0))
    for (float i = 0.0; i < 10.0; i++) {
        float cx = -0.7 + i * 0.15;
        float cw = 0.05 + sin(i * 10.0) * 0.01;
        float ch = 0.15 + cos(i * 20.0) * 0.05;
        
        vec2 cp = p - vec2(cx, sag);
        // Sway animation
        float sway = sin(iTime * (2.0 + iMid * 3.0) + i) * (0.05 + iLevel * 0.12) + iBeat * 0.06;
        cp.x -= cp.y * sway;
        
        // Shirt shape
        float shirt = max(abs(cp.x) - cw, cp.y);
        shirt = max(shirt, -cp.y - ch);
        // Add sleeves
        float sleeves = segment(cp, vec2(-cw, 0.0), vec2(-cw - 0.04, -0.05)) - 0.015;
        sleeves = min(sleeves, segment(cp, vec2(cw, 0.0), vec2(cw + 0.04, -0.05)) - 0.015);
        shirt = min(shirt, sleeves);
        
        if (shirt < 0.0) {
            vec3 cCol = mix(vec3(0.8, 0.2, 0.2), vec3(0.2, 0.3, 0.8), fract(i * 0.3));
            if (fract(i * 0.7) > 0.5) cCol = vec3(0.9, 0.8, 0.2); // yellow
            
            // Shading
            cCol *= 0.8 + 0.2 * smoothstep(-cw, cw, cp.x);
            // Wrinkles
            cCol -= 0.1 * sin(cp.x * 50.0) * smoothstep(0.0, -ch, cp.y);
            col = cCol;
        }
    }
    
    // Detailed Bird cage
    vec2 cageP = p - vec2(0.4, 0.3);
    float cageBody = length(vec2(cageP.x, max(0.0, cageP.y))) - 0.08;
    cageBody = max(cageBody, -cageP.y - 0.1);
    if (cageBody < 0.0) {
        col = vec3(0.2); // inside shadow
        // Bamboo bars
        float bars = abs(fract(cageP.x * 25.0) - 0.5);
        if (bars < 0.1) col = vec3(0.6, 0.45, 0.2);
        // Horizontal rings
        if (abs(cageP.y) < 0.005 || abs(cageP.y + 0.05) < 0.005 || abs(cageP.y + 0.09) < 0.005) {
            col = vec3(0.7, 0.55, 0.3);
        }
    }
    // Hook
    float hook = abs(length(cageP - vec2(0.0, 0.09)) - 0.01);
    if (hook < 0.003 && cageP.y > 0.09) col = vec3(0.3);
    
    // Plant pot & leaves
    vec2 potP = p - vec2(-0.4, -0.2);
    float pot = max(abs(potP.x) - 0.04 + potP.y * 0.1, abs(potP.y) - 0.05);
    if (pot < 0.0) col = vec3(0.6, 0.3, 0.2); // terracotta
    
    // Vines falling from pot
    for(float i=0.0; i<3.0; i++) {
        float vx = sin(potP.y * 10.0 + i) * 0.02;
        float vine = segment(potP, vec2(0.0, 0.0), vec2(vx, -0.3 + i*0.05));
        if (vine < 0.005) col = vec3(0.1, 0.3, 0.1);
        // Leaves
        float lDist = length(vec2(potP.x - vx - sin(potP.y*30.0)*0.02, fract(potP.y * 10.0) - 0.5));
        if (lDist < 0.2 && potP.y < 0.0 && potP.y > -0.3) col = vec3(0.2, 0.45, 0.15);
    }
    
    gl_FragColor = vec4(col, 1.0);
}

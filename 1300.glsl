void main() {
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    // Background: White/grey backdrop
    vec3 col = vec3(0.9, 0.9, 0.9); 
    
    // Tactical Vest main body
    float vestBase = length(max(abs(p - vec2(0.0, -0.1)) - vec2(0.4, 0.6), 0.0)) - 0.1;
    
    // Neck area cutout
    float neck = length(p - vec2(0.0, 0.6)) - 0.25;
    
    if (vestBase < 0.0 && neck > 0.0) {
        col = vec3(0.1, 0.1, 0.12); // Dark grey/black fabric
        
        // Fabric texture (Cordura/Nylon)
        float fabric = fract(sin(p.x * 200.0) * cos(p.y * 200.0) * 10.0);
        col *= 0.9 + 0.1 * fabric;
        
        // Molle webbing (horizontal strips)
        float molle = fract(p.y * 15.0);
        if (molle < 0.2 && p.y < 0.3 && p.y > -0.5 && abs(p.x) < 0.35) {
            col = vec3(0.05); // Darker strips
            // Webbing texture animation (subtle pulsing to simulate light moving over nylon)
            float shine = sin(p.x * 10.0 + iTime * 2.0) * 0.5 + 0.5;
            col += vec3(0.05) * shine;
        }
        
        // Pouches
        // Left side pouches
        float pouch1 = length(max(abs(p - vec2(-0.25, -0.2)) - vec2(0.08, 0.15), 0.0)) - 0.02;
        if (pouch1 < 0.0) {
            col = vec3(0.12);
            // Flap
            if (p.y > -0.1) col = vec3(0.08);
        }
        float pouch2 = length(max(abs(p - vec2(-0.1, -0.2)) - vec2(0.08, 0.15), 0.0)) - 0.02;
        if (pouch2 < 0.0) col = vec3(0.12);
        
        // Right side large pouch
        float pouch3 = length(max(abs(p - vec2(0.25, -0.6)) - vec2(0.15, 0.15), 0.0)) - 0.03;
        if (pouch3 < 0.0) {
            col = vec3(0.1);
            // Zipper detail
            if (abs(p.x - 0.25) < 0.01) col = vec3(0.05);
        }
        
        // Upper right small pouch
        float pouch4 = length(max(abs(p - vec2(0.3, 0.1)) - vec2(0.08, 0.06), 0.0)) - 0.02;
        if (pouch4 < 0.0) col = vec3(0.13);
        
        // Shoulder pads
        float padL = length(max(abs(p - vec2(-0.35, 0.5)) - vec2(0.1, 0.05), 0.0)) - 0.02;
        float padR = length(max(abs(p - vec2(0.35, 0.5)) - vec2(0.1, 0.05), 0.0)) - 0.02;
        if (padL < 0.0 || padR < 0.0) col = vec3(0.15);
        
        // Groin protector/lower flap
        float lowerFlap = length(max(abs(p - vec2(0.0, -0.8)) - vec2(0.2, 0.1), 0.0)) - 0.05;
        if (lowerFlap < 0.0 && p.y < -0.7) col = vec3(0.1);
    }
    
    // Arm attachments (deltoid protectors)
    float armL = length(max(abs(p - vec2(-0.6, 0.2)) - vec2(0.1, 0.2), 0.0)) - 0.05;
    if (armL < 0.0) {
        col = vec3(0.1);
        if (abs(p.y - 0.2) < 0.02) col = vec3(0.05); // Strap
    }
    
    float armR = length(max(abs(p - vec2(0.6, 0.2)) - vec2(0.1, 0.2), 0.0)) - 0.05;
    if (armR < 0.0) {
        col = vec3(0.1);
        if (abs(p.y - 0.2) < 0.02) col = vec3(0.05); // Strap
    }

    // Hood/collar area (standing up)
    float collar = length(max(abs(p - vec2(0.0, 0.65)) - vec2(0.2, 0.15), 0.0)) - 0.05;
    // Taper collar towards top
    if (collar < 0.0 - p.y * 0.1) {
        col = vec3(0.08);
        // Subtle fabric folds
        float fold = sin(p.x * 20.0) * 0.02;
        col += vec3(fold);
    }

    // Shadows
    col *= 1.0 - 0.3 * length(p - vec2(0.0, -0.2));

    gl_FragColor = vec4(col, 1.0);
}
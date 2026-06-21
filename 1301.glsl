void main() {
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    // Background: Bright cyan/blue sky
    vec3 col = vec3(0.4, 0.9, 0.95); 
    
    // Purple flag base
    float flagBase = length(max(abs(p) - vec2(0.6, 0.5), 0.0)) - 0.05;
    
    // Right side jagged edge (flames/spikes)
    float spikes = 0.0;
    if (p.x > 0.4) {
        float f = p.y * 10.0;
        spikes = sin(f) * 0.15 * smoothstep(0.4, 0.7, p.x);
        // Add waving animation to spikes
        spikes += sin(f * 2.0 + iTime * 5.0) * 0.05 * smoothstep(0.4, 0.7, p.x);
    }
    
    float flagFull = length(max(abs(p - vec2(spikes, 0.0)) - vec2(0.6, 0.5), 0.0)) - 0.05;

    if (flagFull < 0.0) {
        // Main purple color
        col = vec3(0.5, 0.2, 0.8);
        
        // Fabric texture and waving animation
        float wave = sin(p.x * 5.0 + p.y * 2.0 - iTime * 3.0) * 0.1;
        float fold = abs(sin(p.x * 10.0 + iTime)) * 0.2;
        col *= 0.8 + wave + fold;
        
        // Outer white border
        float border1 = length(max(abs(p) - vec2(0.5, 0.4), 0.0)) - 0.02;
        float border2 = length(max(abs(p) - vec2(0.45, 0.35), 0.0)) - 0.02;
        if (border1 < 0.0 && border2 > 0.0) {
            col = vec3(0.95);
            col *= 0.9 + 0.1 * wave; // Border waves with flag
        }
        
        // Inner white border
        float border3 = length(max(abs(p) - vec2(0.35, 0.25), 0.0)) - 0.02;
        float border4 = length(max(abs(p) - vec2(0.3, 0.2), 0.0)) - 0.02;
        if (border3 < 0.0 && border4 > 0.0) {
            col = vec3(0.95);
            col *= 0.9 + 0.1 * wave;
        }
        
        // Center Cross
        float crossV = length(max(abs(p - vec2(0.0, 0.0)) - vec2(0.02, 0.15), 0.0)) - 0.01;
        float crossH = length(max(abs(p - vec2(0.0, 0.0)) - vec2(0.1, 0.02), 0.0)) - 0.01;
        
        // Decorative cross ends (trefoil/budded)
        float cEnd1 = length(p - vec2(0.0, 0.17)) - 0.03; // Top
        float cEnd2 = length(p - vec2(0.0, -0.17)) - 0.03; // Bottom
        float cEnd3 = length(p - vec2(0.12, 0.0)) - 0.03; // Right
        float cEnd4 = length(p - vec2(-0.12, 0.0)) - 0.03; // Left
        
        float fullCross = min(min(crossV, crossH), min(min(cEnd1, cEnd2), min(cEnd3, cEnd4)));
        
        if (fullCross < 0.0) {
            col = vec3(0.95);
            // Shadow on cross to give it thickness
            if (p.x - p.y > 0.0) col = vec3(0.85);
            col *= 0.9 + 0.1 * wave;
        }
        
        // Top sleeve/loop for pole
        float sleeve = length(max(abs(p - vec2(0.0, 0.55)) - vec2(0.4, 0.05), 0.0)) - 0.02;
        if(sleeve < 0.0) col = vec3(0.45, 0.15, 0.75);
    }

    gl_FragColor = vec4(col, 1.0);
}
void main() {
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;
    
    // Night sky with twinkling stars
    vec3 col = mix(vec3(0.02, 0.04, 0.1), vec3(0.1, 0.15, 0.25), p.y * 0.5 + 0.5);
    
    // Starfield
    vec2 sUV = p * 20.0;
    float starGrid = fract(sin(dot(floor(sUV), vec2(12.9898, 78.233))) * 43758.5453);
    if (starGrid > 0.98) {
        float twinkle = sin(iTime * 5.0 + starGrid * 100.0) * 0.5 + 0.5;
        col += vec3(twinkle * 0.8) * exp(-length(fract(sUV) - 0.5) * 10.0);
    }
    
    // Building silhouette
    if (p.y < -0.4) {
        col = vec3(0.02, 0.03, 0.06);
        if (fract(p.x * 4.0) < 0.1 && p.y > -0.5) col = vec3(0.6, 0.15, 0.15); // roof trim
    }

    #define segment(p, a, b) length(p - a - (b - a) * clamp(dot(p - a, b - a) / dot(b - a, b - a), 0.0, 1.0))
    #define myCosh(x) (exp(x) + exp(-(x))) / 2.0
    
    // Detailed String Lights
    for (float i = 0.0; i < 4.0; i++) {
        // Catenary curve for wire
        float wx = p.x - 0.3 * i + 0.5;
        // Bouncing wire animation
        float bounce = sin(iTime * 2.0 + i) * 0.05;
        float wireY = 0.6 - 0.5 * myCosh(wx * 2.0) + 0.5 + bounce;
        
        if (abs(p.y - wireY) < 0.005) {
            col = vec3(0.1); // dark wire
        }
        
        // Bulbs
        for (int j = 0; j < 6; j++) {
            float fj = float(j);
            float bx = -1.2 + (fj / 5.0) * 2.5 + i * 0.2;
            float bwx = bx - 0.3 * i + 0.5;
            float by = 0.6 - 0.5 * myCosh(bwx * 2.0) + 0.5 + bounce - 0.08;
            
            vec2 bp = vec2(bx, by);
            // Wind swing for bulbs
            float swing = sin(iTime * 3.0 + fj * 0.5) * 0.03;
            bp.x += swing;
            
            float d = length(p - bp);
            
            // Wire drop to bulb
            if (segment(p, vec2(bx, by + 0.08), vec2(bp.x, bp.y + 0.02)) < 0.004) col = vec3(0.1);
            
            vec3 bCol = vec3(1.0);
            float c = mod(fj + i, 3.0);
            if (c == 0.0) bCol = vec3(1.0, 0.2, 0.2); // Red
            else if (c == 1.0) bCol = vec3(1.0, 0.8, 0.2); // Yellow
            else bCol = vec3(0.9, 0.9, 1.0); // White
            
            // Sequential Blinking Animation
            float on = sin(iTime * 4.0 - fj * 1.5 - i * 2.0) * 0.5 + 0.5;
            on = smoothstep(0.4, 0.6, on); // snap on/off
            bCol *= 0.2 + 0.8 * on;
            
            // Bulb glow (additive)
            float glow = exp(-d * 15.0);
            col += bCol * glow * 1.5;
            
            // Solid glass bulb
            if (d < 0.02) {
                col = mix(col, bCol * 2.0, 0.8);
                // Intricate Filament
                vec2 fp = p - bp;
                if (abs(fp.x) < 0.002 && fp.y > -0.01 && fp.y < 0.01) col = vec3(2.0 * on);
                if (abs(length(fp - vec2(0.0, 0.01)) - 0.005) < 0.001 && fp.y > 0.01) col = vec3(2.0 * on);
            }
        }
    }
    
    // Highly Detailed Red Lantern with Pendulum Swing Animation
    vec2 lp = p - vec2(-0.7, 0.1);
    
    // Pendulum physics rotation
    float angle = sin(iTime * 1.5) * 0.3; // 0.3 rad swing
    mat2 rot = mat2(cos(angle), -sin(angle), sin(angle), cos(angle));
    
    // Shift pivot point to the top of the lantern
    lp.y -= 0.2; 
    lp = rot * lp;
    lp.y += 0.2; 
    
    float lanternBody = length(lp * vec2(1.0, 0.8)) - 0.15;
    if (lanternBody < 0.0) {
        col = vec3(0.8, 0.15, 0.15); // rich red
        // Golden ribs with 3D bevel
        float ribs = abs(sin(lp.x * 40.0));
        col = mix(col, vec3(0.9, 0.8, 0.2), smoothstep(0.8, 0.95, ribs) * 0.6);
        // Shading
        col *= 0.7 + 0.3 * smoothstep(0.15, 0.0, length(lp));
        // Top/Bottom caps
        if (abs(lp.y) > 0.17) col = vec3(0.8, 0.7, 0.2); // gold caps
    }
    
    // Tassel swaying separately
    float tasselSwing = sin(iTime * 1.5 + 1.0) * 0.1;
    vec2 tp = lp - vec2(0.0, -0.18);
    tp.x -= tp.y * tasselSwing * 5.0; // bend tassel
    
    if (tp.y < 0.0 && tp.y > -0.2 && abs(tp.x) < 0.02) {
        col = vec3(0.8, 0.15, 0.15);
        float threads = abs(fract(tp.x * 100.0) - 0.5);
        col *= 0.6 + 0.4 * threads;
    }
    
    // Add vignette
    col *= 1.0 - 0.3 * length(p);
    
    gl_FragColor = vec4(col, 1.0);
}

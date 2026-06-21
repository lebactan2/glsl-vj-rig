void main() {
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;
    
    // Background (Grey wall/glass)
    vec3 col = vec3(0.4, 0.45, 0.48);
    
    // Background glass reflection animating
    col += vec3(0.1, 0.15, 0.2) * sin(p.x * 5.0 + p.y * 3.0 + iTime);
    
    // Middle separation line
    if (abs(p.y) < 0.01) col = vec3(0.3, 0.35, 0.4);
    
    // Top reflection
    if (p.y > 0.0 && p.x > -0.6 && p.x < 0.2 && p.y > 0.3 && p.y < 0.8) {
        col = mix(col, vec3(0.9, 0.95, 1.0), 0.6); // White/blue reflection
        // A couple of "building" blocks in reflection swaying slightly
        float sway = sin(iTime)*0.02;
        if (p.x + sway > -0.4 && p.x + sway < -0.2 && p.y > 0.4) col = vec3(0.8);
        if (p.x + sway > 0.0 && p.x + sway < 0.1 && p.y > 0.5) col = vec3(0.7, 0.8, 0.7);
    }
    
    // Helper function for leaf
    // Two leaves, one at y=0.5, one at y=-0.5
    float y_offset = p.y > 0.0 ? 0.5 : -0.5;
    vec2 lp = p - vec2(0.0, y_offset);
    
    // Leaf base shape (horizontal ellipse)
    float leafBase = length(lp * vec2(0.5, 2.5)) - 0.7;
    
    // Add jagged edges
    float jagged = sin(lp.x * 40.0) * 0.03 + sin(lp.x * 80.0) * 0.015;
    float leaf = leafBase + jagged;
    
    if (leaf < 0.0) {
        // Base dark green
        col = vec3(0.1, 0.2, 0.15);
        
        // Vertical leaf veins
        float veins = abs(sin(lp.x * 100.0));
        col *= 0.7 + 0.3 * veins;
        
        // Central stem
        if (abs(lp.y) < 0.02) col = vec3(0.15, 0.25, 0.15);
        
        // Gold decorations (Calligraphy approximation)
        vec3 gold = vec3(0.8, 0.6, 0.2);
        
        // 5 main characters per leaf
        for(float i=-0.8; i<=0.8; i+=0.35) {
            vec2 cp = lp - vec2(i, 0.0);
            
            // Random character shape using noise/sines
            float charShape = length(cp) - 0.08;
            charShape += sin(cp.x * 30.0 + i * 10.0) * 0.03;
            charShape += cos(cp.y * 25.0 + i * 20.0) * 0.04;
            
            // Strokes
            float stroke1 = max(abs(cp.x - cp.y) - 0.02, abs(cp.x + cp.y) - 0.06);
            float stroke2 = max(abs(cp.x + cp.y*0.5) - 0.01, abs(cp.y) - 0.08);
            
            if (min(charShape, min(stroke1, stroke2)) < 0.0) {
                // Gold material with animated shine
                float shine = pow(max(0.0, sin(cp.x * 50.0 + cp.y * 50.0 - iTime*5.0)), 4.0);
                col = gold * (0.8 + 0.4 * cos(cp.x * 50.0 + cp.y * 50.0)) + vec3(0.4)*shine;
            }
        }
        
        // Grapes/vines on the left end (-1.2, 0.0)
        vec2 vp = lp - vec2(-1.2, 0.0);
        float grapeCluster = length(vp) - 0.15;
        if (grapeCluster < 0.0) {
            // Draw individual grapes
            float grapes = 1.0;
            for(float gx=-0.1; gx<=0.1; gx+=0.04) {
                for(float gy=-0.1; gy<=0.1; gy+=0.04) {
                    if(length(vec2(gx,gy)) < 0.12) {
                        float g = length(vp - vec2(gx, gy)) - 0.02;
                        grapes = min(grapes, g);
                    }
                }
            }
            if (grapes < 0.0) {
                float gShine = pow(max(0.0, sin(vp.x*50.0 + vp.y*50.0 - iTime*3.0)), 4.0);
                col = gold * (0.6 + 0.4*sin(vp.x*100.0)) + vec3(0.3)*gShine;
            }
        }
        
        // Gold trim on edges with gleam
        if (leafBase + jagged > -0.02) {
            float trimGleam = pow(max(0.0, sin(lp.x * 20.0 - iTime*4.0)), 8.0);
            col = gold * 0.7 + vec3(0.5)*trimGleam;
        }
    }
    
    // Add specular highlight over the whole glass
    col += vec3(0.1) * max(0.0, sin(p.x * 5.0 + p.y * 10.0 - iTime));

    gl_FragColor = vec4(col, 1.0);
}
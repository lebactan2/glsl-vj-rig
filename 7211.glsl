void main() {
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;
    
    vec3 bgDark = vec3(0.18, 0.18, 0.18); 
    vec3 col = bgDark;
    
    // UI scroll animation (content moves up)
    float scrollY = p.y + fract(iTime * 0.2) * 1.0;
    // We only scroll the content part, not the top/bottom bars.
    
    // Top Status Bar (Static)
    if (p.y > 0.9) {
        col = vec3(0.12, 0.12, 0.12);
        if (p.x < -0.3 && p.x > -0.5 && abs(p.y - 0.95) < 0.02) col = vec3(0.9);
        if (p.x > 0.4 && p.x < 0.5 && abs(p.y - 0.95) < 0.02) col = vec3(0.9);
    }
    // Bottom Bar (Static)
    else if (p.y <= -0.5) {
        col = vec3(0.15, 0.15, 0.15); 
        
        if (p.y > -0.7 && p.y < -0.55) {
            float dPill = max(abs(p.x) - 0.45, abs(p.y + 0.62) - 0.06);
            if (dPill < 0.0) {
                col = vec3(0.3, 0.3, 0.3);
                if (p.x > -0.2 && p.x < 0.2 && abs(p.y + 0.62) < 0.015) col = vec3(0.9);
                if (length(p - vec2(0.4, -0.62)) < 0.015) col = vec3(0.8);
            }
        }
        if (p.y < -0.85) {
            if (abs(p.y + 0.92) < 0.03) {
                if (abs(p.x + 0.4) < 0.03) col = vec3(0.3, 0.6, 1.0); 
                if (abs(p.x + 0.2) < 0.03) col = vec3(0.3, 0.6, 1.0); 
                if (abs(p.x) < 0.03) col = vec3(0.3, 0.6, 1.0); 
                if (abs(p.x - 0.2) < 0.03) col = vec3(0.3, 0.6, 1.0); 
                if (abs(p.x - 0.4) < 0.03) col = vec3(0.3, 0.6, 1.0); 
            }
        }
    }
    // Middle Scrolling Content
    else {
        // Redefine y based on scroll, modulo for repeating content
        float cy = mod(scrollY, 1.5) - 0.75; // Map from -0.75 to 0.75
        
        // Header Area
        if (cy > 0.4) {
            if (cy > 0.55 && cy < 0.65 && abs(p.x) < 0.2) {
                col = vec3(1.0); 
                if (abs(cy - 0.6) < 0.01 && abs(p.x) < 0.18) col = bgDark; 
            }
            if (length(vec2(p.x, cy) - vec2(0.4, 0.6)) < 0.05) col = vec3(0.9);
            
            float dSearch = max(abs(p.x) - 0.45, abs(cy - 0.45) - 0.06);
            if (dSearch < 0.0) {
                col = vec3(0.25, 0.25, 0.25); 
                if (length(vec2(p.x, cy) - vec2(-0.4, 0.45)) < 0.02) col = vec3(0.6);
                if (p.x > -0.3 && p.x < 0.1 && abs(cy - 0.45) < 0.015) col = vec3(0.9);
                if (length(vec2(p.x, cy) - vec2(0.4, 0.45)) < 0.015) col = vec3(0.6);
            }
        }
        // Menu Tabs
        else if (cy > 0.28 && cy <= 0.4) {
            if (abs(cy - 0.34) < 0.015) {
                if (fract(p.x * 8.0) > 0.3) col = vec3(0.7);
                if (p.x < -0.4) col = vec3(1.0);
            }
            if (cy > 0.29 && cy < 0.3 && p.x < -0.4 && p.x > -0.48) col = vec3(1.0);
        }
        // Ads text
        else if (cy > 0.15 && cy <= 0.28) {
            if (abs(cy - 0.2) < 0.02 && p.x > -0.45 && p.x < 0.3) {
                col = vec3(0.9);
                if (p.x < -0.35) col = vec3(1.0); 
            }
        }
        // Book Cards Section
        else if (cy > -0.7 && cy <= 0.15) {
            float cardX = mod(p.x + 0.5, 0.5) - 0.25; 
            float cardIndex = floor((p.x + 0.5) / 0.5);
            
            if (cardIndex >= 0.0 && cardIndex < 2.0 && abs(cardX) < 0.23) {
                col = vec3(0.2, 0.2, 0.22); 
                
                if (cy > -0.35) {
                    vec2 coverP = vec2(cardX, cy + 0.1); // center
                    float dCover = max(abs(coverP.x) - 0.2, abs(coverP.y) - 0.23);
                    
                    if (dCover < 0.0) {
                        vec3 coverBase = vec3(0.4, 0.38, 0.35); 
                        // Animated Noise
                        float noise = fract(sin(dot(coverP + vec2(iTime*0.1), vec2(12.9898, 78.233))) * 43758.5453);
                        col = coverBase * (0.8 + 0.4 * noise);
                        
                        float dMan = max(abs(coverP.x) - 0.12, abs(coverP.y + 0.1) - 0.15); 
                        float dHat = length(coverP - vec2(0.0, 0.1)) - 0.08; 
                        float dBrim = max(abs(coverP.x) - 0.15, abs(coverP.y - 0.1) - 0.02);
                        
                        if (min(min(dMan, dHat), dBrim) < 0.0) {
                            col = vec3(0.1); 
                        }
                        
                        if (abs(coverP.y + 0.05) < 0.08 && abs(coverP.x) < 0.15) {
                            col = mix(col, vec3(0.8, 0.7, 0.5), 0.8); 
                            if (fract(coverP.y * 30.0) < 0.2) col = vec3(0.1); 
                            if (fract(coverP.x * 20.0) < 0.2) col = vec3(0.1); 
                        }
                    }
                } else {
                    if (cy > -0.45 && cy < -0.4) col = vec3(0.5, 0.7, 1.0);
                    if (cy > -0.5 && cy < -0.45 && p.x < 0.0) col = vec3(0.5, 0.7, 1.0); 
                    if (cy > -0.6 && cy < -0.55 && cardX < 0.0) col = vec3(1.0);
                    if (cy > -0.65 && cy < -0.6 && cardX < 0.0) col = vec3(0.6);
                }
            }
        }
    }

    gl_FragColor = vec4(col, 1.0);
}
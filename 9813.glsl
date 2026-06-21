void main() {
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;
    
    vec3 col = vec3(0.0);
    
    // --- Background (Brushed Metal) ---
    // Base color
    col = vec3(0.65, 0.65, 0.68);
    
    // Brushed texture (fine vertical noise) - animated
    float brush = fract(sin(p.x * 500.0 + iTime * 0.5) * 43758.5453);
    brush += fract(sin(p.x * 300.0 + p.y * 10.0 + iTime * 0.5) * 43758.5453) * 0.5;
    col *= 0.9 + 0.1 * brush;
    
    // Broad color reflections (horizontal bands) - animated light sweep
    float lightPulse = sin(iTime * 1.0) * 0.1;
    // Top light
    col += vec3(0.2) * smoothstep(0.5 + lightPulse, 1.0 + lightPulse, p.y);
    // Middle warm band
    col += vec3(0.3, 0.25, 0.1) * smoothstep(0.4, 0.0, abs(p.y - 0.2 - lightPulse*0.5));
    // Bottom cool band
    col -= vec3(0.1, 0.0, 0.1) * smoothstep(0.5, 0.0, abs(p.y + 0.3 - lightPulse));
    col += vec3(0.0, 0.15, 0.0) * smoothstep(0.4, 0.0, abs(p.y + 0.1 - lightPulse*0.8));

    // --- Main Graphics (Three repeating characters) ---
    // They are centered around p.y = 0.25
    if (p.y > -0.1 && p.y < 0.6) {
        // Repeat on x axis
        float spacing = 0.6;
        float x_idx = floor((p.x + spacing * 1.5) / spacing);
        
        if (x_idx >= 0.0 && x_idx < 3.0) {
            vec2 char_p = p;
            char_p.x = mod(p.x + spacing * 0.5, spacing) - spacing * 0.5;
            char_p.y -= 0.25;
            // Bobbing animation for characters
            char_p.y += sin(iTime * 2.0 + x_idx * 1.5) * 0.02;
            
            // The character is black
            float dChar = 1.0;
            
            // 1. Hat (oval)
            float dHat = length(vec2(char_p.x, (char_p.y - 0.2) * 2.5)) - 0.12;
            dChar = min(dChar, dHat);
            
            // 2. Head/Body (complex curvy shape)
            // Top curve
            float dHeadTop = abs(length(vec2(char_p.x, char_p.y - 0.05)) - 0.2) - 0.04;
            if (char_p.y > 0.05) dChar = min(dChar, dHeadTop);
            
            // "Eyes" / loops
            float dEyeL = length(vec2(char_p.x + 0.08, char_p.y)) - 0.04;
            float dEyeR = length(vec2(char_p.x - 0.08, char_p.y)) - 0.04;
            float dEyes = min(dEyeL, dEyeR);
            // cut out the inside of eyes
            dEyes = max(dEyes, -(length(vec2(char_p.x + 0.08, char_p.y + 0.01)) - 0.02));
            dEyes = max(dEyes, -(length(vec2(char_p.x - 0.08, char_p.y + 0.01)) - 0.02));
            dChar = min(dChar, dEyes);
            
            // Bottom swoops
            float dSwoop = abs(sin(char_p.x * 10.0) * 0.1 - (char_p.y + 0.15)) - 0.04;
            if (char_p.y < 0.0 && char_p.x > -0.25 && char_p.x < 0.25) {
                dChar = min(dChar, dSwoop);
            }
            
            // Just roughly fill some areas to make it chunky
            if (length(vec2(char_p.x, char_p.y + 0.1)) < 0.15 && char_p.y > -0.1) dChar = min(dChar, 0.0);
            
            // Masking
            if (char_p.y < -0.25) dChar = 1.0;
            
            if (dChar < 0.0) {
                col = vec3(0.08); // almost black
            }
        }
    }

    // --- Text (OPENING HOURS) ---
    // Approx at p.y = -0.3
    if (abs(p.y + 0.3) < 0.05 && abs(p.x) < 0.4) {
        // Just draw some rough blocks for the text line
        float textPat = sin(p.x * 200.0);
        if (textPat > 0.5 && abs(p.y + 0.28) < 0.015) col = vec3(0.1);
        
        // 13:00 - 20:00 (bigger)
        float numPat = sin(p.x * 150.0);
        if (numPat > 0.3 && abs(p.y + 0.35) < 0.025) {
            if (abs(p.x) > 0.05) col = vec3(0.1); // the dash in middle is missing or smaller
        }
        if (abs(p.x) < 0.02 && abs(p.y + 0.35) < 0.01) col = vec3(0.1); // dash
    }

    // --- Bottom Text / Logos (@luvluvluv.seoul) ---
    if (abs(p.y + 0.6) < 0.1 && abs(p.x) < 0.3) {
        // Text line
        float textPat = sin(p.x * 250.0);
        if (textPat > 0.5 && abs(p.y + 0.58) < 0.01) col = vec3(0.1);
        
        // Small logos below text
        if (abs(p.y + 0.65) < 0.04) {
            float spacing = 0.12;
            float x_idx = floor((p.x + spacing * 1.5) / spacing);
            if (x_idx >= 0.0 && x_idx < 3.0) {
                vec2 lp = p;
                lp.x = mod(p.x + spacing * 0.5, spacing) - spacing * 0.5;
                lp.y += 0.65;
                // Animate logos slightly
                lp.y += sin(iTime * 3.0 + x_idx * 2.0) * 0.005;
                
                // Draw a small black pill/oval
                float dLogo = length(max(abs(lp) - vec2(0.02, 0.01), 0.0)) - 0.02;
                if (dLogo < 0.0) col = vec3(0.1);
                
                // Cutout in logo
                if (length(lp) < 0.015) col = vec3(0.65); // rough background color
            }
        }
    }

    // Add vignette
    col *= 1.0 - 0.2 * length(p);

    
    gl_FragColor = vec4(col, 1.0);
}
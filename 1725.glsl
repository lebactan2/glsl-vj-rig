void main() {
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;
    
    vec3 col = vec3(0.0);
    
    // Background: Storefront / Display Case Structure
    // Frame base
    col = vec3(0.2, 0.15, 0.1); // Dark brown wood/frame
    
    // Left display panel (vertical menu)
    if (p.x < -0.7 && p.y < 0.8 && p.y > -0.5) {
        col = vec3(0.85, 0.88, 0.88); // Light panel
        
        // Chinese characters / vertical text simulation
        float textAnim = sin(iTime + p.y*10.0);
        // Red text blocks
        if (abs(p.x + 0.9) < 0.05 && fract(p.y*4.0) < 0.5) {
            col = vec3(0.7, 0.2, 0.2); 
            if (textAnim > 0.5) col *= 0.8; // subtle blink
        }
        // Green text blocks
        if (abs(p.x + 0.8) < 0.05 && fract(p.y*6.0 + 0.5) < 0.5) {
            col = vec3(0.2, 0.5, 0.3);
            if (textAnim < -0.5) col *= 0.8;
        }
        // Blue text blocks
        if (abs(p.x + 0.85) < 0.15 && p.y > -0.4 && p.y < -0.2 && fract(p.y*20.0) < 0.4) {
            col = vec3(0.2, 0.4, 0.6);
        }
        
        // Frame edge
        if (p.x > -0.72 || p.y < -0.48 || p.y > 0.78) col = vec3(0.3, 0.2, 0.1);
    }
    
    // Main Display Case (Upper glass panel: Horse and Rider)
    if (p.x > -0.5 && p.x < 1.0 && p.y > 0.05 && p.y < 0.8) {
        // Sky/Background
        col = vec3(0.5, 0.7, 0.8); 
        
        // Water/Sea at the bottom
        if (p.y < 0.3) {
            col = vec3(0.2, 0.4, 0.7);
            // Animated waves
            float wave = sin(p.x*20.0 - iTime*3.0)*sin(p.y*50.0);
            if (wave > 0.5) col = vec3(0.8, 0.9, 1.0); // Whitecaps
        }
        
        // Island/Mountain background
        if (p.y > 0.3 && p.y < 0.4) {
            float mt = sin(p.x*10.0)*0.05 + 0.35;
            if (p.y < mt) col = vec3(0.4, 0.5, 0.4);
        }
        
        // The Horse and Rider (Center)
        vec2 hP = p - vec2(0.2, 0.4);
        
        // Horse body
        float horse = length(max(abs(hP) - vec2(0.12, 0.08), 0.0));
        if (horse < 0.05) col = vec3(0.3, 0.2, 0.15); // Brown horse
        // Horse neck/head
        if (length(hP - vec2(0.15, 0.15)) < 0.06) col = vec3(0.3, 0.2, 0.15);
        // Horse legs (animated gallop)
        float legAnim = sin(iTime*8.0)*0.05;
        if (length(hP - vec2(-0.1 + legAnim, -0.15)) < 0.03) col = vec3(0.2, 0.1, 0.05);
        if (length(hP - vec2(0.1 - legAnim, -0.15)) < 0.03) col = vec3(0.2, 0.1, 0.05);
        
        // Rider
        // Body
        if (length(hP - vec2(-0.05, 0.15)) < 0.06) col = vec3(0.7, 0.3, 0.3); // Red clothing
        // Head
        if (length(hP - vec2(-0.05, 0.25)) < 0.04) col = vec3(0.9, 0.8, 0.7); // Skin
        
        // Tree on the right
        if (length(p - vec2(0.7, 0.4)) < 0.15) {
            col = vec3(0.2, 0.5, 0.3); // Leaves
            // Trunk
            if (abs(p.x - 0.7) < 0.02 && p.y < 0.4 && p.y > 0.3) col = vec3(0.3, 0.2, 0.1);
        }
        
        // Frame edge
        if (p.x < -0.48 || p.x > 0.98 || p.y < 0.07 || p.y > 0.78) col = vec3(0.3, 0.2, 0.1);
    }
    
    // Lower Display Case (People Scene)
    if (p.x > -0.5 && p.x < 1.0 && p.y < -0.05 && p.y > -0.7) {
        col = vec3(0.6, 0.55, 0.5); // Room background
        
        // Floor
        if (p.y < -0.5) col = vec3(0.4, 0.35, 0.3);
        
        // Figures
        vec2 fP = p - vec2(0.2, -0.3);
        
        // Figure 1 (Standing/sitting left)
        if (length(max(abs(fP - vec2(-0.1, 0.05)) - vec2(0.05, 0.1), 0.0)) < 0.02) col = vec3(0.8, 0.2, 0.3); // Red robe
        if (length(fP - vec2(-0.1, 0.2)) < 0.03) col = vec3(0.9, 0.8, 0.7); // Head
        
        // Figure 2 (Kneeling center)
        if (length(max(abs(fP - vec2(0.1, -0.1)) - vec2(0.08, 0.05), 0.0)) < 0.02) col = vec3(0.2, 0.5, 0.8); // Blue robe
        if (length(fP - vec2(0.1, 0.0)) < 0.03) col = vec3(0.9, 0.8, 0.7); // Head
        
        // Object/Table right
        if (length(p - vec2(0.75, -0.45)) < 0.15) {
            col = vec3(0.1, 0.3, 0.2); // Dark green table/object
            // Animated texture on object
            if (fract(p.x*20.0 + p.y*15.0 - iTime) < 0.3) col = vec3(0.8, 0.8, 0.4); // Gold accents
        }
        
        // Frame edge
        if (p.x < -0.48 || p.x > 0.98 || p.y < -0.68 || p.y > -0.07) col = vec3(0.3, 0.2, 0.1);
    }
    
    // Curvy wooden dividers between sections
    if (abs(p.y - 0.0) < 0.05 && p.x > -0.5) {
        col = vec3(0.4, 0.25, 0.15); 
        // Wavy pattern
        float wave = sin(p.x * 10.0)*0.02;
        if (abs(p.y - wave) < 0.01) col = vec3(0.2, 0.1, 0.05); // Wood grain/carving line
    }
    
    // Lower items (baskets/bowls below the display)
    if (p.y < -0.7) {
        // Blue basket left
        if (length(max(abs(p - vec2(0.1, -0.9)) - vec2(0.15, 0.1), 0.0)) < 0.05 && p.y < -0.8) {
            col = vec3(0.2, 0.4, 0.8);
            // Basket weave pattern
            if (fract((p.x + p.y)*20.0) < 0.2 || fract((p.x - p.y)*20.0) < 0.2) col *= 0.8;
        }
        
        // White/Grey bowl right
        if (length(max(abs(p - vec2(0.6, -0.9)) - vec2(0.1, 0.05), 0.0)) < 0.05 && p.y < -0.85) {
            col = vec3(0.8, 0.8, 0.8);
            // Shadow inside bowl
            if (p.y > -0.88 && abs(p.x - 0.6) < 0.12) col = vec3(0.4);
        }
    }

    gl_FragColor = vec4(col, 1.0);
}
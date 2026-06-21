void main() {
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;
    
    vec3 col = vec3(0.92, 0.9, 0.88); // Paper background
    
    // Paper texture
    float paper = fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
    col -= paper * 0.03;
    
    vec2 fP = p;
    
    // Head outline (rough side/front profile)
    float headMask = length(vec2(fP.x * 0.9, fP.y * 1.0)) - 0.65;
    
    if (headMask < 0.0) {
        col = vec3(0.94, 0.92, 0.9); // Slightly lighter inside head
        
        // Hair curves outline
        if (fP.y > 0.5 && fract(fP.x*10.0 + sin(fP.y*20.0)) < 0.1) col = vec3(0.2);
        
        // Brain/Veins area (top left)
        if (fP.x < -0.1 && fP.y > 0.0) {
            float veinDist = sin(fP.x * 30.0 + sin(fP.y * 40.0)) * cos(fP.y * 30.0);
            // Animate blood pulsing in veins
            float pulse = sin(iTime*4.0 - length(fP)*10.0);
            if (abs(veinDist) < 0.15) {
                col = vec3(0.8, 0.3, 0.3); // Red veins
                if (pulse > 0.5) col = vec3(0.9, 0.4, 0.4); // Bright red pulse
            }
        }
        
        // The Heart Structure (Orange/Brown shapes)
        // Upper chambers
        float h1 = length(vec2(fP.x + 0.1, fP.y - 0.2)) - 0.18; 
        float h2 = length(vec2(fP.x - 0.1, fP.y + 0.3)) - 0.2; 
        float h3 = length(vec2(fP.x + 0.3, fP.y + 0.15)) - 0.2; 
        float h4 = length(vec2(fP.x + 0.4, fP.y - 0.1)) - 0.15; 
        
        // Main body
        float t1 = length(vec2(fP.x, fP.y)) - 0.12; 
        
        float heart = min(min(min(h1, h2), min(h3, h4)), t1);
        
        if (heart < 0.0 && fP.y < 0.5 && fP.x > -0.3) {
            col = vec3(0.8, 0.45, 0.25); // Brownish orange
            
            // Animate beating heart
            float beat = sin(iTime*5.0);
            if (beat > 0.8) col = vec3(0.85, 0.5, 0.3);
            
            // Inner details (white dots/labels)
            if (h2 < 0.0 && fract(fP.x * 20.0 + fP.y * 20.0) < 0.2) col = vec3(0.9);
            if (h3 < 0.0 && fract(fP.x * 20.0 - fP.y * 20.0) < 0.2) col = vec3(0.9);
            
            // Black outlines for heart chambers
            if (abs(heart) < 0.015) col = vec3(0.1);
        }
        
        // Ear/Side detail
        if (abs(length(vec2(fP.x - 0.5, fP.y - 0.3)) - 0.15) < 0.01) col = vec3(0.2);
    }
    
    // Outer Head outline drawing
    if (abs(headMask) < 0.01) col = vec3(0.2);
    
    // Label Texts (Simulated with scribbles)
    // Lines pointing to heart parts
    if (abs(length(vec2(fP.x - 0.2, fP.y - 0.6)) - 0.2) < 0.01 && fP.x > 0.0 && fP.y > 0.5) col = vec3(0.1, 0.2, 0.6); // Blue ink line
    if (abs(length(vec2(fP.x - 0.4, fP.y - 0.5)) - 0.1) < 0.01 && fP.x > 0.3 && fP.y > 0.4) col = vec3(0.1, 0.2, 0.6);
    
    // Text blocks (scribble math/labels)
    if (fP.y > 0.4 && fP.x < -0.3) { 
        if (sin(fP.x * 40.0 + fP.y * 10.0) * cos(fP.y * 40.0) > 0.7) col = vec3(0.1, 0.2, 0.6);
    }
    if (fP.y < -0.5 && fP.x > 0.1 && fP.x < 0.4) { 
        if (sin(fP.x * 50.0) * cos(fP.y * 50.0) > 0.7) col = vec3(0.1, 0.2, 0.6);
    }
    
    // Large bold text title on right
    if (fP.x > 0.6) {
        if (abs(fP.x - 0.7) < 0.05 && fP.y > -0.4 && fP.y < 0.4) {
            // Text block
            if (fract(fP.y * 20.0) < 0.3) col = vec3(0.2); 
        }
        if (abs(fP.x - 0.8) < 0.02 && fP.y > 0.0 && fP.y < 0.4) {
            if (fract(fP.y * 15.0) < 0.3) col = vec3(0.2);
        }
    }

    gl_FragColor = vec4(col, 1.0);
}
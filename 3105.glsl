void main() {
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;
    
    vec3 col = vec3(0.0);
    
    // Sky
    if (p.y > 0.4) {
        col = mix(vec3(0.7, 0.75, 0.8), vec3(0.85, 0.85, 0.8), p.y);
        
        // Animated moving clouds
        float cloudNoise = sin((p.x - iTime*0.05) * 5.0 + sin(p.y * 10.0)) * cos(p.y * 3.0);
        col += cloudNoise * 0.1;
        
        // Trees in distance
        if (p.x < -0.5 && p.y > 0.5) {
            float treeProfile = 0.6 + sin(p.x * 15.0) * 0.05 + cos(p.x * 30.0) * 0.02;
            if (p.y < treeProfile) col = vec3(0.2, 0.3, 0.2); 
            // Swaying trees
            if (p.y < treeProfile + sin(iTime + p.x*10.0)*0.01) col = vec3(0.25, 0.35, 0.25);
        }
    }
    
    // Roof behind
    if (p.y > 0.2 && p.y <= 0.4) {
        float roofLine = 0.4 + p.x * -0.1;
        if (p.y < roofLine) {
            col = vec3(0.6, 0.6, 0.55); 
            if (fract(p.x * 20.0) < 0.05) col *= 0.9;
        }
    }
    
    // The Cat
    vec2 catP = p - vec2(0.0, 0.4);
    if (catP.x > -0.05 && catP.x < 0.05 && catP.y > 0.0 && catP.y < 0.12) {
        col = vec3(0.1); // Black fur
        
        // Cat Head
        if (catP.y > 0.08) {
            // Ears
            if (abs(catP.x) > 0.02 && catP.y > 0.1) col = vec3(0.1); 
            
            // White face marking
            if (abs(catP.x) < 0.015 && catP.y < 0.1) col = vec3(0.9);
            
            // Blinking eyes
            float blink = smoothstep(0.95, 1.0, sin(iTime * 2.0));
            if (abs(abs(catP.x) - 0.01) < 0.005 && abs(catP.y - 0.09) < 0.005 * (1.0 - blink)) {
                col = vec3(0.8, 0.9, 0.2); // Greenish eyes
            }
        }
        // White chest
        if (catP.y > 0.03 && catP.y < 0.08 && abs(catP.x) < 0.02) {
            col = vec3(0.9);
        }
        
        // Swishing tail
        float tailAnim = sin(iTime * 3.0) * 0.02;
        if (catP.y < 0.02 && catP.x > 0.04 && catP.x < 0.1 + tailAnim) {
            float tailCurve = -(catP.x - 0.04)*0.5;
            if (abs(catP.y - tailCurve) < 0.01) col = vec3(0.1);
        }
    }
    
    // Main Wall (Weathered texture)
    if (p.y > -0.5 && p.y <= 0.3) {
        col = vec3(0.6, 0.6, 0.6); // Base concrete
        
        // Grungy streaks
        float drips = sin(p.x * 50.0) * sin(p.x * 12.0) + cos(p.x * 30.0);
        col -= drips * 0.05;
        
        // Peeling white paint
        if (p.y < 0.2 + p.x * 0.3 && p.y > -0.2 - p.x * 0.2) {
            col = mix(col, vec3(0.85, 0.85, 0.85), 0.7); 
            if (fract(p.x * 10.0 + p.y * 10.0) < 0.1) col *= 0.9;
        }
        
        // Time-based shifting shadow
        float shadowSweep = sin(p.x + iTime*0.5) * 0.1;
        if (p.y < -0.3 + shadowSweep) col *= 0.7;
    }
    
    // Exposed brick/broken wall at bottom
    if (p.y <= -0.5) {
        float edgeNoise = sin(p.x * 20.0) * 0.05 + cos(p.x * 45.0) * 0.02;
        if (p.y < -0.5 + edgeNoise) {
            
            col = vec3(0.3, 0.3, 0.3); // Dark mortar
            
            vec2 brickGrid = vec2(p.x * 4.0, p.y * 8.0);
            vec2 bId = floor(brickGrid);
            float holeChance = fract(sin(dot(bId, vec2(12.9898, 78.233))) * 43758.5453);
            
            if (holeChance > 0.5) {
                vec2 bF = fract(brickGrid);
                if (bF.x > 0.2 && bF.x < 0.8 && bF.y > 0.2 && bF.y < 0.8) {
                    col = vec3(0.6, 0.3, 0.2); // Red brick
                    if (fract(bF.x * 5.0) < 0.1) col *= 0.8;
                }
            }
            
            float dirt = sin(p.x * 80.0) * 0.5 + 0.5;
            col *= 0.8 + 0.2 * dirt;
        }
    }

    gl_FragColor = vec4(col, 1.0);
}
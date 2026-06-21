void main() {
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;
    
    vec3 col = vec3(0.0);
    
    // Background wall (white/grey)
    col = vec3(0.85, 0.85, 0.85);
    
    // Ground path (reddish brick pavement)
    if (p.y < -0.6) {
        col = vec3(0.5, 0.35, 0.3);
        
        // Perspective grid for bricks
        vec2 floorUV = vec2(p.x / (abs(p.y) + 0.1), 1.0 / (abs(p.y) + 0.1));
        float brickX = fract(floorUV.x * 10.0);
        float brickY = fract(floorUV.y * 10.0 + iTime*(0.5 + iLevel*4.0) + iBeat*0.3); // Scrolling floor (audio)
        if (brickX > 0.9 || brickY > 0.9) col = vec3(0.3, 0.2, 0.15); // Mortar lines
    } 
    // Right wall/column (stone texture)
    else if (p.x > 1.2) {
        col = vec3(0.6, 0.6, 0.55);
        // Stone blocks
        vec2 stoneP = p * vec2(2.0, 5.0);
        stoneP.x += mod(floor(stoneP.y), 2.0) * 0.5;
        if (fract(stoneP.x) > 0.9 || fract(stoneP.y) > 0.9) col = vec3(0.4, 0.4, 0.35);
        
        // Texture
        col -= 0.1 * fract(sin(dot(p*100.0, vec2(12.9898, 78.233))) * 43758.5453);
    }
    // Main White Gate Structure
    else if (p.y < 0.6) {
        col = vec3(0.9, 0.9, 0.9); // White paint
        
        // Gate grid coordinates
        vec2 gP = p;
        // Symmetry for two doors
        gP.x = abs(gP.x) - 0.6;
        
        float iron = 0.0;
        
        // Main bounding frame
        if (abs(p.x) < 1.15 && abs(p.y + 0.1) < 0.6) {
             // Frame edges
             if (abs(abs(p.x) - 1.1) < 0.03 || abs(abs(p.y + 0.1) - 0.55) < 0.03) iron = 1.0;
             // Center split
             if (abs(p.x) < 0.02) iron = 1.0;
             
             // Sunburst / Fan pattern in each half
             float angle = atan(gP.y + 0.1, gP.x);
             float dist = length(gP + vec2(0.0, 0.1));
             
             // Concentric arcs
             if (abs(dist - 0.4) < 0.02 && gP.y > -0.1) iron = 1.0;
             if (abs(dist - 0.5) < 0.02 && gP.y > -0.1) iron = 1.0;
             
             // Rays (animating outward)
             float rayAnim = fract(dist - iTime*0.5);
             if (dist < 0.5 && gP.y > -0.1 && fract(angle * 4.0) < 0.1) {
                 iron = 1.0;
                 if (rayAnim < 0.2) col = vec3(1.0); // Highlight running along rays
             }
             
             // Lower section curls/swirls
             if (p.y < -0.1 && p.y > -0.5) {
                 vec2 swirlP = fract(p * 4.0 + vec2(iTime*0.2, 0.0)) - 0.5;
                 if (abs(length(swirlP) - 0.3) < 0.04) iron = 1.0;
                 // Center of swirl
                 if (length(swirlP) < 0.08) iron = 1.0;
             }
        }
        
        if (iron > 0.0) {
            // White painted metal, slightly weathered
            col = vec3(0.85, 0.85, 0.85); 
            // Rust spots
            float rust = fract(sin(dot(p*80.0, vec2(12.9898, 78.233))) * 43758.5453);
            if (rust > 0.9) col = vec3(0.6, 0.4, 0.2);
            
            // Shadows
            col *= 0.9;
        } else if (abs(p.x) < 1.15 && abs(p.y + 0.1) < 0.6) {
            // Solid backing or darker interior behind gate
            col = vec3(0.8, 0.8, 0.8);
        }
        
        // Small "BORNA" sign
        if (p.x > 0.1 && p.x < 0.4 && p.y > 0.45 && p.y < 0.55) {
            col = vec3(0.9, 0.9, 0.9); // Sign bg
            // Red text block
            if (abs(p.y - 0.5) < 0.02 && p.x > 0.15 && p.x < 0.35) col = vec3(0.8, 0.1, 0.1);
        }
    }
    
    // Top foliage (overhanging green leaves)
    if (p.y > 0.3) {
        float leaves = sin(p.x * 15.0 + iTime)*cos(p.y * 15.0) + sin(p.x * 30.0 + p.y * 10.0 - iTime)*0.5;
        // Make foliage denser at top left
        float density = p.y + (1.0 - p.x)*0.5; 
        
        if (leaves > -0.2 && density > 1.0) col = vec3(0.2, 0.4, 0.1); // Dark leaves
        if (leaves > 0.3 && density > 0.8) col = vec3(0.4, 0.6, 0.2); // Mid leaves
        if (leaves > 0.6 && density > 0.6) col = vec3(0.6, 0.8, 0.3); // Bright leaves
    }
    
    // Motorcycle on the right (Scooter)
    vec2 scP = p - vec2(0.9, -0.4);
    if (length(max(abs(scP) - vec2(0.35, 0.3), 0.0)) < 0.15) {
        // Only draw if we're in bounding box
        float mcBody = 0.0;
        
        // Front fairing
        if (length(scP - vec2(-0.2, 0.1)) < 0.25) mcBody = 1.0;
        // Headlight/handlebar area
        if (length(scP - vec2(-0.3, 0.4)) < 0.15) {
            mcBody = 1.0;
            // Mirror
            if (length(scP - vec2(-0.4, 0.6)) < 0.05) col = vec3(0.1, 0.3, 0.2); // Green mirror reflection
        }
        // Seat
        if (length(scP - vec2(0.2, 0.2)) < 0.2) mcBody = 2.0; // Black seat
        
        if (mcBody == 1.0) {
            col = vec3(0.6, 0.3, 0.1); // Bronze/Brown body
            // Metallic highlight
            if (scP.y > 0.0 && scP.x < 0.0) col += 0.2;
        } else if (mcBody == 2.0) {
            col = vec3(0.15); // Seat
        }
        
        // Wheels
        if (length(scP - vec2(-0.1, -0.3)) < 0.15) col = vec3(0.1);
        if (length(scP - vec2(0.3, -0.3)) < 0.15) col = vec3(0.1);
    }

    gl_FragColor = vec4(col, 1.0);
}
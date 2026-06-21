float hash(vec2 p) { return fract(sin(dot(p + iTime*0.05, vec2(12.9898, 78.233))) * 43758.5453); }
float noise(vec2 p) {
    vec2 i = floor(p), f = fract(p);
    vec2 u = f*f*(3.0-2.0*f);
    return mix(mix(hash(i + vec2(0.0,0.0)), hash(i + vec2(1.0,0.0)), u.x),
               mix(hash(i + vec2(0.0,1.0)), hash(i + vec2(1.0,1.0)), u.x), u.y);
}

void main() {
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;
    
    // Background: Painted Blue Sky
    vec3 col = mix(vec3(0.3, 0.6, 0.85), vec3(0.2, 0.5, 0.8), uv.y);
    
    // Painted Clouds
    // Use noise to create streaky, horizontal cloud layers
    float cloudNoise1 = noise(p * vec2(2.0, 15.0));
    float cloudNoise2 = noise(p * vec2(4.0, 20.0) + vec2(10.0, 0.0));
    
    // Animation: Clouds drifting slowly
    float drift = iTime * 0.05;
    
    float cloudShape = smoothstep(0.4, 0.6, cloudNoise1 * sin(p.y * 20.0 + drift * 10.0));
    cloudShape += smoothstep(0.5, 0.7, cloudNoise2 * cos(p.y * 30.0 - drift * 5.0)) * 0.5;
    
    if (p.y > 0.0) {
        // Blend white clouds into blue sky
        col = mix(col, vec3(0.95, 0.95, 0.98), cloudShape * 0.8);
        // Brush stroke texture on clouds
        col *= 1.0 - 0.05 * noise(p * vec2(50.0, 200.0));
    }
    
    // Painted Birds (Flock in 'V' formation)
    // Create a repeating coordinate system for birds, but mask it to a specific area
    vec2 bp = p - vec2(0.5, 0.6); // Center of flock
    // Rotate to align with flight path
    float a = -0.5; // Angle
    bp = vec2(bp.x * cos(a) - bp.y * sin(a), bp.x * sin(a) + bp.y * cos(a));
    
    // Grid for birds
    vec2 birdGrid = fract(bp * vec2(6.0, 6.0)) - 0.5;
    vec2 birdID = floor(bp * vec2(6.0, 6.0));
    
    // V-shape mask
    float vMask = abs(birdID.y) - birdID.x * 0.5;
    
    if (abs(vMask) < 1.0 && birdID.x > -2.0 && birdID.x < 4.0) {
        // Animation: Birds flapping
        float flap = sin(iTime * 10.0 + birdID.x * 2.0 + birdID.y * 3.0);
        
        // Draw individual bird (V shape)
        float wingY = birdGrid.y + abs(birdGrid.x) * (0.5 + flap * 0.2);
        float bird = length(max(abs(vec2(birdGrid.x, wingY)) - vec2(0.06, 0.01), 0.0));
        
        // Bird body/head
        bird = min(bird, length(birdGrid - vec2(0.0, 0.02)) - 0.02);
        
        if (bird < 0.01) {
            col = vec3(0.1); // Black painted bird
            // Rough brush edge
            if (noise(p * 200.0) > 0.6) col = mix(col, vec3(0.3, 0.6, 0.85), 0.5);
        }
    }
    
    // Large Rock Formation (Bonsai/Penjing style)
    // Create jagged, vertical peaks
    float rockHeight = -0.5;
    // Peak 1 (Left)
    rockHeight += 0.9 * exp(-15.0 * pow(p.x + 0.9, 2.0)); 
    // Peak 2 (Mid-Left, Tallest)
    rockHeight += 1.3 * exp(-20.0 * pow(p.x + 0.4, 2.0));       
    // Peak 3 (Mid-Right)
    rockHeight += 0.8 * exp(-12.0 * pow(p.x - 0.1, 2.0)); 
    // Peak 4 (Right)
    rockHeight += 0.5 * exp(-15.0 * pow(p.x - 0.6, 2.0));
    
    // Add jaggedness
    rockHeight += 0.15 * sin(p.x * 20.0) + 0.1 * cos(p.x * 45.0);
    // Add noise displacement
    rockHeight += 0.1 * noise(p * 15.0);
    
    if (p.y < rockHeight) {
        // Base rock color (Light grey/white limestone)
        col = vec3(0.7, 0.7, 0.75);
        
        // Rock Texture (Vertical striations, holes, and shadows)
        float rTex1 = noise(p * vec2(10.0, 5.0));
        float rTex2 = noise(p * vec2(30.0, 10.0));
        
        // Combine textures for a rough, pitted look (like Scholar's rocks)
        col = mix(col, vec3(0.85, 0.85, 0.9), rTex1); // Highlights
        col = mix(col, vec3(0.4, 0.4, 0.4), rTex2 * 0.5); // Shadows/pits
        
        // Deep vertical crevices
        float crevice = abs(sin(p.x * 30.0 + noise(p*10.0)*8.0));
        if (crevice < 0.15) {
            col *= 0.4 + crevice * 3.0; // Deep shadow
        }
        
        // Horizontal cracks
        float crack = abs(cos(p.y * 25.0 + noise(p*5.0)*5.0));
        if (crack < 0.05) col *= 0.6;
        
        // Shadowing from peaks (fake ambient occlusion)
        float ao = smoothstep(0.0, 0.5, rockHeight - p.y);
        col *= 1.0 - 0.3 * ao;
        
        // Brown dirt/roots near the bottom
        if (p.y < -0.7 + noise(p*5.0)*0.2) {
            col = mix(col, vec3(0.3, 0.2, 0.1), 0.6);
            
            // Hanging roots/vines
            float roots = abs(sin(p.x * 50.0 + p.y * 10.0));
            if (roots < 0.1 && noise(p*20.0) > 0.5) col = vec3(0.15, 0.1, 0.05);
        }
        
        // Plants/Ferns growing on the rocks
        // Distribute plants based on noise and depth
        float plantZone = noise(p * vec2(8.0, 8.0));
        if (plantZone > 0.7 && p.y < rockHeight - 0.1) {
            
            // Create fern/leaf shape
            vec2 leafP = fract(p * vec2(15.0, 15.0)) - 0.5;
            float leafID = floor(p.x * 15.0) + floor(p.y * 15.0);
            
            // Randomly rotate leaves
            float angle = leafID * 2.0;
            leafP = vec2(leafP.x * cos(angle) - leafP.y * sin(angle), leafP.x * sin(angle) + leafP.y * cos(angle));
            
            // Animation: Leaves rustling in wind
            float rustle = sin(iTime * 4.0 + leafID) * 0.1;
            leafP.x += rustle * leafP.y; // Bend top of leaf
            
            float leaf = length(max(abs(leafP) - vec2(0.05, 0.3), 0.0)); // Base shape
            // Serrated edge
            leaf += 0.05 * sin(leafP.y * 100.0);
            
            if (leaf < 0.02) {
                // Different plant colors (some green, some reddish/snake plant)
                if (mod(leafID, 3.0) == 0.0) {
                    col = vec3(0.5, 0.2, 0.2); // Reddish plant (Coleus)
                    if (abs(leafP.x) < 0.01) col = vec3(0.2, 0.4, 0.2); // Green center
                } else if (mod(leafID, 4.0) == 0.0) {
                     col = vec3(0.2, 0.4, 0.2); // Snake plant (Sansevieria)
                     // Yellow edges
                     if (abs(leafP.x) > 0.03) col = vec3(0.7, 0.7, 0.2);
                } else {
                    col = vec3(0.2, 0.5, 0.2); // Standard green fern
                    // Highlight
                    if (leafP.x > 0.0) col = vec3(0.4, 0.7, 0.3);
                }
                
                // Shadow underneath
                col *= 0.5 + 0.5 * smoothstep(-0.3, 0.0, leafP.y);
            }
        }
    }
    
    // Vignette
    col *= 1.0 - 0.3 * length(p);

    gl_FragColor = vec4(col, 1.0);
}
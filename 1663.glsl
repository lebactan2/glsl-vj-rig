void main() {
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    // Background: Dark frame structure
    vec3 col = vec3(0.15, 0.15, 0.18); 
    
    // Top blue sign area
    if (p.y > 0.8) {
        col = vec3(0.2, 0.5, 0.75); // Blue background
        // Sign text/pattern
        float signText = sin(p.x*20.0 + iTime*2.0)*sin(p.y*20.0);
        if (signText > 0.5) col *= 0.8; 
    }
    // Bottom pavement
    else if (p.y < -0.85) {
        col = vec3(0.35, 0.35, 0.35); // Concrete
        // Pebbles/texture
        float pebble = fract(sin(dot(floor(p*50.0), vec2(12.9898, 78.233))) * 43758.5453);
        col -= 0.1 * pebble;
    }
    else {
        // Decorative Iron Gate
        
        // Grid setup
        vec2 gridP = p * vec2(3.0, 4.0);
        vec2 fGrid = fract(gridP) - 0.5;
        vec2 iGrid = floor(gridP);
        
        float iron = 0.0;
        vec3 ironCol = vec3(0.3, 0.4, 0.4); // Rusty/painted metal
        
        // Main grid frame
        if (abs(fGrid.x) > 0.46 || abs(fGrid.y) > 0.46) iron = 1.0;
        
        // Procedural decorative patterns per cell
        float cellType = fract(sin(dot(iGrid, vec2(12.9898, 78.233))) * 43758.5453);
        
        // Pattern 1: Circles
        if (cellType < 0.3) {
            float r = length(fGrid);
            if (abs(r - 0.3) < 0.03) iron = 1.0;
            // Connecting line
            if (abs(fGrid.x) < 0.02) iron = 1.0;
            
            // Flower details animated
            float angle = atan(fGrid.y, fGrid.x);
            float petals = cos(angle * 8.0 + iTime);
            if (r < 0.3 && r > 0.25 && petals > 0.5) ironCol = vec3(0.7, 0.8, 0.5); // Greenish painted detail
        } 
        // Pattern 2: Diamonds
        else if (cellType < 0.6) {
            float d = abs(fGrid.x) + abs(fGrid.y);
            if (abs(d - 0.35) < 0.03) iron = 1.0;
            
            // Inner diamond pulsating
            if (abs(d - 0.15 - 0.05*sin(iTime*2.0 + iGrid.x)) < 0.02) ironCol = vec3(0.6, 0.7, 0.8); // Blueish detail
        } 
        // Pattern 3: Bricks/Rectangles
        else {
            if (abs(fGrid.x) < 0.02 || abs(fGrid.y) < 0.02) iron = 1.0;
            if (abs(fGrid.y - 0.25) < 0.02 || abs(fGrid.y + 0.25) < 0.02) iron = 1.0;
            if (fGrid.y > 0.0 && abs(fGrid.x - 0.25) < 0.02) iron = 1.0;
            if (fGrid.y < 0.0 && abs(fGrid.x + 0.25) < 0.02) iron = 1.0;
        }
        
        // Draw the iron gate
        if (iron > 0.0) {
            col = ironCol; 
            // Highlight/Shadow for 3D feel
            if (fGrid.x > 0.46 || fGrid.y > 0.46) col *= 0.6;
            if (fGrid.x < -0.46 || fGrid.y < -0.46) col *= 1.4;
        } else {
            // Dark mesh behind the iron
            float mesh = step(0.8, fract(p.x * 100.0)) + step(0.8, fract(p.y * 100.0));
            col = vec3(0.1) + 0.05 * mesh;
        }
        
        // Red Warning Sign in the middle
        if (abs(p.x) < 0.35 && abs(p.y + 0.1) < 0.18) {
            // Sign background
            col = vec3(0.85, 0.15, 0.15); 
            
            // White text lines (simulated)
            // Title
            if (abs(p.y + 0.05) < 0.04 && fract(p.x*25.0) < 0.7 && abs(p.x) < 0.3) {
                col = vec3(0.95, 0.95, 0.2); // Yellow title
            }
            // Subtitles
            if (abs(p.y + 0.13) < 0.015 && fract(p.x*30.0) < 0.6 && abs(p.x) < 0.25) col = vec3(1.0); 
            if (abs(p.y + 0.18) < 0.015 && fract(p.x*30.0) < 0.6 && abs(p.x) < 0.28) col = vec3(1.0); 
            
            // Border
            if (max(abs(p.x) - 0.33, abs(p.y + 0.1) - 0.16) > 0.0) {
                col = vec3(0.95, 0.95, 0.2); // Yellow border
            }
        }
    }

    gl_FragColor = vec4(col, 1.0);
}
void main() {
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(0.0);
    
    // Background wall
    col = vec3(0.9, 0.9, 0.9); // White wall base
    
    // Concrete texture
    float concreteTex = fract(sin(dot(p*100.0, vec2(12.9898, 78.233))) * 43758.5453);
    col -= 0.1 * concreteTex;
    
    // Darker lower section
    if (p.y < -0.8) {
        col = vec3(0.4, 0.4, 0.45); // Dark grey concrete path
        float groundTex = fract(sin(dot(p*50.0, vec2(12.9898, 78.233))) * 43758.5453);
        col -= 0.15 * groundTex;
    }
    
    // Blue ornate iron gate
    vec2 gateP = p * vec2(4.0, 4.0);
    vec2 fGate = fract(gateP) - 0.5;
    vec2 iGate = floor(gateP);
    
    float iron = 0.0;
    
    // Check bounds for gate
    if (p.x > -1.2 && p.x < 1.2 && p.y < 0.6 && p.y > -0.8) {
        // Main grid lines
        if (abs(fGate.x) > 0.46 || abs(fGate.y) > 0.46) iron = 1.0;
        
        // Complex star/cross pattern
        float d1 = abs(fGate.x + fGate.y);
        float d2 = abs(fGate.x - fGate.y);
        
        // Diagonal cross
        if (abs(d1) < 0.04 || abs(d2) < 0.04) iron = 1.0;
        
        // Inner circle/diamond pattern based on grid cell
        float centerDist = length(fGate);
        if (centerDist < 0.25 && centerDist > 0.2) iron = 1.0;
        
        // Animated pattern detail
        float cellAnim = sin(iTime + iGate.x*10.0 + iGate.y*10.0);
        if (cellAnim > 0.5 && centerDist < 0.15) {
            // Inner small cross
            if (abs(fGate.x) < 0.02 || abs(fGate.y) < 0.02) iron = 1.0;
        }
        
        // Frame borders
        if (p.y > 0.55 || p.y < -0.75 || p.x > 1.15 || p.x < -1.15) iron = 1.0;
    }
    
    if (iron > 0.0) {
        // Teal/blue metal color
        col = vec3(0.2, 0.6, 0.6);
        // Bevel/highlight
        if (fGate.x > 0.0 && fGate.y > 0.0) col += 0.1;
        if (fGate.x < 0.0 && fGate.y < 0.0) col -= 0.1;
    }
    
    // House number sign "27H"
    if (p.x < -0.9 && p.x > -1.4 && p.y > 0.0 && p.y < 0.2) {
        col = vec3(0.7, 0.6, 0.3); // Brass/gold plaque
        if (fract(p.x*20.0 + iTime*0.5) < 0.1) col = vec3(0.9, 0.8, 0.4); // Shine
        
        // Number text roughly
        if (abs(p.y - 0.1) < 0.05 && p.x > -1.3 && p.x < -1.0) {
            // Dark text
            if (fract(p.x * 10.0) < 0.4) col = vec3(0.2, 0.2, 0.1);
        }
    }
    
    // Plant on the left (Palm tree like)
    vec2 plantP = p - vec2(-1.2, -0.6);
    
    // Pot
    if (length(max(abs(plantP - vec2(0.0, 0.1)) - vec2(0.2, 0.2), 0.0)) - 0.05 < 0.0 && plantP.y < 0.3) {
        col = vec3(0.1, 0.2, 0.6); // Blue pot
        // Pot texture
        if (fract(plantP.y*20.0) < 0.2) col *= 0.8;
    }
    
    // Stem
    if (abs(plantP.x) < 0.04 && plantP.y > 0.3 && plantP.y < 1.0) {
        col = vec3(0.5, 0.6, 0.3); // Green stem
        // Stem segments
        if (fract(plantP.y*15.0 - iTime) < 0.2) col = vec3(0.4, 0.5, 0.2);
    }
    
    // Palm leaves
    if (plantP.y > 0.8) {
        vec2 leafOrig = plantP - vec2(0.0, 0.8);
        float r = length(leafOrig);
        float a = atan(leafOrig.y, leafOrig.x);
        
        // Swaying animation
        float sway = sin(iTime + a*2.0)*0.1;
        
        // Fronds
        float fronds = sin(a*12.0 + sway*10.0);
        if (r < 0.8 && r > 0.1 && fronds > 0.6) {
            col = vec3(0.3, 0.6, 0.2);
            if (fronds > 0.9) col += 0.1; // Highlight
        }
    }
    
    // Overhanging vines/leaves top
    if (p.y > 0.6) {
        float vineTex = sin(p.x * 20.0 + iTime*0.5)*cos(p.y * 30.0) + sin(p.x * 50.0)*0.5;
        if (vineTex > 0.2) col = vec3(0.2, 0.4, 0.2); // Dark green leaf
        else if (vineTex > 0.0) col = vec3(0.4, 0.6, 0.3); // Light green leaf
        else {
             // Sky behind leaves
             col = mix(col, vec3(0.6, 0.8, 0.9), 0.5); 
        }
    }

    gl_FragColor = vec4(col, 1.0);
}
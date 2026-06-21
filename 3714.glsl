void main() {
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;
    
    // Infinite scrolling downward
    float scrollSpeed = 1.0;
    vec2 scrollP = p;
    scrollP.y += iTime * scrollSpeed;
    
    vec3 col = vec3(0.2, 0.2, 0.22); // Asphalt base
    
    // Asphalt noise
    float noise = fract(sin(dot(scrollP * 150.0, vec2(12.9898, 78.233))) * 43758.5453);
    col += (noise - 0.5) * 0.15;
    
    // Manhole cover top (Repeats with scroll)
    vec2 manholeP = scrollP;
    manholeP.y = fract((manholeP.y + 1.0)/3.0)*3.0 - 1.0; // Repeat every 3 units
    if (length(manholeP - vec2(0.0, 1.3)) < 0.35) {
        col = vec3(0.15);
        // Pattern on cover
        if (fract(manholeP.x * 20.0 + manholeP.y * 20.0) < 0.2) col *= 0.8;
    }
    
    // Arrow Shape SDF (Repeats)
    vec2 arrP = scrollP;
    arrP.y = fract((arrP.y + 1.5)/3.0)*3.0 - 1.5;
    
    // Left vertical stroke
    float arrowDist = max(abs(arrP.x + 0.5) - 0.15, abs(arrP.y - 0.3) - 0.6);
    // Diagonal stroke
    vec2 pRot = mat2(0.707, -0.707, 0.707, 0.707) * (arrP - vec2(-0.2, -0.1));
    float box2 = max(abs(pRot.x) - 0.3, abs(pRot.y) - 0.2);
    // Right arrow head
    float tri1 = max(abs(arrP.x - 0.4) - 0.3, arrP.y + arrP.x*1.5 - 0.8);
    tri1 = max(tri1, -arrP.y - 0.5);
    
    arrowDist = min(arrowDist, min(box2, tri1));
    float mask = smoothstep(0.01, -0.01, arrowDist);
    
    // Cracks (Voronoi approximation)
    vec2 vp = arrP * 10.0;
    vec2 i = floor(vp);
    vec2 f = fract(vp);
    float minDist = 1.0;
    for(int y=-1; y<=1; y++) {
        for(int x=-1; x<=1; x++) {
            vec2 neighbor = vec2(float(x), float(y));
            vec2 point = fract(sin(vec2(dot(i + neighbor, vec2(127.1,311.7)), dot(i + neighbor, vec2(269.5,183.3)))) * 43758.5453);
            vec2 diff = neighbor + point - f;
            float dist = length(diff);
            minDist = min(minDist, dist);
        }
    }
    float cracks = smoothstep(0.05, 0.08, minDist);
    
    if (mask > 0.0) {
        col = vec3(0.85, 0.85, 0.85) * cracks; // White paint with cracks
    }
    
    // Feet and clothes (Fixed position, mimicking walking)
    float walkCycle = sin(iTime * scrollSpeed * 5.0);
    
    // Left clothes swaying
    if (p.x < -0.3 && p.y < -0.4 + walkCycle*0.05) {
        col = vec3(0.05); // Black skirt
        if (fract(p.y*10.0 + iTime*2.0) < 0.1) col *= 1.2; // Fabric folds
    }
    
    // Left shoe stepping
    float leftStep = max(0.0, -walkCycle);
    vec2 lShoeP = p - vec2(-0.4, -0.85 + leftStep * 0.1);
    if (length(lShoeP) < 0.15) {
        col = vec3(0.1);
        if (length(lShoeP - vec2(0.05, 0.05)) < 0.05) col = vec3(0.8, 0.3, 0.1); 
    }
    
    // Right shoe stepping
    float rightStep = max(0.0, walkCycle);
    vec2 rShoeP = p - vec2(0.4, -0.85 + rightStep * 0.1);
    if (length(rShoeP) < 0.15) {
        col = vec3(0.1);
        if (length(rShoeP - vec2(-0.05, 0.05)) < 0.05) col = vec3(0.8, 0.3, 0.1); 
    }

    gl_FragColor = vec4(col, 1.0);
}
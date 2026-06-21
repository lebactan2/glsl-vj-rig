void main() {
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;
    
    vec3 col = vec3(1.0); // White background
    
    // Animation offsets for floating effect
    float bob1 = sin(iTime * 1.5 + 0.0) * 0.05;
    float bob2 = sin(iTime * 1.2 + 1.0) * 0.05;
    float bob3 = sin(iTime * 1.8 + 2.0) * 0.05;
    float bob4 = sin(iTime * 1.4 + 3.0) * 0.05;
    float bob5 = sin(iTime * 1.6 + 4.0) * 0.05;
    
    // 1. Blue patterned dress (Left)
    vec2 p1 = p - vec2(-0.7, 0.1 + bob1);
    float dress1 = max(abs(p1.x) - 0.25, abs(p1.y) - 0.6);
    if (dress1 < 0.0) {
        col = vec3(0.1, 0.2, 0.6);
        // Pattern with shimmer
        float pat1 = fract(sin(p1.x*50.0 + p1.y*20.0 + iTime)*43758.5);
        if (pat1 > 0.8) col = vec3(0.3, 0.4, 0.8);
        col += vec3(0.2) * pow(abs(sin(p1.x*10.0 + p1.y*10.0 - iTime*3.0)), 5.0); // Shimmer
        // Cutout for neck
        if (length(p1 - vec2(0.0, 0.6)) < 0.1) col = vec3(1.0);
    }
    
    // 2. Grey suit sitting (Center)
    vec2 p2 = p - vec2(-0.1, -0.2 + bob2);
    float suit2 = max(abs(p2.x) - 0.2, abs(p2.y) - 0.3); // torso
    float leg2 = max(abs(p2.x + 0.1) - 0.1, abs(p2.y + 0.4) - 0.3); // legs crossed
    if (min(suit2, leg2) < 0.0) {
        col = vec3(0.4, 0.45, 0.5);
        // Lapels
        if (abs(p2.x) < 0.05 && p2.y > 0.0) col = vec3(1.0); // shirt
        if (abs(p2.x) < 0.02 && p2.y > 0.0) col = vec3(0.8, 0.1, 0.1); // tie
        // Neck cutout
        if (length(p2 - vec2(0.0, 0.35)) < 0.1) col = vec3(1.0);
    }
    
    // 3. Maroon dress (Center right, bottom)
    vec2 p3 = p - vec2(0.3, -0.4 + bob3);
    float dress3 = max(abs(p3.x) - 0.15, abs(p3.y) - 0.5);
    if (dress3 < 0.0) {
        col = vec3(0.5, 0.1, 0.2); // Maroon
        // Wrinkles moving
        if (fract(p3.y * 10.0 + sin(p3.x*20.0 + iTime*2.0)) < 0.1) col *= 0.8;
        // Neck
        if (length(p3 - vec2(0.0, 0.5)) < 0.08) col = vec3(1.0);
    }
    
    // 4. Black floral dress (Far right)
    vec2 p4 = p - vec2(0.7, -0.1 + bob4);
    float dress4 = max(abs(p4.x) - 0.2, abs(p4.y) - 0.6);
    if (dress4 < 0.0) {
        col = vec3(0.1);
        // Floral pattern animating
        float noise = fract(sin(p4.x*40.0 + iTime*0.5)*cos(p4.y*40.0 + iTime*0.5)*10.0);
        if (noise > 0.7) col = vec3(0.8, 0.2, 0.3); // Red flowers
        else if (noise > 0.6) col = vec3(0.5, 0.5, 0.5); // Grey leaves
        // Neck
        if (length(p4 - vec2(0.0, 0.6)) < 0.08) col = vec3(1.0);
    }
    
    // 5. Black formal Ao Dai top right
    vec2 p5 = p - vec2(0.4, 0.6 + bob5);
    float dress5 = max(abs(p5.x) - 0.2, abs(p5.y) - 0.3);
    if (dress5 < 0.0) {
        col = vec3(0.05); // Very dark blue/black
        // Silver pattern shimmering
        float pat5 = fract(p5.x*30.0 + sin(p5.y*30.0 + iTime));
        if (pat5 < 0.1 && p5.y < 0.0) col = vec3(0.8 + 0.2*sin(iTime*5.0));
        if (length(p5 - vec2(0.0, 0.35)) < 0.1) col = vec3(1.0);
    }

    gl_FragColor = vec4(col, 1.0);
}
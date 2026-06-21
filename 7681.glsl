void main() {
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;
    
    vec3 col = vec3(0.0);
    
    // Background: Bright blue sky with subtle clouds
    col = vec3(0.4, 0.7, 0.9);
    col += 0.1 * sin(p.x * 5.0 + iTime * 0.2) * sin(p.y * 3.0);
    
    // Lower left: Temple roof
    if (p.x + p.y < -0.2) {
        col = vec3(0.7, 0.3, 0.2); // reddish roof tiles
        // Animate tile pattern slightly
        vec2 tileP = p + vec2(iTime*0.05, 0.0);
        if (fract(tileP.x * 10.0 - tileP.y * 10.0) < 0.1) col *= 0.8; // tile lines
        if (fract(tileP.x * 5.0 + tileP.y * 5.0) < 0.05) col *= 0.7;
    }
    
    // Dragon
    vec3 dragonCol = vec3(0.9, 0.75, 0.2); // golden yellow
    float isDragon = 0.0;
    
    // Apply a wave animation to the dragon's body coordinates
    vec2 dp = p;
    dp.y += sin(dp.x * 4.0 + iTime * 2.0) * 0.05;
    
    // Main body curve (diagonal across)
    float bodyCurve = sin(dp.x * 3.0) * 0.3;
    if (abs(dp.y - bodyCurve - 0.1) < 0.1 && dp.x > -0.6 && dp.x < 0.8) {
        isDragon = 1.0;
        // Scales
        if (fract(dp.x * 20.0) < 0.2 || fract(dp.y * 20.0) < 0.2) {
            dragonCol *= 0.8;
        }
    }
    
    // Dragon head (top right)
    vec2 headP = p - vec2(0.7, sin(0.7 * 3.0) * 0.3 + 0.1 + sin(0.7 * 4.0 + iTime * 2.0) * 0.05);
    if (length(headP) < 0.15) {
        isDragon = 1.0;
        dragonCol = vec3(0.8, 0.6, 0.1);
        // Eye
        if (length(headP - vec2(-0.05, 0.05)) < 0.03) dragonCol = vec3(1.0, 0.0, 0.0); // red eye
        // Horns/whiskers
        if (headP.y > 0.1 && headP.x > 0.0) dragonCol = vec3(0.6, 0.8, 0.3); // green accents
    }
    
    // Legs/claws
    if (abs(p.x - 0.2) < 0.05 && p.y > bodyCurve - 0.1 && p.y < bodyCurve + 0.1) {
        isDragon = 1.0; // claw 1
    }
    if (abs(p.x - (-0.3)) < 0.05 && p.y > bodyCurve - 0.1 && p.y < bodyCurve + 0.1) {
        isDragon = 1.0; // claw 2
    }
    
    // Green/blue accents (tail/mane)
    if (isDragon > 0.0 && fract(p.x * 8.0) < 0.15 && p.y > bodyCurve + 0.1) {
        dragonCol = vec3(0.2, 0.6, 0.5); // teal
    }
    
    if (isDragon > 0.0) {
        col = dragonCol;
        // Basic lighting
        col *= 0.8 + 0.4 * p.y;
    }
    
    // Vignette
    col *= 1.0 - 0.1 * length(p);
    
    gl_FragColor = vec4(col, 1.0);
}
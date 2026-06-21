void main() {
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;
    
    vec3 col = vec3(0.0);
    
    vec2 up_p = vec2(p.y, -p.x);
    
    // Add walking bounce to everything above floor
    float bounce = abs(sin(iTime * 4.0)) * 0.05;
    
    if (up_p.y < -0.2) {
        vec3 tileWhite = vec3(0.85, 0.85, 0.88);
        vec3 tileDirt = vec3(0.6, 0.6, 0.6);
        
        // Panning floor (moving forward)
        float gridX = fract(up_p.x * 2.0);
        float gridY = fract((up_p.y + iTime*0.5) * 2.0);
        
        col = mix(tileWhite, tileDirt, 0.2 + 0.1 * sin(up_p.x * 10.0));
        
        if (gridX < 0.02 || gridY < 0.02) {
            col = vec3(0.3);
        }
        
        float shadow = exp(-length(up_p - vec2(0.0, -0.5)) * 3.0);
        col *= 1.0 - 0.5 * shadow;
    } else {
        col = vec3(0.7, 0.7, 0.7); 
        
        if (up_p.y > -0.1 && up_p.y < 0.8 && abs(up_p.x) < 0.8) {
            col = vec3(0.4, 0.5, 0.5);
            // Sliding reflection
            float refl = sin((up_p.x + up_p.y)*10.0 + iTime*2.0);
            col += vec3(0.1) * smoothstep(0.8, 1.0, refl);
            
            vec2 posterP = up_p;
            // Shift posters to give parallax
            posterP.y -= iTime * 0.2;
            posterP.y = mod(posterP.y, 1.0) - 0.2;
            
            if (posterP.x > 0.1 && posterP.y > 0.1 && posterP.y < 0.5) {
                col = vec3(0.1, 0.5, 0.3); 
                if (fract(posterP.y * 20.0) > 0.5 && posterP.x > 0.3) col = vec3(0.9); 
            }
            if (posterP.x < -0.1 && posterP.y > 0.1 && posterP.y < 0.5) {
                col = vec3(0.1, 0.3, 0.6); 
                if (fract(posterP.y * 25.0) > 0.6) col = vec3(0.9); 
            }
        }
    }
    
    vec3 shirtCol = vec3(0.7, 0.15, 0.15); 
    vec3 shortsCol = vec3(0.45, 0.55, 0.65); 
    vec3 bootsCol = vec3(0.2, 0.45, 0.2); 
    vec3 skinCol = vec3(0.85, 0.65, 0.5); 
    
    // Walking leg animation
    float legWalk1 = sin(iTime * 4.0) * 0.1;
    float legWalk2 = sin(iTime * 4.0 + 3.1415) * 0.1;

    vec2 lLegP = up_p - vec2(-0.15, -0.3 + bounce);
    lLegP.y -= legWalk1;
    float dLLeg = max(abs(lLegP.x) - 0.15, abs(lLegP.y) - 0.2);
    
    vec2 rLegP = up_p - vec2(0.25, -0.3 + bounce);
    rLegP.y -= legWalk2;
    float dRLeg = max(abs(rLegP.x) - 0.15, abs(rLegP.y) - 0.2);
    
    vec2 lBootP = up_p - vec2(-0.15, -0.65 + bounce);
    lBootP.y -= legWalk1;
    float dLBoot = max(abs(lBootP.x) - 0.12, abs(lBootP.y) - 0.25);
    
    vec2 rBootP = up_p - vec2(0.35, -0.6 + bounce);
    rBootP.y -= legWalk2;
    float dRBoot = length(rBootP - vec2(clamp(rBootP.x, -0.1, 0.2), 0.0)) - 0.15;
    
    vec2 torsoP = up_p - vec2(-0.1, 0.3 + bounce);
    float dTorso = max(abs(torsoP.x) - 0.25, abs(torsoP.y) - 0.4);
    
    vec2 lArmP = up_p - vec2(-0.4, 0.1 + bounce);
    // Arm swinging
    float armSwing = sin(iTime * 4.0) * 0.1;
    lArmP.x += armSwing;
    float dLArm = max(abs(lArmP.x) - 0.08, abs(lArmP.y) - 0.25);
    float dLHand = length(up_p - vec2(-0.45 + armSwing, -0.2 + bounce)) - 0.08;
    
    vec2 rArmP = up_p - vec2(0.2, 0.5 + bounce);
    float dRArm = length(rArmP - vec2(clamp(rArmP.x, -0.1, 0.15), clamp(rArmP.y, -0.1, 0.2))) - 0.08;
    float dRHand = length(up_p - vec2(0.4, 0.7 + bounce)) - 0.08;
    
    vec2 boxP = up_p - vec2(0.5, 0.6 + bounce);
    vec2 boxRot = vec2(boxP.x * 0.8 + boxP.y * 0.6, -boxP.x * 0.6 + boxP.y * 0.8);
    float dBox = max(abs(boxRot.x) - 0.2, abs(boxRot.y) - 0.2);
    
    if (dBox < 0.0) {
        col = vec3(0.75, 0.6, 0.45); 
        if (abs(boxRot.x) < 0.02) col = vec3(0.6, 0.45, 0.3);
    } else if (dTorso < 0.0 || dLArm < 0.0) {
        col = shirtCol;
        col *= 0.8 + 0.2 * up_p.x; 
    } else if (dLLeg < 0.0 || dRLeg < 0.0) {
        col = shortsCol;
        col *= 0.8 + 0.2 * sin(up_p.x * 50.0) * cos(up_p.y * 40.0);
    } else if (dLBoot < 0.0 || dRBoot < 0.0) {
        col = bootsCol;
        col *= 0.7 + 0.3 * exp(-abs(up_p.x * 10.0));
    } else if (dRArm < 0.0) {
        col = skinCol;
    } else if (dLHand < 0.0 || dRHand < 0.0) {
        col = skinCol;
    }
    
    if (length(up_p - vec2(-0.5 + armSwing, -0.2 + bounce)) < 0.06) {
        col = vec3(0.3, 0.2, 0.1); 
    }
    
    col *= 1.0 - 0.1 * length(p);
    
    gl_FragColor = vec4(col, 1.0);
}
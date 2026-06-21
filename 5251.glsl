void main() {
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;
    
    // Waving fabric
    float wave = sin(p.x * 5.0 + iTime) * 0.05 + sin(p.y * 3.0 - iTime * 0.5) * 0.05;
    vec2 dp = p + wave;
    
    vec3 col = vec3(0.1, 0.1, 0.2);
    col *= 0.9 + 0.1 * sin(dp.x * 100.0) * sin(dp.y * 100.0);
    
    // 1. Woman's Face
    vec2 faceP = dp - vec2(0.1, -0.1);
    float face = length(vec2(faceP.x, faceP.y * 1.2)) - 0.4;
    float hair = length(vec2(faceP.x + 0.2, faceP.y + 0.2)) - 0.5;
    
    if (hair < 0.0 && face > 0.0) {
        col = vec3(0.15, 0.1, 0.1);
        col *= 0.8 + 0.2 * sin(faceP.x * 20.0 + sin(faceP.y * 10.0 + iTime)); // Flowing hair
    }
    
    if (face < 0.0) {
        col = vec3(0.9, 0.75, 0.65);
        col *= 0.8 + 0.2 * smoothstep(-0.4, 0.0, faceP.x);
        
        if (length(faceP - vec2(-0.15, 0.1)) < 0.05) {
            col = vec3(1.0);
            if (length(faceP - vec2(-0.15, 0.1)) < 0.02) col = vec3(0.1);
        }
        
        vec2 lipP = faceP - vec2(-0.05, -0.15);
        float lip = length(vec2(lipP.x, lipP.y * 2.0)) - 0.04;
        if (lip < 0.0) col = vec3(0.7, 0.1, 0.2);
        
        vec2 handP = faceP - vec2(0.2, -0.2);
        float finger1 = max(abs(handP.x + handP.y - 0.1) - 0.03, abs(handP.x - handP.y + 0.1) - 0.15);
        if (finger1 < 0.0) {
            col = vec3(0.95, 0.8, 0.7);
            if (handP.x < -0.05) col = vec3(0.6, 0.1, 0.2);
        }
    }
    
    // 2. Fuchsia Flowers pulsing
    vec2 f1P = dp - vec2(0.7, -0.1);
    float a1 = atan(f1P.y, f1P.x);
    float r1 = length(f1P);
    float pPulse = sin(iTime * 2.0) * 0.02;
    float petals1 = r1 - 0.3 - pPulse - 0.2 * sin(a1 * 5.0) * cos(a1 * 3.0);
    if (petals1 < 0.0) {
        col = mix(vec3(0.8, 0.1, 0.5), vec3(0.4, 0.1, 0.6), r1 * 3.0);
        if (fract(a1 * 10.0 + iTime) < 0.1 && r1 > 0.1) col = vec3(0.9, 0.4, 0.6); // Animated stamen
    }
    
    vec2 f2P = dp - vec2(0.4, 0.5);
    float a2 = atan(f2P.y, f2P.x);
    float r2 = length(f2P);
    float petals2 = r2 - 0.25 - pPulse - 0.15 * sin(a2 * 6.0);
    if (petals2 < 0.0) {
        col = mix(vec3(0.7, 0.1, 0.4), vec3(0.3, 0.1, 0.5), r2 * 4.0);
    }
    
    vec2 leafP = dp - vec2(0.8, 0.3);
    float leaf1 = length(vec2(leafP.x - leafP.y, leafP.x + leafP.y*2.0)) - 0.2;
    if (leaf1 < 0.0 && petals1 > 0.0 && petals2 > 0.0) {
        col = vec3(0.3, 0.5, 0.2);
    }
    
    // Hat (Static object in foreground, doesn't wave with fabric)
    vec2 hatP = p - vec2(-1.2 + sin(iTime)*0.05, -0.2); // Hat swaying slightly
    float hatRadius = length(hatP);
    
    if (hatRadius < 1.4) {
        col = vec3(0.85, 0.75, 0.55);
        vec3 lightDir = normalize(vec3(1.0, 1.0, 1.0));
        vec3 normal = normalize(vec3(hatP.x, hatP.y, 1.4 - hatRadius));
        float diff = max(0.0, dot(normal, lightDir));
        col *= 0.6 + 0.5 * diff;
        
        // Moving specular gleam on the hat
        float spec = pow(max(0.0, dot(reflect(-lightDir, normal), vec3(0.0, 0.0, 1.0))), 16.0);
        col += vec3(0.9, 0.8, 0.6) * spec * (0.3 + 0.2*sin(iTime*3.0));
        
        float rings = fract(hatRadius * 30.0);
        if (rings < 0.2) col *= 0.85;
        if (rings > 0.8) col *= 1.1;
        
        float angle = atan(hatP.y, hatP.x);
        float radials = fract(angle * 40.0 + sin(hatRadius * 10.0)*0.5);
        if (radials < 0.1) col *= 0.9;
    } else {
        float shadow = smoothstep(1.4, 1.6, hatRadius);
        col *= mix(0.3, 1.0, shadow);
    }

    gl_FragColor = vec4(col, 1.0);
}
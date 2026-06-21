float sdBox( in vec2 p, in vec2 b ) {
    vec2 d = abs(p)-b;
    return length(max(d,0.0)) + min(max(d.x,d.y),0.0);
}
void main() {
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;
    
    // Animated wood texture
    vec3 col = vec3(0.4, 0.2, 0.1);
    float woodLines = sin(p.x * 20.0 + sin(p.y * 15.0 + iTime * 0.2) * 2.0);
    col *= 0.6 + 0.4 * woodLines;
    
    // Signboard
    if (abs(p.x) < 0.7 && p.y > -0.5 && p.y < 0.0) {
        col = vec3(0.1, 0.5, 0.4); 
        // Board texture
        col += 0.05 * fract(sin(dot(p, vec2(12.0, 78.0))) * 43758.0);
        
        float border = max(abs(p.x) - 0.65, abs(p.y + 0.25) - 0.22);
        if (border > 0.0) {
            col = vec3(0.8, 0.2, 0.2); 
            // Animated red border shine
            col += 0.2 * smoothstep(0.9, 1.0, sin(p.x * 10.0 + p.y * 10.0 + iTime * 3.0));
        }
        
        // Text/characters
        if (abs(p.y + 0.35) < 0.08 && abs(p.x) < 0.5) {
            float textId = floor(p.x * 6.0);
            float letter = sdBox(vec2(fract(p.x * 6.0) - 0.5, p.y + 0.35), vec2(0.2, 0.05));
            if (letter < 0.0) {
                col = vec3(0.9, 0.8, 0.2);
                col += 0.2 * sin(iTime * 5.0 + textId); // pulsating letters
            }
        }
        
        if (p.y > -0.2 && p.y < -0.05 && abs(p.x) < 0.4) {
            float charId = floor(p.x * 4.0);
            float charBox = sdBox(vec2(fract(p.x * 4.0) - 0.5, p.y + 0.12), vec2(0.3, 0.06));
            if (charBox < 0.0) {
                col = vec3(0.9, 0.8, 0.2);
                col += 0.2 * cos(iTime * 4.0 + charId); // pulsating letters
            }
        }
    }
    
    // Gold area above
    if (p.y > 0.1 && p.y < 0.5 && abs(p.x) < 0.8) {
        // Animate gold sparkling
        float gold = fract(sin(dot(p*10.0 + iTime*0.1, vec2(1.0, 1.0))) * 100.0);
        col = mix(vec3(0.5, 0.4, 0.1), vec3(0.9, 0.7, 0.1), gold);
        // Moving highlight
        col += 0.3 * smoothstep(0.8, 1.0, sin(p.x * 5.0 - iTime * 2.0));
        
        if (abs(p.x) < 0.1 && p.y > 0.1) col = vec3(0.6, 0.1, 0.1);
    }
    
    // Shadow under board
    if (p.y < -0.5 && p.y > -0.6 && abs(p.x) < 0.75) {
        col *= smoothstep(-0.5, -0.6, p.y);
    }
    
    gl_FragColor = vec4(col, 1.0);
}

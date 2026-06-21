void main() {
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;
    
    vec3 col = vec3(0.7, 0.65, 0.6); // Wall
    col -= 0.1 * p.y; // gradient wall
    
    // Animated perspective floor
    if (p.x > 0.0 && p.y < 0.0) {
        vec2 st = vec2(p.x / (p.y - 0.1), 1.0 / (p.y - 0.1));
        st.x += iTime * 0.2; // Floor panning left
        float tile = max(step(0.1, fract(st.x * 5.0)), step(0.1, fract(st.y * 5.0)));
        col = mix(vec3(0.8), vec3(0.6), tile);
    }
    
    // Shelves/items on left
    if (p.y > -0.4 && p.y < 0.5 && p.x < 0.2) {
        float sId = floor((p.y + p.x) * 10.0);
        vec2 sp = vec2(fract((p.y + p.x) * 10.0) - 0.5, p.x);
        
        if (abs(sp.y) < 0.2 && sp.x > -0.3 && sp.x < 0.3) {
            float rnd = fract(sId * 0.123);
            if (rnd < 0.3) col = vec3(0.1); 
            else if (rnd < 0.6) col = vec3(0.8, 0.1, 0.1); 
            else col = vec3(0.9); 
            
            // Subtle pulse on items
            col += 0.1 * sin(iTime * 3.0 + sId);
        }
        
        // Dark shelf border
        if (length(vec2(sp.x, sp.y + 0.2)) < 0.1) col = vec3(0.05);
    }
    
    // Floating objects
    vec2 bp = p - vec2(-0.5, 0.0);
    bp.y += sin(iTime * 2.0) * 0.05; // float up and down
    if (length(bp * vec2(1.0, 0.8)) < 0.2 + 0.05*sin(bp.y*20.0 + iTime*5.0)) { // undulating edge
        col = vec3(0.9, 0.4, 0.8); 
        col *= 0.5 + 0.5 * smoothstep(0.2, 0.0, length(bp)); // shading
    }
    
    vec2 gp = p - vec2(-0.1, -0.1);
    gp.x += cos(iTime * 1.5) * 0.05; // float left and right
    if (length(gp * vec2(1.0, 0.7)) < 0.15 + 0.05*cos(gp.x*20.0 - iTime*4.0)) {
        col = vec3(0.2, 0.8, 0.6); 
        col *= 0.5 + 0.5 * smoothstep(0.15, 0.0, length(gp));
    }

    gl_FragColor = vec4(col, 1.0);
}

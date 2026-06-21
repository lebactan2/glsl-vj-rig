void main() {
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;
    
    vec3 col = vec3(0.55, 0.55, 0.55);
    float noise = fract(sin(dot(p + iTime*0.05, vec2(12.9898, 78.233))) * 43758.5453);
    col *= 0.95 + 0.05 * noise;
    
    // The Red "P" Sign with proper shading and details
    float angle = 0.05;
    mat2 rot = mat2(cos(angle), -sin(angle), sin(angle), cos(angle));
    vec2 sp = rot * p;
    
    vec2 signBox = vec2(0.4, 0.55);
    vec2 d = abs(sp) - signBox + vec2(0.1);
    float signDist = length(max(d, 0.0)) + min(max(d.x, d.y), 0.0) - 0.1;
    
    if (signDist < 0.0) {
        // Shaded red background for sign
        col = vec3(0.7, 0.15, 0.15);
        col *= 0.8 + 0.2 * smoothstep(-0.4, 0.4, sp.x + sp.y); // gradient
        
        // Inner white outline
        if (abs(signDist + 0.03) < 0.01) col = vec3(0.9);
        
        #define segment(p, a, b) length(p - a - (b - a) * clamp(dot(p - a, b - a) / dot(b - a, b - a), 0.0, 1.0))
        
        // White "P"
        float pLetter = segment(sp, vec2(-0.15, 0.2), vec2(-0.15, -0.2));
        pLetter = min(pLetter, segment(sp, vec2(-0.15, 0.2), vec2(0.05, 0.2)));
        pLetter = min(pLetter, segment(sp, vec2(-0.15, 0.0), vec2(0.05, 0.0)));
        pLetter = min(pLetter, segment(sp, vec2(0.05, 0.2), vec2(0.15, 0.1)));
        pLetter = min(pLetter, segment(sp, vec2(0.15, 0.1), vec2(0.05, 0.0)));
        
        if (pLetter < 0.06) col = vec3(1.0);
        
        // Animated arrow below P
        float arrowAnim = fract(iTime * 0.5) * 0.1;
        vec2 ap = sp - vec2(0.0, -0.35 + arrowAnim);
        float arrow = segment(ap, vec2(0.0, 0.08), vec2(0.0, -0.08));
        arrow = min(arrow, segment(ap, vec2(0.0, -0.08), vec2(-0.06, 0.0)));
        arrow = min(arrow, segment(ap, vec2(0.0, -0.08), vec2(0.06, 0.0)));
        
        if (arrow < 0.02) col = vec3(1.0);
    }
    
    // Detailed Green Leaves
    if (p.x < -0.4) {
        float sway = sin(iTime * 2.0) * 0.1;
        for(float i=0.0; i<15.0; i++) {
            vec2 center = vec2(-1.2 + sin(i*1.2)*0.4 + sway * (1.0 + sin(i)), -0.8 + i*0.12);
            vec2 lp = p - center;
            float a = sin(i) * 0.5 + 0.5 + sway * 0.5 * cos(i);
            mat2 rotL = mat2(cos(a), -sin(a), sin(a), cos(a));
            lp = rotL * lp;
            
            float leaf = length(vec2(lp.x, lp.y * 2.5)) - 0.15 - sin(i)*0.05;
            
            if (leaf < 0.0) {
                vec3 leafCol = vec3(0.2, 0.45, 0.15);
                leafCol *= 0.7 + 0.3 * smoothstep(-0.1, 0.1, lp.x); // shading
                if (abs(lp.x) < 0.005) leafCol *= 0.6; // central vein
                col = mix(col, leafCol, 0.95);
            }
        }
    }

    gl_FragColor = vec4(col, 1.0);
}

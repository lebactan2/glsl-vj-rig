float sdRoundBox( in vec2 p, in vec2 b, in float r ) {
  vec2 q = abs(p) - b + r;
  return length(max(q,0.0)) + min(max(q.x,q.y),0.0) - r;
}

void main() {
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;
    
    vec3 col = vec3(0.92, 0.82, 0.25); // Yellow
    // subtle wavy background
    col *= 0.95 + 0.05 * sin(p.y * 10.0 + p.x * 5.0);
    
    // Draw 3 lines of text-like shapes
    // NHOM KIENG
    vec2 p1 = p;
    p1.y -= 0.5;
    
    float textShape = 1.0;
    
    // Line 1: NHOM (4 letters)
    vec2 p_line1 = p - vec2(0.0, 0.5);
    vec2 grid1 = vec2(fract(p_line1.x * 2.0) - 0.5, p_line1.y);
    float l1 = sdRoundBox(grid1, vec2(0.15, 0.2), 0.05);
    if(abs(p_line1.x) > 1.0) l1 = 1.0;
    
    // Line 2: KIENG (5 letters)
    vec2 p_line2 = p - vec2(0.0, 0.0);
    vec2 grid2 = vec2(fract(p_line2.x * 2.5) - 0.5, p_line2.y);
    float l2 = sdRoundBox(grid2, vec2(0.12, 0.2), 0.05);
    if(abs(p_line2.x) > 1.25) l2 = 1.0;
    
    // Line 3: 0908 223111 (numbers)
    vec2 p_line3 = p - vec2(0.0, -0.5);
    vec2 grid3 = vec2(fract(p_line3.x * 4.0) - 0.5, p_line3.y);
    float l3 = sdRoundBox(grid3, vec2(0.08, 0.15), 0.03);
    if(abs(p_line3.x) > 1.8) l3 = 1.0;

    float textDist = min(l1, min(l2, l3));
    
    // Shadow offset with animation
    vec2 shadowOffset = vec2(-0.02, -0.04) + vec2(sin(iTime*2.0)*0.01, cos(iTime*2.5)*0.01);
    
    // Recompute distances for shadow
    vec2 p1s = p_line1 - shadowOffset;
    float l1s = sdRoundBox(vec2(fract(p1s.x * 2.0) - 0.5, p1s.y), vec2(0.15, 0.2), 0.05);
    if(abs(p1s.x) > 1.0) l1s = 1.0;

    vec2 p2s = p_line2 - shadowOffset;
    float l2s = sdRoundBox(vec2(fract(p2s.x * 2.5) - 0.5, p2s.y), vec2(0.12, 0.2), 0.05);
    if(abs(p2s.x) > 1.25) l2s = 1.0;
    
    vec2 p3s = p_line3 - shadowOffset;
    float l3s = sdRoundBox(vec2(fract(p3s.x * 4.0) - 0.5, p3s.y), vec2(0.08, 0.15), 0.03);
    if(abs(p3s.x) > 1.8) l3s = 1.0;
    
    float shadowDist = min(l1s, min(l2s, l3s));
    
    // Render shadow (Red/Pink gradient)
    if(shadowDist < 0.0) {
        col = mix(vec3(0.9, 0.2, 0.3), vec3(0.9, 0.4, 0.5), shadowDist * -10.0);
    }
    
    // Render text background (white border)
    if(textDist < 0.02) {
        col = vec3(1.0); // white border
    }
    
    // Render text core (Blue)
    if(textDist < 0.0) {
        col = vec3(0.1, 0.2, 0.5); 
        // Add some highlight inside the blue
        if (textDist < -0.02) {
           col = mix(col, vec3(0.15, 0.25, 0.6), smoothstep(-0.02, -0.05, textDist));
        }
    }

    gl_FragColor = vec4(col, 1.0);
}

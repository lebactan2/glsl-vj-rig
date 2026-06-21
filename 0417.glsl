float map(vec3 p) {
    float base = max(length(p.xz) - 0.6, abs(p.y) - 0.3);
    base -= 0.02 * sin(atan(p.z, p.x) * 14.0);
    base -= 0.01 * sin(p.y * 50.0);
    
    vec3 stonePos = p - vec3(0.0, 0.35, 0.0);
    float stone = length(stonePos) - 0.12;
    stone += 0.02 * sin(stonePos.x*25.0) * sin(stonePos.z*25.0); 
    
    return min(base, stone);
}

vec3 getNormal(vec3 p) {
    vec2 e = vec2(0.01, 0);
    return normalize(vec3(
        map(p+e.xyy) - map(p-e.xyy),
        map(p+e.yxy) - map(p-e.yxy),
        map(p+e.yyx) - map(p-e.yyx)
    ));
}

void main() {
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 ro = vec3(0.0, 1.2, -2.5);
    vec3 rd = normalize(vec3(p.x, p.y - 0.4, 1.0));
    
    float d = 0.0;
    for(int i=0; i<64; i++) {
        vec3 p3 = ro + rd * d;
        float dist = map(p3);
        if (dist < 0.001) break;
        d += dist;
        if (d > 10.0) break;
    }
    
    vec3 col = vec3(0.75); 
    if (p.y < -0.3) col = vec3(0.35); 
    
    if (d < 10.0) {
        vec3 p3 = ro + rd * d;
        vec3 n = getNormal(p3);
        vec3 light = normalize(vec3(cos(iTime), 1.5, sin(iTime)));
        float diff = max(dot(n, light), 0.1);
        
        if (p3.y > 0.28 && length(p3.xz) < 0.18) {
            col = vec3(0.9, 0.9, 0.85) * diff;
        } else {
            col = vec3(0.1) * diff;
            vec3 view = normalize(ro - p3);
            vec3 ref = reflect(-light, n);
            float spec = pow(max(dot(view, ref), 0.0), 32.0);
            col += vec3(0.3) * spec;
        }
    }
    
    col *= 1.0 - length(p)*0.15;

    
    gl_FragColor = vec4(col, 1.0);
}

void main() {
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    // Perspective floor
    vec3 col = vec3(0.0);
    if (p.y < 0.3) {
        vec2 floorUV = vec2(p.x / (0.4 - p.y), 1.0 / (0.4 - p.y));
        
        // Pavement green tiles
        vec2 tileUV = fract(floorUV * 2.0);
        vec2 tileId = floor(floorUV * 2.0);
        
        float tileNoise = fract(sin(dot(tileId, vec2(12.9898, 78.233))) * 43758.5453);
        col = vec3(0.4, 0.45, 0.4) * (0.8 + 0.2 * tileNoise); // green tint
        
        // Small white squares on some tiles
        if (tileUV.x > 0.3 && tileUV.x < 0.7 && tileUV.y > 0.3 && tileUV.y < 0.7) {
             if (fract(tileNoise * 100.0) < 0.5) {
                 col = vec3(0.65, 0.65, 0.6) * (0.8 + 0.2 * tileNoise);
             }
        }
        
        if (tileUV.x < 0.05 || tileUV.y < 0.05) col *= 0.5; // grout
        
        // The bumpy middle line!
        if (floorUV.x > -0.2 && floorUV.x < 0.2) {
            // Animate the pebbles shifting slightly
            float pebbles = fract(sin(dot(floorUV * 100.0 + iTime*0.5, vec2(12.9898, 78.233))) * 43758.5453);
            vec3 pebbleCol = mix(vec3(0.2), vec3(0.8), pebbles);
            
            // Grid for the bumpy line
            if (fract(floorUV.y * 4.0) < 0.05 || fract(floorUV.x * 20.0) < 0.05) pebbleCol *= 0.5;
            
            col = pebbleCol;
        }
        
        // distance fading
        col *= smoothstep(0.3, -0.5, p.y);
    } else {
        col = vec3(0.3); // street/wall
    }

    gl_FragColor = vec4(col, 1.0);
}
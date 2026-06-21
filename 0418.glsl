void main() {
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(0.5, 0.5, 0.52); // Wall color
    
    // Wall texture
    col *= 0.9 + 0.1 * fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
    
    // Pallets (slanted rects)
    vec2 palletUV = p * mat2(0.9, -0.1, 0.1, 0.9);
    palletUV *= 2.0;
    palletUV.y += 1.0;
    
    // Red pallet in back
    if (palletUV.x > -1.2 && palletUV.x < 1.2 && palletUV.y > 0.1 && palletUV.y < 2.0) {
        vec3 redPallet = vec3(0.5, 0.2, 0.2);
        vec2 grid = fract(palletUV * 5.0);
        if (grid.x < 0.1 || grid.y < 0.1 || grid.x > 0.9 || grid.y > 0.9) redPallet *= 0.6;
        if (fract(palletUV.x * 2.5) > 0.8 && fract(palletUV.y * 2.5) > 0.8) redPallet *= 0.3; // holes
        col = redPallet;
    }

    // Green pallets in front
    palletUV.y -= 0.2;
    palletUV.x -= 0.1;
    if (palletUV.x > -1.2 && palletUV.x < 1.2 && palletUV.y > 0.1 && palletUV.y < 2.0) {
        vec3 greenPallet = vec3(0.6, 0.7, 0.2);
        vec2 grid = fract(palletUV * 5.0);
        
        // Pattern animation: glowing holes!
        float glow = sin(iTime * 2.0 + palletUV.x * 10.0 + palletUV.y * 5.0) * 0.1 + 0.1;
        
        if (grid.x < 0.1 || grid.y < 0.1 || grid.x > 0.9 || grid.y > 0.9) greenPallet *= 0.6;
        
        if (fract(palletUV.x * 2.5) > 0.8 && fract(palletUV.y * 2.5) > 0.8) {
            greenPallet *= 0.3; 
            greenPallet += vec3(glow, glow * 0.5, 0.0); // Animate inside holes
        }
        
        // shading
        greenPallet *= 0.8 + 0.2 * palletUV.y;
        col = greenPallet;
    }

    gl_FragColor = vec4(col, 1.0);
}
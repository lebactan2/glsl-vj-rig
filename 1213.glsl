void main() {
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;
    
    vec3 col = vec3(0.88, 0.88, 0.9);
    
    float frameW = 0.75, frameH = 0.65;
    vec2 fp = vec2(p.x - 0.1, p.y + 0.05);
    float frameBox = max(abs(fp.x) - frameW, abs(fp.y) - frameH);
    
    if (frameBox < 0.0) {
        float innerBox = max(abs(fp.x) - frameW + 0.08, abs(fp.y) - frameH + 0.08);
        if (innerBox > 0.0) {
            // Detailed golden frame
            vec3 gold = vec3(0.8, 0.65, 0.2);
            vec3 darkGold = vec3(0.4, 0.3, 0.1);
            float latX = abs(fract(fp.x * 20.0 + fp.y * 20.0) - 0.5);
            float latY = abs(fract(fp.x * 20.0 - fp.y * 20.0) - 0.5);
            float lattice = min(latX, latY);
            float rims = min(abs(frameBox), abs(innerBox));
            if (rims < 0.01) col = vec3(0.9, 0.8, 0.4);
            else {
                col = mix(gold, darkGold, smoothstep(0.0, 0.2, lattice));
                col *= 0.8 + 0.2 * sin(fp.x * 50.0);
            }
        } else {
            // Scene inside
            vec2 sp = fp / vec2(frameW - 0.08, frameH - 0.08);
            
            // Sky gradient
            col = mix(vec3(0.4, 0.7, 0.9), vec3(0.8, 0.9, 0.95), -sp.y * 0.5 + 0.5);
            
            // Animated Clouds
            float cloudNoise = sin(sp.x * 5.0 + iTime * 0.5) * sin(sp.x * 10.0 + sp.y * 5.0 + iTime * 0.3);
            if (sp.y > 0.2) col = mix(col, vec3(1.0), smoothstep(0.5, 0.9, cloudNoise));
            
            // Mountain
            float mnt = -0.1 + sin(sp.x * 5.0) * 0.1 + cos(sp.x * 12.0) * 0.05;
            if (sp.y < mnt) col = vec3(0.4, 0.45, 0.5);
            
            // Animated Ocean with Parallax
            if (sp.y < -0.1) {
                col = mix(vec3(0.1, 0.3, 0.6), vec3(0.4, 0.8, 0.9), (sp.y + 1.0)*0.5);
                float wave = sin(sp.x * 40.0 - iTime * 4.0) * sin(sp.y * 60.0 + iTime * 2.0);
                col += wave * (0.05 + iBass * 0.2);
                // Specular sun glints on water
                if (wave > 0.8) col += 0.2 + iTreble * 0.5;
            }
            
            // Animated Sailing Boat
            float sailProgress = mod(iTime * 0.2, 2.0) - 1.0; // moves from -1 to 1
            vec2 bp = sp - vec2(sailProgress, -0.2);
            // Bobbing on waves
            bp.y += sin(iTime * 4.0) * (0.02 + iBeat * 0.05);
            // Hull
            float hull = max(abs(bp.x) - 0.1 + bp.y * 0.5, abs(bp.y + 0.02) - 0.02);
            if (hull < 0.0) col = vec3(0.2, 0.15, 0.1);
            
            #define segment(p, a, b) length(p - a - (b - a) * clamp(dot(p - a, b - a) / dot(b - a, b - a), 0.0, 1.0))
            
            // Mast & Sail
            float mast = segment(bp, vec2(0.0, 0.0), vec2(0.0, 0.2));
            if (mast < 0.005) col = vec3(0.1);
            // Sail billowing in wind
            float billow = sin(bp.y * 10.0 - iTime * 5.0) * 0.02;
            float sail = max(bp.x - billow, -bp.x - 0.1 + bp.y * 0.5);
            sail = max(sail, max(bp.y - 0.18, -bp.y));
            if (sail < 0.0) {
                col = vec3(0.9, 0.2, 0.2);
                col *= 0.8 + 0.2 * bp.x * 10.0; // 3D shading
            }
            
            // Balcony railing and animated flowers
            if (sp.x > 0.4 && sp.y > -0.7) {
                float rails = min(abs(fract(sp.x * 8.0) - 0.5), abs(sp.y + 0.4));
                if (rails < 0.02) col = vec3(0.9);
                
                // Detailed flowers with wind rustle
                vec2 flp = sp * vec2(10.0, 15.0);
                // Wind rustle distortion
                flp.x += sin(flp.y * 5.0 + iTime * 4.0) * 0.2;
                
                vec2 flpFrac = fract(flp) - 0.5;
                float flower = length(flpFrac) - 0.2 - sin(atan(flpFrac.y, flpFrac.x) * 5.0) * 0.1;
                
                if (flower < 0.0 && sp.y > -0.4) {
                    float colorSeed = fract(floor(flp.x) + floor(flp.y));
                    vec3 fCol = colorSeed > 0.5 ? vec3(0.9, 0.2, 0.5) : vec3(0.8, 0.1, 0.2);
                    // Core
                    if (length(flpFrac) < 0.05) fCol = vec3(0.9, 0.9, 0.1);
                    col = mix(col, fCol, 0.95);
                }
            }
        }
    } else {
        col = mix(vec3(0.6), col, smoothstep(0.0, 0.02, frameBox - 0.02)); // shadow
    }
    
    gl_FragColor = vec4(col, 1.0);
}

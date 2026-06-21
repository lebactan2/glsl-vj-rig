void main() {
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;
    
    vec3 col = vec3(0.0);
    
    col = vec3(0.9, 0.9, 0.9);
    
    float boxW = 1.3;
    float boxH = 0.5;
    
    vec2 bp = p;
    bp.y *= 1.0 + (bp.x + 1.0) * 0.05;
    
    float dCasing = max(abs(bp.x) - boxW, abs(bp.y) - boxH);
    
    if (dCasing < 0.0) {
        col = vec3(0.6, 0.6, 0.62);
        col *= 0.8 + 0.2 * bp.y;
        
        if (bp.x < -boxW + 0.1) {
            col = vec3(0.4, 0.4, 0.42); 
        } else {
            float sW = boxW - 0.12;
            float sH = boxH - 0.08;
            float dScreen = max(abs(bp.x + 0.05) - sW, abs(bp.y) - sH);
            
            if (dScreen < 0.0) {
                vec3 screenCol = vec3(0.05, 0.0, 0.0);
                
                vec2 gridP = bp * vec2(60.0, 30.0);
                vec2 fGrid = fract(gridP) - 0.5;
                float isDot = smoothstep(0.45, 0.35, length(fGrid));
                
                if (isDot > 0.0) {
                    vec3 ledCol = vec3(0.0); 
                    
                    float bx = abs(bp.x + 0.05);
                    float by = abs(bp.y);
                    if (bx > sW - 0.03 || by > sH - 0.04) {
                        // Animated RGB border
                        float cId = mod(floor(gridP.x) + floor(gridP.y) - iTime*10.0, 3.0);
                        if (cId < 1.0) ledCol = vec3(1.0, 0.0, 0.0);
                        else if (cId < 2.0) ledCol = vec3(0.0, 1.0, 0.0);
                        else ledCol = vec3(0.0, 0.0, 1.0);
                    } else {
                        // Scrolling Content
                        vec2 scrollP = bp;
                        scrollP.x += fract(iTime * 0.3) * 3.0 - 1.5; // Scroll right to left
                        // Wrap around
                        scrollP.x = mod(scrollP.x + 1.5, 3.0) - 1.5;
                        
                        // 1. Logo 
                        vec2 logoP = scrollP - vec2(-0.7, 0.0);
                        float dLogo = length(logoP) - 0.25;
                        if (dLogo < 0.0) {
                            // Spinning Logo
                            float a = atan(logoP.y, logoP.x) + iTime * 2.0;
                            ledCol = vec3(1.0, 0.1, 0.1); 
                            if (sin(a * 8.0) > 0.5 && length(logoP) > 0.15) ledCol = vec3(0.0);
                            if (length(logoP) < 0.1) ledCol = vec3(0.0); 
                        }
                        
                        // 2. Text "MAM NON" 
                        if (scrollP.x > -0.2 && scrollP.y > 0.15 && scrollP.y < 0.35) {
                            if (fract(scrollP.x * 15.0) > 0.2 && fract(scrollP.y * 10.0) > 0.2) {
                                ledCol = vec3(0.8, 1.0, 0.2); 
                            }
                        }
                        
                        // 3. Text "HOA MY"
                        if (scrollP.x > -0.2 && scrollP.y > -0.1 && scrollP.y < 0.1) {
                            if (fract(scrollP.x * 12.0) > 0.2 && fract(scrollP.y * 8.0) > 0.2) {
                                // Flashing color
                                ledCol = mix(vec3(1.0, 0.2, 0.8), vec3(0.2, 0.8, 1.0), sin(iTime*5.0)*0.5+0.5); 
                            }
                        }
                        
                        // 4. Text "MAN HINH LED"
                        if (scrollP.x > -0.8 && scrollP.y > -0.35 && scrollP.y < -0.15) {
                            if (fract(scrollP.x * 20.0) > 0.2 && fract(scrollP.y * 12.0) > 0.2) {
                                ledCol = vec3(0.1, 1.0, 0.3); 
                            }
                        }
                    }
                    
                    screenCol = mix(screenCol, ledCol * 1.5, isDot * (ledCol.r + ledCol.g + ledCol.b > 0.0 ? 1.0 : 0.0));
                }
                
                col = screenCol;
                col += vec3(0.1, 0.2, 0.1) * (1.0 - length(bp));
            }
        }
    }

    col *= 1.0 - 0.1 * length(p);
    
    gl_FragColor = vec4(col, 1.0);
}
void main() {
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;
    
    vec3 col = vec3(0.0);
    // Background panels
    if (p.x < -0.3) {
        col = vec3(0.5, 0.3, 0.4);
        float textLines = fract(p.x * 20.0);
        if (textLines < 0.2 && p.y > -0.8 && p.y < 0.8 && fract(p.y * 15.0) < 0.4) {
            col = mix(col, vec3(0.9), 0.5);
        }
    } else {
        col = vec3(0.4, 0.45, 0.48);
    }
    
    // Animated Smoke coming from the cap (Left side)
    // The cap is around (-0.8, -0.3)
    vec2 sp = p - vec2(-0.9, -0.4);
    // Smoke drifts up and left
    float smoke = sin(sp.x*10.0 + iTime*2.0 + sin(sp.y*5.0)) * cos(sp.y*8.0 - iTime);
    if (sp.x < 0.0 && sp.y > -0.2) {
        col += vec3(0.5) * max(0.0, smoke) * 0.3 * smoothstep(0.0, -1.0, sp.x);
    }
    
    float obj = 1.0;
    vec3 objCol = vec3(0.25, 0.2, 0.15);
    
    // 1. Right Base
    if (p.x > 0.4 && p.x < 1.5) {
        float h = 0.5;
        if (p.x > 0.5) h = 0.6;
        if (p.x > 0.7) h = 0.65;
        if (p.x > 0.9) h = 0.7;
        
        float tier = abs(p.y) - h;
        if (p.x > 0.6 && p.x < 0.7) tier += sin(p.y * 30.0 + iTime) * 0.02; // wiggling edge
        obj = min(obj, tier);
    }
    
    // 2. Middle Cage
    if (p.x > -0.2 && p.x <= 0.4) {
        float r = mix(0.4, 0.6, 1.0 - pow(abs((p.x - 0.1) / 0.3), 2.0));
        float cageBase = abs(p.y) - r;
        
        // Rotating cage effect
        float cx = p.x;
        float cy = p.y;
        float rotTime = iTime * 0.5;
        float band1 = abs(sin(cx * 10.0 + cy * 15.0 + rotTime));
        float band2 = abs(sin(cx * 10.0 - cy * 15.0 - rotTime));
        float band3 = abs(sin(cy * 20.0 + rotTime*2.0));
        
        float cageCutout = min(band1, min(band2, band3));
        
        if (cageBase < 0.0) {
            if (cageCutout > 0.2) {
                // Inside cage glowing embers
                float embers = max(0.0, sin(p.x*30.0 + iTime*5.0)*cos(p.y*30.0 + iTime*3.0));
                col = mix(col, vec3(0.6, 0.2, 0.05)*embers, 0.8);
            } else {
                obj = min(obj, cageBase);
            }
        }
    }
    
    // 3. Left Cap
    if (p.x > -0.8 && p.x <= -0.2) {
        float neckY = p.y - (p.x + 0.2) * 0.5;
        float neck = abs(neckY) - 0.2;
        obj = min(obj, neck);
        
        vec2 capP = p - vec2(-0.8, -0.3);
        float cap = length(vec2(capP.x, capP.y * 0.8)) - 0.25;
        if (cap < 0.0) {
            obj = min(obj, cap);
            float r = length(capP);
            // Throbbing rings
            if (abs(r - 0.1 - sin(iTime)*0.01) < 0.02 || abs(r - 0.03 + cos(iTime)*0.01) < 0.01) {
                objCol *= 0.5;
            }
        }
        
        float a = atan(capP.y, capP.x) + iTime; // rotating spikes
        float spikes = cap + 0.05 + sin(a * 8.0) * 0.08;
        obj = min(obj, spikes);
    }
    
    if (obj < 0.0) {
        col = objCol;
        col *= 0.6 + 0.4 * cos(p.y * 5.0);
        
        // Moving specular highlight
        col += vec3(0.2, 0.15, 0.1) * max(0.0, sin(p.x * 10.0 + p.y * 20.0 - iTime*3.0));
        
        if (obj > -0.01) col = vec3(0.4, 0.35, 0.25);
    }

    gl_FragColor = vec4(col, 1.0);
}
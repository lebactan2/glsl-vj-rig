void main() {
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;
    
    vec3 col = vec3(0.98); // White background
    
    // Grid lines
    if (fract(uv.x * 20.0) < 0.05 || fract(uv.y * 15.0) < 0.05) col = vec3(0.9);
    
    // Fibonacci / Trend Lines (Chaotic intersections)
    for (int i = 0; i < 40; i++) {
        float fi = float(i);
        // Animated line endpoints
        vec2 p1 = vec2(sin(fi * 1.3 + iTime*0.1) * 2.0, cos(fi * 1.7 - iTime*0.05) * 2.0);
        vec2 p2 = vec2(sin(fi * 2.1 - iTime*0.15) * 2.0, cos(fi * 2.5 + iTime*0.2) * 2.0);
        
        vec2 pa = p - p1, ba = p2 - p1;
        float h = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0);
        float d = length(pa - ba * h);
        
        if (d < 0.003) {
            float type = fract(sin(fi * 11.2) * 43758.5);
            if (type < 0.3) col = vec3(0.8, 0.2, 0.2); // Red lines
            else if (type < 0.6) col = vec3(0.2, 0.6, 0.2); // Green lines
            else if (type < 0.85) col = vec3(0.2, 0.3, 0.8); // Blue lines
            else col = vec3(0.5, 0.2, 0.5); // Purple lines
        }
    }
    
    // Horizontal price levels
    for (int i = 0; i < 20; i++) {
        float fi = float(i);
        // Slowly shifting levels
        float ypos = sin(fi * 15.3 + iTime*0.1) * 0.8;
        if (abs(p.y - ypos) < 0.003) {
            col = vec3(0.3, 0.3, 0.4);
            if (fi < 3.0 && abs(p.y - ypos) < 0.005) col = vec3(0.1); // Thick levels
        }
    }
    
    // Candlesticks (Moving prices)
    float xScaled = p.x * 5.0 + iTime; // Scrolling right to left
    
    float barX = floor(xScaled * 5.0) / 5.0;
    float nextBarX = floor((xScaled + 0.2) * 5.0) / 5.0;
    
    // Generate open/close prices
    float openPrice = barX * 0.2 + sin(barX * 2.0)*0.2 + sin(barX * 5.0)*0.1;
    float closePrice = nextBarX * 0.2 + sin(nextBarX * 2.0)*0.2 + sin(nextBarX * 5.0)*0.1;
    
    // Add dynamic volatility based on time
    float vol = 0.15 + 0.05 * sin(iTime*5.0 + barX);
    float highPrice = max(openPrice, closePrice) + abs(sin(barX * 30.0)) * vol;
    float lowPrice = min(openPrice, closePrice) - abs(sin(barX * 20.0)) * vol;
    
    // Wicks
    if (abs(fract(xScaled * 5.0) - 0.5) < 0.05 && p.y > lowPrice && p.y < highPrice) {
        if (closePrice > openPrice) col = vec3(0.1, 0.6, 0.1); 
        else col = vec3(0.8, 0.1, 0.1); 
    }
    
    // Body
    if (abs(fract(xScaled * 5.0) - 0.5) < 0.25 && p.y > min(openPrice, closePrice) && p.y < max(openPrice, closePrice)) {
        if (closePrice > openPrice) col = vec3(0.2, 0.8, 0.2); 
        else col = vec3(0.9, 0.2, 0.2); 
    }
    
    // Right Sidebar (Price axis)
    if (uv.x > 0.9) {
        col = vec3(0.95);
        if (fract(p.y * 10.0) < 0.05) col = vec3(0.5); // Ticks
        
        // Current Price Label (Black box)
        float curPrice = sin(iTime*0.5)*0.2 + 0.2; // Simulating current price moving
        if (abs(p.y - curPrice) < 0.05) {
            col = vec3(0.1); 
            if (fract(p.x * 50.0) < 0.5) col = vec3(0.9); // Text
        }
    }

    gl_FragColor = vec4(col, 1.0);
}
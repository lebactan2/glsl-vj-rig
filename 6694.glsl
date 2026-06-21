void main() {
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;
    
    vec3 col = vec3(0.0);
    
    col = vec3(0.88, 0.88, 0.85); 
    
    vec2 sp = p + vec2(0.1, 0.0); 
    float shelfY = fract(sp.y * 3.5); 
    float shelfX = fract(sp.x * 2.5); 
    
    if (shelfY < 0.05 || shelfX < 0.05) {
        col = vec3(0.95); 
    } else {
        vec2 cellId = floor(vec2(sp.x * 2.5, sp.y * 3.5));
        float rand = fract(sin(dot(cellId, vec2(39.346, 11.135))) * 43758.5453);
        
        if (rand < 0.2) col = vec3(0.8, 0.8, 0.2); 
        else if (rand < 0.4) col = vec3(0.1, 0.3, 0.7); 
        else if (rand < 0.6) col = vec3(0.8, 0.3, 0.2); 
        else if (rand < 0.8) col = vec3(0.2, 0.2, 0.2); 
        else col = vec3(0.6); 
        
        // Flowing noise on items
        col *= 0.8 + 0.2 * fract(sin(p.x * 40.0 + p.y * 60.0 + iTime*2.0)*100.0);
        col *= 0.7 + 0.3 * shelfY; 
    }
    
    if (p.x > 0.5 && p.y > -0.2 && p.y < 0.6) {
        col = vec3(0.2, 0.2, 0.25); 
        if (abs(p.x - 0.7) < 0.02) col = vec3(0.8, 0.8, 0.1); 
    }

    vec3 shirtColor = vec3(0.85, 0.84, 0.82); 
    vec3 pantsBlue = vec3(0.2, 0.3, 0.45);
    vec3 silhouetteBlack = vec3(0.0);
    
    bool isFigure = false;
    
    float breath = sin(iTime * 1.5) * 0.01;
    vec2 fp = p;
    fp.y -= breath;

    float dHead = length(fp - vec2(0.0, 0.65)) - 0.18;
    if (dHead < 0.0) {
        col = silhouetteBlack;
        isFigure = true;
    }
    
    if (abs(fp.x) < 0.12 && fp.y > 0.4 && fp.y < 0.5) {
        col = shirtColor;
        if (abs(fp.x) < 0.02 && fp.y > 0.45) col *= 0.8;
        isFigure = true;
    }
    
    float torsoWidth = 0.32 + breath - (fp.y) * -0.05;
    if (fp.y < 0.45 && fp.y > -0.45 && abs(fp.x) < torsoWidth) {
        col = shirtColor;
        isFigure = true;
        
        if (abs(fp.x) < 0.03) col *= 0.95;
        if (abs(fp.x - 0.03) < 0.005) col *= 0.8;
        if (fract(fp.y * 5.0) < 0.08 && abs(fp.x) < 0.01) col = vec3(0.7);
        
        if (abs(abs(fp.x) - 0.16) < 0.09 && fp.y > 0.15 && fp.y < 0.32) {
            col *= 0.95; 
            if (fp.y > 0.27) {
                col *= 0.9;
                if (fp.y < 0.29 - abs(abs(fp.x)-0.16)*0.2) col *= 0.9;
            }
            if (abs(abs(fp.x) - 0.16) < 0.015 && abs(fp.y - 0.29) < 0.015) col = vec3(0.7);
        }
        
        // Shimmering shirt folds
        col *= 0.85 + 0.15 * cos(fp.x * 25.0 + fp.y * 15.0 + iTime*4.0);
        if (fp.y < -0.4) col *= 0.8;
    }
    
    float dArmLeft = max(abs(fp.x + 0.38 + breath) - 0.09, abs(fp.y - 0.0) - 0.35);
    if (dArmLeft < 0.0 && fp.y < 0.4) {
        col = shirtColor * 0.9; 
        isFigure = true;
    }
    float dArmRight = max(abs(fp.x - 0.38 - breath) - 0.09, abs(fp.y - 0.0) - 0.35);
    if (dArmRight < 0.0 && fp.y < 0.4) {
        col = shirtColor * 0.9;
        isFigure = true;
    }
    
    if (length(fp - vec2(-0.4 - breath, -0.4)) < 0.06) {
        col = silhouetteBlack;
        isFigure = true;
    }
    if (length(fp - vec2(0.4 + breath, -0.4)) < 0.06) {
        col = silhouetteBlack;
        isFigure = true;
    }
    
    if (p.y < -0.45 && abs(p.x) < 0.28) {
        col = pantsBlue;
        if (abs(p.x) < 0.02) col = vec3(0.1, 0.15, 0.2);
        col *= 0.9 + 0.1 * fract(sin(p.x*80.0 + p.y*80.0)*10.0);
        isFigure = true;
    }

    if (!isFigure) {
        float shadow = length(p - vec2(0.0, 0.0)) - 0.55;
        if (shadow < 0.0) col *= 0.85;
    }
    
    gl_FragColor = vec4(col, 1.0);
}
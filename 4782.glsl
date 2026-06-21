void main() {
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    
    // Grid 3 columns, 2 rows
    vec2 gridUV = uv * vec2(3.0, 2.0);
    vec2 cell = floor(gridUV);
    vec2 p = fract(gridUV) * 2.0 - 1.0;
    p.x *= (iResolution.x/3.0) / (iResolution.y/2.0);
    
    vec3 col = vec3(0.9, 0.85, 0.7); // Beige wall
    
    // Subtle lighting animation on wall per cell
    float wallLight = sin(iTime + cell.x + cell.y) * 0.05;
    col += wallLight;
    
    // Wooden Floor
    if (p.y < -0.3) {
        col = vec3(0.6, 0.4, 0.2);
        // Floor lines
        if (fract(p.x * 5.0 + p.y * 2.0) < 0.05) col *= 0.8;
    }
    
    // Background Window/Painting
    float win = max(abs(p.x) - 0.3, abs(p.y - 0.4) - 0.3);
    if (win < 0.0) {
        col = vec3(0.3, 0.4, 0.5); // Blueish view
        // Animated clouds in window
        col += sin(p.x*10.0 + iTime + p.y*5.0) * 0.05;
    }
    
    // Table
    float tableLeg1 = max(abs(p.x - 0.4) - 0.05, abs(p.y + 0.2) - 0.2);
    float tableLeg2 = max(abs(p.x + 0.1) - 0.05, abs(p.y + 0.2) - 0.2);
    if (min(tableLeg1, tableLeg2) < 0.0) col = vec3(0.1); // Dark wood
    
    float tableTop = max(abs(p.x - 0.15) - 0.4, abs(p.y - 0.0) - 0.05);
    if (tableTop < 0.0) col = vec3(0.1);
    
    // Tablecloth
    float cloth = max(abs(p.x - 0.15) - 0.35, abs(p.y + 0.05) - 0.15);
    if (cloth < 0.0) {
        col = vec3(0.9);
        // Lace edge
        if (p.y < -0.05 && fract(p.x * 20.0) < 0.2) col = vec3(0.1); // Transparent/holes
    }
    
    // Chair
    float chair = max(abs(p.x + 0.4) - 0.15, abs(p.y + 0.1) - 0.3);
    if (chair < 0.0 && p.x < -0.3) col = vec3(0.15);

    // Figure
    vec3 figCol = vec3(0.1); // Default black
    float hash = fract(sin(dot(cell, vec2(12.9898, 78.233))) * 43758.5453);
    
    // Animated gold sparkles
    float sparkle = pow(abs(sin(p.x*30.0 + p.y*40.0 + iTime*3.0)), 10.0);
    vec3 gold = vec3(1.0, 0.8, 0.2) * sparkle;
    
    if (hash < 0.25) figCol = vec3(0.2, 0.3, 0.8); // Blue
    else if (hash < 0.5) figCol = vec3(0.8, 0.2, 0.2); // Red
    else if (hash < 0.75) {
        // Floral
        figCol = vec3(0.1);
        if (fract(p.x*15.0)*fract(p.y*15.0) > 0.5) figCol = vec3(0.8, 0.6, 0.2);
    }
    
    // Add sparkles to clothes
    figCol += gold;
    
    // Head
    if (length(p - vec2(-0.4, 0.25)) < 0.1) col = figCol;
    // Body
    float body = max(abs(p.x + 0.4) - 0.12, abs(p.y) - 0.2);
    if (body < 0.0) col = figCol;
    
    // Grid borders
    if (max(abs(fract(gridUV.x)-0.5), abs(fract(gridUV.y)-0.5)) > 0.49) col = vec3(1.0);
    
    gl_FragColor = vec4(col, 1.0);
}
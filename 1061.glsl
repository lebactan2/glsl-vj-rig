void main() {
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    // Pink background with pattern
    vec3 col = mix(vec3(0.95, 0.75, 0.8), vec3(0.9, 0.6, 0.7), length(p) * 0.5);

    float pattern = sin(p.x * 20.0 + iTime * 0.5) * sin(p.y * 20.0 + iTime * 0.3);
    col += pattern * 0.05 * vec3(1.0, 0.8, 0.9);

    // Red bar at the top (GIẢI ĐẶC BIỆT 2 TỶ ĐỒNG)
    if (p.y > 0.4 && p.y < 0.6) {
        col = vec3(0.8, 0.1, 0.2); // Red
        float shine = smoothstep(0.0, 0.2, sin(p.x * 5.0 + iTime * 2.0));
        col += shine * 0.1;
        
        // Add fake text to the red bar
        float textWave = sin(p.x * 100.0) * sin(p.y * 100.0);
        if (textWave > 0.8 && abs(p.y - 0.5) < 0.03) col = vec3(0.9, 0.8, 0.2); // gold text
    }

    // Helper for line segments
    #define segment(p, a, b) length(p - a - (b - a) * clamp(dot(p - a, b - a) / dot(b - a, b - a), 0.0, 1.0))

    // Big red numbers 2K4
    vec2 numP = p - vec2(0.5, 0.1);
    float dText = 1.0;
    
    // '2'
    vec2 p2 = numP - vec2(-0.15, 0.0);
    dText = min(dText, segment(p2, vec2(-0.04, 0.04), vec2(0.0, 0.08)));
    dText = min(dText, segment(p2, vec2(0.0, 0.08), vec2(0.04, 0.04)));
    dText = min(dText, segment(p2, vec2(0.04, 0.04), vec2(-0.04, -0.08)));
    dText = min(dText, segment(p2, vec2(-0.04, -0.08), vec2(0.05, -0.08)));
    
    // 'K'
    vec2 pK = numP - vec2(0.0, 0.0);
    dText = min(dText, segment(pK, vec2(-0.03, 0.08), vec2(-0.03, -0.08)));
    dText = min(dText, segment(pK, vec2(-0.03, 0.0), vec2(0.04, 0.08)));
    dText = min(dText, segment(pK, vec2(-0.01, 0.02), vec2(0.04, -0.08)));
    
    // '4'
    vec2 p4 = numP - vec2(0.15, 0.0);
    dText = min(dText, segment(p4, vec2(0.02, -0.08), vec2(0.02, 0.08)));
    dText = min(dText, segment(p4, vec2(0.02, 0.08), vec2(-0.04, 0.0)));
    dText = min(dText, segment(p4, vec2(-0.05, 0.0), vec2(0.05, 0.0)));

    if (dText < 0.015) {
        col = vec3(0.85, 0.15, 0.25);
    } else if (dText < 0.02) {
        col = vec3(1.0, 0.8, 0.8); // outline
    }

    // God of wealth figure in the center (gold, red, green)
    if (length(p) < 0.3) {
        vec3 godCol = mix(vec3(0.9, 0.7, 0.1), vec3(0.8, 0.2, 0.1), p.y + 0.5);
        godCol = mix(godCol, vec3(0.1, 0.6, 0.3), smoothstep(0.1, 0.0, length(p - vec2(0.0, -0.1))));
        col = mix(col, godCol, smoothstep(0.3, 0.28, length(p)));
        
        float glimmer = pow(sin(p.x * 50.0 + p.y * 50.0 + iTime * 3.0) * 0.5 + 0.5, 10.0);
        if (length(p) < 0.3) col += glimmer * vec3(1.0, 0.9, 0.5) * 0.5;
    }

    // The series of big red numbers at the bottom
    if (p.y < -0.3 && p.y > -0.45) {
        vec2 gridP = p;
        gridP.x = fract(p.x * 8.0) - 0.5;
        // Make tiny number-like shapes in the grid
        float numLike = segment(gridP, vec2(-0.2, 0.05), vec2(0.2, 0.05));
        numLike = min(numLike, segment(gridP, vec2(0.2, 0.05), vec2(0.2, -0.05)));
        numLike = min(numLike, segment(gridP, vec2(-0.2, -0.05), vec2(0.2, -0.05)));
        
        if (numLike < 0.05) {
            col = vec3(0.8, 0.1, 0.15);
        }
    }

    // Dark brown/fabric background at the edges
    if (p.y > 0.8 || p.y < -0.8) {
        col = vec3(0.3, 0.25, 0.2); 
        float tex = fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
        col -= tex * 0.05;
    }

    gl_FragColor = vec4(col, 1.0);
}

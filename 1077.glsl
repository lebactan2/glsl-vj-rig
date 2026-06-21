void main() {
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    // Background: Metallic plate with holes
    vec3 col = vec3(0.6, 0.6, 0.65);
    
    // Pattern animation: Subtle reflection on the metal
    float reflection = sin(p.x * 3.0 + p.y * 3.0 + iTime) * 0.1;
    col += reflection;

    // Holes in the metal plate
    vec2 gridP = fract(p * 5.0) - 0.5;
    if (length(gridP) < 0.1) {
        col = vec3(0.2, 0.2, 0.2);
    }

    // Colored pencils in the top area
    if (p.y > 0.2 && p.x > -0.4 && p.x < 0.6) {
        float pencilIdx = floor((p.x + 0.4) * 5.0); // 5 pencils
        float pencilPos = fract((p.x + 0.4) * 5.0);
        if (pencilPos > 0.1 && pencilPos < 0.9) {
            if (pencilIdx == 0.0) col = vec3(0.8, 0.3, 0.2); // Orange
            else if (pencilIdx == 1.0) col = vec3(0.2, 0.5, 0.8); // Blue
            else if (pencilIdx == 2.0) col = vec3(0.9, 0.6, 0.3); // Peach
            else if (pencilIdx == 3.0) col = vec3(0.3, 0.6, 0.8); // Light Blue
            else col = vec3(0.2, 0.4, 0.7); // Dark Blue
            
            // Pencil texture/shading
            float shade = sin(pencilPos * 3.1415) * 0.2;
            col -= (1.0 - shade) * 0.2;
        }
    }

    // Laser beam and bright red spot
    vec2 laserPos = vec2(sin(iTime * 2.0) * 0.3, -0.3 + cos(iTime * 1.5) * 0.2); // Animated laser position
    float dLaser = length(p - laserPos);
    
    // Glow effect
    if (dLaser < 0.2) {
        vec3 glowCol = vec3(1.0, 0.2, 0.1);
        float intensity = pow(0.2 / (dLaser + 0.01), 1.5) * 0.05;
        col += glowCol * intensity;
    }
    
    // Core of the laser
    if (dLaser < 0.02) {
        col = vec3(1.0, 0.8, 0.8);
    }

    gl_FragColor = vec4(col, 1.0);
}
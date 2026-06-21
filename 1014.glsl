void main() {
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    // Background: Stone floor
    vec3 col = vec3(0.4, 0.4, 0.42); 
    // Floor texture
    float floorTex = fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
    col -= floorTex * 0.1;

    // The blue plastic chair
    if (p.y > -0.6) {
        col = vec3(0.3, 0.5, 0.9); // Bright blue plastic
        
        // Plastic shading
        float lighting = sin(p.x * 2.0 + p.y * 1.5) * 0.15;
        col += lighting;
        
        // Shiny reflection animation on the plastic
        float shine = smoothstep(0.4, 0.5, sin(p.x * 8.0 - p.y * 8.0 + iTime * 2.0));
        col += shine * 0.1;

        // Floral cutout pattern
        vec2 center = vec2(0.0, 0.2);
        vec2 fp = p - center;
        
        // Repeating flowers
        fp = mod(fp, 0.6) - 0.3;
        
        float r = length(fp);
        float a = atan(fp.y, fp.x);
        
        // Cutout shape (revealing background)
        float petals = sin(a * 10.0 + iTime * 0.5) * 0.05 + 0.1;
        if (r < petals) {
            col = vec3(0.35, 0.35, 0.37); // Background color through hole
        }
        
        // Embossed floral lines
        float lines = abs(r - petals);
        if (lines < 0.01) {
            col *= 0.7; // Shadow edge
        }
    }

    // Chair leg
    if (p.y < -0.6 && p.x > 0.4 && p.x < 0.6) {
        col = vec3(0.2, 0.4, 0.8);
        col -= abs(p.x - 0.5) * 2.0; // Cylinder shading
    }

    gl_FragColor = vec4(col, 1.0);
}

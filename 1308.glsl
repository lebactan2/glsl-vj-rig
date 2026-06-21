void main() {
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(0.98, 0.98, 0.98); 
    
    // Paper texture
    float paper = fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
    col *= 0.98 + 0.02 * paper;

    vec3 ink = vec3(0.1, 0.1, 0.1); 
    float lineThickness = 0.008; // Thicker lines

    // Head
    float head = abs(length(p - vec2(0.0, 0.7)) - 0.15);
    if (head < lineThickness) col = ink;
    
    // Hair texture
    if (length(p - vec2(0.0, 0.7)) < 0.14) {
        float hair = sin(p.x * 100.0 + p.y * 100.0);
        if (hair > 0.8 && p.y > 0.7) col = ink;
    }

    #define segment(p, a, b) length(p - a - (b - a) * clamp(dot(p - a, b - a) / dot(b - a, b - a), 0.0, 1.0))

    // Kite Garment Structure
    float lines = 1.0;
    lines = min(lines, segment(p, vec2(0.0, 0.55), vec2(0.0, -0.1))); // Spine
    lines = min(lines, segment(p, vec2(0.0, 0.4), vec2(-0.8, 0.2))); // Left shoulder
    lines = min(lines, segment(p, vec2(0.0, 0.4), vec2(0.8, 0.2))); // Right shoulder
    lines = min(lines, segment(p, vec2(0.0, -0.1), vec2(-0.8, 0.2))); // Left bottom V
    lines = min(lines, segment(p, vec2(0.0, -0.1), vec2(0.8, 0.2))); // Right bottom V
    
    // Arc across back
    float arc = abs(length(p - vec2(0.0, -0.4)) - 0.7);
    if (arc < lineThickness && p.y > 0.1 && abs(p.x) < 0.6) col = ink;

    // Sleeves
    lines = min(lines, segment(p, vec2(-0.8, 0.2), vec2(-0.8, 0.0)));
    lines = min(lines, segment(p, vec2(0.8, 0.2), vec2(0.8, 0.0)));

    // Legs
    lines = min(lines, segment(p, vec2(-0.2, -0.1), vec2(-0.3, -0.9)));
    lines = min(lines, segment(p, vec2(0.2, -0.1), vec2(0.3, -0.9)));
    lines = min(lines, segment(p, vec2(-0.05, -0.3), vec2(-0.1, -0.9)));
    lines = min(lines, segment(p, vec2(0.05, -0.3), vec2(0.1, -0.9)));
    lines = min(lines, segment(p, vec2(-0.2, -0.1), vec2(0.2, -0.1))); // Waist

    if (lines < lineThickness) col = ink;
    
    // Shading crosshatching
    if (p.y > 0.0 && p.y < 0.3 && abs(p.x) > 0.4 && abs(p.x) < 0.8) {
        float hatch = sin((p.x + p.y) * 150.0);
        float drawAnim = smoothstep(0.0, 1.0, sin(iTime * 2.0));
        if (hatch > 0.9 && drawAnim > 0.5) col = mix(col, ink, 0.4);
    }

    // Text: "Forbes"
    vec2 tp = p - vec2(-0.3, 0.1);
    float text = 1.0;
    // F
    text = min(text, segment(tp, vec2(0.0, 0.0), vec2(0.0, 0.1)));
    text = min(text, segment(tp, vec2(0.0, 0.1), vec2(0.05, 0.1)));
    text = min(text, segment(tp, vec2(0.0, 0.05), vec2(0.04, 0.05)));
    // o
    text = min(text, abs(length(tp - vec2(0.1, 0.03)) - 0.03));
    // r
    text = min(text, segment(tp, vec2(0.16, 0.0), vec2(0.16, 0.06)));
    text = min(text, segment(tp, vec2(0.16, 0.05), vec2(0.2, 0.06)));
    // b
    text = min(text, segment(tp, vec2(0.24, -0.02), vec2(0.24, 0.1)));
    text = min(text, abs(length(tp - vec2(0.27, 0.02)) - 0.03));
    // e
    text = min(text, abs(length(tp - vec2(0.35, 0.03)) - 0.03));
    text = min(text, segment(tp, vec2(0.32, 0.03), vec2(0.38, 0.03)));
    // s
    text = min(text, segment(tp, vec2(0.44, 0.06), vec2(0.4, 0.06)));
    text = min(text, segment(tp, vec2(0.4, 0.06), vec2(0.4, 0.03)));
    text = min(text, segment(tp, vec2(0.4, 0.03), vec2(0.44, 0.03)));
    text = min(text, segment(tp, vec2(0.44, 0.03), vec2(0.44, 0.0)));
    text = min(text, segment(tp, vec2(0.44, 0.0), vec2(0.4, 0.0)));

    if (text < 0.005) col = ink;

    gl_FragColor = vec4(col, 1.0);
}

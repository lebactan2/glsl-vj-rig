// Layer 5 — dark seams: the curb frame beside the grate + block joint lines.
// Animation: a soft glow pulse travels along the seams.
mat2 rot(float a){ float s = sin(a), c = cos(a); return mat2(c, -s, s, c); }

// distance to the outline of a rotated box
float boxEdge(vec2 p, vec2 c, vec2 h, float ang){
    vec2 d = abs(rot(ang) * (p - c)) - h;
    float outside = length(max(d, 0.0));
    float inside = min(max(d.x, d.y), 0.0);
    return abs(outside + inside);
}

void main() {
    vec2 uv = gl_FragCoord.xy / iResolution.xy;

    float seam = 0.0;

    // curb line between grate and pavement
    float edge = 0.27 - uv.y * 0.05;
    seam = max(seam, smoothstep(0.012, 0.0, abs(uv.x - edge - 0.03)));

    // outlines of the paver / mosaic blocks
    seam = max(seam, smoothstep(0.010, 0.0, boxEdge(uv, vec2(0.58, 0.40), vec2(0.30, 0.33), -0.32)));
    seam = max(seam, smoothstep(0.010, 0.0, boxEdge(uv, vec2(0.78, 0.82), vec2(0.24, 0.11), -0.32)));

    // a couple of expansion joints across the ground
    float j = abs(fract(dot(uv, vec2(0.7, -0.7)) * 3.0) - 0.5);
    seam = max(seam, smoothstep(0.03, 0.0, j) * 0.5);

    if (seam < 0.02) { gl_FragColor = vec4(0.0); return; }

    // dark joint, with a glow pulse travelling along it
    float pulse = 0.5 + 0.5 * sin(dot(uv, vec2(1.0, 1.0)) * 8.0 - iTime * 2.5);
    vec3 col = mix(vec3(0.02), vec3(0.20, 0.18, 0.12), pulse * 0.6);

    gl_FragColor = vec4(col, seam * uOpacity);
}

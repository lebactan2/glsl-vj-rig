// Layer 2 — large smooth beige paver bands (the big plain tan blocks).
// Animation: a soft specular light band sweeps diagonally across them.
float hash(vec2 p){ return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453); }

mat2 rot(float a){ float s = sin(a), c = cos(a); return mat2(c, -s, s, c); }

// 1.0 inside a rotated box centered at c with half-size h
float box(vec2 p, vec2 c, vec2 h, float ang){
    vec2 d = rot(ang) * (p - c);
    vec2 q = abs(d) - h;
    return step(max(q.x, q.y), 0.0);
}

void main() {
    vec2 uv = gl_FragCoord.xy / iResolution.xy;

    // two large smooth bands in the upper / right pavement
    float m = max(
        box(uv, vec2(0.78, 0.82), vec2(0.24, 0.11), -0.32),
        box(uv, vec2(0.86, 0.50), vec2(0.13, 0.22), -0.32)
    );
    if (m < 0.5) { gl_FragColor = vec4(0.0); return; }

    // beige base with fine sandy grain
    float grain = hash(floor(gl_FragCoord.xy / 2.0));
    vec3 col = mix(vec3(0.80, 0.73, 0.55), vec3(0.88, 0.82, 0.64), grain * 0.6 + 0.2);

    // diagonal specular sweep
    float sweep = dot(uv, vec2(0.7, -0.7));
    float glow = smoothstep(0.06, 0.0, abs(fract(sweep * 1.2 - iTime * 0.12) - 0.5) - 0.46);
    col += glow * vec3(0.18, 0.16, 0.10);

    gl_FragColor = vec4(col, uOpacity);
}

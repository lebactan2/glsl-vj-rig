// Layer 4 — metal drainage grate with vertical slats (left side).
// Animation: a bright glint slides down the slats; slats shimmer subtly.
void main() {
    vec2 uv = gl_FragCoord.xy / iResolution.xy;

    // left strip, slightly skewed to echo the photo's angle
    float edge = 0.27 - uv.y * 0.05;
    if (uv.x > edge) { gl_FragColor = vec4(0.0); return; }

    float sx = uv.x / edge;                       // 0..1 across the grate

    // vertical slats: dark bars separated by thin bright gaps
    float bars = abs(fract(sx * 15.0) - 0.5);
    float slat = smoothstep(0.16, 0.30, bars);    // 1 = bar body, 0 = gap
    vec3 col = mix(vec3(0.04, 0.04, 0.05), vec3(0.13, 0.13, 0.15), slat);

    // specular glint travelling down the bars
    float glint = smoothstep(0.10, 0.0, abs(fract(uv.y - iTime * 0.18) - 0.5) - 0.4);
    col += glint * slat * vec3(0.35, 0.37, 0.42);

    // faint shimmer so the metal feels alive
    col += slat * 0.04 * sin(uv.y * 80.0 + iTime * 3.0);

    // soft shadow in the gaps
    col -= (1.0 - slat) * 0.03;

    gl_FragColor = vec4(col, uOpacity);
}

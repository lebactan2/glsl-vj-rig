// Layer 3 — beige mosaic tile grid (the block of small square tiles).
// Animation: per-tile brightness flicker + a "wet" highlight sweeping over rows.
float hash(vec2 p){ return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453); }

mat2 rot(float a){ float s = sin(a), c = cos(a); return mat2(c, -s, s, c); }

float box(vec2 p, vec2 c, vec2 h, float ang){
    vec2 d = rot(ang) * (p - c);
    vec2 q = abs(d) - h;
    return step(max(q.x, q.y), 0.0);
}

void main() {
    vec2 uv = gl_FragCoord.xy / iResolution.xy;

    // big tiled block, center-right, rotated to match the perspective
    vec2 c = vec2(0.58, 0.40);
    float ang = -0.32;
    if (box(uv, c, vec2(0.30, 0.33), ang) < 0.5) { gl_FragColor = vec4(0.0); return; }

    // local tile coordinates inside the rotated block
    vec2 local = rot(ang) * (uv - c);
    vec2 g = local * vec2(34.0, 38.0);
    vec2 cell = fract(g);
    vec2 id = floor(g);

    // grout lines
    float edge = min(min(cell.x, 1.0 - cell.x), min(cell.y, 1.0 - cell.y));
    float grout = smoothstep(0.0, 0.07, edge);

    // per-tile beige variation
    float r = hash(id);
    vec3 tile = mix(vec3(0.74, 0.66, 0.46), vec3(0.90, 0.84, 0.62), r);

    // animation: each tile breathes slightly out of phase
    tile *= 0.88 + 0.12 * sin(iTime * 1.5 + r * 6.2831 + id.x * 0.6 + id.y * 0.9);

    vec3 groutCol = vec3(0.32, 0.30, 0.27);
    vec3 col = mix(groutCol, tile, grout);

    // wet highlight sweeping across rows
    float wet = smoothstep(0.5, 1.0, sin(local.y * 6.0 - iTime * 1.2));
    col += wet * grout * vec3(0.10, 0.09, 0.06);

    gl_FragColor = vec4(col, uOpacity);
}

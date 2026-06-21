// Layer 1 — speckled granite / terrazzo ground (the gray aggregate surface).
// Animation: quartz flecks twinkle, slow brightness drift across the surface.
float hash(vec2 p){ return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453); }

void main() {
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 px = gl_FragCoord.xy;

    // multi-scale speckle
    float fine = hash(floor(px / 1.5));
    float med  = hash(floor(uv * 320.0));
    float coarse = hash(floor(uv * 90.0));
    float spec = fine * 0.5 + med * 0.3 + coarse * 0.2;

    vec3 col = mix(vec3(0.40, 0.40, 0.42), vec3(0.74, 0.74, 0.77), spec);
    col += (step(0.93, med) - step(0.985, med)) * 0.22;   // bright quartz grains
    col -= step(0.965, coarse) * 0.18;                     // dark mineral flecks

    // slow large-scale brightness drift (sun on aggregate)
    col *= 0.92 + 0.10 * sin(uv.x * 2.3 - uv.y * 1.7 + iTime * 0.25);

    // animated twinkle on the brightest grains
    float tw = step(0.988, hash(floor(uv * 240.0) + floor(iTime * 4.0)));
    col += tw * 0.45;

    gl_FragColor = vec4(col, uOpacity);
}

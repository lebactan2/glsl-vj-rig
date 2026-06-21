uniform sampler2D iChannel0;
uniform vec2 iImageResolution;

mat2 rot(float a) {
    float s = sin(a);
    float c = cos(a);
    return mat2(c, -s, s, c);
}

vec2 coverUv(vec2 uv, vec2 canvas, vec2 image) {
    float canvasAspect = canvas.x / canvas.y;
    float imageAspect = image.x / image.y;
    vec2 scale = canvasAspect > imageAspect
        ? vec2(1.0, imageAspect / canvasAspect)
        : vec2(canvasAspect / imageAspect, 1.0);
    return (uv - 0.5) * scale + 0.5;
}

float luma(vec3 c) {
    return dot(c, vec3(0.2126, 0.7152, 0.0722));
}

void main() {
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 texUv = coverUv(uv, iResolution, iImageResolution);
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    float t = iTime * 0.2174;
    vec2 photoP = texUv - 0.5;
    float r = length(p) * (1.0 - iBeat * 0.10);
    float a = atan(p.y, p.x);
    float segments = 7.0000;
    float slice = 6.2831853 / segments;
    float ma = abs(mod(a + slice * 0.5 + sin(t) * 0.025 + iLevel * 0.5 + iBeat * 0.3, slice) - slice * 0.5);
    vec2 k = vec2(cos(ma), sin(ma)) * r;
    k += 0.035 * vec2(sin(k.y * 8.0 + t * 2.2), cos(k.x * 7.0 - t * 1.8));

    float ringWave = sin(r * 18.4000 - t * 3.0);
    float petals = cos(ma * 14.0000 + r * 4.7763 + sin(t + r * 2.0));
    float lattice = sin((k.x + k.y) * 19.6047) *
                    sin((k.x - k.y) * 25.9933);
    float bead = smoothstep(0.86, 0.99, cos(ma * 25.0000 - t * 2.4)) *
                 smoothstep(0.035, 0.0, abs(fract(r * 7.6705 - t * 0.18) - 0.5));

    vec2 warp = vec2(
        sin(k.y * 7.7132 + t * 1.8 + petals),
        cos(k.x * 9.8070 - t * 1.6 + ringWave)
    ) * 0.0143;
    vec2 sampleUv = clamp(texUv + warp * (1.0 + iBass * 3.0) * smoothstep(1.35, 0.05, r), 0.001, 0.999);
    vec3 photo = texture2D(iChannel0, sampleUv).rgb;
    float fgMask = texture2D(iMatte, texUv).r;                       // 1 = foreground subject
    vec2 fgUv = clamp(texUv + (texUv - 0.5) * (iBeat * 0.10 + iBass * 0.04), 0.001, 0.999);
    photo = mix(photo, texture2D(iChannel0, fgUv).rgb, fgMask);      // foreground pops; bg stays warped
    vec3 photoSoft = texture2D(iChannel0, clamp(texUv + warp * 2.5, 0.001, 0.999)).rgb;

    vec3 c1 = vec3(0.7294, 0.7137, 0.6706);
    vec3 c2 = vec3(0.1686, 0.1804, 0.1843);
    vec3 c3 = vec3(0.4392, 0.4314, 0.4157);
    vec3 c4 = vec3(0.6235, 0.6157, 0.5843);
    vec3 c5 = vec3(0.8392, 0.8392, 0.8196);

    vec3 patternColor = mix(c1, c2, smoothstep(-0.55, 0.70, ringWave + petals * 0.34));
    patternColor = mix(patternColor, c4, smoothstep(0.15, 0.92, lattice));
    float mask = 0.10 + smoothstep(0.78, 0.98, abs(lattice)) * 0.18;

    vec2 tile = fract(k * 5.0 + vec2(t * 0.06, -t * 0.04)) - 0.5;
    float clover = cos(atan(tile.y, tile.x) * 4.0) * 0.16 + 0.24 - length(tile);
    float lead = smoothstep(0.018, 0.0, abs(clover));
    patternColor = mix(patternColor, c3, smoothstep(0.0, 0.08, clover) * 0.80);
    patternColor = mix(patternColor, c5, lead * 0.90);
    mask = max(mask, smoothstep(0.0, 0.08, clover) * 0.50 + lead * 0.30);

    mask = max(mask, bead * 0.42);

    float edge = length(photo - photoSoft) * 0.6236;
    mask *= smoothstep(1.28, 0.02, r);
    mask *= 0.65 + smoothstep(0.05, 0.38, edge + abs(luma(photo) - 0.4894) * 0.35);

    vec3 tintedPhoto = mix(photo.bgr, photo, 0.6337);
    vec3 col = mix(tintedPhoto, patternColor, clamp(mask * 0.2032, 0.0, 0.42));
    col += c5 * bead * 0.0916;
    col += vec3(1.0, 0.95, 0.82) * smoothstep(0.96, 1.0, sin(r * 42.0 - t * 7.0 + petals)) * 0.035;
    col = mix(col, col * (0.74 + 0.26 * smoothstep(1.45, 0.02, length(photoP) * 2.0)), 0.55);

    gl_FragColor = vec4(pow(clamp(col, 0.0, 1.0), vec3(0.94)), 1.0);
}

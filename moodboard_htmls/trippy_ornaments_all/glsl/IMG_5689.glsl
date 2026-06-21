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

    float t = iTime * 0.2930;
    vec2 photoP = texUv - 0.5;
    float r = length(p) * (1.0 - iBeat * 0.10);
    float a = atan(p.y, p.x);
    float segments = 12.0000;
    float slice = 6.2831853 / segments;
    float ma = abs(mod(a + slice * 0.5 + sin(t) * 0.025 + iLevel * 0.5 + iBeat * 0.3, slice) - slice * 0.5);
    vec2 k = vec2(cos(ma), sin(ma)) * r;
    k += 0.035 * vec2(sin(k.y * 8.0 + t * 2.2), cos(k.x * 7.0 - t * 1.8));

    float ringWave = sin(r * 12.8000 - t * 3.0);
    float petals = cos(ma * 24.0000 + r * 5.7237 + sin(t + r * 2.0));
    float lattice = sin((k.x + k.y) * 22.8443) *
                    sin((k.x - k.y) * 24.9699);
    float bead = smoothstep(0.86, 0.99, cos(ma * 25.0000 - t * 2.4)) *
                 smoothstep(0.035, 0.0, abs(fract(r * 7.8925 - t * 0.18) - 0.5));

    vec2 warp = vec2(
        sin(k.y * 9.1530 + t * 1.8 + petals),
        cos(k.x * 9.4171 - t * 1.6 + ringWave)
    ) * 0.0135;
    vec2 sampleUv = clamp(texUv + warp * (1.0 + iBass * 3.0) * smoothstep(1.35, 0.05, r), 0.001, 0.999);
    vec3 photo = texture2D(iChannel0, sampleUv).rgb;
    float fgMask = texture2D(iMatte, texUv).r;                       // 1 = foreground subject
    vec2 fgUv = clamp(texUv + (texUv - 0.5) * (iBeat * 0.10 + iBass * 0.04), 0.001, 0.999);
    photo = mix(photo, texture2D(iChannel0, fgUv).rgb, fgMask);      // foreground pops; bg stays warped
    vec3 photoSoft = texture2D(iChannel0, clamp(texUv + warp * 2.5, 0.001, 0.999)).rgb;

    vec3 c1 = vec3(0.5451, 0.5725, 0.5098);
    vec3 c2 = vec3(0.2471, 0.4196, 0.2667);
    vec3 c3 = vec3(0.5647, 0.4706, 0.4196);
    vec3 c4 = vec3(0.8902, 0.8784, 0.8471);
    vec3 c5 = vec3(0.4392, 0.2275, 0.1882);

    vec3 patternColor = mix(c1, c2, smoothstep(-0.55, 0.70, ringWave + petals * 0.34));
    patternColor = mix(patternColor, c4, smoothstep(0.15, 0.92, lattice));
    float mask = 0.10 + smoothstep(0.78, 0.98, abs(lattice)) * 0.18;

    float scallop = sin((r * 18.0 - t * 2.0) + cos(a * segments) * 1.8);
    float enamel = smoothstep(0.18, 0.84, scallop + lattice * 0.55);
    float pin = smoothstep(0.025, 0.0, abs(sin(a * 30.0 + t) * 0.5 + cos(r * 28.0 - t * 1.3) * 0.5));
    patternColor = mix(patternColor, c3, enamel * 0.68);
    patternColor = mix(patternColor, c5, pin * 0.52);
    mask = max(mask, enamel * 0.46 + pin * 0.28);

    mask = max(mask, bead * 0.42);

    float edge = length(photo - photoSoft) * 0.5956;
    mask *= smoothstep(1.28, 0.02, r);
    mask *= 0.65 + smoothstep(0.05, 0.38, edge + abs(luma(photo) - 0.5190) * 0.35);

    vec3 tintedPhoto = mix(photo.bgr, photo, 0.6711);
    vec3 col = mix(tintedPhoto, patternColor, clamp(mask * 0.2500, 0.0, 0.42));
    col += c5 * bead * 0.1150;
    col += vec3(1.0, 0.95, 0.82) * smoothstep(0.96, 1.0, sin(r * 42.0 - t * 7.0 + petals)) * 0.035;
    col = mix(col, col * (0.74 + 0.26 * smoothstep(1.45, 0.02, length(photoP) * 2.0)), 0.55);

    gl_FragColor = vec4(pow(clamp(col, 0.0, 1.0), vec3(0.94)), 1.0);
}

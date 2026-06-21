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
        ? vec2(1.0, canvasAspect / imageAspect)
        : vec2(imageAspect / canvasAspect, 1.0);
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

    float t = iTime * 0.2451;
    vec2 photoP = texUv - 0.5;
    float r = length(p) * (1.0 - iBeat * 0.10);
    float a = atan(p.y, p.x);
    float segments = 9.0000;
    float slice = 6.2831853 / segments;
    float ma = abs(mod(a + slice * 0.5 + sin(t) * 0.025 + iLevel * 0.5 + iBeat * 0.3, slice) - slice * 0.5);
    vec2 k = vec2(cos(ma), sin(ma)) * r;
    k += 0.035 * vec2(sin(k.y * 8.0 + t * 2.2), cos(k.x * 7.0 - t * 1.8));

    float ringWave = sin(r * 21.2000 - t * 3.0);
    float petals = cos(ma * 18.0000 + r * 5.5658 + sin(t + r * 2.0));
    float lattice = sin((k.x + k.y) * 20.7884) *
                    sin((k.x - k.y) * 21.4053);
    float bead = smoothstep(0.86, 0.99, cos(ma * 27.0000 - t * 2.4)) *
                 smoothstep(0.035, 0.0, abs(fract(r * 8.1503 - t * 0.18) - 0.5));

    vec2 warp = vec2(
        sin(k.y * 8.2393 + t * 1.8 + petals),
        cos(k.x * 8.0592 - t * 1.6 + ringWave)
    ) * 0.0105;
    vec2 sampleUv = clamp(texUv + warp * (1.0 + iBass * 3.0) * smoothstep(1.35, 0.05, r), 0.001, 0.999);
    vec3 photo = texture2D(iChannel0, sampleUv).rgb;
    float fgMask = texture2D(iMatte, texUv).r;                       // 1 = foreground subject
    vec2 fgUv = clamp(texUv + (texUv - 0.5) * (iBeat * 0.10 + iBass * 0.04), 0.001, 0.999);
    photo = mix(photo, texture2D(iChannel0, fgUv).rgb, fgMask);      // foreground pops; bg stays warped
    vec3 photoSoft = texture2D(iChannel0, clamp(texUv + warp * 2.5, 0.001, 0.999)).rgb;

    vec3 c1 = vec3(0.6157, 0.6078, 0.5686);
    vec3 c2 = vec3(0.4784, 0.3373, 0.3176);
    vec3 c3 = vec3(0.5333, 0.5294, 0.4980);
    vec3 c4 = vec3(0.6588, 0.6549, 0.6235);
    vec3 c5 = vec3(0.7137, 0.7137, 0.6824);

    vec3 patternColor = mix(c1, c2, smoothstep(-0.55, 0.70, ringWave + petals * 0.34));
    patternColor = mix(patternColor, c4, smoothstep(0.15, 0.92, lattice));
    float mask = 0.10 + smoothstep(0.78, 0.98, abs(lattice)) * 0.18;

    float ornament = sin(k.x * 15.0 + petals * 2.0 + t * 1.5) *
                     cos(k.y * 17.0 - ringWave * 0.3 - t);
    float inlay = smoothstep(0.52, 0.96, ornament);
    patternColor = mix(patternColor, c3, inlay * 0.75);
    mask = max(mask, inlay * 0.55);
    mask = max(mask, smoothstep(0.020, 0.0, abs(fract(r * 7.0 - t * 0.10) - 0.5)) * 0.45);

    mask = max(mask, bead * 0.42);

    float edge = length(photo - photoSoft) * 0.4980;
    mask *= smoothstep(1.28, 0.02, r);
    mask *= 0.65 + smoothstep(0.05, 0.38, edge + abs(luma(photo) - 0.5534) * 0.35);

    vec3 tintedPhoto = mix(photo.bgr, photo, 0.6642);
    vec3 col = mix(tintedPhoto, patternColor, clamp(mask * 0.2203, 0.0, 0.42));
    col += c5 * bead * 0.1001;
    col += vec3(1.0, 0.95, 0.82) * smoothstep(0.96, 1.0, sin(r * 42.0 - t * 7.0 + petals)) * 0.035;
    col = mix(col, col * (0.74 + 0.26 * smoothstep(1.45, 0.02, length(photoP) * 2.0)), 0.55);

    gl_FragColor = vec4(pow(clamp(col, 0.0, 1.0), vec3(0.94)), 1.0);
}

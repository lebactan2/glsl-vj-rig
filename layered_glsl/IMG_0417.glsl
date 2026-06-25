/* @layer_metadata
{
  "title": "Shader: IMG_0417",
  "layers": [
    {
      "name": "Background",
      "keywords": ["background", "wall", "floor", "gray", "backdrop"]
    },
    {
      "name": "Pedestal",
      "keywords": ["pedestal", "base", "stone", "column", "black"]
    },
    {
      "name": "Stone",
      "keywords": ["stone", "gem", "sphere", "white", "top"]
    }
  ]
}
*/
float img17_base(vec3 p) {
    float base = max(length(p.xz) - 0.6, abs(p.y) - 0.3);
    base -= 0.02 * sin(atan(p.z, p.x) * 14.0);
    base -= 0.01 * sin(p.y * 50.0);
    return base;
}
float img17_stone(vec3 p) {
    vec3 sp = p - vec3(0.0, 0.35, 0.0);
    float s = length(sp) - 0.12;
    s += 0.02 * sin(sp.x * 25.0) * sin(sp.z * 25.0);
    return s;
}
float layer_Mapping(vec3 p) { return min(img17_base(p), img17_stone(p)); }

vec3 getNormal(vec3 p) {
    vec2 e = vec2(0.01, 0);
    return normalize(vec3(
        layer_Mapping(p+e.xyy) - layer_Mapping(p-e.xyy),
        layer_Mapping(p+e.yxy) - layer_Mapping(p-e.yxy),
        layer_Mapping(p+e.yyx) - layer_Mapping(p-e.yyx)
    ));
}

// ---- shared camera + raymarch ----
float img17_march(vec2 p, out vec3 ro, out vec3 rd) {
    ro = vec3(0.0, 1.2, -2.5);
    rd = normalize(vec3(p.x, p.y - 0.4, 1.0));
    float d = 0.0;
    for(int i = 0; i < 64; i++) {
        float dist = layer_Mapping(ro + rd * d);
        if (dist < 0.001) break;
        d += dist;
        if (d > 10.0) break;
    }
    return d;
}
float img17_vig(vec2 p) { return 1.0 - length(p) * 0.15; }

vec4 layer_Background(vec2 uv) {
    vec2 p = uv * 2.0 - 1.0; p.x *= iResolution.x / iResolution.y;
    vec3 ro, rd;
    float d = img17_march(p, ro, rd);
    if (d < 10.0) return vec4(0.0);                 // geometry hit -> backdrop hidden
    vec3 col = p.y < -0.3 ? vec3(0.35) : vec3(0.75);
    col *= img17_vig(p);
    return vec4(col, 1.0);
}
vec4 layer_Pedestal(vec2 uv) {
    vec2 p = uv * 2.0 - 1.0; p.x *= iResolution.x / iResolution.y;
    vec3 ro, rd;
    float d = img17_march(p, ro, rd);
    if (d >= 10.0) return vec4(0.0);
    vec3 p3 = ro + rd * d;
    if (p3.y > 0.28 && length(p3.xz) < 0.18) return vec4(0.0);   // that's the Stone
    vec3 n = getNormal(p3);
    vec3 light = normalize(vec3(cos(iTime), 1.5, sin(iTime)));
    float diff = max(dot(n, light), 0.1);
    vec3 col = vec3(0.1) * diff;
    vec3 view = normalize(ro - p3);
    float spec = pow(max(dot(view, reflect(-light, n)), 0.0), 32.0);
    col += vec3(0.3) * spec;
    col *= img17_vig(p);
    return vec4(col, 1.0);
}
vec4 layer_Stone(vec2 uv) {
    vec2 p = uv * 2.0 - 1.0; p.x *= iResolution.x / iResolution.y;
    vec3 ro, rd;
    float d = img17_march(p, ro, rd);
    if (d >= 10.0) return vec4(0.0);
    vec3 p3 = ro + rd * d;
    if (!(p3.y > 0.28 && length(p3.xz) < 0.18)) return vec4(0.0);
    vec3 n = getNormal(p3);
    vec3 light = normalize(vec3(cos(iTime), 1.5, sin(iTime)));
    float diff = max(dot(n, light), 0.1);
    vec3 col = vec3(0.9, 0.9, 0.85) * diff;
    col *= img17_vig(p);
    return vec4(col, 1.0);
}

void main() {
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec3 col = vec3(0.0);
    vec4 bg = layer_Background(uv); col = mix(col, bg.rgb, bg.a);
    vec4 pd = layer_Pedestal(uv);   col = mix(col, pd.rgb, pd.a);
    vec4 st = layer_Stone(uv);      col = mix(col, st.rgb, st.a);
    gl_FragColor = vec4(col, 1.0);
}

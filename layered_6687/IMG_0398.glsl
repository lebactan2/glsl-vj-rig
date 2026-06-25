mat2 rot(float a) {
    float c = cos(a), s = sin(a);
    return mat2(c, -s, s, c);
}

vec2 hash2(vec2 p) {
    p = vec2(dot(p, vec2(127.1, 311.7)), dot(p, vec2(269.5, 183.3)));
    return -1.0 + 2.0 * fract(sin(p) * 43758.5453123);
}

float noise(vec2 p) {
    const float K1 = 0.366025404;
    const float K2 = 0.211324865;
    vec2 i = floor(p + (p.x + p.y) * K1);
    vec2 a = p - i + (i.x + i.y) * K2;
    float m = step(a.y, a.x);
    vec2 o = vec2(m, 1.0 - m);
    vec2 b = a - o + K2;
    vec2 c = a - 1.0 + 2.0 * K2;
    vec3 h = max(0.5 - vec3(dot(a, a), dot(b, b), dot(c, c)), 0.0);
    vec3 n = h * h * h * h * vec3(dot(a, hash2(i + 0.0)), dot(b, hash2(i + o)), dot(c, hash2(i + 1.0)));
    return dot(n, vec3(70.0));
}

vec4 layer_Floor(vec2 uv) {
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    if (p.y < -0.1) {
        vec2 floorUV = vec2(p.x / (p.y + 0.1), 1.0 / (p.y + 0.1));
        float planks = fract(floorUV.x * 2.0);
        float plankLine = smoothstep(0.0, 0.05, planks) * smoothstep(1.0, 0.95, planks);
        float woodGrain = noise(floorUV * vec2(1.0, 10.0));
        vec3 woodCol = mix(vec3(0.2, 0.1, 0.05), vec3(0.3, 0.15, 0.08), woodGrain);
        vec3 col = woodCol * plankLine;
        float depthDarken = clamp(abs(p.y + 0.1) * 2.0, 0.0, 1.0);
        col *= depthDarken;
        return vec4(col, 1.0);
    }
    return vec4(0.0);
}

vec4 layer_CeilingGrid(vec2 uv) {
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    if (p.y > 0.4) {
        vec2 ceilUV = vec2(p.x / (p.y - 0.4), 1.0 / (p.y - 0.4));
        vec2 grid = fract(ceilUV * 5.0);
        float gridLine = smoothstep(0.0, 0.1, grid.x) * smoothstep(1.0, 0.9, grid.x) *
                         smoothstep(0.0, 0.1, grid.y) * smoothstep(1.0, 0.9, grid.y);
        vec3 col = mix(vec3(0.8, 0.9, 1.0), vec3(0.1, 0.1, 0.15), gridLine);
        float depthDarken = clamp((p.y - 0.4) * 2.0, 0.0, 1.0);
        col *= depthDarken;
        return vec4(col, 1.0);
    }
    return vec4(0.0);
}

vec4 layer_BackgroundForest(vec2 uv) {
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    if (!(p.y < -0.1) && !(p.y > 0.4)) {
        if (abs(p.x) > 0.6) {
            float forestNoise = fract(sin(p.x * 50.0 + iTime*0.05) * 43758.0);
            float treeProfile = 0.2 + 0.3 * sin(p.x * 20.0) + 0.1 * forestNoise;
            if (p.y < treeProfile) {
                return vec4(0.05, 0.08, 0.05, 1.0);
            } else {
                vec3 sky = mix(vec3(0.05, 0.1, 0.2), vec3(0.01, 0.02, 0.05), p.y);
                float moon = length(p - vec2(-0.8, 0.3));
                sky += vec3(0.8, 0.9, 1.0) * smoothstep(0.1, 0.0, moon);
                return vec4(sky, 1.0);
            }
        } else {
            return vec4(0.1, 0.1, 0.1, 1.0);
        }
    }
    return vec4(0.0);
}

vec4 layer_GlowingScreens(vec2 uv) {
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    if (!(p.y < -0.1) && !(p.y > 0.4) && !(abs(p.x) > 0.6)) {
        float wave = sin(p.y * 20.0 - iTime * 5.0) * 0.5 + 0.5;
        vec3 screenCol = mix(vec3(0.0, 0.5, 1.0), vec3(0.0, 0.8, 0.5), wave);
        float edge = smoothstep(0.5, 0.6, abs(p.x));
        screenCol *= (1.0 - edge);
        return vec4(screenCol, 1.0);
    }
    return vec4(0.0);
}

vec4 layer_WoodenSculpture(vec2 uv) {
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    if (!(p.y < -0.1) && !(p.y > 0.4) && !(abs(p.x) > 0.6)) {
        float dSculpt = length(vec2(p.x, p.y + 0.1)) - 0.3;
        dSculpt += 0.05 * sin(p.y * 15.0); 
        
        if (dSculpt < 0.0) {
            float g = noise(p * 20.0);
            vec3 sculptCol = mix(vec3(0.4, 0.2, 0.1), vec3(0.2, 0.1, 0.05), g);
            float shadow = smoothstep(0.0, -0.1, dSculpt);
            sculptCol *= shadow;
            return vec4(sculptCol, 1.0);
        }
    }
    return vec4(0.0);
}

vec4 layer_Scene(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;

    vec3 col = vec3(0.0);
    
    vec4 l1 = layer_Floor(uv);
    col = mix(col, l1.rgb, l1.a);
    
    vec4 l2 = layer_CeilingGrid(uv);
    col = mix(col, l2.rgb, l2.a);
    
    vec4 l3 = layer_BackgroundForest(uv);
    col = mix(col, l3.rgb, l3.a);
    
    vec4 l4 = layer_GlowingScreens(uv);
    col = mix(col, l4.rgb, l4.a);
    
    vec4 l5 = layer_WoodenSculpture(uv);
    col = mix(col, l5.rgb, l5.a);
  return vec4(clamp(vec3(col),0.0,1.0), 1.0);
}

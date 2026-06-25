mat2 rot(float a) {
    float c = cos(a), s = sin(a);
    return mat2(c, -s, s, c);
}

float sdBox(vec2 p, vec2 b) {
    vec2 d = abs(p) - b;
    return length(max(d, 0.0)) + min(max(d.x, d.y), 0.0);
}

float sdDiamond(vec2 p, vec2 size) {
    p = rot(3.14159 / 4.0) * p;
    return sdBox(p, size);
}

float sdSegment(vec2 p, vec2 a, vec2 b, float r1, float r2) {
    vec2 pa = p - a, ba = b - a;
    float h = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0);
    return length(pa - ba * h) - mix(r1, r2, h);
}

float smin(float a, float b, float k) {
    float h = clamp(0.5 + 0.5 * (b - a) / k, 0.0, 1.0);
    return mix(b, a, h) - k * h * (1.0 - h);
}

vec2 hash(vec2 p) {
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
    vec3 n = h * h * h * h * vec3(dot(a, hash(i + 0.0)), dot(b, hash(i + o)), dot(c, hash(i + 1.0)));
    return dot(n, vec3(70.0));
}

float woodGrain(vec2 uv, float stretch) {
    vec2 p = uv * vec2(stretch, 2.0);
    float n = noise(p);
    n += 0.5 * noise(p * 2.0);
    n += 0.25 * noise(p * 4.0);
    return smoothstep(0.0, 1.0, abs(sin(uv.y * 30.0 + n * 5.0)));
}

float petal(vec2 p, float a, vec2 offset) {
    p = rot(a) * (p - offset);
    p.y -= 0.05;
    vec2 q = vec2(p.x * 2.0, p.y + p.x * p.x * 3.0);
    return length(q) - 0.12;
}

vec4 layer_Background(vec2 uv) {
    return vec4(0.95, 0.95, 0.94, 1.0);
}

vec4 layer_WoodStripes(vec2 uv) {
    float aspect = iResolution.x / iResolution.y;
    vec2 p = uv;
    p.x *= aspect;
    
    if ((uv.y > 0.35 && uv.y < 0.5) || uv.y < 0.1) {
        float g = woodGrain(p, 10.0);
        vec3 woodDark = vec3(0.3, 0.15, 0.05);
        vec3 woodLight = vec3(0.6, 0.35, 0.18);
        return vec4(mix(woodLight, woodDark, g), 1.0);
    }
    return vec4(0.0);
}

vec4 layer_Watermark(vec2 uv) {
    float aspect = iResolution.x / iResolution.y;
    vec2 p = uv;
    p.x *= aspect;
    
    bool inWood = ((uv.y > 0.35 && uv.y < 0.5) || uv.y < 0.1);
    
    if (!inWood) {
        vec2 lp1 = p - vec2(0.5, 0.6);
        float dLeaf1 = length(vec2(lp1.x * 1.5, lp1.y + lp1.x * lp1.x * 2.0)) - 0.25;
        if (dLeaf1 < 0.0) {
            float alpha = 1.0 - smoothstep(-0.01, 0.0, dLeaf1);
            vec3 leafCol = vec3(0.9, 0.9, 0.89);
            return vec4(leafCol, alpha);
        }
    }
    return vec4(0.0);
}

vec4 layer_Diamonds(vec2 uv) {
    float aspect = iResolution.x / iResolution.y;
    vec2 p = uv;
    p.x *= aspect;
    
    vec4 finalCol = vec4(0.0);
    
    for (int i = 0; i < 3; i++) {
        vec2 dp = p - vec2(0.2 + float(i) * 0.15, 0.8);
        float d1 = sdDiamond(dp, vec2(0.04));
        float d2 = sdDiamond(dp, vec2(0.02));
        
        if (d1 < 0.0) {
            vec3 diamCol = vec3(0.8, 0.8, 0.78);
            if (d1 < -0.01 && d1 > -0.015) diamCol *= 0.9;
            float alpha = 1.0 - smoothstep(-0.002, 0.002, d1);
            finalCol.rgb = mix(finalCol.rgb, diamCol, alpha);
            finalCol.a = mix(finalCol.a, 1.0, alpha);
        }
        if (d2 < 0.0) {
            vec3 innerCol = vec3(0.35, 0.2, 0.1);
            float g = woodGrain(dp * 5.0, 5.0);
            innerCol = mix(innerCol, innerCol * 0.5, g);
            float alpha = 1.0 - smoothstep(-0.002, 0.002, d2);
            finalCol.rgb = mix(finalCol.rgb, innerCol, alpha);
            finalCol.a = mix(finalCol.a, 1.0, alpha);
        }
    }
    return finalCol;
}

vec4 layer_Shelf(vec2 uv) {
    float aspect = iResolution.x / iResolution.y;
    vec2 p = uv;
    p.x *= aspect;
    
    float dShelf = sdBox(p - vec2(aspect*0.5, 0.15), vec2(0.35, 0.03));
    if (dShelf < 0.01) {
        float g = woodGrain(p, 15.0);
        vec3 shelfCol = mix(vec3(0.4, 0.2, 0.1), vec3(0.2, 0.1, 0.02), g);
        if (p.y > 0.17) shelfCol += 0.05;
        float alpha = 1.0 - smoothstep(0.0, 0.002, dShelf);
        return vec4(shelfCol, alpha);
    }
    return vec4(0.0);
}

vec4 layer_Vases(vec2 uv) {
    float aspect = iResolution.x / iResolution.y;
    vec2 p = uv;
    p.x *= aspect;

    vec2 vp1 = p - vec2(0.7, 0.18);
    float v1_y = clamp(vp1.y, 0.0, 0.35);
    float v1_w = mix(0.12, 0.04, smoothstep(0.0, 0.35, v1_y));
    v1_w += 0.03 * sin(v1_y * 3.14 * 2.0) * (1.0 - v1_y / 0.35);
    float dV1 = abs(vp1.x) - v1_w;
    dV1 = max(dV1, -vp1.y);
    dV1 = max(dV1, vp1.y - 0.35);

    vec2 vp2 = p - vec2(0.9, 0.18);
    float v2_y = clamp(vp2.y, 0.0, 0.45);
    float v2_w = mix(0.1, 0.04, smoothstep(0.0, 0.45, v2_y));
    v2_w += 0.05 * sin(v2_y * 3.14 * 2.5) * (1.0 - v2_y / 0.45);
    float dV2 = abs(vp2.x) - v2_w;
    dV2 = max(dV2, -vp2.y);
    dV2 = max(dV2, vp2.y - 0.45);

    float dVase = min(dV1, dV2);
    if (dVase < 0.01) {
        float y = (dV1 < dV2) ? (vp1.y / 0.35) : (vp2.y / 0.45);
        float nx = (dV1 < dV2) ? (vp1.x / v1_w) : (vp2.x / v2_w);
        vec3 vcol = mix(vec3(0.92, 0.92, 0.9), vec3(0.85, 0.7, 0.55), smoothstep(0.1, 0.7, y));
        
        float lines = sin(y * 150.0);
        vcol *= 0.95 + 0.05 * lines;

        float shade = sqrt(max(0.0, 1.0 - nx * nx));
        vcol *= 0.5 + 0.5 * shade;
        vcol += 0.15 * pow(max(0.0, shade), 3.0);

        float alpha = 1.0 - smoothstep(0.0, 0.002, dVase);
        return vec4(vcol, alpha);
    }
    return vec4(0.0);
}

vec4 layer_Branches(vec2 uv) {
    float aspect = iResolution.x / iResolution.y;
    vec2 p = uv;
    p.x *= aspect;

    float dBranch = 1000.0;
    vec2 t1 = vec2(0.7, 0.45);
    dBranch = smin(dBranch, sdSegment(p, t1 - vec2(0.0, 0.15), t1 + vec2(-0.05, 0.1), 0.015, 0.01), 0.02);
    dBranch = smin(dBranch, sdSegment(p, t1 + vec2(-0.05, 0.1), t1 + vec2(0.0, 0.3), 0.01, 0.006), 0.02);
    dBranch = smin(dBranch, sdSegment(p, t1 + vec2(0.0, 0.3), t1 + vec2(0.1, 0.45), 0.006, 0.002), 0.02);
    dBranch = smin(dBranch, sdSegment(p, t1 + vec2(-0.03, 0.2), t1 + vec2(-0.15, 0.35), 0.006, 0.002), 0.02);
    dBranch = smin(dBranch, sdSegment(p, t1 + vec2(-0.1, 0.3), t1 + vec2(-0.05, 0.4), 0.003, 0.001), 0.01);
    
    vec2 t2 = vec2(0.9, 0.55);
    dBranch = smin(dBranch, sdSegment(p, t2 - vec2(0.0, 0.15), t2 + vec2(0.1, 0.1), 0.015, 0.01), 0.02);
    dBranch = smin(dBranch, sdSegment(p, t2 + vec2(0.1, 0.1), t2 + vec2(0.25, 0.2), 0.01, 0.005), 0.02);
    dBranch = smin(dBranch, sdSegment(p, t2 + vec2(0.25, 0.2), t2 + vec2(0.4, 0.35), 0.005, 0.001), 0.02);
    dBranch = smin(dBranch, sdSegment(p, t2 + vec2(0.05, 0.0), t2 + vec2(-0.1, 0.15), 0.008, 0.003), 0.02);
    dBranch = smin(dBranch, sdSegment(p, t2 + vec2(-0.1, 0.15), t2 + vec2(-0.15, 0.3), 0.003, 0.001), 0.01);
    dBranch = smin(dBranch, sdSegment(p, t2 + vec2(0.2, 0.15), t2 + vec2(0.15, 0.3), 0.005, 0.002), 0.01);
    
    dBranch = smin(dBranch, sdSegment(p, t1 + vec2(0.0, 0.3), t2 + vec2(0.25, 0.2), 0.006, 0.004), 0.03);

    if (dBranch < 0.015) {
        vec3 branchCol = vec3(0.15, 0.12, 0.1);
        float alpha = 1.0 - smoothstep(0.0, 0.002, dBranch);
        return vec4(branchCol, alpha);
    }
    return vec4(0.0);
}

vec4 layer_Flowers(vec2 uv) {
    float aspect = iResolution.x / iResolution.y;
    vec2 p = uv;
    p.x *= aspect;

    float dFlower = 1000.0;
    vec2 f1 = vec2(0.35, 0.25);
    vec2 f2 = vec2(1.1, 0.2);

    for (int i = 0; i < 4; i++) {
        float a = float(i) * 3.14 * 2.0 / 4.0 + 0.3;
        dFlower = min(dFlower, petal(p, a, f1));
    }
    for (int i = 0; i < 5; i++) {
        float a = float(i) * 3.14 * 2.0 / 5.0 - 0.2;
        dFlower = min(dFlower, petal(p, a, f2));
    }

    if (dFlower < 0.01) {
        float dc = min(length(p - f1), length(p - f2));
        vec3 fcol = vec3(0.98, 0.98, 0.96);
        fcol -= 0.4 * smoothstep(0.0, 0.15, dc);
        fcol *= (0.8 + 0.2 * smoothstep(-0.05, 0.0, dFlower));
        float alpha = 1.0 - smoothstep(0.0, 0.002, dFlower);
        return vec4(fcol, alpha);
    }
    return vec4(0.0);
}

vec4 layer_Scene(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;

    vec3 col = vec3(0.0);
    
    vec4 l1 = layer_Background(uv);
    col = mix(col, l1.rgb, l1.a);
    
    vec4 l2 = layer_WoodStripes(uv);
    col = mix(col, l2.rgb, l2.a);
    
    vec4 l3 = layer_Watermark(uv);
    col = mix(col, l3.rgb, l3.a);
    
    vec4 l4 = layer_Diamonds(uv);
    col = mix(col, l4.rgb, l4.a);
    
    vec4 l5 = layer_Shelf(uv);
    col = mix(col, l5.rgb, l5.a);
    
    vec4 l6 = layer_Vases(uv);
    col = mix(col, l6.rgb, l6.a);
    
    vec4 l7 = layer_Branches(uv);
    col = mix(col, l7.rgb, l7.a);
    
    vec4 l8 = layer_Flowers(uv);
    col = mix(col, l8.rgb, l8.a);
  return vec4(clamp(vec3(col),0.0,1.0), 1.0);
}

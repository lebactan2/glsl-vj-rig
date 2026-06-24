float hash(vec2 p) { return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453); }
float noise(vec2 p) {
    vec2 i = floor(p); vec2 f = fract(p);
    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(mix(hash(i + vec2(0.0,0.0)), hash(i + vec2(1.0,0.0)), u.x),
               mix(hash(i + vec2(0.0,1.0)), hash(i + vec2(1.0,1.0)), u.x), u.y);
}

float sdBox(vec3 p, vec3 b) {
    vec3 q = abs(p) - b;
    return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);
}

float layer_Mapping(vec3 p) {
    float dBox = sdBox(p - vec3(-1.0, 0.0, -1.0), vec3(1.2, 0.8, 1.2));
    float dTop = sdBox(p - vec3(-1.0, 0.85, -1.0), vec3(1.25, 0.05, 1.25));
    float dPillar = sdBox(p - vec3(-1.0, 1.5, -1.0), vec3(1.0, 0.6, 1.0));
    float dGround = p.y + 0.8;
    return min(min(min(dBox, dTop), dPillar), dGround);
}

vec3 layer_TileMaterial(vec2 p) {
    p *= vec2(4.0, 8.0);
    float row = floor(p.y);
    p.x += mod(row, 2.0) * 0.5;
    vec2 cell = fract(p);
    vec2 id = floor(p);
    
    float band = mod(floor(row / 2.0), 2.0);
    vec3 baseCol = band < 0.5 ? vec3(0.35, 0.38, 0.4) : vec3(0.55, 0.58, 0.6);
    baseCol *= 0.8 + 0.4 * hash(id);
    
    float tex = noise(p * 20.0) * 0.5 + noise(p * 40.0) * 0.25;
    baseCol = mix(baseCol, vec3(0.2), tex * 0.3);
    
    float groutX = smoothstep(0.0, 0.03, cell.x) * smoothstep(1.0, 0.97, cell.x);
    float groutY = smoothstep(0.0, 0.08, cell.y) * smoothstep(1.0, 0.92, cell.y);
    float grout = groutX * groutY;
    
    vec3 finalCol = mix(vec3(0.7, 0.75, 0.75), baseCol, grout);
    finalCol += 0.1 * smoothstep(0.9, 0.95, cell.x) * grout;
    finalCol -= 0.1 * smoothstep(0.05, 0.0, cell.x) * grout;
    return finalCol;
}

vec3 layer_PillarMaterial(vec3 pos) {
    vec3 matCol = vec3(0.6, 0.62, 0.6);
    matCol *= 0.8 + 0.2 * noise(pos.xz * 50.0 + pos.xy * 50.0);
    return matCol;
}

vec3 layer_GroundMaterial(vec3 pos) {
    vec3 matCol = vec3(0.3, 0.3, 0.3);
    if (pos.x > 0.2) {
        vec2 fUV = pos.xz * 2.0;
        vec2 fID = floor(fUV);
        vec2 fCell = fract(fUV);
        float g = smoothstep(0.0, 0.02, fCell.x) * smoothstep(1.0, 0.98, fCell.x) *
                  smoothstep(0.0, 0.02, fCell.y) * smoothstep(1.0, 0.98, fCell.y);
        vec3 tileC = mix(vec3(0.8, 0.8, 0.8), vec3(0.4, 0.4, 0.4), step(0.5, hash(fID)));
        float flower = step(abs(length(fCell - 0.5) - 0.2), 0.05);
        tileC = mix(tileC, vec3(0.2), flower);
        matCol = mix(vec3(0.5), tileC, g);
    } else {
        float tex = noise(pos.xz * 10.0);
        matCol *= 0.8 + 0.2 * tex;
    }
    return matCol;
}

float layer_Lighting(vec3 pos, vec3 n) {
    vec3 light = normalize(vec3(1.0, 2.0, 1.0));
    float diff = max(dot(n, light), 0.0);
    float amb = 0.3 + 0.1 * n.y;
    
    float sh = 1.0;
    float st = 0.02;
    for(int i = 0; i < 30; i++) {
        float h = layer_Mapping(pos + light * st);
        if(h < 0.001) { sh = 0.1; break; }
        sh = min(sh, 10.0 * h / st);
        st += h;
        if(st > 3.0) break;
    }
    return amb + diff * sh;
}

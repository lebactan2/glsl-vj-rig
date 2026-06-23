/* @layer_metadata
{
  "title": "3D Grey Stone Tiles",
  "layers": [
    {
      "name": "Mapping",
      "keywords": ["sdf", "box", "pillar", "ground", "3D", "geometry"]
    },
    {
      "name": "Tile Material",
      "keywords": ["tiles", "texture", "grey", "grout", "bands"]
    },
    {
      "name": "Pillar Material",
      "keywords": ["pillar", "concrete", "solid", "grey"]
    },
    {
      "name": "Ground Material",
      "keywords": ["ground", "floor", "flower", "pattern"]
    },
    {
      "name": "Lighting",
      "keywords": ["lighting", "diffuse", "ambient", "shadow", "raymarching"]
    }
  ]
}
*/
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

void main() {
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;
    
    vec3 ro = vec3(1.5, 1.0, 1.5);
    vec3 target = vec3(0.0, 0.0, 0.0);
    vec3 cw = normalize(target - ro);
    vec3 cu = normalize(cross(cw, vec3(0.0, 1.0, 0.0)));
    vec3 cv = cross(cu, cw);
    vec3 rd = normalize(p.x * cu + p.y * cv + 1.5 * cw);
    
    float d = 0.0, t = 0.0;
    vec3 pos;
    for(int i = 0; i < 100; i++) {
        pos = ro + rd * t;
        d = layer_Mapping(pos);
        if(d < 0.001 || t > 20.0) break;
        t += d;
    }
    
    vec3 col = vec3(0.0);
    if(t < 20.0) {
        vec2 e = vec2(0.001, 0.0);
        vec3 n = normalize(vec3(
            layer_Mapping(pos + e.xyy) - layer_Mapping(pos - e.xyy),
            layer_Mapping(pos + e.yxy) - layer_Mapping(pos - e.yxy),
            layer_Mapping(pos + e.yyx) - layer_Mapping(pos - e.yyx)
        ));
        
        vec3 matCol = vec3(0.5);
        
        float isBox = step(sdBox(pos - vec3(-1.0, 0.0, -1.0), vec3(1.2, 0.8, 1.2)), 0.01);
        float isTop = step(sdBox(pos - vec3(-1.0, 0.85, -1.0), vec3(1.25, 0.05, 1.25)), 0.01);
        float isPillar = step(sdBox(pos - vec3(-1.0, 1.5, -1.0), vec3(1.0, 0.6, 1.0)), 0.01);
        float isGround = step(abs(pos.y + 0.8), 0.01);
        
        if (isBox > 0.5) {
            vec2 tileUV = vec2(0.0);
            if (abs(n.z) > 0.5) tileUV = pos.xy;
            else if (abs(n.x) > 0.5) tileUV = vec2(pos.z, pos.y);
            else tileUV = pos.xz;
            matCol = layer_TileMaterial(tileUV);
        } else if (isTop > 0.5 || isPillar > 0.5) {
            matCol = layer_PillarMaterial(pos);
        } else if (isGround > 0.5) {
            matCol = layer_GroundMaterial(pos);
        }
        
        float lightIntensity = layer_Lighting(pos, n);
        col = matCol * lightIntensity;
    } else {
        col = vec3(0.05);
    }
    
    col = pow(col, vec3(0.4545));
    gl_FragColor = vec4(col, 1.0);
}

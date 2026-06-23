/* @layer_metadata
{
  "title": "Porcelain Mosaic",
  "layers": [
    {
      "name": "Background Cement",
      "keywords": ["cement", "grey", "noise", "background"]
    },
    {
      "name": "Character Mask",
      "keywords": ["character", "mask", "shape", "abstract"]
    },
    {
      "name": "Mosaic Tiles",
      "keywords": ["voronoi", "shards", "tiles", "mosaic"]
    },
    {
      "name": "Tile Material",
      "keywords": ["porcelain", "surface", "white", "blue", "patterns"]
    },
    {
      "name": "Grout and Bevel",
      "keywords": ["grout", "bevel", "edge", "shadow"]
    },
    {
      "name": "Drop Shadow",
      "keywords": ["drop", "shadow", "outside"]
    }
  ]
}
*/
vec2 hash2(vec2 p) {
    p = vec2(dot(p,vec2(127.1,311.7)), dot(p,vec2(269.5,183.3)));
    return fract(sin(p)*43758.5453);
}

float sdSegment(vec2 p, vec2 a, vec2 b, float r) {
    vec2 pa = p - a, ba = b - a;
    float h = clamp(dot(pa,ba)/dot(ba,ba), 0.0, 1.0);
    return length(pa - ba*h) - r;
}

void layer_BackgroundCement(in vec2 p, inout vec3 col) {
    col = vec3(0.55, 0.56, 0.58);
    float noise = fract(sin(dot(p*100.0, vec2(12.9898, 78.233))) * 43758.5453);
    col -= noise * 0.1;
}

void layer_CharacterMask(in vec2 p, out float d) {
    float top = abs(length(p - vec2(0.0, 0.6)) - 0.2) - 0.05;
    float topCrescent = max(top, -p.y + 0.6);
    
    float h1 = sdSegment(p, vec2(-0.4, 0.4), vec2(0.4, 0.4), 0.08);
    h1 = min(h1, sdSegment(p, vec2(-0.4, 0.4), vec2(-0.6, 0.6), 0.06));
    h1 = min(h1, sdSegment(p, vec2(0.4, 0.4), vec2(0.6, 0.6), 0.06));
    
    float h2 = sdSegment(p, vec2(-0.5, 0.0), vec2(0.5, 0.0), 0.08);
    float v1 = sdSegment(p, vec2(0.0, 0.2), vec2(0.0, -0.2), 0.08);
    
    float b1 = sdSegment(p, vec2(-0.1, -0.1), vec2(-0.6, -0.6), 0.08);
    float b2 = sdSegment(p, vec2(0.1, -0.1), vec2(0.6, -0.6), 0.08);
    
    d = min(topCrescent, min(h1, min(h2, min(v1, min(b1, b2)))));
}

void layer_MosaicTiles(in vec2 p, out float edgeDist, out vec2 closestId) {
    vec2 grid = p * 12.0;
    vec2 id = floor(grid);
    vec2 f = fract(grid);
    
    vec2 res = vec2(8.0);
    vec2 mr;
    
    for(int j=-1; j<=1; j++)
    for(int i=-1; i<=1; i++) {
        vec2 b = vec2(i, j);
        vec2 pt = hash2(id + b);
        vec2 r = b + pt - f;
        float dist = dot(r,r);
        if(dist < res.x) {
            res.x = dist;
            mr = r;
            closestId = id + b;
        }
    }
    
    res.x = 8.0;
    for(int j=-2; j<=2; j++)
    for(int i=-2; i<=2; i++) {
        vec2 b = vec2(i, j);
        vec2 pt = hash2(id + b);
        vec2 r = b + pt - f;
        if(dot(mr-r,mr-r) > 0.00001) {
            res.x = min(res.x, dot( 0.5*(mr+r), normalize(r-mr) ));
        }
    }
    edgeDist = res.x;
}

void layer_TileMaterial(in vec2 p, in vec2 closestId, inout vec3 col) {
    col = vec3(0.95);
    float pattern = sin(closestId.x * 15.0 + p.x * 40.0) * cos(closestId.y * 15.0 + p.y * 40.0);
    pattern += 0.5 * sin(length(p - closestId*0.1) * 100.0);
    
    if (pattern > 0.5) {
        col = vec3(0.1, 0.2, 0.7);
    }
}

void layer_GroutAndBevel(in float d, in float edgeDist, inout vec3 col) {
    if (edgeDist < 0.05) {
        col = vec3(0.85);
    }
    col *= 0.8 + 0.2 * smoothstep(0.0, -0.05, d);
}

void layer_DropShadow(in float d, inout vec3 col) {
    float shadow = smoothstep(0.0, 0.05, d);
    col = mix(col * 0.6, col, shadow);
}

void main() {
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;
    
    vec3 col = vec3(0.0);
    
    layer_BackgroundCement(p, col);
    
    float d;
    layer_CharacterMask(p, d);
    
    if (d < 0.0) {
        float edgeDist;
        vec2 closestId;
        layer_MosaicTiles(p, edgeDist, closestId);
        
        if (edgeDist >= 0.05) {
            layer_TileMaterial(p, closestId, col);
        }
        layer_GroutAndBevel(d, edgeDist, col);
    } else {
        layer_DropShadow(d, col);
    }
    
    gl_FragColor = vec4(col, 1.0);
}

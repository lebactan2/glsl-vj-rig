/* @layer_metadata
{
  "title": "Breeze Blocks Pattern",
  "layers": [
    {
      "name": "Stone Base",
      "keywords": ["stone", "base", "grey", "grout", "ledge", "horizon"]
    },
    {
      "name": "Breeze Blocks",
      "keywords": ["terracotta", "blocks", "frame", "mortar", "curved"]
    },
    {
      "name": "Holes Background",
      "keywords": ["holes", "sky", "background", "interior", "shadow"]
    },
    {
      "name": "Wall Lighting",
      "keywords": ["lighting", "darkens", "edges", "curved wall"]
    }
  ]
}
*/
float hash(vec2 p) { return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453); }

void layer_StoneBase(in vec2 p, float baseLine, inout vec3 col, out float isBase) {
    isBase = 0.0;
    if (p.y < baseLine) {
        isBase = 1.0;
        vec2 stUV = vec2(p.x * 4.0, (p.y - baseLine) * 4.0);
        float row = floor(stUV.y);
        if (mod(row, 2.0) == 0.0) stUV.x += 0.5; // Offset pattern
        
        vec2 id = floor(stUV);
        vec2 cell = fract(stUV);
        
        float val = hash(id);
        vec3 stone = mix(vec3(0.5, 0.52, 0.5), vec3(0.65, 0.65, 0.6), val);
        
        float tex = hash(stUV * 10.0);
        stone *= 0.9 + 0.2 * tex;
        
        float grout = smoothstep(0.0, 0.05, cell.x) * smoothstep(1.0, 0.95, cell.x) *
                      smoothstep(0.0, 0.05, cell.y) * smoothstep(1.0, 0.95, cell.y);
        
        col = mix(vec3(0.8), stone, grout);
        
        if (p.y > baseLine - 0.05) {
            col = vec3(0.9); // White ledge
        }
    }
}

void layer_BreezeBlocks(in vec2 p, in vec2 blockUV, in vec2 cell, in vec2 q, inout vec3 col, out float frameOuter, out float hole) {
    float frameBorderX = 0.48;
    float frameBorderY = 0.48;
    frameOuter = max(q.x - frameBorderX, q.y - frameBorderY);
    
    float holeBox = max(q.x - 0.35, q.y - 0.25);
    float holeDiag = (q.x + q.y) * 0.707 - 0.35; // diagonal cut
    hole = max(holeBox, holeDiag);
    
    if (hole > 0.0 && frameOuter <= 0.0) {
        vec3 terra = vec3(0.7, 0.35, 0.25);
        float tex = hash(blockUV * 20.0);
        terra *= 0.9 + 0.2 * tex;
        
        if (hole < 0.05) {
            terra *= 0.5 + 0.5 * step(0.0, cell.y);
        }
        col = terra;
    } else if (frameOuter > 0.0) {
        col = vec3(0.85);
    }
}

void layer_HolesBackground(in vec2 uv, in vec2 cell, in float hole, in float frameOuter, inout vec3 col) {
    if (!(hole > 0.0 && frameOuter <= 0.0) && !(frameOuter > 0.0)) {
        vec3 sky = mix(vec3(0.8, 0.9, 1.0), vec3(0.6, 0.6, 0.6), clamp(uv.y, 0.0, 1.0));
        col = sky;
        float shadow = smoothstep(-0.1, 0.1, cell.y) * smoothstep(-0.3, 0.3, cell.x);
        col *= 0.6 + 0.4 * shadow;
    }
}

void layer_WallLighting(in vec2 p, in float isBase, inout vec3 col) {
    if (isBase < 0.5) {
        col *= 1.0 - abs(p.x) * 0.2;
    }
}

void main() {
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;
    
    vec3 col = vec3(0.0);
    float baseLine = -0.6;
    float isBase = 0.0;
    
    layer_StoneBase(p, baseLine, col, isBase);
    
    if (isBase < 0.5) {
        float curve = p.x * p.x * 0.15;
        vec2 blockUV = vec2(p.x, p.y + curve);
        blockUV *= vec2(6.0, 12.0); // grid scale
        
        vec2 id = floor(blockUV);
        vec2 cell = fract(blockUV) - 0.5;
        vec2 q = abs(cell);
        
        float frameOuter = 0.0;
        float hole = 0.0;
        
        layer_BreezeBlocks(p, blockUV, cell, q, col, frameOuter, hole);
        layer_HolesBackground(uv, cell, hole, frameOuter, col);
    }
    
    layer_WallLighting(p, isBase, col);
    
    gl_FragColor = vec4(col, 1.0);
}

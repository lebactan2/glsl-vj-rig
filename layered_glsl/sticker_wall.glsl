/* @layer_metadata
{
  "title": "Sticker Wall",
  "layers": [
    {
      "name": "Metal Panels",
      "keywords": ["metal", "panels", "seams", "dirt", "grime", "wall"]
    },
    {
      "name": "Small Stickers",
      "keywords": ["stickers", "ads", "paper", "text", "random"]
    },
    {
      "name": "Warning Sign",
      "keywords": ["warning", "sign", "electrical", "red", "text", "lightning"]
    }
  ]
}
*/
float hash(vec2 p) { return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453); }

void layer_MetalPanels(in vec2 p, inout vec3 col) {
    col = vec3(0.75, 0.76, 0.78);
    float seams = step(abs(fract(p.x * 4.0) - 0.5), 0.01);
    col = mix(col, vec3(0.4), seams);
    
    float dirt = hash(floor(p * 200.0)) * 0.1;
    col -= dirt * (1.0 - p.y);
}

void layer_SmallStickers(in vec2 p, inout vec3 col) {
    vec2 grid = p * vec2(10.0, 15.0);
    vec2 id = floor(grid);
    vec2 f = fract(grid);
    
    float n = hash(id);
    if (n > 0.6) {
        float w = 0.2 + 0.2 * hash(id + 1.0);
        float h = 0.15 + 0.15 * hash(id + 2.0);
        vec2 center = vec2(0.5) + 0.2 * vec2(hash(id + 3.0), hash(id + 4.0)) - 0.1;
        
        vec2 dist = abs(f - center);
        if (dist.x < w && dist.y < h) {
            vec3 stickerCol = vec3(0.95, 0.95, 0.9);
            
            float lines = step(abs(fract((f.y - center.y) * 15.0) - 0.5), 0.2);
            vec3 textColor = hash(id + 5.0) > 0.5 ? vec3(0.1, 0.2, 0.7) : vec3(0.1, 0.6, 0.3);
            
            float textMask = step(dist.x, w - 0.05) * step(dist.y, h - 0.05);
            col = mix(stickerCol, textColor, lines * textMask);
        }
    }
}

void layer_WarningSign(in vec2 p, inout vec3 col) {
    if (p.x > 0.35 && p.x < 0.65 && p.y > 0.7 && p.y < 0.9) {
        vec3 signCol = vec3(0.98);
        
        float text1 = step(abs(p.y - 0.85), 0.02) * step(abs(p.x - 0.5), 0.1);
        float text2 = step(abs(p.y - 0.78), 0.015) * step(abs(p.x - 0.5), 0.12);
        float text3 = step(abs(p.y - 0.74), 0.015) * step(abs(p.x - 0.5), 0.12);
        
        float boltX = abs(p.x - 0.4);
        float bolt = step(boltX, 0.02 - (p.y - 0.8)*0.1) * step(p.y, 0.88) * step(0.72, p.y);
        
        col = mix(signCol, vec3(0.8, 0.1, 0.1), clamp(text1 + text2 + text3 + bolt, 0.0, 1.0));
    }
}

void main() {
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv;
    
    vec3 col = vec3(0.0);
    
    layer_MetalPanels(p, col);
    layer_SmallStickers(p, col);
    layer_WarningSign(p, col);
    
    gl_FragColor = vec4(col, 1.0);
}

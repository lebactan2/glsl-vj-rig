/* @layer_metadata
{
  "title": "Shader: IMG_1011",
  "layers": [
    {
      "name": "Wall Tiles",
      "keywords": ["wall", "tiles", "pattern", "beige", "brown", "animation"]
    },
    {
      "name": "Floor Tiles",
      "keywords": ["floor", "tiles", "stone", "grey", "animation"]
    },
    {
      "name": "Chair Shadow",
      "keywords": ["shadow", "chair", "dark"]
    },
    {
      "name": "Woven Chair",
      "keywords": ["chair", "woven", "blue", "metal", "frame", "silver", "fabric", "holes"]
    }
  ]
}
*/
void layer_WallTiles(in vec2 p, in float iTime, inout vec3 col, out bool isWall) {
    isWall = false;
    if (p.x < 0.2) {
        isWall = true;
        col = vec3(0.7, 0.6, 0.4); 
        float tile = step(0.1, fract(p.y * 10.0)) * step(0.1, fract(p.x * 5.0 + step(0.5, fract(p.y * 5.0)) * 0.5));
        col *= mix(0.8, 1.0, tile);
        
        float wallAnim = sin(p.x * 20.0 + iTime) * cos(p.y * 20.0 + iTime) * 0.05;
        col += wallAnim;
    }
}

void layer_FloorTiles(in vec2 p, in float iTime, inout vec3 col) {
    col = vec3(0.6, 0.6, 0.6);
    float floorTile = fract(p.x * 8.0 + p.y * 8.0);
    col *= mix(0.8, 1.0, step(0.1, floorTile));
    
    float floorAnim = sin(length(p) * 20.0 - iTime * 2.0) * 0.05;
    col += floorAnim;
}

void layer_ChairShadow(in vec2 p, inout vec3 col) {
    if (p.x > 0.1 && p.x < 0.8 && p.y > -0.8 && p.y < 0.2) {
        col *= 0.4;
    }
}

void layer_WovenChair(in vec2 p, in float iTime, inout vec3 col) {
    if (p.x > -0.6 && p.x < 0.4 && p.y > -0.6 && p.y < 0.5) {
        if (abs(p.x + 0.6) < 0.02 || abs(p.x - 0.4) < 0.02 || abs(p.y - 0.5) < 0.02 || abs(p.y + 0.6) < 0.02) {
            col = vec3(0.8, 0.8, 0.85); 
            float shine = smoothstep(0.0, 0.1, sin((p.x + p.y) * 10.0 + iTime * 3.0));
            col += shine * 0.5;
        } else {
            col = vec3(0.1, 0.2, 0.6); 
            float weaveX = abs(fract(p.x * 15.0) - 0.5);
            float weaveY = abs(fract(p.y * 15.0) - 0.5);
            
            if (weaveX > 0.1 ^^ weaveY > 0.1) {
                col *= 0.8; 
            }
            if (weaveX < 0.05 && weaveY < 0.05) {
                if (p.x < 0.2) col = vec3(0.6, 0.5, 0.3);
                else col = vec3(0.5);
            }
        }
    }
}

void main() {
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(0.0);
    bool isWall;
    
    layer_WallTiles(p, iTime, col, isWall);
    
    if (!isWall) {
        layer_FloorTiles(p, iTime, col);
    }
    
    layer_ChairShadow(p, col);
    layer_WovenChair(p, iTime, col);

    gl_FragColor = vec4(col, 1.0);
}

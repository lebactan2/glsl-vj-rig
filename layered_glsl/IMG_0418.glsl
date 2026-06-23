/* @layer_metadata
{
  "title": "Shader: IMG_0418",
  "layers": [
    {
      "name": "Wall",
      "keywords": ["wall", "texture", "grey", "background"]
    },
    {
      "name": "Red Pallet",
      "keywords": ["pallet", "red", "back", "holes"]
    },
    {
      "name": "Green Pallets",
      "keywords": ["pallet", "green", "front", "glow", "animation", "holes"]
    }
  ]
}
*/
void layer_Wall(in vec2 p, inout vec3 col) {
    col = vec3(0.5, 0.5, 0.52);
    col *= 0.9 + 0.1 * fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}

void layer_RedPallet(in vec2 palletUV, inout vec3 col) {
    if (palletUV.x > -1.2 && palletUV.x < 1.2 && palletUV.y > 0.1 && palletUV.y < 2.0) {
        vec3 redPallet = vec3(0.5, 0.2, 0.2);
        vec2 grid = fract(palletUV * 5.0);
        if (grid.x < 0.1 || grid.y < 0.1 || grid.x > 0.9 || grid.y > 0.9) redPallet *= 0.6;
        if (fract(palletUV.x * 2.5) > 0.8 && fract(palletUV.y * 2.5) > 0.8) redPallet *= 0.3;
        col = redPallet;
    }
}

void layer_GreenPallets(in vec2 palletUV, in float iTime, inout vec3 col) {
    vec2 pUV = palletUV;
    pUV.y -= 0.2;
    pUV.x -= 0.1;
    if (pUV.x > -1.2 && pUV.x < 1.2 && pUV.y > 0.1 && pUV.y < 2.0) {
        vec3 greenPallet = vec3(0.6, 0.7, 0.2);
        vec2 grid = fract(pUV * 5.0);
        
        float glow = sin(iTime * 2.0 + pUV.x * 10.0 + pUV.y * 5.0) * 0.1 + 0.1;
        
        if (grid.x < 0.1 || grid.y < 0.1 || grid.x > 0.9 || grid.y > 0.9) greenPallet *= 0.6;
        
        if (fract(pUV.x * 2.5) > 0.8 && fract(pUV.y * 2.5) > 0.8) {
            greenPallet *= 0.3; 
            greenPallet += vec3(glow, glow * 0.5, 0.0);
        }
        
        greenPallet *= 0.8 + 0.2 * pUV.y;
        col = greenPallet;
    }
}

void main() {
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(0.0);
    layer_Wall(p, col);
    
    vec2 palletUV = p * mat2(0.9, -0.1, 0.1, 0.9);
    palletUV *= 2.0;
    palletUV.y += 1.0;
    
    layer_RedPallet(palletUV, col);
    layer_GreenPallets(palletUV, iTime, col);

    gl_FragColor = vec4(col, 1.0);
}

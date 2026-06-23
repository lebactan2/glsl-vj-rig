/* @layer_metadata
{
  "title": "Shader: IMG_1077",
  "layers": [
    {
      "name": "Metallic Plate",
      "keywords": ["metal", "plate", "reflection", "animation", "background"]
    },
    {
      "name": "Holes",
      "keywords": ["holes", "grid", "dark"]
    },
    {
      "name": "Colored Pencils",
      "keywords": ["pencils", "colors", "orange", "blue", "peach", "texture"]
    },
    {
      "name": "Laser Beam",
      "keywords": ["laser", "beam", "spot", "red", "glow", "animation"]
    }
  ]
}
*/
void layer_MetallicPlate(in vec2 p, in float iTime, inout vec3 col) {
    col = vec3(0.6, 0.6, 0.65);
    float reflection = sin(p.x * 3.0 + p.y * 3.0 + iTime) * 0.1;
    col += reflection;
}

void layer_Holes(in vec2 p, inout vec3 col) {
    vec2 gridP = fract(p * 5.0) - 0.5;
    if (length(gridP) < 0.1) {
        col = vec3(0.2, 0.2, 0.2);
    }
}

void layer_ColoredPencils(in vec2 p, inout vec3 col) {
    if (p.y > 0.2 && p.x > -0.4 && p.x < 0.6) {
        float pencilIdx = floor((p.x + 0.4) * 5.0); 
        float pencilPos = fract((p.x + 0.4) * 5.0);
        if (pencilPos > 0.1 && pencilPos < 0.9) {
            if (pencilIdx == 0.0) col = vec3(0.8, 0.3, 0.2); 
            else if (pencilIdx == 1.0) col = vec3(0.2, 0.5, 0.8); 
            else if (pencilIdx == 2.0) col = vec3(0.9, 0.6, 0.3); 
            else if (pencilIdx == 3.0) col = vec3(0.3, 0.6, 0.8); 
            else col = vec3(0.2, 0.4, 0.7); 
            
            float shade = sin(pencilPos * 3.1415) * 0.2;
            col -= (1.0 - shade) * 0.2;
        }
    }
}

void layer_LaserBeam(in vec2 p, in float iTime, inout vec3 col) {
    vec2 laserPos = vec2(sin(iTime * 2.0) * 0.3, -0.3 + cos(iTime * 1.5) * 0.2); 
    float dLaser = length(p - laserPos);
    
    if (dLaser < 0.2) {
        vec3 glowCol = vec3(1.0, 0.2, 0.1);
        float intensity = pow(0.2 / (dLaser + 0.01), 1.5) * 0.05;
        col += glowCol * intensity;
    }
    
    if (dLaser < 0.02) {
        col = vec3(1.0, 0.8, 0.8);
    }
}

void main() {
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(0.0);
    
    layer_MetallicPlate(p, iTime, col);
    layer_Holes(p, col);
    layer_ColoredPencils(p, col);
    layer_LaserBeam(p, iTime, col);

    gl_FragColor = vec4(col, 1.0);
}

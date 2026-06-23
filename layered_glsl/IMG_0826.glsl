/* @layer_metadata
{
  "title": "Shader: IMG_0826",
  "layers": [
    {
      "name": "Surrounding Wall",
      "keywords": ["wall", "grey", "background"]
    },
    {
      "name": "Blue Tiles",
      "keywords": ["blue", "tiles", "grout", "above gate"]
    },
    {
      "name": "Scissor Gate",
      "keywords": ["gate", "scissor", "lattice", "metal", "animation", "stretch"]
    },
    {
      "name": "Right Pillar",
      "keywords": ["pillar", "cables", "right", "dark"]
    }
  ]
}
*/
void layer_SurroundingWall(inout vec3 col) {
    col = vec3(0.8, 0.8, 0.8);
}

void layer_BlueTiles(in vec2 p, inout vec3 col) {
    if (p.y > 0.3 && abs(p.x) < 0.6) {
        col = vec3(0.6, 0.8, 0.9);
        if (fract(p.x * 20.0) < 0.1 || fract(p.y * 20.0) < 0.1) {
            col = vec3(0.5, 0.7, 0.8);
        }
    }
}

void layer_ScissorGate(in vec2 p, in float iTime, inout vec3 col) {
    if (p.y < 0.3 && abs(p.x) < 0.6) {
        col = vec3(0.05, 0.05, 0.05); 
        
        float stretch = 1.0 + 0.1 * sin(iTime * 2.0);
        vec2 gp = p;
        gp.x *= stretch;
        
        float diag1 = abs(fract(gp.x * 5.0 + gp.y * 5.0) - 0.5);
        float diag2 = abs(fract(gp.x * 5.0 - gp.y * 5.0) - 0.5);
        float vertical = abs(fract(gp.x * 5.0) - 0.5);
        
        if (diag1 < 0.05 || diag2 < 0.05 || vertical < 0.03) {
            col = vec3(0.85, 0.8, 0.75);
            col *= 0.8 + 0.2 * sin(gp.x * 50.0);
        }
    }
}

void layer_RightPillar(in vec2 p, inout vec3 col) {
    if (p.x > 0.6) {
        col = vec3(0.2, 0.2, 0.2);
        float cable1 = abs(p.x - 0.7 - 0.05 * sin(p.y * 5.0));
        float cable2 = abs(p.x - 0.8 + 0.08 * cos(p.y * 7.0));
        if (cable1 < 0.02 || cable2 < 0.015) {
            col = vec3(0.1);
        }
    }
}

void main() {
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;
    
    vec3 col = vec3(0.0);
    
    layer_SurroundingWall(col);
    layer_BlueTiles(p, col);
    layer_ScissorGate(p, iTime, col);
    layer_RightPillar(p, col);
    
    gl_FragColor = vec4(col, 1.0);
}

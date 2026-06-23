/* @layer_metadata
{
  "title": "Shader: IMG_1663",
  "layers": [
    {
      "name": "Sign Area",
      "keywords": ["sign", "blue", "top", "background"]
    },
    {
      "name": "Pavement",
      "keywords": ["pavement", "concrete", "pebbles", "bottom", "background"]
    },
    {
      "name": "Decorative Iron Gate",
      "keywords": ["iron", "gate", "decorative", "patterns", "circles", "diamonds", "bricks", "mesh"]
    },
    {
      "name": "Red Warning Sign",
      "keywords": ["warning", "sign", "red", "yellow", "text"]
    }
  ]
}
*/
void layer_SignArea(in vec2 p, in float iTime, inout vec3 col) {
    if (p.y > 0.8) {
        col = vec3(0.2, 0.5, 0.75); 
        float signText = sin(p.x*20.0 + iTime*2.0)*sin(p.y*20.0);
        if (signText > 0.5) col *= 0.8; 
    }
}

void layer_Pavement(in vec2 p, inout vec3 col) {
    if (p.y < -0.85) {
        col = vec3(0.35, 0.35, 0.35); 
        float pebble = fract(sin(dot(floor(p*50.0), vec2(12.9898, 78.233))) * 43758.5453);
        col -= 0.1 * pebble;
    }
}

void layer_DecorativeIronGate(in vec2 p, in float iTime, inout vec3 col) {
    if (p.y <= 0.8 && p.y >= -0.85) {
        vec2 gridP = p * vec2(3.0, 4.0);
        vec2 fGrid = fract(gridP) - 0.5;
        vec2 iGrid = floor(gridP);
        
        float iron = 0.0;
        vec3 ironCol = vec3(0.3, 0.4, 0.4); 
        
        if (abs(fGrid.x) > 0.46 || abs(fGrid.y) > 0.46) iron = 1.0;
        
        float cellType = fract(sin(dot(iGrid, vec2(12.9898, 78.233))) * 43758.5453);
        
        if (cellType < 0.3) {
            float r = length(fGrid);
            if (abs(r - 0.3) < 0.03) iron = 1.0;
            if (abs(fGrid.x) < 0.02) iron = 1.0;
            
            float angle = atan(fGrid.y, fGrid.x);
            float petals = cos(angle * 8.0 + iTime);
            if (r < 0.3 && r > 0.25 && petals > 0.5) ironCol = vec3(0.7, 0.8, 0.5); 
        } 
        else if (cellType < 0.6) {
            float d = abs(fGrid.x) + abs(fGrid.y);
            if (abs(d - 0.35) < 0.03) iron = 1.0;
            
            if (abs(d - 0.15 - 0.05*sin(iTime*2.0 + iGrid.x)) < 0.02) ironCol = vec3(0.6, 0.7, 0.8); 
        } 
        else {
            if (abs(fGrid.x) < 0.02 || abs(fGrid.y) < 0.02) iron = 1.0;
            if (abs(fGrid.y - 0.25) < 0.02 || abs(fGrid.y + 0.25) < 0.02) iron = 1.0;
            if (fGrid.y > 0.0 && abs(fGrid.x - 0.25) < 0.02) iron = 1.0;
            if (fGrid.y < 0.0 && abs(fGrid.x + 0.25) < 0.02) iron = 1.0;
        }
        
        if (iron > 0.0) {
            col = ironCol; 
            if (fGrid.x > 0.46 || fGrid.y > 0.46) col *= 0.6;
            if (fGrid.x < -0.46 || fGrid.y < -0.46) col *= 1.4;
        } else {
            float mesh = step(0.8, fract(p.x * 100.0)) + step(0.8, fract(p.y * 100.0));
            col = vec3(0.1) + 0.05 * mesh;
        }
    }
}

void layer_RedWarningSign(in vec2 p, inout vec3 col) {
    if (p.y <= 0.8 && p.y >= -0.85) {
        if (abs(p.x) < 0.35 && abs(p.y + 0.1) < 0.18) {
            col = vec3(0.85, 0.15, 0.15); 
            
            if (abs(p.y + 0.05) < 0.04 && fract(p.x*25.0) < 0.7 && abs(p.x) < 0.3) {
                col = vec3(0.95, 0.95, 0.2); 
            }
            if (abs(p.y + 0.13) < 0.015 && fract(p.x*30.0) < 0.6 && abs(p.x) < 0.25) col = vec3(1.0); 
            if (abs(p.y + 0.18) < 0.015 && fract(p.x*30.0) < 0.6 && abs(p.x) < 0.28) col = vec3(1.0); 
            
            if (max(abs(p.x) - 0.33, abs(p.y + 0.1) - 0.16) > 0.0) {
                col = vec3(0.95, 0.95, 0.2); 
            }
        }
    }
}

void main() {
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(0.15, 0.15, 0.18); 
    
    layer_SignArea(p, iTime, col);
    layer_Pavement(p, col);
    layer_DecorativeIronGate(p, iTime, col);
    layer_RedWarningSign(p, col);

    gl_FragColor = vec4(col, 1.0);
}

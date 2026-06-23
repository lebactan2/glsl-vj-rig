/* @layer_metadata
{
  "title": "Shader: IMG_1720",
  "layers": [
    {
      "name": "Background",
      "keywords": ["wall", "white", "grey", "background"]
    },
    {
      "name": "Ground Path",
      "keywords": ["ground", "path", "pavement", "brick", "animation"]
    },
    {
      "name": "Right Wall Column",
      "keywords": ["wall", "column", "stone", "texture"]
    },
    {
      "name": "White Gate Structure",
      "keywords": ["gate", "white", "structure", "sunburst", "fan", "swirls", "rust", "borna", "sign"]
    },
    {
      "name": "Top Foliage",
      "keywords": ["foliage", "leaves", "overhanging", "green", "animation"]
    },
    {
      "name": "Motorcycle",
      "keywords": ["motorcycle", "scooter", "fairing", "seat", "wheels", "mirror"]
    }
  ]
}
*/
void layer_Background(in vec2 p, inout vec3 col) {
    col = vec3(0.85, 0.85, 0.85);
}

void layer_GroundPath(in vec2 p, in float iTime, inout vec3 col) {
    if (p.y < -0.6) {
        col = vec3(0.5, 0.35, 0.3);
        
        vec2 floorUV = vec2(p.x / (abs(p.y) + 0.1), 1.0 / (abs(p.y) + 0.1));
        float brickX = fract(floorUV.x * 10.0);
        float brickY = fract(floorUV.y * 10.0 + iTime*0.5); 
        if (brickX > 0.9 || brickY > 0.9) col = vec3(0.3, 0.2, 0.15); 
    }
}

void layer_RightWallColumn(in vec2 p, inout vec3 col) {
    if (p.x > 1.2 && p.y >= -0.6) {
        col = vec3(0.6, 0.6, 0.55);
        vec2 stoneP = p * vec2(2.0, 5.0);
        stoneP.x += mod(floor(stoneP.y), 2.0) * 0.5;
        if (fract(stoneP.x) > 0.9 || fract(stoneP.y) > 0.9) col = vec3(0.4, 0.4, 0.35);
        
        col -= 0.1 * fract(sin(dot(p*100.0, vec2(12.9898, 78.233))) * 43758.5453);
    }
}

void layer_WhiteGateStructure(in vec2 p, in float iTime, inout vec3 col) {
    if (p.y < 0.6 && p.x <= 1.2 && p.y >= -0.6) {
        col = vec3(0.9, 0.9, 0.9); 
        
        vec2 gP = p;
        gP.x = abs(gP.x) - 0.6;
        
        float iron = 0.0;
        
        if (abs(p.x) < 1.15 && abs(p.y + 0.1) < 0.6) {
             if (abs(abs(p.x) - 1.1) < 0.03 || abs(abs(p.y + 0.1) - 0.55) < 0.03) iron = 1.0;
             if (abs(p.x) < 0.02) iron = 1.0;
             
             float angle = atan(gP.y + 0.1, gP.x);
             float dist = length(gP + vec2(0.0, 0.1));
             
             if (abs(dist - 0.4) < 0.02 && gP.y > -0.1) iron = 1.0;
             if (abs(dist - 0.5) < 0.02 && gP.y > -0.1) iron = 1.0;
             
             float rayAnim = fract(dist - iTime*0.5);
             if (dist < 0.5 && gP.y > -0.1 && fract(angle * 4.0) < 0.1) {
                 iron = 1.0;
                 if (rayAnim < 0.2) col = vec3(1.0); 
             }
             
             if (p.y < -0.1 && p.y > -0.5) {
                 vec2 swirlP = fract(p * 4.0 + vec2(iTime*0.2, 0.0)) - 0.5;
                 if (abs(length(swirlP) - 0.3) < 0.04) iron = 1.0;
                 if (length(swirlP) < 0.08) iron = 1.0;
             }
        }
        
        if (iron > 0.0) {
            col = vec3(0.85, 0.85, 0.85); 
            float rust = fract(sin(dot(p*80.0, vec2(12.9898, 78.233))) * 43758.5453);
            if (rust > 0.9) col = vec3(0.6, 0.4, 0.2);
            
            col *= 0.9;
        } else if (abs(p.x) < 1.15 && abs(p.y + 0.1) < 0.6) {
            col = vec3(0.8, 0.8, 0.8);
        }
        
        if (p.x > 0.1 && p.x < 0.4 && p.y > 0.45 && p.y < 0.55) {
            col = vec3(0.9, 0.9, 0.9); 
            if (abs(p.y - 0.5) < 0.02 && p.x > 0.15 && p.x < 0.35) col = vec3(0.8, 0.1, 0.1);
        }
    }
}

void layer_TopFoliage(in vec2 p, in float iTime, inout vec3 col) {
    if (p.y > 0.3) {
        float leaves = sin(p.x * 15.0 + iTime)*cos(p.y * 15.0) + sin(p.x * 30.0 + p.y * 10.0 - iTime)*0.5;
        float density = p.y + (1.0 - p.x)*0.5; 
        
        if (leaves > -0.2 && density > 1.0) col = vec3(0.2, 0.4, 0.1); 
        if (leaves > 0.3 && density > 0.8) col = vec3(0.4, 0.6, 0.2); 
        if (leaves > 0.6 && density > 0.6) col = vec3(0.6, 0.8, 0.3); 
    }
}

void layer_Motorcycle(in vec2 p, inout vec3 col) {
    vec2 scP = p - vec2(0.9, -0.4);
    if (length(max(abs(scP) - vec2(0.35, 0.3), 0.0)) < 0.15) {
        float mcBody = 0.0;
        
        if (length(scP - vec2(-0.2, 0.1)) < 0.25) mcBody = 1.0;
        if (length(scP - vec2(-0.3, 0.4)) < 0.15) {
            mcBody = 1.0;
            if (length(scP - vec2(-0.4, 0.6)) < 0.05) col = vec3(0.1, 0.3, 0.2); 
        }
        if (length(scP - vec2(0.2, 0.2)) < 0.2) mcBody = 2.0; 
        
        if (mcBody == 1.0) {
            col = vec3(0.6, 0.3, 0.1); 
            if (scP.y > 0.0 && scP.x < 0.0) col += 0.2;
        } else if (mcBody == 2.0) {
            col = vec3(0.15); 
        }
        
        if (length(scP - vec2(-0.1, -0.3)) < 0.15) col = vec3(0.1);
        if (length(scP - vec2(0.3, -0.3)) < 0.15) col = vec3(0.1);
    }
}

void main() {
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(0.0);
    
    layer_Background(p, col);
    layer_GroundPath(p, iTime, col);
    layer_RightWallColumn(p, col);
    layer_WhiteGateStructure(p, iTime, col);
    layer_TopFoliage(p, iTime, col);
    layer_Motorcycle(p, col);

    gl_FragColor = vec4(col, 1.0);
}

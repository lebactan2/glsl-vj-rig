/* @layer_metadata
{
  "title": "Shader: IMG_2586",
  "layers": [
    {
      "name": "Background",
      "keywords": ["wall", "metal", "gate", "floor", "brick", "perspective", "animation"]
    },
    {
      "name": "Table Benches",
      "keywords": ["table", "bench", "isometric", "perspective", "chessboard", "tiles", "shine", "animation"]
    }
  ]
}
*/
void layer_Background(in vec2 p, in float iTime, inout vec3 col) {
    if (p.y > 0.2) {
        if (p.x > -0.5 && p.x < 0.6) {
            col = vec3(0.25, 0.25, 0.3); 
            if (fract((p.x + 0.5) * 15.0) < 0.2) col = vec3(0.15); 
            if (fract(p.x * 10.0 + p.y * 10.0) < 0.1 || fract(p.x * 10.0 - p.y * 10.0) < 0.1) col = vec3(0.2); 
        } else {
            col = vec3(0.8, 0.7, 0.4); 
            if (abs(p.x + 0.55) < 0.05 || abs(p.x - 0.65) < 0.05) col = vec3(0.85); 
        }
    } else {
        col = vec3(0.6, 0.3, 0.2); 
        
        float floorDepth = 0.1 - p.y;
        vec2 groundP = vec2(p.x / floorDepth, 1.0 / floorDepth);
        if (p.y < 0.1) {
            groundP.x += iTime * 0.2;
            groundP.y -= iTime * 0.5;
            
            vec2 brickGrid = fract(groundP * vec2(2.0, 5.0));
            if (fract(groundP.y * 5.0) > 0.5) brickGrid.x = fract(groundP.x * 2.0 + 0.5); 
            
            if (brickGrid.x < 0.05 || brickGrid.y < 0.05) col = vec3(0.4, 0.2, 0.15); 
            
            float noise = fract(sin(dot(floor(groundP * vec2(2.0, 5.0)), vec2(12.9898, 78.233))) * 43758.5453);
            col += (noise - 0.5) * 0.1;
        }
    }
}

void layer_TableBenches(in vec2 p, in float iTime, inout vec3 col) {
    vec2 tP = p - vec2(0.0, 0.0);
    vec2 tableUV = vec2(tP.x + tP.y * 2.0, tP.x - tP.y * 2.0) * 1.5;
    
    vec2 lbP = p - vec2(-0.8, -0.2);
    vec2 lbUV = vec2(lbP.x + lbP.y * 2.0, lbP.x - lbP.y * 2.0) * 1.8;
    
    vec2 rbP = p - vec2(0.8, -0.4);
    vec2 rbUV = vec2(rbP.x + rbP.y * 2.0, rbP.x - rbP.y * 2.0) * 1.8;
    
    vec2 fbP = p - vec2(0.2, -0.5);
    vec2 fbUV = vec2(fbP.x + fbP.y * 2.0, fbP.x - fbP.y * 2.0) * 1.5;

    float isTable = 0.0;
    
    if (tableUV.x > -1.0 && tableUV.x < 1.0 && tableUV.y > -1.0 && tableUV.y < 1.0) {
        if (abs(tableUV.x) < 0.3 && abs(tableUV.y) < 0.3) {
            vec2 cbGrid = fract(tableUV * 15.0);
            if ((cbGrid.x > 0.5 && cbGrid.y > 0.5) || (cbGrid.x < 0.5 && cbGrid.y < 0.5)) {
                col = vec3(0.1, 0.3, 0.15); 
            } else {
                col = vec3(0.9, 0.9, 0.9); 
            }
        } else {
            vec2 tGrid = fract(tableUV * 4.0);
            col = vec3(0.6, 0.75, 0.85); 
            if (abs(tGrid.x - 0.5) + abs(tGrid.y - 0.5) < 0.4) col = vec3(0.85, 0.9, 0.95); 
            
            if (tGrid.x < 0.02 || tGrid.y < 0.02) col = vec3(0.3);
            
            float shine = sin(tableUV.x*5.0 + tableUV.y*5.0 - iTime*3.0);
            if (shine > 0.9) col += vec3(0.2);
        }
        isTable = 1.0;
    }
    
    if (isTable == 0.0 && tableUV.x < 1.0 && tableUV.y > -1.0 && tP.y < 0.0 && tP.y > -0.05) {
        if (tP.x + tP.y * 2.0 > -1.0 && tP.x - tP.y * 2.0 < 1.0) {
            col = vec3(0.5); 
        }
    }
    
    if (p.x > -0.15 && p.x < 0.15 && p.y < 0.0 && p.y > -0.4) {
        col = vec3(0.6); 
        if (fract(p.x * 15.0) < 0.2) col *= 0.8; 
        col *= 1.0 - (0.0 - p.y) * 0.5; 
    }
    
    if (fbUV.x > -0.8 && fbUV.x < 0.8 && fbUV.y > -0.3 && fbUV.y < 0.3) {
        vec2 tGrid = fract(fbUV * 4.0);
        col = vec3(0.6, 0.75, 0.85);
        if (abs(tGrid.x - 0.5) + abs(tGrid.y - 0.5) < 0.4) col = vec3(0.85, 0.9, 0.95);
        if (tGrid.x < 0.02 || tGrid.y < 0.02) col = vec3(0.3);
        
        float shine = sin(fbUV.x*5.0 + fbUV.y*5.0 - iTime*3.0);
        if (shine > 0.9) col += vec3(0.2);
    }
    if (abs(fbP.x - 0.3) < 0.08 && fbP.y < -0.05 && fbP.y > -0.3) col = vec3(0.55); 
    if (abs(fbP.x + 0.3) < 0.08 && fbP.y < -0.05 && fbP.y > -0.3) col = vec3(0.55); 
}

void main() {
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(0.0);
    
    layer_Background(p, iTime, col);
    layer_TableBenches(p, iTime, col);

    gl_FragColor = vec4(col, 1.0);
}

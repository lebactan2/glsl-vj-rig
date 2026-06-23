/* @layer_metadata
{
  "title": "Shader: IMG_6551",
  "layers": [
    {
      "name": "Wall",
      "keywords": ["wall", "noise"]
    },
    {
      "name": "Railing",
      "keywords": ["railing", "balcony", "lotus", "animation", "bloom"]
    },
    {
      "name": "Window",
      "keywords": ["window", "frame", "grille", "pattern", "scrolling", "animation"]
    },
    {
      "name": "Roof and Dragon",
      "keywords": ["roof", "dragon", "tiles", "flowing", "shimmering", "gold"]
    }
  ]
}
*/
void layer_Wall(in vec2 p, in float iTime, inout vec3 col) {
    vec3 wallColor = vec3(0.85, 0.7, 0.65); 
    col = wallColor;
    
    float wallNoise = fract(sin(dot(p + iTime*0.05, vec2(12.9898, 78.233))) * 43758.5453);
    col *= 0.95 + 0.05 * wallNoise;
}

void layer_Railing(in vec2 p, in float iTime, inout vec3 col) {
    if (p.y > -0.6 && p.y < -0.1) {
        vec3 balconyTan = vec3(0.85, 0.8, 0.6); 
        bool isRailing = false;
        
        if (abs(p.y - -0.1) < 0.015) isRailing = true;
        if (abs(p.y - -0.6) < 0.015) isRailing = true;
        if (fract(p.x * 4.0) < 0.05) isRailing = true;
        
        vec2 panelP = vec2(fract(p.x * 4.0) - 0.5, p.y - -0.35);
        panelP.x *= 0.25; 
        
        float bloom = sin(iTime * 2.0 + p.x * 5.0) * 0.01;
        float rL = length(panelP);
        
        if (abs(rL - 0.1 - bloom) < 0.005 && panelP.y > -0.05) isRailing = true; 
        if (abs(length(panelP - vec2(0.0, 0.1)) - 0.08 + bloom) < 0.005) isRailing = true; 
        if (abs(panelP.x) < 0.005 && panelP.y < 0.0) isRailing = true;
        
        if (isRailing) {
            col = balconyTan;
            col *= 0.8 + 0.2 * cos(p.x * 20.0);
        } else {
            col *= 0.85; 
        }
    }
}

void layer_Window(in vec2 p, in float iTime, inout vec3 col) {
    vec2 winCenter = vec2(0.1, 0.4);
    vec2 winSize = vec2(0.4, 0.45);
    vec3 frameColor = vec3(0.8, 0.4, 0.4);  
    vec3 grilleGreen = vec3(0.2, 0.6, 0.5); 
    
    if (abs(p.x - winCenter.x) < winSize.x && abs(p.y - winCenter.y) < winSize.y) {
        col = vec3(0.05, 0.08, 0.1); 
        
        if (abs(p.x - winCenter.x) > winSize.x - 0.02 || abs(p.y - winCenter.y) > winSize.y - 0.02) {
            col = frameColor;
        } else {
            vec2 gw = (p - winCenter + winSize) / (winSize * 2.0); 
            
            vec2 cellCoords = vec2(gw.x * 2.0, gw.y * 4.0);
            cellCoords.x += sin(iTime + cellCoords.y) * 0.1;
            
            vec2 localGrid = fract(cellCoords) - 0.5; 
            
            bool isGrille = false;
            
            if (abs(localGrid.x) > 0.45 || abs(localGrid.y) > 0.45) isGrille = true;
            
            float rG = length(localGrid);
            if (abs(rG - 0.15) < 0.04) isGrille = true;
            
            if (abs(length(localGrid - vec2(0.5, 0.5)) - 0.35) < 0.03) isGrille = true;
            if (abs(length(localGrid - vec2(-0.5, -0.5)) - 0.35) < 0.03) isGrille = true;
            if (abs(length(localGrid - vec2(-0.5, 0.5)) - 0.35) < 0.03) isGrille = true;
            if (abs(length(localGrid - vec2(0.5, -0.5)) - 0.35) < 0.03) isGrille = true;
            
            if (isGrille) {
                col = grilleGreen;
                if (localGrid.x + localGrid.y > 0.0) col += vec3(0.1, 0.2, 0.1);
            }
        }
    }
}

void layer_RoofAndDragon(in vec2 p, in float iTime, inout vec3 col) {
    if (p.x > 0.8) {
        float roofCurve = p.x - 0.8 + p.y * 0.2; 
        
        if (p.y < -0.1 + roofCurve*2.0 && p.y > -0.5) {
            col = vec3(0.9);
            if (fract(p.x * 15.0) < 0.5) col = vec3(0.2, 0.5, 0.4); 
            
            if (p.y > -0.2 + roofCurve*2.0) {
                col = vec3(0.7, 0.3, 0.3); 
                float scallops = sin(p.x * 30.0) * sin(p.y * 20.0 + iTime*2.0); 
                col *= 0.8 + 0.2 * scallops;
            }
        }
        
        vec2 dragP = p - vec2(1.2, 0.2); 
        if (length(dragP) < 0.3) {
            float aD = atan(dragP.y, dragP.x);
            float dragShape = 0.15;
            
            dragShape += sin(aD * 8.0 + iTime*3.0) * 0.05;
            dragShape += cos(aD * 15.0 - iTime*5.0) * 0.03;
            dragShape += sin(dragP.x * 50.0) * 0.02; 
            
            if (length(dragP) < dragShape) {
                col = vec3(0.8, 0.7, 0.2); 
                float spec = pow(max(0.0, sin(dragP.x * 20.0 + dragP.y * 20.0 + iTime*4.0)), 4.0); 
                col += vec3(spec);
                if (dragP.y < 0.0) col *= 0.6;
            }
        }
    }
}

void main() {
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(0.0);
    
    layer_Wall(p, iTime, col);
    layer_Railing(p, iTime, col);
    layer_Window(p, iTime, col);
    layer_RoofAndDragon(p, iTime, col);

    gl_FragColor = vec4(col, 1.0);
}

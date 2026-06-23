/* @layer_metadata
{
  "title": "Shader: IMG_6786",
  "layers": [
    {
      "name": "Background",
      "keywords": ["background", "wood", "table", "grain", "animation"]
    },
    {
      "name": "Ticket",
      "keywords": ["ticket", "bend", "float", "grid", "numbers", "shading"]
    },
    {
      "name": "Hand",
      "keywords": ["hand", "fingers", "tapping", "animation", "skin"]
    }
  ]
}
*/
void layer_Background(in vec2 p, in float iTime, inout vec3 col) {
    vec3 woodDark = vec3(0.15, 0.1, 0.08);
    vec3 woodLight = vec3(0.25, 0.15, 0.12);
    
    float grainTime = iTime * 0.1;
    float grain = sin((p.x + grainTime) * 50.0 + iTime * 0.5) * cos((p.x + grainTime) * 20.0 + p.y * 5.0 - iTime * 0.2) + sin((p.x + grainTime) * 100.0) * 0.5;
    col = mix(woodDark, woodLight, grain * 0.5 + 0.5);
    col *= 0.8 + 0.2 * p.y; 
}

void layer_Ticket(in vec2 p, in float iTime, inout vec3 col) {
    float tW = 1.3;
    float tH = 0.45;
    
    float floatT = sin(iTime * 1.5) * 0.02;
    vec2 tp = p;
    tp.y += sin(tp.x * 3.0) * 0.02 - floatT; 
    tp.x += cos(iTime * 1.2) * 0.01;
    
    float dTicket = max(abs(tp.x) - tW, abs(tp.y) - tH);
    
    if (dTicket < 0.0) {
        vec3 tCol = vec3(0.9, 0.85, 0.65); 
        
        tCol *= 0.95 - 0.05 * cos(tp.x * 10.0 + iTime);
        
        if (tp.x > -1.0 && tp.x < 1.25 && tp.y > -0.4 && tp.y < 0.4) {
            vec2 gridP = tp - vec2(-1.0, 0.0);
            float gx = fract(gridP.x * 3.5); 
            float gy = fract(gridP.y * 3.5); 
            
            if (gx < 0.02 || gy < 0.03) {
                tCol = vec3(0.1); 
            } else {
                vec2 cellP = vec2(fract(gridP.x * 3.5), fract(gridP.y * 3.5));
                
                if (tp.x > -0.8) {
                    vec2 cellId = floor(vec2(gridP.x * 3.5, gridP.y * 3.5));
                    float rand = fract(sin(dot(cellId + floor(iTime*2.0), vec2(12.9898, 78.233))) * 43758.5453);
                    
                    if (rand > 0.4) {
                        if (abs(cellP.x - 0.5) < 0.25 && abs(cellP.y - 0.5) < 0.25) {
                            if (abs(abs(cellP.x - 0.5) - 0.15) > 0.05 && abs(abs(cellP.y - 0.5) - 0.15) > 0.05) {
                                tCol = vec3(0.1);
                            }
                            if (abs(cellP.y - 0.5) < 0.05 && abs(cellP.x - 0.5) < 0.15) tCol = vec3(0.1);
                        }
                    }
                }
            }
        }
        
        if (tp.x < -0.8) {
            if (abs(tp.x + 1.1) < 0.15 && tp.y > 0.0) {
                 if (fract(tp.y * 15.0 - iTime) > 0.3) tCol = vec3(0.1);
            }
            if (length(tp - vec2(-1.1, -0.2)) < 0.15) tCol = vec3(0.1);
        }
        
        col = tCol;
    }
    
    if (dTicket > 0.0 && dTicket < 0.05 && tp.y < 0.0) {
        col *= 0.5; 
    }
}

void layer_Hand(in vec2 p, in float iTime, inout vec3 col) {
    vec3 skin = vec3(0.85, 0.65, 0.55);
    
    float tap1 = abs(sin(iTime * 4.0)) * 0.05;
    float tap2 = abs(cos(iTime * 3.5)) * 0.04;
    float tap3 = abs(sin(iTime * 5.0 + 1.0)) * 0.03;
    
    vec2 f1P = p - vec2(-0.5, -0.8 + tap1);
    float dF1 = length(f1P - vec2(0.0, clamp(f1P.y, -1.0, 0.4))) - 0.1;
    vec2 f1Pr = vec2(f1P.x - f1P.y * 0.5, f1P.y);
    float dF1r = length(f1Pr - vec2(0.0, clamp(f1Pr.y, -1.0, 0.5))) - 0.1;
    
    vec2 f2P = p - vec2(-0.2, -0.9 + tap2);
    vec2 f2Pr = vec2(f2P.x - f2P.y * 0.8, f2P.y);
    float dF2r = length(f2Pr - vec2(0.0, clamp(f2Pr.y, -1.0, 0.6))) - 0.12;

    vec2 f3P = p - vec2(0.8, -0.8 + tap3);
    vec2 f3Pr = vec2(f3P.x + f3P.y * 0.5, f3P.y);
    float dF3r = length(f3Pr - vec2(0.0, clamp(f3Pr.y, -1.0, 0.4))) - 0.15;
    
    float dHand = min(min(dF1r, dF2r), dF3r);
    
    if (dHand < 0.0) {
        col = skin;
        col *= 0.8 + 0.2 * cos(dHand * 20.0);
        if (dF1r < 0.0 && f1Pr.y > 0.35) col = vec3(0.9, 0.75, 0.65);
        if (dF2r < 0.0 && f2Pr.y > 0.45) col = vec3(0.9, 0.75, 0.65);
        if (dF3r < 0.0 && f3Pr.y > 0.25) col = vec3(0.9, 0.75, 0.65);
        if (dHand > -0.02) col *= 0.8;
    }
}

void main() {
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(0.0);
    
    layer_Background(p, iTime, col);
    layer_Ticket(p, iTime, col);
    layer_Hand(p, iTime, col);

    gl_FragColor = vec4(col, 1.0);
}

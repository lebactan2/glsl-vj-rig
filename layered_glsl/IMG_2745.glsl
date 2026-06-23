/* @layer_metadata
{
  "title": "Shader: IMG_2745",
  "layers": [
    {
      "name": "Background",
      "keywords": ["ceiling", "wall", "tile", "red", "peeling", "paint", "mortar"]
    },
    {
      "name": "Lantern Wire",
      "keywords": ["wire", "lantern", "swing", "animation"]
    },
    {
      "name": "Lantern",
      "keywords": ["lantern", "light", "flicker", "ribs", "characters", "scrolling", "ring", "decorative"]
    },
    {
      "name": "Tassel",
      "keywords": ["tassel", "strands", "swaying", "fringe", "gold", "cap"]
    }
  ]
}
*/
void layer_Background(in vec2 p, inout vec3 col) {
    if (p.y > 0.6) {
        col = vec3(0.85, 0.85, 0.8); 
        float noise = fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
        col -= noise * 0.05;
        if (fract(sin(p.x * 10.0 + cos(p.y * 15.0)) * 20.0) < 0.05) col *= 0.8;
    }
    else {
        col = vec3(0.4, 0.1, 0.1); 
        vec2 tileP = vec2(p.x * 2.0, p.y * 3.0);
        if (fract(tileP.y) > 0.5) tileP.x += 0.5; 
        
        vec2 grid = fract(tileP);
        if (grid.x < 0.02 || grid.y < 0.02) col = vec3(0.6, 0.5, 0.5); 
        
        col *= 0.5 + 0.5 * smoothstep(1.5, 0.0, length(p));
        if (p.x > 0.8) col *= 0.6; 
    }
}

void layer_LanternWire(in vec2 p, in vec2 lanternCenter, inout vec3 col) {
    if (p.y > 0.55 && p.y < 0.65 && abs(p.x - lanternCenter.x * (0.65-p.y)*10.0) < 0.01) {
        col = vec3(0.1);
    }
}

void layer_Lantern(in vec2 p, in vec2 lanternCenter, in float iTime, inout vec3 col) {
    float lanternRadius = 0.55;
    vec2 lP = p - lanternCenter;
    lP.x /= 1.1; 
    
    float lDist = length(lP);
    
    if (lDist < lanternRadius) {
        col = vec3(0.9, 0.8, 0.6);
        
        float z = sqrt(lanternRadius*lanternRadius - lP.x*lP.x - lP.y*lP.y);
        
        float flicker = 0.9 + 0.1 * sin(iTime * 15.0) * cos(iTime * 7.0);
        float glow = (z / lanternRadius) * flicker;
        col *= 0.7 + 0.4 * glow;
        
        float ribAng = atan(lP.x, z);
        if (fract(ribAng * 8.0) < 0.05) col *= 0.85;
        
        float wrapX = atan(lP.x, z) * 2.0 + iTime*0.5; 
        
        if (lP.y > 0.15 && lP.y < 0.4) {
            if (sin(wrapX * 10.0) * cos(lP.y * 30.0) > 0.2) col = vec3(0.7, 0.2, 0.2);
            if (abs(fract(wrapX) - 0.5) < 0.2 && abs(lP.y - 0.25) < 0.05) col = vec3(0.7, 0.2, 0.2);
        }
        if (lP.y > -0.1 && lP.y < 0.15) {
            if (sin(wrapX * 8.0 + sin(lP.y * 20.0)) > 0.5) col = vec3(0.1); 
            if (abs(lP.y - 0.02) < 0.04 && fract(wrapX*2.0) < 0.5) col = vec3(0.1);
        }
        if (lP.y > -0.35 && lP.y < -0.1) {
            if (cos(wrapX * 12.0) * sin(lP.y * 25.0) > 0.2) col = vec3(0.7, 0.2, 0.2);
        }
        
        if (lP.y < -0.35) {
            col = vec3(0.8, 0.7, 0.2); 
            float scallop = sin(wrapX * 20.0);
            if (lP.y < -0.4 + scallop * 0.02) {
                col = vec3(0.9, 0.3, 0.2); 
                if (fract(wrapX * 8.0) < 0.2) col = vec3(0.3, 0.6, 0.3); 
            }
        }
    }
}

void layer_Tassel(in vec2 p, in vec2 lanternCenter, in float iTime, inout vec3 col) {
    vec2 tP = p - lanternCenter;
    if (tP.x > -0.1 && tP.x < 0.1 && tP.y < -0.55 && tP.y > -0.85) {
        col = vec3(0.6, 0.2, 0.15); 
        
        float strandSway = sin(iTime * 3.0 + tP.y * 10.0) * 0.02;
        if (fract((tP.x + strandSway) * 100.0) < 0.3) col *= 0.7; 
        
        if (tP.y > -0.6) {
            col = vec3(0.8, 0.7, 0.2);
            if (fract(tP.x * 20.0) < 0.2) col *= 0.8;
        }
    }
}

void main() {
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(0.0);
    
    layer_Background(p, col);
    
    float swing = sin(iTime * 2.0) * 0.1;
    vec2 lanternCenter = vec2(swing, 0.0);
    
    layer_LanternWire(p, lanternCenter, col);
    layer_Lantern(p, lanternCenter, iTime, col);
    layer_Tassel(p, lanternCenter, iTime, col);

    gl_FragColor = vec4(col, 1.0);
}

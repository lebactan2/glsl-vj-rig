/* @layer_metadata
{
  "title": "Shader: IMG_1847",
  "layers": [
    {
      "name": "Background",
      "keywords": ["wall", "grey", "stone", "concrete", "texture"]
    },
    {
      "name": "Carved Symbol",
      "keywords": ["carving", "symbol", "stone", "frame", "highlight", "shadow"]
    },
    {
      "name": "Top Louvers",
      "keywords": ["louvers", "vents", "top", "white", "black"]
    },
    {
      "name": "Bottom Surface",
      "keywords": ["surface", "shelf", "table", "bottom", "speckle", "granite"]
    }
  ]
}
*/
void layer_Background(in vec2 p, in float iTime, inout vec3 col, out float noise) {
    col = vec3(0.75, 0.73, 0.7);
    noise = fract(sin(dot(p + iTime*0.01, vec2(12.9898, 78.233))) * 43758.5453);
    col -= noise * 0.1;
}

void layer_CarvedSymbol(in vec2 p, in float iTime, in float noise, inout vec3 col) {
    if (abs(p.x) < 0.7 && p.y < 0.8 && p.y > -0.7) {
        if (abs(abs(p.x) - 0.65) < 0.05 || abs(p.y - 0.75) < 0.05 || abs(p.y + 0.65) < 0.05) {
            col = vec3(0.3, 0.3, 0.35); 
            col -= noise * 0.15;
            
            if (abs(p.x) - 0.65 < 0.0 && p.x > 0.0) col += 0.05;
            if (p.y - 0.75 < 0.0 && p.y > 0.0) col -= 0.05;
        } 
        else {
            col = vec3(0.8, 0.78, 0.75);
            col -= noise * 0.05;
            
            vec2 sP = p; 
            float sym = 0.0;
            
            if (abs(sP.x) < 0.04 && sP.y > -0.45 && sP.y < 0.4) sym = 1.0;
            
            if (abs(length(vec2(sP.x, sP.y - 0.55)) - 0.1) < 0.03) sym = 1.0;
            
            if (sP.y > 0.2 && sP.y < 0.45) {
                float bell = 0.4 - sP.y;
                if (abs(abs(sP.x) - bell) < 0.03 && sP.y > 0.25) sym = 1.0;
                if (abs(length(vec2(abs(sP.x) - 0.15, sP.y - 0.3)) - 0.05) < 0.02) sym = 1.0;
            }
            
            if (abs(sP.y - 0.1) < 0.03 && abs(sP.x) < 0.25) sym = 1.0;
            if (abs(abs(sP.x) - 0.15) < 0.02 && sP.y > 0.1 && sP.y < 0.2) sym = 1.0;
            
            if (abs(sP.y + 0.1) < 0.03 && abs(sP.x) < 0.35) sym = 1.0;
            if (abs(abs(sP.x) - 0.25) < 0.02 && abs(sP.y + 0.1) < 0.08) sym = 1.0;
            
            if (sP.y < -0.2 && sP.y > -0.6) {
                float swirlR = length(vec2(abs(sP.x) - 0.2, sP.y + 0.35));
                if (abs(swirlR - 0.15) < 0.03 && sP.y < -0.3) sym = 1.0;
                
                if (abs(length(vec2(sP.x, sP.y + 0.5)) - 0.1) < 0.03 && sP.y < -0.5) sym = 1.0;
                
                if (abs(abs(sP.x) - 0.1) < 0.02 && sP.y < -0.25 && sP.y > -0.35) sym = 1.0;
            }
            
            if (sym > 0.0) {
                col = vec3(0.3, 0.3, 0.35); 
                
                float highlight = sin(p.x * 5.0 + p.y * 5.0 + iTime * 2.0);
                if (highlight > 0.8) col += 0.2 * (highlight - 0.8) * 5.0;
                
                col -= noise * 0.2;
            } else {
                vec2 shadP = p + vec2(-0.01, 0.01);
                float shadow = 0.0;
                if (abs(shadP.x) < 0.04 && shadP.y > -0.45 && shadP.y < 0.4) shadow = 1.0;
                if (abs(length(vec2(shadP.x, shadP.y - 0.55)) - 0.1) < 0.03) shadow = 1.0;
                if (abs(shadP.y - 0.1) < 0.03 && abs(shadP.x) < 0.25) shadow = 1.0;
                if (abs(shadP.y + 0.1) < 0.03 && abs(shadP.x) < 0.35) shadow = 1.0;
                
                if (shadow > 0.0) col *= 0.8;
            }
        }
    }
}

void layer_TopLouvers(in vec2 p, inout vec3 col) {
    if (p.y > 0.85) {
        col = vec3(0.9, 0.9, 0.9); 
        if (fract(p.x * 5.0) < 0.8 && p.y > 0.9) col = vec3(0.1, 0.1, 0.15); 
    }
}

void layer_BottomSurface(in vec2 p, inout vec3 col) {
    if (p.y < -0.7) {
       if (p.y < -0.8) {
           col = vec3(0.3, 0.15, 0.1);
           float speckle = fract(sin(dot(p*200.0, vec2(12.9898, 78.233))) * 43758.5453);
           col += 0.1 * speckle;
       } else {
           col = vec3(0.4, 0.2, 0.15); 
       }
    }
}

void main() {
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(0.0);
    float noise = 0.0;
    
    layer_Background(p, iTime, col, noise);
    layer_CarvedSymbol(p, iTime, noise, col);
    layer_TopLouvers(p, col);
    layer_BottomSurface(p, col);

    gl_FragColor = vec4(col, 1.0);
}

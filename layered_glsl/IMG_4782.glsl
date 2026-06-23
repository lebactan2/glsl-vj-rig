/* @layer_metadata
{
  "title": "Shader: IMG_4782",
  "layers": [
    {
      "name": "Wall",
      "keywords": ["wall", "beige", "lighting", "animation"]
    },
    {
      "name": "Floor",
      "keywords": ["floor", "wooden", "lines"]
    },
    {
      "name": "Window",
      "keywords": ["window", "clouds", "animation"]
    },
    {
      "name": "Table",
      "keywords": ["table", "legs", "top", "tablecloth", "lace"]
    },
    {
      "name": "Chair",
      "keywords": ["chair"]
    },
    {
      "name": "Figure",
      "keywords": ["figure", "sparkles", "gold", "clothes"]
    },
    {
      "name": "Grid Borders",
      "keywords": ["grid", "borders"]
    }
  ]
}
*/
void layer_Wall(in vec2 cell, in float iTime, inout vec3 col) {
    col = vec3(0.9, 0.85, 0.7); 
    
    float wallLight = sin(iTime + cell.x + cell.y) * 0.05;
    col += wallLight;
}

void layer_Floor(in vec2 p, inout vec3 col) {
    if (p.y < -0.3) {
        col = vec3(0.6, 0.4, 0.2);
        if (fract(p.x * 5.0 + p.y * 2.0) < 0.05) col *= 0.8;
    }
}

void layer_Window(in vec2 p, in float iTime, inout vec3 col) {
    float win = max(abs(p.x) - 0.3, abs(p.y - 0.4) - 0.3);
    if (win < 0.0) {
        col = vec3(0.3, 0.4, 0.5); 
        col += sin(p.x*10.0 + iTime + p.y*5.0) * 0.05;
    }
}

void layer_Table(in vec2 p, inout vec3 col) {
    float tableLeg1 = max(abs(p.x - 0.4) - 0.05, abs(p.y + 0.2) - 0.2);
    float tableLeg2 = max(abs(p.x + 0.1) - 0.05, abs(p.y + 0.2) - 0.2);
    if (min(tableLeg1, tableLeg2) < 0.0) col = vec3(0.1); 
    
    float tableTop = max(abs(p.x - 0.15) - 0.4, abs(p.y - 0.0) - 0.05);
    if (tableTop < 0.0) col = vec3(0.1);
    
    float cloth = max(abs(p.x - 0.15) - 0.35, abs(p.y + 0.05) - 0.15);
    if (cloth < 0.0) {
        col = vec3(0.9);
        if (p.y < -0.05 && fract(p.x * 20.0) < 0.2) col = vec3(0.1); 
    }
}

void layer_Chair(in vec2 p, inout vec3 col) {
    float chair = max(abs(p.x + 0.4) - 0.15, abs(p.y + 0.1) - 0.3);
    if (chair < 0.0 && p.x < -0.3) col = vec3(0.15);
}

void layer_Figure(in vec2 p, in vec2 cell, in float iTime, inout vec3 col) {
    vec3 figCol = vec3(0.1); 
    float hash = fract(sin(dot(cell, vec2(12.9898, 78.233))) * 43758.5453);
    
    float sparkle = pow(abs(sin(p.x*30.0 + p.y*40.0 + iTime*3.0)), 10.0);
    vec3 gold = vec3(1.0, 0.8, 0.2) * sparkle;
    
    if (hash < 0.25) figCol = vec3(0.2, 0.3, 0.8); 
    else if (hash < 0.5) figCol = vec3(0.8, 0.2, 0.2); 
    else if (hash < 0.75) {
        figCol = vec3(0.1);
        if (fract(p.x*15.0)*fract(p.y*15.0) > 0.5) figCol = vec3(0.8, 0.6, 0.2);
    }
    
    figCol += gold;
    
    if (length(p - vec2(-0.4, 0.25)) < 0.1) col = figCol;
    float body = max(abs(p.x + 0.4) - 0.12, abs(p.y) - 0.2);
    if (body < 0.0) col = figCol;
}

void layer_GridBorders(in vec2 gridUV, inout vec3 col) {
    if (max(abs(fract(gridUV.x)-0.5), abs(fract(gridUV.y)-0.5)) > 0.49) col = vec3(1.0);
}

void main() {
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    
    vec2 gridUV = uv * vec2(3.0, 2.0);
    vec2 cell = floor(gridUV);
    vec2 p = fract(gridUV) * 2.0 - 1.0;
    p.x *= (iResolution.x/3.0) / (iResolution.y/2.0);
    
    vec3 col = vec3(0.0);
    
    layer_Wall(cell, iTime, col);
    layer_Floor(p, col);
    layer_Window(p, iTime, col);
    layer_Table(p, col);
    layer_Chair(p, col);
    layer_Figure(p, cell, iTime, col);
    layer_GridBorders(gridUV, col);

    gl_FragColor = vec4(col, 1.0);
}

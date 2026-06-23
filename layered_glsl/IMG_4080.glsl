/* @layer_metadata
{
  "title": "Shader: IMG_4080",
  "layers": [
    {
      "name": "Fabric",
      "keywords": ["fabric", "yellow-green", "wave", "wrinkles", "animation"]
    },
    {
      "name": "Red Symbols",
      "keywords": ["symbols", "red", "square", "star", "insect", "wings", "text"]
    },
    {
      "name": "Wood Slats",
      "keywords": ["wood", "slats", "top right"]
    },
    {
      "name": "Ground",
      "keywords": ["ground", "grey", "noise"]
    }
  ]
}
*/
void layer_Fabric(in vec2 p, in float iTime, inout vec3 col) {
    col = vec3(0.8, 0.9, 0.2);
    
    float wrinkle = sin(p.x * 5.0 + p.y * 2.0 + iTime) * sin(p.y * 3.0 - iTime*0.5);
    col += wrinkle * 0.1;
}

void layer_RedSymbols(in vec2 p, in float iTime, inout vec3 col) {
    vec3 red = vec3(0.85, 0.1, 0.15);
    
    vec2 sCenter = vec2(0.0, 0.6);
    vec2 p1 = p - sCenter;
    float dSq = max(abs(p1.x), abs(p1.y)) - 0.2;
    float dCirc = length(p1) - 0.18;
    float a = iTime * 0.5;
    mat2 rotStar = mat2(cos(a), -sin(a), sin(a), cos(a));
    vec2 p1Star = p1 * rotStar;
    float dStar = max(abs(p1Star.x) - 0.05, abs(p1Star.y) - 0.05);
    dStar = min(dStar, max(abs(p1Star.x + p1Star.y) - 0.05, abs(p1Star.x - p1Star.y) - 0.05));
    
    if (dSq < 0.0 && dCirc > 0.0) col = red;
    if (dStar < 0.0) col = red;
    
    vec2 iCenter = vec2(0.0, 0.1);
    vec2 p2 = p - iCenter;
    float body = length(p2 / vec2(0.05, 0.15)) - 1.0;
    float wingFlap = abs(sin(iTime * 15.0)) * 0.05;
    float wings = length(abs(p2) - vec2(0.1, 0.05 - wingFlap)) - 0.05;
    if (min(body, wings) < 0.0) col = red;
    
    vec2 tCenter = vec2(0.0, -0.4);
    vec2 p3 = p - tCenter;
    float d3 = max(abs(p3.x + 0.15) - 0.1, abs(p3.y) - 0.15);
    d3 = max(d3, -(max(abs(p3.x + 0.15) - 0.05, abs(p3.y) - 0.1)));
    d3 = max(d3, -max(abs(p3.x + 0.2), abs(p3.y) - 0.02));
    
    float d6 = max(abs(p3.x) - 0.1, abs(p3.y) - 0.15);
    d6 = max(d6, -(max(abs(p3.x) - 0.05, abs(p3.y) - 0.1)));
    
    float dx = max(abs(abs(p3.x - 0.2) - 0.05) - 0.02, abs(p3.y) - 0.1);
    
    float text = min(d3, min(d6, dx));
    if (text < 0.0) {
        col = vec3(1.0); 
        if (text < -0.02) col = red;
    }
}

void layer_WoodSlats(in vec2 p, inout vec3 col) {
    if (p.x > 0.4 && p.y > 0.5) {
        float slat = fract(p.x * 4.0 - p.y * 2.0);
        if (slat > 0.1) {
            col = vec3(0.8, 0.5, 0.3) * (0.8 + 0.2*sin(p.x*50.0)); 
        }
    }
}

void layer_Ground(in vec2 uv, in vec2 p, inout vec3 col) {
    if (p.x > 0.6) {
        vec2 gp = uv * 2.0 - 1.0; 
        gp.x *= iResolution.x / iResolution.y;
        float gNoise = fract(sin(dot(gp * 200.0, vec2(12.9898, 78.233))) * 43758.5453);
        col = vec3(0.2 + gNoise * 0.1);
    }
}

void main() {
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    
    float waveX = sin(uv.y * 10.0 + iTime * 2.0) * 0.02;
    float waveY = cos(uv.x * 5.0 + iTime * 1.5) * 0.02;
    vec2 wuv = uv + vec2(waveX, waveY);
    
    vec2 p = wuv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(0.0);
    
    layer_Fabric(p, iTime, col);
    layer_RedSymbols(p, iTime, col);
    layer_WoodSlats(p, col);
    layer_Ground(uv, p, col);

    gl_FragColor = vec4(col, 1.0);
}

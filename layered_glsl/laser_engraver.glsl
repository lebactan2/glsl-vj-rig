/* @layer_metadata
{
  "title": "Laser Engraver",
  "layers": [
    {
      "name": "Optical Breadboard",
      "keywords": ["optical", "breadboard", "aluminum", "brushed", "holes"]
    },
    {
      "name": "Laser Dot",
      "keywords": ["laser", "dot", "red", "glowing"]
    },
    {
      "name": "Vignette",
      "keywords": ["vignette", "background"]
    }
  ]
}
*/
void layer_OpticalBreadboard(in vec2 p, in vec2 uv, inout vec3 col) {
    vec2 st = vec2(p.x / (abs(p.y - 0.8) + 0.3), 1.0 / (abs(p.y - 0.8) + 0.3));
    st *= 4.0; 
    
    float ang = 0.15;
    st = mat2(cos(ang), -sin(ang), sin(ang), cos(ang)) * st;

    vec2 id = floor(st);
    vec2 f = fract(st);

    col = vec3(0.65, 0.68, 0.72); 
    
    float brush = fract(sin(dot(uv * vec2(0.5, 200.0), vec2(12.98, 78.23))) * 43758.5);
    col *= 0.9 + 0.1 * brush;

    float dHole = length(f - 0.5);
    
    if (dHole < 0.18) {
        if (dHole < 0.06) {
            col = vec3(0.1); 
        } else {
            float thread = sin(dHole * 150.0);
            col = vec3(0.5) * (0.8 + 0.2 * thread);
        }
        col *= 0.7 + 0.6 * smoothstep(-0.2, 0.2, (f.x - 0.5) + (f.y - 0.5));
    }
}

void layer_LaserDot(in vec2 p, in float iTime, inout vec3 col) {
    float t = iTime * 2.0;
    vec2 laserPos = vec2(sin(t)*0.4, -0.2 + cos(t*0.5)*0.3);
    float dLaser = length(p - laserPos);
    
    vec3 laserCol = vec3(1.0, 0.2, 0.1);
    float glow = exp(-dLaser * 15.0);
    float intense = exp(-dLaser * 80.0);
    
    col += laserCol * glow * 1.8;
    col += vec3(1.0) * intense * 2.5;
}

void layer_Vignette(in vec2 p, inout vec3 col) {
    col *= smoothstep(1.5, 0.2, length(vec2(p.x, p.y + 0.5)));
}

void main() {
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(0.0);

    layer_OpticalBreadboard(p, uv, col);
    layer_LaserDot(p, iTime, col);
    layer_Vignette(p, col);

    gl_FragColor = vec4(col, 1.0);
}

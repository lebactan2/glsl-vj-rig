/* @layer_metadata
{
  "title": "Shader: IMG_0415",
  "layers": [
    {
      "name": "Gravel Floor",
      "keywords": ["gravel", "floor", "texture", "noise"]
    },
    {
      "name": "Stones",
      "keywords": ["stones", "rocks", "shapes"]
    },
    {
      "name": "White Cubes",
      "keywords": ["cubes", "white", "plinths", "stripes"]
    },
    {
      "name": "Brick Wall",
      "keywords": ["brick", "wall", "background"]
    },
    {
      "name": "Dark Window",
      "keywords": ["dark", "window", "opening"]
    }
  ]
}
*/
void layer_GravelFloor(in vec2 st, in float iTime, inout vec3 col) {
    float gravel = fract(sin(dot(st * 15.0 + iTime*0.5, vec2(12.9, 78.2))) * 43758.0);
    col = vec3(0.25) * (0.7 + 0.5 * gravel);
}

void layer_Stones(in vec2 st, inout vec3 col) {
    float stoneId = floor(st.y * 2.0);
    float stoneShape = length(vec2(st.x - sin(stoneId)*0.4, fract(st.y * 2.0) - 0.5));
    
    if (stoneShape < 0.3) {
        col = vec3(0.5, 0.5, 0.52); 
        col *= 0.8 + 0.2 * fract(sin(dot(st, vec2(1.0, 2.0)))*430.0); 
    }
}

void layer_WhiteCubes(in vec2 st, inout vec3 col) {
    if (st.x > 0.4 && st.y > 0.5 && st.y < 2.5) {
        float cubeShape = max(abs(fract(st.y) - 0.5), abs(st.x - 0.8));
        if (cubeShape < 0.25) {
            col = vec3(0.9); 
            if (mod(st.y*25.0, 1.0) < 0.3 && abs(st.x - 0.8) < 0.15) col = vec3(0.1);
        }
    }
}

void layer_BrickWall(in vec2 p, inout vec3 col) {
    col = vec3(0.8, 0.75, 0.7); 
    float by = fract(p.y * 15.0);
    float bx = fract(p.x * 8.0 + floor(p.y*15.0)*0.5);
    if (by < 0.1 || bx < 0.05) col *= 0.7;
}

void layer_DarkWindow(in vec2 p, inout vec3 col) {
    if (p.x > 0.1 && p.y > 0.2 && p.y < 0.8) {
        col = vec3(0.1, 0.15, 0.15); 
        col += vec3(0.1) * smoothstep(0.0, 0.1, p.x + p.y - 1.0); 
    }
}

void main() {
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(0.0);

    if (p.y < 0.1) {
        vec2 st = vec2(p.x / (p.y - 0.2), 1.0 / (p.y - 0.2)) * 3.0;
        
        layer_GravelFloor(st, iTime, col);
        layer_Stones(st, col);
        layer_WhiteCubes(st, col);
        
        col *= smoothstep(-1.0, 0.1, p.y); 
    } else {
        layer_BrickWall(p, col);
        layer_DarkWindow(p, col);
    }

    gl_FragColor = vec4(col, 1.0);
}

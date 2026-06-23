/* @layer_metadata
{
  "title": "Shader: IMG_0398",
  "layers": [
    {
      "name": "Floor",
      "keywords": ["floor", "wood", "plank", "noise", "projection"]
    },
    {
      "name": "Ceiling Grid",
      "keywords": ["ceiling", "grid", "roof"]
    },
    {
      "name": "Background Forest",
      "keywords": ["forest", "trees", "projection", "background", "animate"]
    },
    {
      "name": "Glowing Screens",
      "keywords": ["screens", "glow", "wave", "animation", "middle"]
    },
    {
      "name": "Wooden Sculpture",
      "keywords": ["wooden", "sculpture", "grain", "right"]
    }
  ]
}
*/
void layer_Floor(in vec2 p, inout vec3 col) {
    if (p.y < -0.1) {
        vec2 floorUV = vec2(p.x / (p.y + 0.1), 1.0 / (p.y + 0.1));
        float noise = fract(sin(dot(floorUV, vec2(12.9, 78.2))) * 43758.0);
        float plank = smoothstep(0.4, 0.5, abs(fract(floorUV.x * 2.0) - 0.5));
        
        col = mix(vec3(0.3, 0.15, 0.05), vec3(0.4, 0.2, 0.1), noise*0.5 + plank*0.5);
        col *= smoothstep(-0.1, -0.8, p.y);
    }
}

void layer_CeilingGrid(in vec2 p, inout vec3 col) {
    if (p.y > 0.4) {
        col = vec3(0.15);
        vec2 ceilUV = vec2(p.x / (1.5 - p.y), 1.0 / (1.5 - p.y));
        if (fract(ceilUV.x * 5.0) < 0.05 || fract(ceilUV.y * 3.0) < 0.05) col = vec3(0.05);
    }
}

void layer_BackgroundForest(in vec2 p, in float iTime, inout vec3 col) {
    if (p.x < -0.1 && p.y > 0.1 && p.y < 0.4) {
        float forestNoise = fract(sin(p.x * 50.0 + iTime*0.05) * 43758.0);
        if (forestNoise < 0.3) col = vec3(0.2, 0.4, 0.2) * (0.5 + forestNoise);
        else col = vec3(0.15, 0.2, 0.15);
    }
}

void layer_GlowingScreens(in vec2 p, in float iTime, inout vec3 col) {
    if (p.y > -0.1 && p.y < 0.2 && p.x > -0.7 && p.x < 0.5) {
        float screenId = floor((p.x + 0.7) * 8.0);
        float screenLocalX = fract((p.x + 0.7) * 8.0);
        
        if (screenLocalX > 0.1 && screenLocalX < 0.9) {
            float wave = sin(screenLocalX * 10.0 + iTime * 2.0 + screenId) * 0.05;
            if (p.y < 0.05 + wave) {
                col = mix(vec3(0.2, 0.5, 0.8), vec3(0.6, 0.8, 0.9), p.y*10.0);
            } else {
                col = vec3(0.1, 0.2, 0.4);
            }
            col += vec3(0.2);
        }
    }
}

void layer_WoodenSculpture(in vec2 p, inout vec3 col) {
    if (p.x > 0.5 && p.y > -0.2 && p.y < 0.3) {
        col = vec3(0.3, 0.15, 0.05);
        float grain = fract(sin(p.x * 50.0 + p.y * 10.0) * 43758.0);
        col *= 0.8 + 0.2 * grain;
    }
}

void main() {
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(0.0);
    
    if (p.y < -0.1) {
        layer_Floor(p, col);
    } else if (p.y > 0.4) {
        layer_CeilingGrid(p, col);
    } else {
        col = vec3(0.1); 
        layer_BackgroundForest(p, iTime, col);
        layer_GlowingScreens(p, iTime, col);
        layer_WoodenSculpture(p, col);
    }
    
    gl_FragColor = vec4(col, 1.0);
}

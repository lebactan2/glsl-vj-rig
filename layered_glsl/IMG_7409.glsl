/* @layer_metadata
{
  "title": "Shader: IMG_7409",
  "layers": [
    {
      "name": "Background",
      "keywords": ["background", "concrete", "grey", "floor", "noise"]
    },
    {
      "name": "Background Garments",
      "keywords": ["garments", "green", "tarp", "red", "shirt"]
    },
    {
      "name": "White Shirt",
      "keywords": ["white", "shirt", "tie", "epaulettes", "collar"]
    },
    {
      "name": "Blue Shirt",
      "keywords": ["blue", "shirt", "wrinkles", "epaulettes", "buttons"]
    }
  ]
}
*/
#define segment(p, a, b) length(p - a - (b - a) * clamp(dot(p - a, b - a) / dot(b - a, b - a), 0.0, 1.0))

void layer_Background(in vec2 p, inout vec3 col) {
    col = vec3(0.45, 0.45, 0.47);
    float floorNoise = fract(sin(dot(floor(p * 80.0), vec2(127.1, 311.7))) * 43758.5453);
    col += floorNoise * 0.05;
}

void layer_BackgroundGarments(in vec2 p, in float s1Body, in float s2Body, inout vec3 col) {
    float greenArea = max(p.x - 0.5, p.y - 0.4);
    if (greenArea < 0.0 && s1Body > 0.0 && s2Body > 0.0) {
        if (p.x > 0.0 && p.y > 0.0) col = vec3(0.2, 0.45, 0.2); 
        if (p.y > 0.6) col = vec3(0.8, 0.15, 0.15); 
    }
}

void layer_WhiteShirt(in vec2 p, in float s1Body, out float s2Body, inout vec3 col) {
    vec2 s2 = p - vec2(0.2, 0.0);
    s2Body = length(max(abs(s2) - vec2(0.3, 0.4), 0.0)) - 0.1;
    if (s2Body < 0.0 && s1Body > 0.0) {
        vec3 s2Col = vec3(0.9, 0.92, 0.95);
        s2Col += sin(s2.x * 15.0 + s2.y * 12.0) * 0.03;
        
        float tie = segment(s2, vec2(0.0, 0.4), vec2(0.0, -0.2));
        if (tie < 0.03 + (0.3 - s2.y)*0.02) {
            s2Col = vec3(0.1, 0.1, 0.15); 
        }
        
        for (float i = 0.0; i < 2.0; i++) {
            vec2 epPos = vec2(-0.2 + i * 0.4, 0.25);
            vec2 epL = s2 - epPos;
            if (abs(epL.x) < 0.06 && abs(epL.y) < 0.025) {
                s2Col = vec3(0.1);
                if (fract(epL.x * 25.0) < 0.4) s2Col = vec3(0.8, 0.7, 0.2);
            }
        }
        
        float collarL = segment(s2, vec2(0.0, 0.35), vec2(-0.15, 0.25));
        float collarR = segment(s2, vec2(0.0, 0.35), vec2(0.15, 0.25));
        if (min(collarL, collarR) < 0.04) {
            s2Col = vec3(0.8, 0.15, 0.15);
        }
        col = s2Col;
    } else if (s2Body < 0.02 && s1Body > 0.0) {
        col *= 0.6;
    }
}

void layer_BlueShirt(in vec2 p, out float s1Body, inout vec3 col) {
    vec2 s1 = p - vec2(-0.3, -0.2);
    s1Body = length(max(abs(s1) - vec2(0.35, 0.35), 0.0)) - 0.1;
    if (s1Body < 0.0) {
        vec3 s1Col = vec3(0.55, 0.7, 0.85);
        s1Col += sin(s1.x * 20.0 + s1.y * 10.0) * 0.04; 
        
        for (float i = 0.0; i < 3.0; i++) {
            vec2 epPos = vec2(-0.55 + i * 0.5, 0.05);
            vec2 epL = s1 - epPos;
            if (abs(epL.x) < 0.07 && abs(epL.y) < 0.03) {
                s1Col = vec3(0.1, 0.1, 0.15);
                if (fract(epL.x * 25.0) < 0.4) s1Col = vec3(0.8, 0.7, 0.2); 
            }
        }
        for (float i = 0.0; i < 4.0; i++) {
            if (length(s1 - vec2(0.0, -0.3 + i * 0.15)) < 0.015) s1Col = vec3(0.8);
        }
        col = s1Col;
    } else if (s1Body < 0.02) {
        col *= 0.6; 
    }
}

void main() {
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(0.0);
    
    layer_Background(p, col);
    
    float s1Body, s2Body;
    
    // We need s1Body to process WhiteShirt and BackgroundGarments
    vec2 s1 = p - vec2(-0.3, -0.2);
    s1Body = length(max(abs(s1) - vec2(0.35, 0.35), 0.0)) - 0.1;
    
    // WhiteShirt needs s1Body and computes s2Body
    layer_WhiteShirt(p, s1Body, s2Body, col);
    layer_BackgroundGarments(p, s1Body, s2Body, col);
    
    // BlueShirt is drawn on top
    layer_BlueShirt(p, s1Body, col);

    gl_FragColor = vec4(col, 1.0);
}

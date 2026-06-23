/* @layer_metadata
{
  "title": "Shader: IMG_0824",
  "layers": [
    {
      "name": "Sky",
      "keywords": ["sky", "blue", "background"]
    },
    {
      "name": "Left Building",
      "keywords": ["building", "left", "grey", "shutter", "door"]
    },
    {
      "name": "Right Building",
      "keywords": ["building", "right", "blue", "perspective"]
    },
    {
      "name": "Street",
      "keywords": ["street", "pavement", "asphalt", "wet", "reflection", "rain"]
    },
    {
      "name": "Leaves",
      "keywords": ["leaves", "tree", "green", "sway", "animation"]
    },
    {
      "name": "Motorcycle",
      "keywords": ["motorcycle", "silhouette", "black"]
    }
  ]
}
*/
void layer_Sky(inout vec3 col) {
    col = vec3(0.8, 0.85, 0.9);
}

void layer_LeftBuilding(in vec2 p, inout vec3 col) {
    if (p.x < -0.1 && p.y > -0.5) {
        col = vec3(0.85, 0.85, 0.8);
        if (fract(p.y * 20.0) < 0.1) col *= 0.8;
        
        if (p.x > -0.6 && p.y < 0.0) {
             col = vec3(0.2, 0.25, 0.2);
        }
    }
}

void layer_RightBuilding(in vec2 p, inout vec3 col) {
    if (p.x > -0.1 && p.y > -0.2) {
        col = vec3(0.3, 0.5, 0.8);
        if (fract(p.y * 10.0 - p.x * 2.0) < 0.05) col *= 0.9;
    }
}

void layer_Street(in vec2 p, in float iTime, inout vec3 col) {
    if (p.y < -0.5) {
        col = vec3(0.4, 0.4, 0.45);
        float noise = fract(sin(dot(p*50.0, vec2(12.9, 78.2)))*43758.0);
        col += (noise - 0.5) * 0.1;
        
        float wet = smoothstep(0.4, 0.6, sin(p.x * 10.0 + iTime) * cos(p.y * 15.0));
        col = mix(col, vec3(0.5, 0.55, 0.6), wet * 0.3);
    }
}

void layer_Leaves(in vec2 p, in float iTime, inout vec3 col) {
    float leafSway = sin(iTime * 1.5 + p.y * 10.0) * 0.05;
    vec2 leafP = p - vec2(leafSway, 0.0);
    if (leafP.x > 0.0 && leafP.y > 0.2) {
        float leafNoise = fract(sin(dot(leafP*10.0, vec2(12.9, 78.2)))*43758.0);
        if (leafNoise > 0.4 && distance(leafP, vec2(0.5, 0.8)) < 0.7) {
            col = mix(vec3(0.2, 0.4, 0.1), vec3(0.3, 0.6, 0.2), leafNoise);
        }
    }
}

void layer_Motorcycle(in vec2 p, inout vec3 col) {
    if (length(p - vec2(-0.5, -0.6)) < 0.2 || length(p - vec2(-0.8, -0.5)) < 0.15) {
        col = vec3(0.1, 0.1, 0.15);
    }
}

void main() {
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;
    
    vec3 col = vec3(0.0);
    
    layer_Sky(col);
    layer_LeftBuilding(p, col);
    layer_RightBuilding(p, col);
    layer_Street(p, iTime, col);
    layer_Leaves(p, iTime, col);
    layer_Motorcycle(p, col);
    
    gl_FragColor = vec4(col, 1.0);
}

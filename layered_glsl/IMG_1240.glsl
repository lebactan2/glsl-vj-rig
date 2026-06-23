/* @layer_metadata
{
  "title": "Shader: IMG_1240",
  "layers": [
    {
      "name": "Signboard",
      "keywords": ["signboard", "dark", "frame"]
    },
    {
      "name": "Text GIAI",
      "keywords": ["text", "green", "giai"]
    },
    {
      "name": "Text NUOC MIA",
      "keywords": ["text", "red", "nuoc mia", "outline"]
    },
    {
      "name": "Sugarcane Stalks",
      "keywords": ["sugarcane", "stalks", "bamboo", "segments", "green"]
    },
    {
      "name": "Sugarcane Leaves",
      "keywords": ["sugarcane", "leaves", "green", "vein"]
    }
  ]
}
*/
#define segment(p, a, b) length(p - a - (b - a) * clamp(dot(p - a, b - a) / dot(b - a, b - a), 0.0, 1.0))

void layer_Signboard(in vec2 p, inout vec3 col, out bool insideSign) {
    float signW = 1.1, signH = 0.85;
    insideSign = false;
    if (abs(p.x) < signW && abs(p.y) < signH) {
        col = vec3(0.05); 
        insideSign = true;
    } else {
        col = vec3(0.2); 
    }
}

void layer_TextGiai(in vec2 p, inout vec3 col) {
    vec2 t1 = p - vec2(-0.6, 0.5);
    float d1 = 1.0;
    
    d1 = min(d1, segment(t1, vec2(0.0, 0.08), vec2(-0.05, 0.08)));
    d1 = min(d1, segment(t1, vec2(-0.05, 0.08), vec2(-0.05, -0.08)));
    d1 = min(d1, segment(t1, vec2(-0.05, -0.08), vec2(0.0, -0.08)));
    d1 = min(d1, segment(t1, vec2(0.0, -0.08), vec2(0.0, 0.0)));
    d1 = min(d1, segment(t1, vec2(0.0, 0.0), vec2(-0.02, 0.0)));
    
    d1 = min(d1, segment(t1, vec2(0.08, 0.08), vec2(0.08, -0.08)));
    
    d1 = min(d1, segment(t1, vec2(0.16, -0.08), vec2(0.2, 0.08)));
    d1 = min(d1, segment(t1, vec2(0.2, 0.08), vec2(0.24, -0.08)));
    d1 = min(d1, segment(t1, vec2(0.18, 0.0), vec2(0.22, 0.0)));
    if (d1 < 0.015) col = vec3(0.15, 0.8, 0.2);
}

void layer_TextNuocMia(in vec2 p, inout vec3 col) {
    vec2 t2 = p - vec2(-0.3, 0.1);
    float d2 = 1.0;
    
    d2 = min(d2, segment(t2, vec2(-0.2, -0.15), vec2(-0.2, 0.15)));
    d2 = min(d2, segment(t2, vec2(-0.2, 0.15), vec2(-0.05, -0.15)));
    d2 = min(d2, segment(t2, vec2(-0.05, -0.15), vec2(-0.05, 0.15)));
    
    d2 = min(d2, segment(t2, vec2(0.15, -0.15), vec2(0.15, 0.15)));
    d2 = min(d2, segment(t2, vec2(0.15, 0.15), vec2(0.25, 0.0)));
    d2 = min(d2, segment(t2, vec2(0.25, 0.0), vec2(0.35, 0.15)));
    d2 = min(d2, segment(t2, vec2(0.35, 0.15), vec2(0.35, -0.15)));
    
    d2 = min(d2, segment(t2, vec2(0.45, 0.15), vec2(0.45, -0.15)));
    
    d2 = min(d2, segment(t2, vec2(0.55, -0.15), vec2(0.65, 0.15)));
    d2 = min(d2, segment(t2, vec2(0.65, 0.15), vec2(0.75, -0.15)));
    if (d2 < 0.02) {
        col = vec3(0.9, 0.1, 0.15); 
        if (d2 > 0.01) col = vec3(1.0, 0.8, 0.8); 
    }
}

void layer_SugarcaneStalks(in vec2 p, inout vec3 col) {
    for (float i = 0.0; i < 4.0; i++) {
        float cx = 0.6 + i * 0.1;
        float sway = sin(p.y * 2.0 + i) * 0.05;
        float stalk = abs(p.x - cx - sway);
        
        if (stalk < 0.025) {
            vec3 stalkCol = mix(vec3(0.5, 0.7, 0.2), vec3(0.7, 0.8, 0.3), stalk * 40.0);
            float seg = fract(p.y * 6.0 + i * 0.4);
            if (seg > 0.9) stalkCol = vec3(0.3, 0.4, 0.1); 
            
            col = stalkCol;
        }
    }
}

void layer_SugarcaneLeaves(in vec2 p, inout vec3 col) {
    vec2 lp = p - vec2(-0.8, -0.6);
    float leaf = max(lp.y - lp.x * lp.x * 2.0, -lp.y - 0.05 + lp.x * lp.x * 1.5);
    if (leaf < 0.0 && lp.x > 0.0 && lp.x < 1.0) {
        col = vec3(0.2, 0.8, 0.2); 
        if (abs(lp.y - lp.x * lp.x * 1.7) < 0.005) col = vec3(0.1, 0.5, 0.1);
    }
}

void main() {
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;
    
    vec3 col = vec3(0.0);
    bool insideSign;
    
    layer_Signboard(p, col, insideSign);
    
    if (insideSign) {
        layer_TextGiai(p, col);
        layer_TextNuocMia(p, col);
        layer_SugarcaneStalks(p, col);
        layer_SugarcaneLeaves(p, col);
    }
    
    gl_FragColor = vec4(col, 1.0);
}

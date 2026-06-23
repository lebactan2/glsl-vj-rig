/* @layer_metadata
{
  "title": "Shader: IMG_5538",
  "layers": [
    {
      "name": "Background",
      "keywords": ["background", "noise"]
    },
    {
      "name": "Motorcycle Wheel",
      "keywords": ["wheel", "tire", "spokes", "animation", "rotating"]
    },
    {
      "name": "Red Panel",
      "keywords": ["panel", "red", "highlights", "decal", "key"]
    },
    {
      "name": "Seat",
      "keywords": ["seat", "black", "text"]
    },
    {
      "name": "Grab Rail",
      "keywords": ["grab", "rail", "black", "tube"]
    }
  ]
}
*/
void layer_Background(in vec2 p, in float iTime, inout vec3 col, out float noise) {
    col = vec3(0.2); 
    noise = fract(sin(dot(p + iTime*0.05, vec2(12.9898, 78.233))) * 43758.5453);
    col *= 0.8 + 0.2 * noise;
}

void layer_MotorcycleWheel(in vec2 p, in float iTime, inout vec3 col) {
    vec2 wheelCenter = vec2(1.5, -0.3);
    float wheelR = length(p - wheelCenter);
    
    if (wheelR < 1.3) {
        col = vec3(0.15);
        
        if (wheelR > 1.0) {
            float angle = atan(p.y - wheelCenter.y, p.x - wheelCenter.x) + iTime * 2.0; 
            if (fract(angle * 20.0 + wheelR * 5.0) < 0.2) {
                col *= 0.5;
            }
            if (abs(wheelR - 1.05) < 0.02) col = vec3(0.5); 
        } else {
            col = vec3(0.3); 
            
            float angle = atan(p.y - wheelCenter.y, p.x - wheelCenter.x) + iTime * 2.0; 
            float spokes1 = abs(sin(angle * 18.0));
            float spokes2 = abs(cos((angle + 0.1) * 18.0));
            
            if (spokes1 < 0.02 || spokes2 < 0.02) {
                col = vec3(0.8, 0.85, 0.9);
                col *= 0.8 + 0.2 * sin(wheelR * 50.0);
            }
            
            if (wheelR < 0.4) {
                col = vec3(0.6); 
                if (fract(wheelR * 10.0) < 0.1) col *= 0.7; 
                if (max(abs(p.x - wheelCenter.x), abs(p.y - wheelCenter.y)) < 0.1) col = vec3(0.8);
            }
        }
    }
}

void layer_RedPanel(in vec2 p, in float iTime, inout vec3 col) {
    float curve1 = p.y - sin(p.x * 1.5 + 1.0) * 0.4;
    float curve2 = p.y - (-p.x * 0.8 + 0.2); 
    
    bool inRedPanel = p.x > -0.8 && p.x < 1.0 && p.y > -0.8 && curve1 > -0.8 && curve1 < 0.8;
    if (p.x + p.y*0.5 > 0.8) inRedPanel = false;
    
    if (inRedPanel) {
        col = vec3(0.85, 0.1, 0.15); 
        
        col *= 0.8 + 0.3 * smoothstep(0.0, 0.5, curve1); 
        col *= 0.9 + 0.2 * cos((p.x - 0.2) * 5.0); 
        
        float specMove = sin(iTime) * 0.2;
        float hl1 = abs(p.y - sin(p.x * 1.5 + 0.8) * 0.4 - 0.4 - specMove);
        if (hl1 < 0.05 && p.x < 0.2) {
            col += vec3(0.8) * smoothstep(0.05, 0.0, hl1); 
        }
        float hl2 = abs(p.x + p.y*0.2 + 0.2 + specMove*0.5);
        if (hl2 < 0.1 && p.y > 0.2 && p.x < 0.0) {
            col += vec3(0.5) * smoothstep(0.1, 0.0, hl2); 
        }
        
        float decalPath = p.y - sin(p.x * 1.2 + 0.5) * 0.5 + 0.4;
        if (abs(decalPath) < 0.08 && p.x > 0.0 && p.x < 0.8) {
            col = vec3(0.4, 0.1, 0.5);
            float letters = fract(p.x * 10.0 - p.y*5.0); 
            if (letters < 0.6 && abs(decalPath) < 0.05) {
                col = vec3(0.9, 0.8, 0.2); 
            }
        }
        
        vec2 kp = p - vec2(0.2, -0.4);
        float dKey = length(kp);
        if (dKey < 0.08) {
            col = vec3(0.8, 0.2, 0.2); 
            if (dKey < 0.06) {
                col = vec3(0.6); 
                if (dKey < 0.04) col = vec3(0.7); 
                if (abs(kp.x) < 0.01 && abs(kp.y) < 0.03) col = vec3(0.1);
            }
        }
        
        if (p.x < -0.4 && p.y > 0.4) {
            if (abs(p.x - -0.6) < 0.15 && abs(p.y - 0.7) < 0.15) {
                col = vec3(0.95);
                if (abs(p.x + p.y - 0.1) < 0.02) col = vec3(0.85, 0.1, 0.15); 
                if (abs(p.x - p.y + 1.3) < 0.02) col = vec3(0.85, 0.1, 0.15);
            }
        }
    }
}

void layer_Seat(in vec2 p, in float noise, inout vec3 col) {
    float seatEdge = p.y - sin(p.x * 2.0) * 0.2 + 0.2;
    if (p.x < 0.0 && seatEdge < 0.0 && p.x + p.y < -0.2) {
        col = vec3(0.15, 0.16, 0.17); 
        
        col *= 0.95 + 0.05 * noise;
        col *= 0.8 + 0.3 * smoothstep(0.0, -0.5, seatEdge);
        
        if (p.y > -0.6 && p.y < -0.4 && p.x < -0.3) {
            float letters = fract(p.x * 8.0);
            if (letters < 0.7 && fract(p.x*20.0 + p.y*15.0) > 0.3) {
                col = vec3(0.9); 
                if (noise > 0.7) col *= 0.8;
            }
        }
    }
}

void layer_GrabRail(in vec2 p, in float noise, inout vec3 col) {
    vec2 rp = p;
    rp.y -= sin(rp.x * 1.5) * 0.4 - 0.1;
    
    float railDist = abs(rp.y + rp.x*0.5); 
    if (railDist < 0.06 && p.x > -1.0 && p.x < 0.5 && p.y < 0.6) {
        col = vec3(0.1); 
        float tubeShade = smoothstep(0.06, 0.0, railDist);
        col *= 0.5 + 0.5 * tubeShade;
        
        if (abs(railDist - 0.04) < 0.005 && rp.y+rp.x*0.5 > 0.0) {
            col += vec3(0.3); 
        }
        
        if (noise > 0.95) {
            col = mix(col, vec3(0.4, 0.25, 0.15), 0.8); 
        }
    }
}

void main() {
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(0.0);
    float noise;
    
    layer_Background(p, iTime, col, noise);
    layer_MotorcycleWheel(p, iTime, col);
    layer_RedPanel(p, iTime, col);
    layer_Seat(p, noise, col);
    layer_GrabRail(p, noise, col);

    gl_FragColor = vec4(col, 1.0);
}

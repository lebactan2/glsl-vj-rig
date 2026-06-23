/* @layer_metadata
{
  "title": "Shader: IMG_1426",
  "layers": [
    {
      "name": "Sky",
      "keywords": ["sky", "blue", "painted"]
    },
    {
      "name": "Clouds",
      "keywords": ["clouds", "painted", "drifting", "texture"]
    },
    {
      "name": "Birds",
      "keywords": ["birds", "flock", "painted", "animation"]
    },
    {
      "name": "Rocks",
      "keywords": ["rocks", "peaks", "texture", "crevice", "crack", "roots", "bonsai"]
    },
    {
      "name": "Plants",
      "keywords": ["plants", "ferns", "leaves", "animation", "rustle"]
    },
    {
      "name": "Vignette",
      "keywords": ["vignette"]
    }
  ]
}
*/
float hash(vec2 p, float iTime) { return fract(sin(dot(p + iTime*0.05, vec2(12.9898, 78.233))) * 43758.5453); }
float noise(vec2 p, float iTime) {
    vec2 i = floor(p), f = fract(p);
    vec2 u = f*f*(3.0-2.0*f);
    return mix(mix(hash(i + vec2(0.0,0.0), iTime), hash(i + vec2(1.0,0.0), iTime), u.x),
               mix(hash(i + vec2(0.0,1.0), iTime), hash(i + vec2(1.0,1.0), iTime), u.x), u.y);
}

void layer_Sky(in vec2 uv, inout vec3 col) {
    col = mix(vec3(0.3, 0.6, 0.85), vec3(0.2, 0.5, 0.8), uv.y);
}

void layer_Clouds(in vec2 p, in float iTime, inout vec3 col) {
    float cloudNoise1 = noise(p * vec2(2.0, 15.0), iTime);
    float cloudNoise2 = noise(p * vec2(4.0, 20.0) + vec2(10.0, 0.0), iTime);
    
    float drift = iTime * 0.05;
    
    float cloudShape = smoothstep(0.4, 0.6, cloudNoise1 * sin(p.y * 20.0 + drift * 10.0));
    cloudShape += smoothstep(0.5, 0.7, cloudNoise2 * cos(p.y * 30.0 - drift * 5.0)) * 0.5;
    
    if (p.y > 0.0) {
        col = mix(col, vec3(0.95, 0.95, 0.98), cloudShape * 0.8);
        col *= 1.0 - 0.05 * noise(p * vec2(50.0, 200.0), iTime);
    }
}

void layer_Birds(in vec2 p, in float iTime, inout vec3 col) {
    vec2 bp = p - vec2(0.5, 0.6); 
    float a = -0.5; 
    bp = vec2(bp.x * cos(a) - bp.y * sin(a), bp.x * sin(a) + bp.y * cos(a));
    
    vec2 birdGrid = fract(bp * vec2(6.0, 6.0)) - 0.5;
    vec2 birdID = floor(bp * vec2(6.0, 6.0));
    
    float vMask = abs(birdID.y) - birdID.x * 0.5;
    
    if (abs(vMask) < 1.0 && birdID.x > -2.0 && birdID.x < 4.0) {
        float flap = sin(iTime * 10.0 + birdID.x * 2.0 + birdID.y * 3.0);
        
        float wingY = birdGrid.y + abs(birdGrid.x) * (0.5 + flap * 0.2);
        float bird = length(max(abs(vec2(birdGrid.x, wingY)) - vec2(0.06, 0.01), 0.0));
        
        bird = min(bird, length(birdGrid - vec2(0.0, 0.02)) - 0.02);
        
        if (bird < 0.01) {
            col = vec3(0.1); 
            if (noise(p * 200.0, iTime) > 0.6) col = mix(col, vec3(0.3, 0.6, 0.85), 0.5);
        }
    }
}

void layer_Rocks(in vec2 p, out float rockHeight, in float iTime, inout vec3 col) {
    rockHeight = -0.5;
    rockHeight += 0.9 * exp(-15.0 * pow(p.x + 0.9, 2.0)); 
    rockHeight += 1.3 * exp(-20.0 * pow(p.x + 0.4, 2.0));       
    rockHeight += 0.8 * exp(-12.0 * pow(p.x - 0.1, 2.0)); 
    rockHeight += 0.5 * exp(-15.0 * pow(p.x - 0.6, 2.0));
    
    rockHeight += 0.15 * sin(p.x * 20.0) + 0.1 * cos(p.x * 45.0);
    rockHeight += 0.1 * noise(p * 15.0, iTime);
    
    if (p.y < rockHeight) {
        col = vec3(0.7, 0.7, 0.75);
        
        float rTex1 = noise(p * vec2(10.0, 5.0), iTime);
        float rTex2 = noise(p * vec2(30.0, 10.0), iTime);
        
        col = mix(col, vec3(0.85, 0.85, 0.9), rTex1); 
        col = mix(col, vec3(0.4, 0.4, 0.4), rTex2 * 0.5); 
        
        float crevice = abs(sin(p.x * 30.0 + noise(p*10.0, iTime)*8.0));
        if (crevice < 0.15) {
            col *= 0.4 + crevice * 3.0; 
        }
        
        float crack = abs(cos(p.y * 25.0 + noise(p*5.0, iTime)*5.0));
        if (crack < 0.05) col *= 0.6;
        
        float ao = smoothstep(0.0, 0.5, rockHeight - p.y);
        col *= 1.0 - 0.3 * ao;
        
        if (p.y < -0.7 + noise(p*5.0, iTime)*0.2) {
            col = mix(col, vec3(0.3, 0.2, 0.1), 0.6);
            
            float roots = abs(sin(p.x * 50.0 + p.y * 10.0));
            if (roots < 0.1 && noise(p*20.0, iTime) > 0.5) col = vec3(0.15, 0.1, 0.05);
        }
    }
}

void layer_Plants(in vec2 p, in float rockHeight, in float iTime, inout vec3 col) {
    float plantZone = noise(p * vec2(8.0, 8.0), iTime);
    if (plantZone > 0.7 && p.y < rockHeight - 0.1) {
        
        vec2 leafP = fract(p * vec2(15.0, 15.0)) - 0.5;
        float leafID = floor(p.x * 15.0) + floor(p.y * 15.0);
        
        float angle = leafID * 2.0;
        leafP = vec2(leafP.x * cos(angle) - leafP.y * sin(angle), leafP.x * sin(angle) + leafP.y * cos(angle));
        
        float rustle = sin(iTime * 4.0 + leafID) * 0.1;
        leafP.x += rustle * leafP.y; 
        
        float leaf = length(max(abs(leafP) - vec2(0.05, 0.3), 0.0)); 
        leaf += 0.05 * sin(leafP.y * 100.0);
        
        if (leaf < 0.02) {
            if (mod(leafID, 3.0) == 0.0) {
                col = vec3(0.5, 0.2, 0.2); 
                if (abs(leafP.x) < 0.01) col = vec3(0.2, 0.4, 0.2); 
            } else if (mod(leafID, 4.0) == 0.0) {
                 col = vec3(0.2, 0.4, 0.2); 
                 if (abs(leafP.x) > 0.03) col = vec3(0.7, 0.7, 0.2);
            } else {
                col = vec3(0.2, 0.5, 0.2); 
                if (leafP.x > 0.0) col = vec3(0.4, 0.7, 0.3);
            }
            
            col *= 0.5 + 0.5 * smoothstep(-0.3, 0.0, leafP.y);
        }
    }
}

void layer_Vignette(in vec2 p, inout vec3 col) {
    col *= 1.0 - 0.3 * length(p);
}

void main() {
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(0.0);
    float rockHeight = 0.0;
    
    layer_Sky(uv, col);
    layer_Clouds(p, iTime, col);
    layer_Birds(p, iTime, col);
    layer_Rocks(p, rockHeight, iTime, col);
    layer_Plants(p, rockHeight, iTime, col);
    layer_Vignette(p, col);

    gl_FragColor = vec4(col, 1.0);
}

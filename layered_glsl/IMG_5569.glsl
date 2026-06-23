/* @layer_metadata
{
  "title": "Shader: IMG_5569",
  "layers": [
    {
      "name": "Background",
      "keywords": ["background", "floor", "noise"]
    },
    {
      "name": "Rock Speaker",
      "keywords": ["rock", "speaker", "texture", "lighting", "moss"]
    },
    {
      "name": "Speaker Holes",
      "keywords": ["speaker", "holes", "mesh", "vibration", "animation"]
    },
    {
      "name": "Logo",
      "keywords": ["logo", "TIC"]
    },
    {
      "name": "Cable",
      "keywords": ["cable"]
    }
  ]
}
*/
void layer_Background(in vec2 p, in float iTime, inout vec3 col) {
    col = vec3(0.85, 0.85, 0.85);
    float bgNoise = fract(sin(dot(p + iTime*0.05, vec2(12.9898, 78.233))) * 43758.5453);
    if (p.x + p.y > 0.5) {
        col *= 0.95 + 0.05 * bgNoise; 
    } else {
        col = vec3(0.95); 
    }
}

void layer_RockSpeaker(in vec2 p, in float iTime, out float rLength, out vec2 rp, out float rockShape, inout vec3 col) {
    float a = atan(p.y, p.x);
    float r = length(p);
    
    rockShape = 0.65;
    rockShape += sin(a * 3.0 + iTime*0.2) * 0.1; 
    rockShape += cos(a * 5.0 + 1.0) * 0.05;
    rockShape += sin(a * 7.0) * 0.03;
    
    float edgeNoise = fract(sin(a * 50.0) * 4375.5453) * 0.02;
    rockShape += edgeNoise;

    rp = p - vec2(-0.1, -0.1);
    rLength = length(rp);
    
    if (rLength < rockShape) {
        col = vec3(0.22, 0.23, 0.25);
        
        float rockNoise = fract(sin(dot(rp * 10.0, vec2(12.9898, 78.233))) * 43758.5453);
        float rockNoise2 = fract(sin(dot(rp * 30.0, vec2(39.346, 11.135))) * 43758.5453);
        
        col *= 0.8 + 0.4 * rockNoise;
        
        if (rockNoise2 > 0.8 && rLength > 0.4) {
            col = mix(col, vec3(0.2, 0.4, 0.3), 0.5);
        }
        
        vec3 normal = normalize(vec3(rp.x, rp.y, rockShape - rLength));
        vec3 lightDir = normalize(vec3(-1.0, 1.0, 1.0));
        float diff = max(dot(normal, lightDir), 0.0);
        col *= 0.5 + 0.5 * diff;
    }
}

void layer_SpeakerHoles(in vec2 rp, in float rLength, in float rockShape, in float iTime, inout vec3 col) {
    if (rLength < rockShape) {
        vec2 center = vec2(0.1, 0.0); 
        float dHoles = 1.0;
        
        float centerHole = length(rp - center) - 0.06;
        dHoles = min(dHoles, centerHole);
        
        for(float i=0.0; i<8.0; i++) {
            float ang = i * 3.14159 / 4.0;
            vec2 pos = center + vec2(cos(ang), sin(ang)) * 0.18;
            vec2 hp = rp - pos;
            
            float c = cos(-ang);
            float s = sin(-ang);
            mat2 rot = mat2(c, -s, s, c);
            hp = rot * hp;
            
            float oval = max(abs(hp.x) - 0.06, abs(hp.y) - 0.02) - 0.02;
            if (mod(i, 2.0) == 0.0) oval = length(rp - pos) - 0.05;
            
            dHoles = min(dHoles, oval);
        }
        
         for(float i=0.0; i<4.0; i++) {
            float ang = i * 3.14159 / 2.0 + 3.14159/4.0;
            vec2 pos = center + vec2(cos(ang), sin(ang)) * 0.09;
            float hole = length(rp - pos) - 0.03;
            dHoles = min(dHoles, hole);
        }

        if (dHoles < 0.0) {
            col = vec3(0.08, 0.09, 0.1);
            float meshAnim = sin(iTime * 10.0 + length(rp) * 20.0) * 0.1;
            if (fract(rp.x * 100.0 + meshAnim) < 0.2 || fract(rp.y * 100.0 + meshAnim) < 0.2) {
                col *= 0.5;
            }
            float vibration = sin(iTime * 30.0) * 0.005;
            col *= smoothstep(0.0, -0.01 + vibration, dHoles);
        }
    }
}

void layer_Logo(in vec2 rp, in float rLength, in float rockShape, inout vec3 col) {
    if (rLength < rockShape) {
        vec2 logoPos = vec2(0.5, 0.2);
        if (length(rp - logoPos) < 0.05) {
            col = vec3(0.15); 
            if (length(rp - logoPos) > 0.04) col = vec3(0.3); 
        }
    }
}

void layer_Cable(in vec2 p, inout vec3 col) {
    float dCable = abs(length(p - vec2(0.3, 1.2)) - 0.6);
    if (dCable < 0.02 && p.x > 0.3 && p.y > 0.6) {
        col = vec3(0.85); 
        col *= 0.7 + 0.3 * cos((dCable * 50.0) * 3.14159);
        if (dCable < 0.005 && p.x > 0.8) col = vec3(0.2, 0.6, 0.3);
    }
}

void main() {
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(0.0);
    
    layer_Background(p, iTime, col);
    
    float rLength, rockShape;
    vec2 rp;
    layer_RockSpeaker(p, iTime, rLength, rp, rockShape, col);
    layer_SpeakerHoles(rp, rLength, rockShape, iTime, col);
    layer_Logo(rp, rLength, rockShape, col);
    
    layer_Cable(p, col);

    gl_FragColor = vec4(col, 1.0);
}

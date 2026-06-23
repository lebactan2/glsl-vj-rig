/* @layer_metadata
{
  "title": "Checkered Wood Pattern",
  "layers": [
    {
      "name": "Dark Wood",
      "keywords": ["dark", "wood", "vertical", "grain", "reddish", "brown"]
    },
    {
      "name": "Light Wood",
      "keywords": ["light", "wood", "horizontal", "beige", "fine"]
    },
    {
      "name": "Groove and Bevel",
      "keywords": ["groove", "bevel", "edge", "3D", "shadow", "highlight"]
    }
  ]
}
*/
// Hash function
vec2 hash(vec2 p) {
    p = vec2(dot(p, vec2(127.1, 311.7)), dot(p, vec2(269.5, 183.3)));
    return -1.0 + 2.0 * fract(sin(p) * 43758.5453123);
}

// Gradient noise
float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(mix(dot(hash(i + vec2(0.0, 0.0)), f - vec2(0.0, 0.0)),
                   dot(hash(i + vec2(1.0, 0.0)), f - vec2(1.0, 0.0)), u.x),
               mix(dot(hash(i + vec2(0.0, 1.0)), f - vec2(0.0, 1.0)),
                   dot(hash(i + vec2(1.0, 1.0)), f - vec2(1.0, 1.0)), u.x), u.y);
}

float fbm(vec2 p) {
    float f = 0.0;
    float w = 0.5;
    for(int i = 0; i < 5; i++) {
        f += w * noise(p);
        p *= 2.0;
        w *= 0.5;
    }
    return f;
}

void layer_DarkWood(in vec2 p, in vec2 tileOffset, out vec3 col) {
    vec2 noiseP = (p + tileOffset) * vec2(1.0, 0.1);
    float distortion = fbm(noiseP * 5.0);
    noiseP.x += distortion * 0.15;

    float n = fbm(noiseP * 15.0);
    n += 0.5 * fbm(noiseP * 30.0);
    
    vec3 darkBase = vec3(0.5, 0.22, 0.08);
    vec3 darkHighlight = vec3(0.65, 0.32, 0.15);
    vec3 darkStreak = vec3(0.3, 0.12, 0.05);

    col = mix(darkBase, darkHighlight, n);
    float streakNoise = fbm(noiseP * vec2(40.0, 1.5));
    col = mix(col, darkStreak, smoothstep(0.4, 0.9, streakNoise));
}

void layer_LightWood(in vec2 p, in vec2 tileOffset, out vec3 col) {
    vec2 noiseP = (p + tileOffset) * vec2(0.2, 5.0);
    float distortion = fbm(noiseP * 2.0);
    noiseP.y += distortion * 0.05;

    float n = fbm(noiseP * vec2(2.0, 40.0));
    
    vec3 lightBase = vec3(0.85, 0.8, 0.72);
    vec3 lightHighlight = vec3(0.92, 0.88, 0.8);
    vec3 lightStreak = vec3(0.75, 0.68, 0.58);

    col = mix(lightBase, lightHighlight, n);
    float streakNoise = fbm(noiseP * vec2(1.0, 60.0));
    col = mix(col, lightStreak, smoothstep(0.5, 1.0, streakNoise));
}

void layer_GrooveAndBevel(in vec2 tileUV, inout vec3 col) {
    float grooveWidth = 0.005;
    float distToEdgeX = min(tileUV.x, 1.0 - tileUV.x);
    float distToEdgeY = min(tileUV.y, 1.0 - tileUV.y);
    float minDist = min(distToEdgeX, distToEdgeY);

    vec3 grooveCol = vec3(0.15, 0.05, 0.02);
    if (minDist < grooveWidth) {
        col = mix(grooveCol, col, smoothstep(grooveWidth * 0.2, grooveWidth, minDist));
    } else if (minDist < grooveWidth * 4.0) {
        float bevelSize = grooveWidth * 4.0;
        float shadow = smoothstep(grooveWidth, bevelSize, minDist);
        if ((tileUV.x > 1.0 - bevelSize) || (tileUV.y > 1.0 - bevelSize)) {
            col *= mix(0.75, 1.0, shadow);
        } else if ((tileUV.x < bevelSize) || (tileUV.y < bevelSize)) {
            col *= mix(1.15, 1.0, shadow);
        }
    }
}

void main() {
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    float aspect = iResolution.x / iResolution.y;
    vec2 p = uv;
    p.x *= aspect;

    float scale = 1.5;
    vec2 scaledP = p * scale;
    vec2 tileID = floor(scaledP);
    vec2 tileUV = fract(scaledP);

    bool isDark = mod(tileID.x + tileID.y, 2.0) == 0.0;
    vec2 tileOffset = vec2(hash(tileID).x * 100.0, hash(tileID).y * 100.0);
    
    vec3 col;

    if (isDark) {
        layer_DarkWood(p, tileOffset, col);
    } else {
        layer_LightWood(p, tileOffset, col);
    }

    layer_GrooveAndBevel(tileUV, col);

    gl_FragColor = vec4(col, 1.0);
}

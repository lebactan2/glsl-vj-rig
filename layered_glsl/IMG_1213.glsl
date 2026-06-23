/* @layer_metadata
{
  "title": "Shader: IMG_1213",
  "layers": [
    {
      "name": "Background",
      "keywords": ["background", "base"]
    },
    {
      "name": "Golden Frame",
      "keywords": ["frame", "gold", "lattice", "shadow"]
    },
    {
      "name": "Scene Sky",
      "keywords": ["scene", "sky", "gradient", "clouds", "animation"]
    },
    {
      "name": "Scene Mountain",
      "keywords": ["scene", "mountain"]
    },
    {
      "name": "Scene Ocean",
      "keywords": ["scene", "ocean", "waves", "parallax", "glints", "animation"]
    },
    {
      "name": "Scene Boat",
      "keywords": ["scene", "boat", "sailing", "waves", "mast", "sail", "animation"]
    },
    {
      "name": "Scene Balcony",
      "keywords": ["scene", "balcony", "railing", "flowers", "wind", "rustle", "animation"]
    }
  ]
}
*/
#define segment(p, a, b) length(p - a - (b - a) * clamp(dot(p - a, b - a) / dot(b - a, b - a), 0.0, 1.0))

void layer_Background(inout vec3 col) {
    col = vec3(0.88, 0.88, 0.9);
}

void layer_GoldenFrame(in vec2 p, in vec2 fp, in float frameBox, in float innerBox, inout vec3 col) {
    if (innerBox > 0.0) {
        vec3 gold = vec3(0.8, 0.65, 0.2);
        vec3 darkGold = vec3(0.4, 0.3, 0.1);
        float latX = abs(fract(fp.x * 20.0 + fp.y * 20.0) - 0.5);
        float latY = abs(fract(fp.x * 20.0 - fp.y * 20.0) - 0.5);
        float lattice = min(latX, latY);
        float rims = min(abs(frameBox), abs(innerBox));
        if (rims < 0.01) col = vec3(0.9, 0.8, 0.4);
        else {
            col = mix(gold, darkGold, smoothstep(0.0, 0.2, lattice));
            col *= 0.8 + 0.2 * sin(fp.x * 50.0);
        }
    }
}

void layer_SceneSky(in vec2 sp, in float iTime, inout vec3 col) {
    col = mix(vec3(0.4, 0.7, 0.9), vec3(0.8, 0.9, 0.95), -sp.y * 0.5 + 0.5);
    float cloudNoise = sin(sp.x * 5.0 + iTime * 0.5) * sin(sp.x * 10.0 + sp.y * 5.0 + iTime * 0.3);
    if (sp.y > 0.2) col = mix(col, vec3(1.0), smoothstep(0.5, 0.9, cloudNoise));
}

void layer_SceneMountain(in vec2 sp, inout vec3 col) {
    float mnt = -0.1 + sin(sp.x * 5.0) * 0.1 + cos(sp.x * 12.0) * 0.05;
    if (sp.y < mnt) col = vec3(0.4, 0.45, 0.5);
}

void layer_SceneOcean(in vec2 sp, in float iTime, inout vec3 col) {
    if (sp.y < -0.1) {
        col = mix(vec3(0.1, 0.3, 0.6), vec3(0.4, 0.8, 0.9), (sp.y + 1.0)*0.5);
        float wave = sin(sp.x * 40.0 - iTime * 4.0) * sin(sp.y * 60.0 + iTime * 2.0);
        col += wave * 0.05;
        if (wave > 0.8) col += 0.2; 
    }
}

void layer_SceneBoat(in vec2 sp, in float iTime, inout vec3 col) {
    float sailProgress = mod(iTime * 0.2, 2.0) - 1.0; 
    vec2 bp = sp - vec2(sailProgress, -0.2);
    bp.y += sin(iTime * 4.0) * 0.02;
    float hull = max(abs(bp.x) - 0.1 + bp.y * 0.5, abs(bp.y + 0.02) - 0.02);
    if (hull < 0.0) col = vec3(0.2, 0.15, 0.1);
    
    float mast = segment(bp, vec2(0.0, 0.0), vec2(0.0, 0.2));
    if (mast < 0.005) col = vec3(0.1);
    float billow = sin(bp.y * 10.0 - iTime * 5.0) * 0.02;
    float sail = max(bp.x - billow, -bp.x - 0.1 + bp.y * 0.5);
    sail = max(sail, max(bp.y - 0.18, -bp.y));
    if (sail < 0.0) {
        col = vec3(0.9, 0.2, 0.2);
        col *= 0.8 + 0.2 * bp.x * 10.0; 
    }
}

void layer_SceneBalcony(in vec2 sp, in float iTime, inout vec3 col) {
    if (sp.x > 0.4 && sp.y > -0.7) {
        float rails = min(abs(fract(sp.x * 8.0) - 0.5), abs(sp.y + 0.4));
        if (rails < 0.02) col = vec3(0.9);
        
        vec2 flp = sp * vec2(10.0, 15.0);
        flp.x += sin(flp.y * 5.0 + iTime * 4.0) * 0.2;
        
        vec2 flpFrac = fract(flp) - 0.5;
        float flower = length(flpFrac) - 0.2 - sin(atan(flpFrac.y, flpFrac.x) * 5.0) * 0.1;
        
        if (flower < 0.0 && sp.y > -0.4) {
            float colorSeed = fract(floor(flp.x) + floor(flp.y));
            vec3 fCol = colorSeed > 0.5 ? vec3(0.9, 0.2, 0.5) : vec3(0.8, 0.1, 0.2);
            if (length(flpFrac) < 0.05) fCol = vec3(0.9, 0.9, 0.1);
            col = mix(col, fCol, 0.95);
        }
    }
}

void main() {
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;
    
    vec3 col = vec3(0.0);
    layer_Background(col);
    
    float frameW = 0.75, frameH = 0.65;
    vec2 fp = vec2(p.x - 0.1, p.y + 0.05);
    float frameBox = max(abs(fp.x) - frameW, abs(fp.y) - frameH);
    
    if (frameBox < 0.0) {
        float innerBox = max(abs(fp.x) - frameW + 0.08, abs(fp.y) - frameH + 0.08);
        if (innerBox > 0.0) {
            layer_GoldenFrame(p, fp, frameBox, innerBox, col);
        } else {
            vec2 sp = fp / vec2(frameW - 0.08, frameH - 0.08);
            layer_SceneSky(sp, iTime, col);
            layer_SceneMountain(sp, col);
            layer_SceneOcean(sp, iTime, col);
            layer_SceneBoat(sp, iTime, col);
            layer_SceneBalcony(sp, iTime, col);
        }
    } else {
        col = mix(vec3(0.6), col, smoothstep(0.0, 0.02, frameBox - 0.02)); 
    }
    
    gl_FragColor = vec4(col, 1.0);
}

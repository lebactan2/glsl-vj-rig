/* @layer_metadata
{
  "title": "Shader: IMG_1276",
  "layers": [
    {
      "name": "Walls",
      "keywords": ["walls", "grey", "background"]
    },
    {
      "name": "Terracotta Roof",
      "keywords": ["roof", "terracotta", "tiles", "3D", "background"]
    },
    {
      "name": "Courtyard Tarp",
      "keywords": ["tarp", "fabric", "flap", "folds", "animation"]
    },
    {
      "name": "Railings",
      "keywords": ["railings", "bars", "metal", "highlight"]
    },
    {
      "name": "Tree",
      "keywords": ["tree", "trunk", "branches", "wood", "bark", "leaves", "rustle", "animation"]
    },
    {
      "name": "Falling Leaves",
      "keywords": ["leaves", "falling", "spin", "animation"]
    },
    {
      "name": "Shadows",
      "keywords": ["shadows", "darken"]
    }
  ]
}
*/
#define segment(p, a, b) length(p - a - (b - a) * clamp(dot(p - a, b - a) / dot(b - a, b - a), 0.0, 1.0))

void layer_Walls(inout vec3 col) {
    col = vec3(0.8, 0.8, 0.8); 
}

void layer_TerracottaRoof(in vec2 p, inout vec3 col) {
    if (p.y > 0.4 && p.y < 0.7) {
        vec2 tileUV = p * vec2(15.0, 10.0);
        float tX = fract(tileUV.x) - 0.5;
        float tY = fract(tileUV.y);
        
        col = mix(vec3(0.7, 0.3, 0.2), vec3(0.5, 0.2, 0.1), tY); 
        col += 0.2 * smoothstep(0.3, 0.0, abs(tX));
        if (abs(tX) > 0.45) col = vec3(0.3, 0.1, 0.05);
    }
}

void layer_CourtyardTarp(in vec2 p, in float iTime, inout vec3 col) {
    float tarpFlap = sin(p.x * 10.0 + iTime * 8.0) * 0.03;
    float tarp = length(max(abs(p - vec2(0.0, -0.5 + tarpFlap)) - vec2(0.8, 0.3), 0.0));
    if (tarp < 0.01) {
        col = vec3(0.65, 0.65, 0.65);
        float fold = sin(p.x * 15.0 + iTime * 5.0) * 0.1;
        col += vec3(fold);
    }
}

void layer_Railings(in vec2 p, inout vec3 col) {
    float railV = abs(fract(p.x * 20.0) - 0.5);
    float railH = abs(p.y - (-0.2));
    if ((railV < 0.1 && p.y > -0.8 && p.y < -0.2) || railH < 0.02) {
        col = vec3(0.4, 0.3, 0.25); 
        col += 0.2 * smoothstep(0.1, 0.0, railV);
    }
}

void layer_Tree(in vec2 p, in float iTime, inout vec3 col) {
    vec2 trunkP = p - vec2(0.2, -0.2);
    float tree = segment(trunkP, vec2(0.0, -0.4), vec2(0.0, 0.4)) - 0.04;
    tree = min(tree, segment(trunkP, vec2(0.0, 0.1), vec2(-0.2, 0.3)) - 0.02);
    tree = min(tree, segment(trunkP, vec2(0.0, 0.2), vec2(0.25, 0.4)) - 0.02);
    
    if (tree < 0.0) {
        col = vec3(0.3, 0.2, 0.1); 
        float bark = sin(trunkP.x * 100.0) * sin(trunkP.y * 50.0);
        col *= 0.8 + 0.2 * bark;
    }
    
    for(int i=0; i<30; i++) {
        float fi = float(i);
        vec2 cp = vec2(0.2 + sin(fi*2.1)*0.4, 0.2 + cos(fi*1.7)*0.3);
        cp.x += sin(iTime * 5.0 + fi) * 0.05;
        cp.y += cos(iTime * 4.0 + fi) * 0.03;
        
        float leaf = length(p - cp) - (0.05 + fract(fi*0.3)*0.05);
        if (leaf < 0.0) {
            vec3 leafCol = mix(vec3(0.4, 0.8, 0.2), vec3(0.2, 0.6, 0.1), fract(fi*0.7));
            col = mix(col, leafCol, 0.95);
            if (fract(p.x * 50.0 + p.y * 30.0) < 0.1) col *= 0.8; 
        }
    }
}

void layer_FallingLeaves(in vec2 p, in float iTime, inout vec3 col) {
    for(float i=0.0; i<15.0; i++) {
        float startX = -1.0 + i * 0.2 + sin(i * 10.0) * 0.1;
        float fallY = 1.0 - fract(iTime * 0.2 + i * 0.1) * 2.5;
        float swayX = startX + sin(fallY * 10.0 + i) * 0.1;
        
        vec2 fallP = p - vec2(swayX, fallY);
        float spinAngle = iTime * 5.0 + i;
        mat2 sRot = mat2(cos(spinAngle), -sin(spinAngle), sin(spinAngle), cos(spinAngle));
        vec2 rFallP = sRot * fallP;
        
        float fallingLeaf = length(max(abs(rFallP) - vec2(0.015, 0.03), 0.0)) - 0.01;
        if (fallingLeaf < 0.0 && fallY > -1.0) {
            col = vec3(0.5, 0.7, 0.2); 
            if (abs(rFallP.x) < 0.005) col = vec3(0.2, 0.4, 0.1); 
        }
    }
}

void layer_Shadows(in vec2 p, inout vec3 col) {
    col *= 1.0 - 0.3 * exp(-10.0 * abs(p.y - (-0.2))); 
    col *= 1.0 - 0.4 * exp(-5.0 * length(p - vec2(0.2, -0.2))); 
}

void main() {
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(0.0);
    
    layer_Walls(col);
    layer_TerracottaRoof(p, col);
    layer_CourtyardTarp(p, iTime, col);
    layer_Railings(p, col);
    layer_Tree(p, iTime, col);
    layer_FallingLeaves(p, iTime, col);
    layer_Shadows(p, col);

    gl_FragColor = vec4(col, 1.0);
}

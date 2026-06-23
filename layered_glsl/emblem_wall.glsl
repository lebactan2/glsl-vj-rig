/* @layer_metadata
{
  "title": "Decorative Emblem Wall",
  "layers": [
    {
      "name": "Background",
      "keywords": ["granite", "stone", "wall", "grey", "speckles"]
    },
    {
      "name": "Emblem",
      "keywords": ["emblem", "metal", "dark", "stone", "cross", "crown", "frame", "bevel"]
    },
    {
      "name": "Shadow",
      "keywords": ["drop shadow", "shadow", "depth"]
    },
    {
      "name": "Ledge",
      "keywords": ["ledge", "table", "marble", "red", "bottom"]
    }
  ]
}
*/
float hash(vec2 p) { return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453); }

float sdBox(vec2 p, vec2 b) {
    vec2 d = abs(p) - b;
    return length(max(d, 0.0)) + min(max(d.x, d.y), 0.0);
}

float emblemSDF(vec2 p) {
    p.x = abs(p.x); // Perfect symmetry
    
    // Outer frame
    float frame = sdBox(p, vec2(0.6, 0.9));
    float frameInner = sdBox(p, vec2(0.52, 0.82));
    float finalFrame = max(frame, -frameInner);
    
    // Center spine
    float spine = sdBox(p - vec2(0.0, -0.1), vec2(0.04, 0.6));
    
    // Top pill shape
    float topOval = sdBox(p - vec2(0.0, 0.65), vec2(0.06, 0.12));
    float topOvalInner = sdBox(p - vec2(0.0, 0.65), vec2(0.02, 0.08));
    float finalTop = max(topOval, -topOvalInner);
    
    // Crown/Cloud shape
    float crownLoop = abs(length(p - vec2(0.2, 0.45)) - 0.15) - 0.04;
    float crownCenter = abs(length(p - vec2(0.0, 0.5)) - 0.12) - 0.04;
    float crown = min(crownLoop, crownCenter);
    crown = max(crown, p.y - 0.55); // Cut top overlapping part
    crown = max(crown, -p.y + 0.3); // Cut bottom
    
    // Horizontal bars
    float bar1 = sdBox(p - vec2(0.15, 0.25), vec2(0.15, 0.04));
    float bar2 = sdBox(p - vec2(0.25, -0.1), vec2(0.2, 0.04));
    
    // Small cross on bar2
    float crossV = sdBox(p - vec2(0.25, -0.1), vec2(0.04, 0.1));
    
    // Bottom curved shape
    float botLoop = abs(length(p - vec2(0.25, -0.6)) - 0.15) - 0.04;
    botLoop = max(botLoop, p.x - 0.4); // cut right edge
    botLoop = max(botLoop, p.y + 0.45); // cut top edge
    
    float botSmile = abs(length(p - vec2(0.0, -0.6)) - 0.1) - 0.04;
    botSmile = max(botSmile, -p.y - 0.6); // keep lower half
    
    // Combine all emblem parts
    float symbol = finalTop;
    symbol = min(symbol, spine);
    symbol = min(symbol, crown);
    symbol = min(symbol, bar1);
    symbol = min(symbol, bar2);
    symbol = min(symbol, crossV);
    symbol = min(symbol, botLoop);
    symbol = min(symbol, botSmile);
    
    // Blend with frame
    return min(finalFrame, symbol);
}

void layer_Background(in vec2 uv, inout vec3 col) {
    vec3 granite = vec3(0.65, 0.62, 0.58);
    float n1 = hash(uv * 200.0);
    float n2 = hash(uv * 400.0 + vec2(1.0));
    
    granite *= 0.85 + 0.3 * n1;
    granite = mix(granite, vec3(0.2, 0.2, 0.18), step(0.85, n2));
    col = granite;
}

void layer_Shadow(in vec2 p, in float d, inout vec3 col) {
    if (d >= 0.0) {
        float shadow = smoothstep(0.0, 0.04, emblemSDF(p - vec2(0.02, -0.02)));
        col = mix(col * 0.5, col, shadow);
    }
}

void layer_Emblem(in vec2 uv, in vec2 p, in float d, inout vec3 col) {
    if (d < 0.0) {
        vec3 embCol = vec3(0.35, 0.36, 0.35);
        embCol *= 0.8 + 0.4 * hash(uv * 300.0 + vec2(2.0));
        col = embCol;
        
        float bevel = smoothstep(0.0, -0.02, d);
        col += vec3(0.15) * bevel * (0.5 + 0.5 * p.y);
    }
}

void layer_Ledge(in vec2 uv, in vec2 p, inout vec3 col) {
    if (p.y < -0.85 && p.x > 0.0) {
        vec3 redMarble = vec3(0.5, 0.2, 0.15);
        redMarble *= 0.8 + 0.4 * hash(uv * 50.0);
        col = redMarble;
        col *= smoothstep(-0.85, -0.9, p.y);
    }
}

void main() {
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;
    
    vec3 col = vec3(0.0);
    
    float d = emblemSDF(p);
    
    layer_Background(uv, col);
    layer_Shadow(p, d, col);
    layer_Emblem(uv, p, d, col);
    layer_Ledge(uv, p, col);
    
    gl_FragColor = vec4(col, 1.0);
}

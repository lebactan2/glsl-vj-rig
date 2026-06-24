#define segment(p, a, b) length(p - a - (b - a) * clamp(dot(p - a, b - a) / dot(b - a, b - a), 0.0, 1.0))

void layer_Background(in vec2 bp, in float boxW, in float boxH, inout vec3 col) {
    float shadow = max(abs(bp.x - 0.05) - boxW, abs(bp.y + 0.05) - boxH);
    if (shadow < 0.0) col = vec3(0.02);
}

void layer_BoxBase(in vec2 bp, in vec2 p, in float boxW, in float boxH, inout vec3 col) {
    vec3 greenBase = vec3(0.12, 0.35, 0.18);
    float noise = fract(sin(dot(p, vec2(12.9898,78.233))) * 43758.5453);
    col = greenBase + noise * 0.03;
    
    col *= 0.8 + 0.2 * smoothstep(boxW - 0.05, boxW, abs(bp.x));
    col *= 0.8 + 0.2 * smoothstep(boxH - 0.05, boxH, abs(bp.y));
    
    if (boxH - abs(bp.y) < 0.03) col = vec3(0.7, 0.1, 0.1);
}

void layer_TextNHANG(in vec2 bp, inout vec3 col) {
    vec2 t1 = bp - vec2(-0.2, 0.6);
    float d1 = 1.0;
    
    d1 = min(d1, segment(t1, vec2(0.0, -0.05), vec2(0.0, 0.05)));
    d1 = min(d1, segment(t1, vec2(0.0, 0.05), vec2(0.08, -0.05)));
    d1 = min(d1, segment(t1, vec2(0.08, -0.05), vec2(0.08, 0.05)));
    
    d1 = min(d1, segment(t1, vec2(0.14, -0.05), vec2(0.14, 0.05)));
    d1 = min(d1, segment(t1, vec2(0.14, 0.0), vec2(0.22, 0.0)));
    d1 = min(d1, segment(t1, vec2(0.22, -0.05), vec2(0.22, 0.05)));
    
    d1 = min(d1, segment(t1, vec2(0.28, -0.05), vec2(0.32, 0.05)));
    d1 = min(d1, segment(t1, vec2(0.32, 0.05), vec2(0.36, -0.05)));
    
    vec3 gold = vec3(0.9, 0.75, 0.3);
    if (d1 < 0.01) col = gold;
}

void layer_TextTHANTAI(in vec2 bp, inout vec3 col) {
    vec2 t2 = bp - vec2(-0.25, 0.45);
    float d2 = 1.0;
    
    d2 = min(d2, segment(t2, vec2(0.0, 0.05), vec2(0.1, 0.05)));
    d2 = min(d2, segment(t2, vec2(0.05, 0.05), vec2(0.05, -0.05)));
    
    d2 = min(d2, segment(t2, vec2(0.14, -0.05), vec2(0.14, 0.05)));
    d2 = min(d2, segment(t2, vec2(0.14, 0.0), vec2(0.22, 0.0)));
    d2 = min(d2, segment(t2, vec2(0.22, -0.05), vec2(0.22, 0.05)));
    
    if (d2 < 0.01) col = vec3(0.95, 0.85, 0.4); 
}

void layer_GoldSeal(in vec2 bp, inout vec3 col) {
    vec3 gold = vec3(0.9, 0.75, 0.3);
    float sealD = length((bp - vec2(0.0, -0.1)) * vec2(1.0, 1.2)) - 0.25;
    if (abs(sealD) < 0.01 || abs(sealD + 0.03) < 0.005) {
        col = gold;
    }
    
    vec2 dp = bp - vec2(0.0, -0.1);
    float dragon = sin(dp.x * 30.0 + dp.y * 20.0) * sin(dp.x * 20.0 - dp.y * 30.0);
    if (sealD < -0.03 && dragon > 0.5) col = mix(col, gold, 0.5);
}

vec4 layer_Background(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    float boxW = 0.35, boxH = 0.85;
    vec2 bp = p;
    float box = max(abs(bp.x) - boxW, abs(bp.y) - boxH);
    
    if (box < 0.0) {
    } else {
        layer_Background(bp, boxW, boxH, col);
    }


  return vec4(clamp(col,0.0,1.0), step(0.0, max(col.r, max(col.g, col.b))));
}

vec4 layer_BoxBase(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    float boxW = 0.35, boxH = 0.85;
    vec2 bp = p;
    float box = max(abs(bp.x) - boxW, abs(bp.y) - boxH);
    
    if (box < 0.0) {
        layer_BoxBase(bp, p, boxW, boxH, col);
    } else {
    }


  return vec4(clamp(col,0.0,1.0), step(0.0, max(col.r, max(col.g, col.b))));
}

vec4 layer_TextNHANG(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    float boxW = 0.35, boxH = 0.85;
    vec2 bp = p;
    float box = max(abs(bp.x) - boxW, abs(bp.y) - boxH);
    
    if (box < 0.0) {
        layer_TextNHANG(bp, col);
    } else {
    }


  return vec4(clamp(col,0.0,1.0), step(0.0, max(col.r, max(col.g, col.b))));
}

vec4 layer_TextTHANTAI(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    float boxW = 0.35, boxH = 0.85;
    vec2 bp = p;
    float box = max(abs(bp.x) - boxW, abs(bp.y) - boxH);
    
    if (box < 0.0) {
        layer_TextTHANTAI(bp, col);
    } else {
    }


  return vec4(clamp(col,0.0,1.0), step(0.0, max(col.r, max(col.g, col.b))));
}

vec4 layer_GoldSeal(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    float boxW = 0.35, boxH = 0.85;
    vec2 bp = p;
    float box = max(abs(bp.x) - boxW, abs(bp.y) - boxH);
    
    if (box < 0.0) {
        layer_GoldSeal(bp, col);
    } else {
    }


  return vec4(clamp(col,0.0,1.0), step(0.0, max(col.r, max(col.g, col.b))));
}

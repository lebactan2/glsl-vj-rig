void layer_MosaicWall(in vec2 p, in float iTime, in float frameOuter, inout vec3 col) {
    if (frameOuter >= 0.0) {
        vec2 tileUV = fract(p * 20.0);
        float tileEdge = smoothstep(0.9, 1.0, tileUV.x) + smoothstep(0.9, 1.0, tileUV.y) + smoothstep(0.1, 0.0, tileUV.x) + smoothstep(0.1, 0.0, tileUV.y);
        float sparkle = fract(sin(dot(floor(p * 20.0) + floor(iTime*2.0), vec2(12.9898, 78.233))) * 43758.5453);
        vec3 tileCol = vec3(0.6 + 0.3*sparkle, 0.65 + 0.25*sparkle, 0.7 + 0.2*sparkle); 
        if (tileEdge > 0.0) tileCol *= 0.5;
        col = tileCol;
    }
}

void layer_GoldFrame(in vec2 p, in float iTime, in float frameOuter, in float frameInner, inout vec3 col) {
    if (frameOuter < 0.0 && frameInner > 0.0) {
        float goldTex = sin(p.x*100.0 + iTime)*sin(p.y*100.0 + iTime);
        col = vec3(0.8, 0.6, 0.1) * (0.8 + 0.2*goldTex);
        if (abs(frameOuter) < 0.02 || abs(frameInner) < 0.02) col *= 0.6;
    }
}

void layer_Padding(in vec2 p, in float iTime, in float frameInner, in float centerHoleOuter, inout vec3 col) {
    if (frameInner < 0.0 && centerHoleOuter >= 0.0) {
        vec2 diaP = p;
        float diaSize = 0.35;
        
        diaP.x += (mod(floor(diaP.y / diaSize), 2.0) * diaSize * 0.5);
        
        vec2 id = floor(diaP / diaSize);
        vec2 fDia = fract(diaP / diaSize) - 0.5;
        
        float d1 = abs(fDia.x + fDia.y);
        float d2 = abs(fDia.x - fDia.y);
        
        float pillow = 1.0 - max(d1, d2); 
        
        col = vec3(0.85, 0.85, 0.85) * (0.5 + 0.5 * pillow);
        
        float leatherTex = fract(sin(dot(p*50.0, vec2(12.9898, 78.233))) * 43758.5453);
        col -= 0.05 * leatherTex;
        
        vec2 gridP = fract((p + vec2(diaSize*0.5, 0.0)) / diaSize) - 0.5;
        if (length(fDia) < 0.04) {
            float btnLight = 0.5 + 0.5*sin(iTime*3.0 + id.x*10.0 + id.y*10.0);
            col = vec3(0.8) + 0.2*btnLight;
            if (length(fDia) > 0.03) col *= 0.5;
        }
    }
}

void layer_WoodFrame(in vec2 p, in float frameInner, in float centerHoleOuter, in float centerHoleInner, inout vec3 col) {
    if (frameInner < 0.0 && centerHoleOuter < 0.0 && centerHoleInner > 0.0) {
        col = vec3(0.15); 
        if (fract(p.x*20.0 + sin(p.y*10.0)) < 0.2) col *= 0.8;
    }
}

void layer_InsideWall(in vec2 p, in float iTime, in float frameInner, in float centerHoleOuter, in float centerHoleInner, inout vec3 col) {
    if (frameInner < 0.0 && centerHoleOuter < 0.0 && centerHoleInner <= 0.0) {
        col = vec3(0.6, 0.55, 0.5); 
        float wallTex = fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
        col -= 0.1 * wallTex;
        
        vec2 wireP1 = p - vec2(0.0, -0.2);
        float w1 = length(vec2(abs(wireP1.x) - 0.1, wireP1.y + 0.1*sin(wireP1.x*10.0 + iTime*2.0))) - 0.01;
        if (w1 < 0.0 && p.y < -0.1) col = vec3(0.1, 0.3, 0.8);
        
        vec2 wireP2 = p - vec2(0.1, -0.1);
        float w2 = length(vec2(abs(wireP2.x) - 0.15, wireP2.y + 0.15*cos(wireP2.x*8.0 - iTime*1.5))) - 0.01;
        if (w2 < 0.0 && p.y < 0.0) col = vec3(0.15);
    }
}

vec4 layer_MosaicWall(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    float frameOuter = max(abs(p.x) - 1.2, abs(p.y) - 0.9);
    float frameInner = max(abs(p.x) - 1.1, abs(p.y) - 0.8);
    float centerHoleOuter = max(abs(p.x) - 0.4, abs(p.y) - 0.5);
    float centerHoleInner = max(abs(p.x) - 0.35, abs(p.y) - 0.45);
    
    layer_MosaicWall(p, iTime, frameOuter, col);


  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

vec4 layer_GoldFrame(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    float frameOuter = max(abs(p.x) - 1.2, abs(p.y) - 0.9);
    float frameInner = max(abs(p.x) - 1.1, abs(p.y) - 0.8);
    float centerHoleOuter = max(abs(p.x) - 0.4, abs(p.y) - 0.5);
    float centerHoleInner = max(abs(p.x) - 0.35, abs(p.y) - 0.45);
    
    layer_GoldFrame(p, iTime, frameOuter, frameInner, col);


  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

vec4 layer_Padding(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    float frameOuter = max(abs(p.x) - 1.2, abs(p.y) - 0.9);
    float frameInner = max(abs(p.x) - 1.1, abs(p.y) - 0.8);
    float centerHoleOuter = max(abs(p.x) - 0.4, abs(p.y) - 0.5);
    float centerHoleInner = max(abs(p.x) - 0.35, abs(p.y) - 0.45);
    
    layer_Padding(p, iTime, frameInner, centerHoleOuter, col);


  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

vec4 layer_WoodFrame(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    float frameOuter = max(abs(p.x) - 1.2, abs(p.y) - 0.9);
    float frameInner = max(abs(p.x) - 1.1, abs(p.y) - 0.8);
    float centerHoleOuter = max(abs(p.x) - 0.4, abs(p.y) - 0.5);
    float centerHoleInner = max(abs(p.x) - 0.35, abs(p.y) - 0.45);
    
    layer_WoodFrame(p, frameInner, centerHoleOuter, centerHoleInner, col);


  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

vec4 layer_InsideWall(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    float frameOuter = max(abs(p.x) - 1.2, abs(p.y) - 0.9);
    float frameInner = max(abs(p.x) - 1.1, abs(p.y) - 0.8);
    float centerHoleOuter = max(abs(p.x) - 0.4, abs(p.y) - 0.5);
    float centerHoleInner = max(abs(p.x) - 0.35, abs(p.y) - 0.45);
    
    layer_InsideWall(p, iTime, frameInner, centerHoleOuter, centerHoleInner, col);


  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

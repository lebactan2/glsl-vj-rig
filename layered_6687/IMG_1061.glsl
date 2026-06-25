#define segment(p, a, b) length(p - a - (b - a) * clamp(dot(p - a, b - a) / dot(b - a, b - a), 0.0, 1.0))

void layer_Background(in vec2 p, in float iTime, inout vec3 col) {
    col = mix(vec3(0.95, 0.75, 0.8), vec3(0.9, 0.6, 0.7), length(p) * 0.5);
    float pattern = sin(p.x * 20.0 + iTime * 0.5) * sin(p.y * 20.0 + iTime * 0.3);
    col += pattern * 0.05 * vec3(1.0, 0.8, 0.9);
}

void layer_RedBar(in vec2 p, in float iTime, inout vec3 col) {
    if (p.y > 0.4 && p.y < 0.6) {
        col = vec3(0.8, 0.1, 0.2); 
        float shine = smoothstep(0.0, 0.2, sin(p.x * 5.0 + iTime * 2.0));
        col += shine * 0.1;
        
        float textWave = sin(p.x * 100.0) * sin(p.y * 100.0);
        if (textWave > 0.8 && abs(p.y - 0.5) < 0.03) col = vec3(0.9, 0.8, 0.2); 
    }
}

void layer_Text2K4(in vec2 p, inout vec3 col) {
    vec2 numP = p - vec2(0.5, 0.1);
    float dText = 1.0;
    
    vec2 p2 = numP - vec2(-0.15, 0.0);
    dText = min(dText, segment(p2, vec2(-0.04, 0.04), vec2(0.0, 0.08)));
    dText = min(dText, segment(p2, vec2(0.0, 0.08), vec2(0.04, 0.04)));
    dText = min(dText, segment(p2, vec2(0.04, 0.04), vec2(-0.04, -0.08)));
    dText = min(dText, segment(p2, vec2(-0.04, -0.08), vec2(0.05, -0.08)));
    
    vec2 pK = numP - vec2(0.0, 0.0);
    dText = min(dText, segment(pK, vec2(-0.03, 0.08), vec2(-0.03, -0.08)));
    dText = min(dText, segment(pK, vec2(-0.03, 0.0), vec2(0.04, 0.08)));
    dText = min(dText, segment(pK, vec2(-0.01, 0.02), vec2(0.04, -0.08)));
    
    vec2 p4 = numP - vec2(0.15, 0.0);
    dText = min(dText, segment(p4, vec2(0.02, -0.08), vec2(0.02, 0.08)));
    dText = min(dText, segment(p4, vec2(0.02, 0.08), vec2(-0.04, 0.0)));
    dText = min(dText, segment(p4, vec2(-0.05, 0.0), vec2(0.05, 0.0)));

    if (dText < 0.015) {
        col = vec3(0.85, 0.15, 0.25);
    } else if (dText < 0.02) {
        col = vec3(1.0, 0.8, 0.8); 
    }
}

void layer_GodOfWealth(in vec2 p, in float iTime, inout vec3 col) {
    if (length(p) < 0.3) {
        vec3 godCol = mix(vec3(0.9, 0.7, 0.1), vec3(0.8, 0.2, 0.1), p.y + 0.5);
        godCol = mix(godCol, vec3(0.1, 0.6, 0.3), smoothstep(0.1, 0.0, length(p - vec2(0.0, -0.1))));
        col = mix(col, godCol, smoothstep(0.3, 0.28, length(p)));
        
        float glimmer = pow(sin(p.x * 50.0 + p.y * 50.0 + iTime * 3.0) * 0.5 + 0.5, 10.0);
        col += glimmer * vec3(1.0, 0.9, 0.5) * 0.5;
    }
}

void layer_BottomNumbers(in vec2 p, inout vec3 col) {
    if (p.y < -0.3 && p.y > -0.45) {
        vec2 gridP = p;
        gridP.x = fract(p.x * 8.0) - 0.5;
        float numLike = segment(gridP, vec2(-0.2, 0.05), vec2(0.2, 0.05));
        numLike = min(numLike, segment(gridP, vec2(0.2, 0.05), vec2(0.2, -0.05)));
        numLike = min(numLike, segment(gridP, vec2(-0.2, -0.05), vec2(0.2, -0.05)));
        
        if (numLike < 0.05) {
            col = vec3(0.8, 0.1, 0.15);
        }
    }
}

void layer_DarkEdges(in vec2 p, inout vec3 col) {
    if (p.y > 0.8 || p.y < -0.8) {
        col = vec3(0.3, 0.25, 0.2); 
        float tex = fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
        col -= tex * 0.05;
    }
}

vec4 layer_Background(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_Background(p, iTime, col);


  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

vec4 layer_RedBar(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_RedBar(p, iTime, col);


  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

vec4 layer_Text2K4(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_Text2K4(p, col);


  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

vec4 layer_GodOfWealth(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_GodOfWealth(p, iTime, col);


  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

vec4 layer_BottomNumbers(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_BottomNumbers(p, col);


  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

vec4 layer_DarkEdges(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_DarkEdges(p, col);


  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

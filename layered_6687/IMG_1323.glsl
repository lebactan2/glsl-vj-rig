#define segment(p, a, b) length(p - a - (b - a) * clamp(dot(p - a, b - a) / dot(b - a, b - a), 0.0, 1.0))

void layer_SignBox(in vec2 tp, in float signBoxTilted, inout vec3 col) {
    if (signBoxTilted < 0.0) {
        col = mix(vec3(0.9, 0.8, 0.1), vec3(1.0, 0.9, 0.3), tp.y + 0.4); 
        if (abs(signBoxTilted) < 0.01) col = vec3(0.8, 0.2, 0.2);
    }
}

void layer_TextALoc(in vec2 tp, in float signBoxTilted, inout vec3 col) {
    if (signBoxTilted < 0.0) {
        vec2 rText = tp - vec2(-0.4, 0.2);
        float dR = 1.0;
        
        dR = min(dR, segment(rText, vec2(-0.1, -0.08), vec2(-0.05, 0.08)));
        dR = min(dR, segment(rText, vec2(-0.05, 0.08), vec2(0.0, -0.08)));
        dR = min(dR, segment(rText, vec2(-0.07, 0.0), vec2(-0.03, 0.0)));
        
        dR = min(dR, segment(rText, vec2(0.1, 0.08), vec2(0.1, -0.08)));
        dR = min(dR, segment(rText, vec2(0.1, -0.08), vec2(0.18, -0.08)));
        
        dR = min(dR, abs(length(rText - vec2(0.3, 0.0)) - 0.06));
        
        float cDist = length(rText - vec2(0.5, 0.0));
        if (cDist < 0.06 && rText.x < 0.52) dR = min(dR, abs(cDist - 0.06));
        
        if (dR < 0.015) {
            col = vec3(0.9, 0.1, 0.1);
            if (dR < 0.005) col = vec3(1.0, 0.5, 0.5);
        }
    }
}

void layer_TextChaoLong(in vec2 tp, in float signBoxTilted, inout vec3 col) {
    if (signBoxTilted < 0.0) {
        vec2 bText = tp - vec2(-0.4, -0.1);
        float dB = 1.0;
        
        float c2Dist = length(bText - vec2(-0.1, 0.0));
        if (c2Dist < 0.06 && bText.x < -0.08) dB = min(dB, abs(c2Dist - 0.06));
        
        dB = min(dB, segment(bText, vec2(0.05, 0.08), vec2(0.05, -0.08)));
        dB = min(dB, segment(bText, vec2(0.15, 0.08), vec2(0.15, -0.08)));
        dB = min(dB, segment(bText, vec2(0.05, 0.0), vec2(0.15, 0.0)));
        
        dB = min(dB, segment(bText, vec2(0.2, -0.08), vec2(0.25, 0.08)));
        dB = min(dB, segment(bText, vec2(0.25, 0.08), vec2(0.3, -0.08)));
        
        dB = min(dB, abs(length(bText - vec2(0.45, 0.0)) - 0.06));

        if (dB < 0.015) {
            col = vec3(0.1, 0.2, 0.8);
            if (dB < 0.005) col = vec3(0.4, 0.6, 1.0);
        }
    }
}

void layer_TreeBark(in vec2 p, in float signBoxTilted, inout vec3 col) {
    if (signBoxTilted > 0.0) {
        if (p.x < -0.75) {
            col = vec3(0.15, 0.1, 0.05);
            float bark = sin(p.y * 60.0 + sin(p.x * 30.0)*15.0);
            col *= 0.7 + 0.3 * bark;
        }
    }
}

void layer_NeonReflections(in vec2 p, in float signBoxTilted, in float iTime, inout vec3 col) {
    if (signBoxTilted > 0.0) {
        float neonGlow = exp(-length(p - vec2(0.5, -0.7)) * 2.0);
        col += vec3(0.0, 0.5, 0.2) * neonGlow * (sin(iTime * 10.0) * 0.2 + 0.8);
        
        float neonGlow2 = exp(-length(p - vec2(-0.2, -0.8)) * 3.0);
        col += vec3(0.8, 0.2, 0.2) * neonGlow2;
    }
}

vec4 layer_SignBox(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    float tilt = p.x * 0.1; 
    vec2 tp = vec2(p.x, p.y + tilt);
    float signBoxTilted = length(max(abs(tp) - vec2(0.7, 0.4), 0.0)) - 0.02;
    
    layer_SignBox(tp, signBoxTilted, col);


  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

vec4 layer_TextALOC(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    float tilt = p.x * 0.1; 
    vec2 tp = vec2(p.x, p.y + tilt);
    float signBoxTilted = length(max(abs(tp) - vec2(0.7, 0.4), 0.0)) - 0.02;
    
    layer_TextALoc(tp, signBoxTilted, col);


  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

vec4 layer_TextCHAOLONG(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    float tilt = p.x * 0.1; 
    vec2 tp = vec2(p.x, p.y + tilt);
    float signBoxTilted = length(max(abs(tp) - vec2(0.7, 0.4), 0.0)) - 0.02;
    
    layer_TextChaoLong(tp, signBoxTilted, col);


  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

vec4 layer_TreeBark(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    float tilt = p.x * 0.1; 
    vec2 tp = vec2(p.x, p.y + tilt);
    float signBoxTilted = length(max(abs(tp) - vec2(0.7, 0.4), 0.0)) - 0.02;
    
    layer_TreeBark(p, signBoxTilted, col);


  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

vec4 layer_NeonReflections(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    float tilt = p.x * 0.1; 
    vec2 tp = vec2(p.x, p.y + tilt);
    float signBoxTilted = length(max(abs(tp) - vec2(0.7, 0.4), 0.0)) - 0.02;
    
    layer_NeonReflections(p, signBoxTilted, iTime, col);


  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

void layer_Sky(inout vec3 col) {
    col = vec3(0.4, 0.9, 0.95); 
}

void layer_Flag(in vec2 p, in float iTime, inout vec3 col) {
    float spikes = 0.0;
    if (p.x > 0.4) {
        float f = p.y * 10.0;
        spikes = sin(f) * 0.15 * smoothstep(0.4, 0.7, p.x);
        spikes += sin(f * 2.0 + iTime * 5.0) * 0.05 * smoothstep(0.4, 0.7, p.x);
    }
    
    float flagFull = length(max(abs(p - vec2(spikes, 0.0)) - vec2(0.6, 0.5), 0.0)) - 0.05;

    if (flagFull < 0.0) {
        col = vec3(0.5, 0.2, 0.8);
        
        float wave = sin(p.x * 5.0 + p.y * 2.0 - iTime * 3.0) * 0.1;
        float fold = abs(sin(p.x * 10.0 + iTime)) * 0.2;
        col *= 0.8 + wave + fold;
        
        float border1 = length(max(abs(p) - vec2(0.5, 0.4), 0.0)) - 0.02;
        float border2 = length(max(abs(p) - vec2(0.45, 0.35), 0.0)) - 0.02;
        if (border1 < 0.0 && border2 > 0.0) {
            col = vec3(0.95);
            col *= 0.9 + 0.1 * wave; 
        }
        
        float border3 = length(max(abs(p) - vec2(0.35, 0.25), 0.0)) - 0.02;
        float border4 = length(max(abs(p) - vec2(0.3, 0.2), 0.0)) - 0.02;
        if (border3 < 0.0 && border4 > 0.0) {
            col = vec3(0.95);
            col *= 0.9 + 0.1 * wave;
        }
        
        float crossV = length(max(abs(p - vec2(0.0, 0.0)) - vec2(0.02, 0.15), 0.0)) - 0.01;
        float crossH = length(max(abs(p - vec2(0.0, 0.0)) - vec2(0.1, 0.02), 0.0)) - 0.01;
        
        float cEnd1 = length(p - vec2(0.0, 0.17)) - 0.03; 
        float cEnd2 = length(p - vec2(0.0, -0.17)) - 0.03; 
        float cEnd3 = length(p - vec2(0.12, 0.0)) - 0.03; 
        float cEnd4 = length(p - vec2(-0.12, 0.0)) - 0.03; 
        
        float fullCross = min(min(crossV, crossH), min(min(cEnd1, cEnd2), min(cEnd3, cEnd4)));
        
        if (fullCross < 0.0) {
            col = vec3(0.95);
            if (p.x - p.y > 0.0) col = vec3(0.85);
            col *= 0.9 + 0.1 * wave;
        }
        
        float sleeve = length(max(abs(p - vec2(0.0, 0.55)) - vec2(0.4, 0.05), 0.0)) - 0.02;
        if(sleeve < 0.0) col = vec3(0.45, 0.15, 0.75);
    }
}

vec4 layer_Sky(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_Sky(col);


  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

vec4 layer_Flag(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_Flag(p, iTime, col);


  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

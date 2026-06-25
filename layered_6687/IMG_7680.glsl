#define segment(p, a, b) length(p - a - (b - a) * clamp(dot(p - a, b - a) / dot(b - a, b - a), 0.0, 1.0))
#define myCosh(x) (exp(x) + exp(-(x))) / 2.0

void layer_Sky(in vec2 p, in float iTime, inout vec3 col) {
    col = mix(vec3(0.02, 0.04, 0.1), vec3(0.1, 0.15, 0.25), p.y * 0.5 + 0.5);
    
    vec2 sUV = p * 20.0;
    float starGrid = fract(sin(dot(floor(sUV), vec2(12.9898, 78.233))) * 43758.5453);
    if (starGrid > 0.98) {
        float twinkle = sin(iTime * 5.0 + starGrid * 100.0) * 0.5 + 0.5;
        col += vec3(twinkle * 0.8) * exp(-length(fract(sUV) - 0.5) * 10.0);
    }
}

void layer_Building(in vec2 p, inout vec3 col) {
    if (p.y < -0.4) {
        col = vec3(0.02, 0.03, 0.06);
        if (fract(p.x * 4.0) < 0.1 && p.y > -0.5) col = vec3(0.6, 0.15, 0.15); 
    }
}

void layer_StringLights(in vec2 p, in float iTime, inout vec3 col) {
    for (float i = 0.0; i < 4.0; i++) {
        float wx = p.x - 0.3 * i + 0.5;
        float bounce = sin(iTime * 2.0 + i) * 0.05;
        float wireY = 0.6 - 0.5 * myCosh(wx * 2.0) + 0.5 + bounce;
        
        if (abs(p.y - wireY) < 0.005) {
            col = vec3(0.1); 
        }
        
        for (int j = 0; j < 6; j++) {
            float fj = float(j);
            float bx = -1.2 + (fj / 5.0) * 2.5 + i * 0.2;
            float bwx = bx - 0.3 * i + 0.5;
            float by = 0.6 - 0.5 * myCosh(bwx * 2.0) + 0.5 + bounce - 0.08;
            
            vec2 bp = vec2(bx, by);
            float swing = sin(iTime * 3.0 + fj * 0.5) * 0.03;
            bp.x += swing;
            
            float d = length(p - bp);
            
            if (segment(p, vec2(bx, by + 0.08), vec2(bp.x, bp.y + 0.02)) < 0.004) col = vec3(0.1);
            
            vec3 bCol = vec3(1.0);
            float c = mod(fj + i, 3.0);
            if (c == 0.0) bCol = vec3(1.0, 0.2, 0.2); 
            else if (c == 1.0) bCol = vec3(1.0, 0.8, 0.2); 
            else bCol = vec3(0.9, 0.9, 1.0); 
            
            float on = sin(iTime * 4.0 - fj * 1.5 - i * 2.0) * 0.5 + 0.5;
            on = smoothstep(0.4, 0.6, on); 
            bCol *= 0.2 + 0.8 * on;
            
            float glow = exp(-d * 15.0);
            col += bCol * glow * 1.5;
            
            if (d < 0.02) {
                col = mix(col, bCol * 2.0, 0.8);
                vec2 fp = p - bp;
                if (abs(fp.x) < 0.002 && fp.y > -0.01 && fp.y < 0.01) col = vec3(2.0 * on);
                if (abs(length(fp - vec2(0.0, 0.01)) - 0.005) < 0.001 && fp.y > 0.01) col = vec3(2.0 * on);
            }
        }
    }
}

void layer_RedLantern(in vec2 p, in float iTime, inout vec3 col) {
    vec2 lp = p - vec2(-0.7, 0.1);
    
    float angle = sin(iTime * 1.5) * 0.3; 
    mat2 rot = mat2(cos(angle), -sin(angle), sin(angle), cos(angle));
    
    lp.y -= 0.2; 
    lp = rot * lp;
    lp.y += 0.2; 
    
    float lanternBody = length(lp * vec2(1.0, 0.8)) - 0.15;
    if (lanternBody < 0.0) {
        col = vec3(0.8, 0.15, 0.15); 
        float ribs = abs(sin(lp.x * 40.0));
        col = mix(col, vec3(0.9, 0.8, 0.2), smoothstep(0.8, 0.95, ribs) * 0.6);
        col *= 0.7 + 0.3 * smoothstep(0.15, 0.0, length(lp));
        if (abs(lp.y) > 0.17) col = vec3(0.8, 0.7, 0.2); 
    }
    
    float tasselSwing = sin(iTime * 1.5 + 1.0) * 0.1;
    vec2 tp = lp - vec2(0.0, -0.18);
    tp.x -= tp.y * tasselSwing * 5.0; 
    
    if (tp.y < 0.0 && tp.y > -0.2 && abs(tp.x) < 0.02) {
        vec3 tCol = vec3(0.8, 0.15, 0.15);
        float threads = abs(fract(tp.x * 100.0) - 0.5);
        tCol *= 0.6 + 0.4 * threads;
        col = mix(col, tCol, 1.0); // Simple mix if drawn over background
    }
}

void layer_Vignette(in vec2 p, inout vec3 col) {
    col *= 1.0 - 0.3 * length(p);
}

vec4 layer_Sky(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_Sky(p, iTime, col);


  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

vec4 layer_Building(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_Building(p, col);


  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

vec4 layer_StringLights(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_StringLights(p, iTime, col);


  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

vec4 layer_RedLantern(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_RedLantern(p, iTime, col);


  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

vec4 layer_Vignette(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_Vignette(p, col);


  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

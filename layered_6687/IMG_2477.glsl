void layer_Background(in vec2 p, inout vec3 col) {
    col = vec3(0.98, 0.96, 0.9); 
    col -= fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453) * 0.05;
}

void layer_TopCertificate(in vec2 p, in float iTime, inout vec3 col) {
    if (p.y > 0.1 && p.y < 0.9 && abs(p.x) < 0.8) {
        float borderDist = max(abs(p.x) - 0.75, abs(p.y - 0.5) - 0.35);
        if (borderDist > 0.0 && borderDist < 0.05) {
            col = vec3(0.8, 0.2, 0.15); 
            if (fract(p.x * 30.0 + p.y * 30.0 + iTime) < 0.3) col *= 0.8;
            if (fract(p.x * 40.0 - p.y * 40.0 - iTime) < 0.3) col *= 0.9;
        } else if (borderDist <= 0.0) {
            if (abs(p.y - 0.7) < 0.04 && abs(p.x) < 0.3) {
                if (fract(p.x * 10.0) < 0.7) col = vec3(0.8, 0.2, 0.15); 
            }
            
            if (p.y > 0.35 && p.y < 0.45 && abs(p.x) < 0.4) {
                float stampX = fract((p.x + 0.4 + iTime*0.05) * 1.25 * 3.0); 
                if (stampX < 0.5 && p.y > 0.35 && p.y < 0.43) {
                    float pulse = 1.0 + sin(iTime*10.0 + p.x*10.0)*0.1;
                    vec2 sP = vec2((stampX - 0.25)/pulse, (p.y - 0.39)/pulse);
                    
                    if (abs(sP.x) < 0.2 && abs(sP.y) < 0.03) {
                        col = vec3(0.8, 0.2, 0.15);
                        if (fract(sP.x * 40.0 + sP.y * 40.0) < 0.2) col = vec3(0.98, 0.96, 0.9);
                    }
                }
            }
            
            if (abs(p.y - 0.25) < 0.02 && abs(p.x) < 0.4) {
                float draw = smoothstep(-0.4, 0.4, sin(iTime*2.0 + p.x));
                if (draw > 0.5) col = vec3(0.2, 0.2, 0.4); 
            }
        }
    }
}

void layer_BottomCertificate(in vec2 p, in float iTime, inout vec3 col) {
    if (p.y < -0.1 && p.y > -0.9 && abs(p.x) < 0.8) {
        float borderDist = max(abs(p.x) - 0.75, abs(p.y + 0.5) - 0.35);
        if (borderDist > 0.0 && borderDist < 0.05) {
            col = vec3(0.2, 0.6, 0.3); 
            if (sin(p.x * 40.0 + iTime*2.0) * cos(p.y * 40.0 + iTime) > 0.0) col = vec3(0.1, 0.5, 0.2);
            
        } else if (borderDist <= 0.0) {
            if (abs(p.x - 0.5) < 0.08 && abs(p.y + 0.4) < 0.1) {
                col = vec3(0.8, 0.6, 0.5); 
                if (p.y > -0.35) col = vec3(0.2); 
                if (p.y < -0.45) col = vec3(0.4, 0.5, 0.8); 
            }
            
            if (abs(p.y + 0.3) < 0.02 && abs(p.x) < 0.4) {
                if (fract(p.x * 12.0) < 0.5) col = vec3(0.1); 
            }
            
            if (p.y > -0.8 && p.y < -0.7 && abs(p.x) < 0.6) {
                float sigNoise = sin(p.x * 40.0 + iTime*5.0) * 0.02;
                if (abs(p.y + 0.75 - sigNoise) < 0.005) col = vec3(0.1); 
            }
        }
    }
}

vec4 layer_Background(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_Background(p, col);


  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

vec4 layer_TopCertificate(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_TopCertificate(p, iTime, col);


  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

vec4 layer_BottomCertificate(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_BottomCertificate(p, iTime, col);


  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

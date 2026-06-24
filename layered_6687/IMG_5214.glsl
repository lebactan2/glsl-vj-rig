void layer_Background(in vec2 p, in vec3 lightDir, in vec2 vp, inout vec3 col) {
    col = vec3(0.5, 0.52, 0.55);
    col *= 0.8 + 0.2 * smoothstep(0.0, 1.0, dot(vec3(p, 0.0), lightDir));
    
    float shadow = length(vec2(vp.x - 0.7 - lightDir.x*0.2, vp.y * 1.5 - lightDir.y*0.1)) - 0.4;
    if (shadow < 0.0) {
        col = mix(col, vec3(0.1), 0.7 * smoothstep(0.0, -0.2, shadow));
    }
}

void layer_Vase(in vec2 vp, in vec3 lightDir, inout vec3 col) {
    float radius = 0.0;
    if (vp.x > -0.8 && vp.x < 0.7) {
        if (vp.x < -0.6) {
            radius = mix(0.15, 0.08, (vp.x + 0.8) / 0.2);
        } else if (vp.x < -0.1) {
            radius = 0.08;
        } else if (vp.x < 0.4) {
            float t = (vp.x + 0.1) / 0.5 * 3.14159;
            radius = 0.08 + 0.2 * sin(t);
        } else {
            radius = mix(0.15, 0.2, (vp.x - 0.4) / 0.3);
            if (fract((vp.x - 0.4) * 20.0) < 0.2) radius += 0.02; 
        }
    }
    float vaseBody = abs(vp.y) - radius;
    
    float decor = 1.0;
    for(float i=0.0; i<6.0; i++) {
        vec2 gp = vec2(-0.2 + i*0.03, 0.0 + sin(i)*0.05);
        decor = min(decor, length(vp - gp) - 0.03);
        gp = vec2(-0.15 + i*0.02, 0.05 + cos(i)*0.06);
        decor = min(decor, length(vp - gp) - 0.03);
    }
    
    vec2 lp1 = vp - vec2(-0.05, 0.15);
    float leaf1 = length(lp1) - 0.15 + sin(atan(lp1.y, lp1.x) * 5.0) * 0.03;
    vec2 lp2 = vp - vec2(0.0, -0.15);
    float leaf2 = length(lp2) - 0.18 + sin(atan(lp2.y, lp2.x) * 7.0) * 0.04;
    decor = min(decor, min(leaf1, leaf2));
    
    float fullVase = vp.x > -0.8 && vp.x < 0.7 ? vaseBody : 1.0;
    
    if (min(fullVase, decor) < 0.0) {
        col = vec3(0.2, 0.15, 0.12);
        
        float ny = vp.y / max(0.01, radius);
        float nx = 0.05; 
        vec3 normal = normalize(vec3(nx, ny, 1.0 - ny*ny));
        
        float diff = max(0.0, dot(normal, lightDir));
        float spec = pow(max(0.0, dot(reflect(-lightDir, normal), vec3(0.0, 0.0, 1.0))), 32.0);
        
        col *= 0.3 + 0.7 * diff;
        col += vec3(0.8, 0.7, 0.5) * spec * 0.5;
        
        if (decor < 0.0 && fullVase > 0.0) {
            col *= 1.2;
            col -= vec3(0.1) * smoothstep(-0.02, 0.0, decor);
        }
        
        if (vp.x > -0.8 && vp.x < -0.75 && fullVase < 0.0) {
            float inner = length(vec2((vp.x + 0.8)*4.0, vp.y)) - 0.12;
            if (inner < 0.0) col = vec3(0.02);
        }
    }
}

vec4 layer_Background(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 lightPos = vec3(sin(iTime)*2.0 - 1.0, 1.0, 1.0 + cos(iTime));
    vec3 lightDir = normalize(lightPos);
    
    vec3 col = vec3(-1.0);
    
    float y_offset = p.y > 0.0 ? 0.4 : -0.4;
    vec2 vp = p - vec2(0.0, y_offset);
    
    layer_Background(p, lightDir, vp, col);


  return vec4(clamp(col,0.0,1.0), step(0.0, max(col.r, max(col.g, col.b))));
}

vec4 layer_Vase(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 lightPos = vec3(sin(iTime)*2.0 - 1.0, 1.0, 1.0 + cos(iTime));
    vec3 lightDir = normalize(lightPos);
    
    vec3 col = vec3(-1.0);
    
    float y_offset = p.y > 0.0 ? 0.4 : -0.4;
    vec2 vp = p - vec2(0.0, y_offset);
    
    layer_Vase(vp, lightDir, col);


  return vec4(clamp(col,0.0,1.0), step(0.0, max(col.r, max(col.g, col.b))));
}

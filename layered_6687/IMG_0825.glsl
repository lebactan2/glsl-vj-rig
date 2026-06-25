void layer_Background(in vec2 p, inout vec3 col) {
    col = vec3(0.5, 0.5, 0.5);
    
    if (p.x > 0.2) {
        col = vec3(0.7, 0.7, 0.65);
        if (fract(p.x * 5.0) < 0.05 || fract(p.y * 5.0) < 0.05) col *= 0.8;
    } else {
        col = vec3(0.4, 0.45, 0.45);
        if (p.y > 0.2) col = vec3(0.6, 0.6, 0.6);
        if (p.x < 0.0 && p.y > 0.2 && p.y < 0.3) col = vec3(0.2, 0.5, 0.3);
    }
}

void layer_PersonPants(in vec2 personP, in float iTime, inout vec3 col) {
    if (personP.y > -0.7 && personP.y < -0.1 && abs(personP.x) < 0.15) {
        col = vec3(0.4, 0.1, 0.5);
        
        vec2 pantUV = personP * 15.0;
        pantUV.y += iTime * 0.5;
        float pantPattern = fract(sin(dot(floor(pantUV), vec2(12.9898, 78.233))) * 43758.5453);
        if (pantPattern > 0.7) col = vec3(0.9);
        else if (pantPattern > 0.5) col = vec3(0.8, 0.2, 0.3);
    }
}

void layer_PersonShirt(in vec2 personP, inout vec3 col) {
    if (personP.y > -0.1 && personP.y < 0.4 && abs(personP.x) < 0.2) {
        col = vec3(0.8, 0.4, 0.1);
        
        if (fract(personP.x * 20.0) < 0.2) col = vec3(0.5, 0.2, 0.1);
        if (fract(personP.y * 20.0) < 0.2) col = vec3(0.5, 0.2, 0.1);
        
        if (abs(personP.y - 0.1) < 0.05 || abs(personP.y - 0.3) < 0.05) {
            col = vec3(0.9, 0.9, 0.1);
        }
    }
}

void layer_PersonHead(in vec2 personP, inout vec3 col) {
    if (length(personP - vec2(0.0, 0.5)) < 0.12) {
        col = vec3(0.9, 0.7, 0.5);
    }
    if (length(personP - vec2(0.0, 0.55)) < 0.13 && personP.y > 0.5) {
        col = vec3(0.95, 0.85, 0.1);
    }
}

void layer_Motorcycle(in vec2 p, inout vec3 col) {
    if (length(p - vec2(-0.5, -0.4)) < 0.3) {
        col = vec3(0.15);
    }
    if (length(p - vec2(-0.3, -0.2)) < 0.15) {
        col = vec3(0.8);
    }
}

void layer_GreenBasket(in vec2 p, inout vec3 col) {
    if (length(p - vec2(0.4, -0.6)) < 0.1) {
        col = vec3(0.4, 0.8, 0.5);
    }
}

vec4 layer_Background(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;
    
    vec3 col = vec3(-1.0);
    
    layer_Background(p, col);
    
    vec2 personP = p - vec2(0.0, -0.1);
    
    
    

  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

vec4 layer_PersonPants(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;
    
    vec3 col = vec3(-1.0);
    
    
    vec2 personP = p - vec2(0.0, -0.1);
    
    layer_PersonPants(personP, iTime, col);
    
    

  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

vec4 layer_PersonShirt(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;
    
    vec3 col = vec3(-1.0);
    
    
    vec2 personP = p - vec2(0.0, -0.1);
    
    layer_PersonShirt(personP, col);
    
    

  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

vec4 layer_PersonHead(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;
    
    vec3 col = vec3(-1.0);
    
    
    vec2 personP = p - vec2(0.0, -0.1);
    
    layer_PersonHead(personP, col);
    
    

  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

vec4 layer_Motorcycle(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;
    
    vec3 col = vec3(-1.0);
    
    
    vec2 personP = p - vec2(0.0, -0.1);
    
    
    layer_Motorcycle(p, col);
    

  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

vec4 layer_GreenBasket(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;
    
    vec3 col = vec3(-1.0);
    
    
    vec2 personP = p - vec2(0.0, -0.1);
    
    
    layer_GreenBasket(p, col);
    

  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

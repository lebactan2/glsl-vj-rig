void layer_Poster(in vec2 p, inout vec3 col) {
    col = vec3(0.1, 0.1, 0.15); 
    
    if (p.x < 0.0 && p.y > -0.4 && p.y < 0.4) {
        col = mix(col, vec3(0.6, 0.1, 0.1), smoothstep(0.4, 0.0, abs(p.y)));
    }

    if (p.x > 0.0 && p.x < 0.3 && p.y > -0.2 && p.y < 0.4) {
        float textLines = step(0.5, fract(p.y * 20.0));
        col = mix(col, vec3(0.8), textLines * 0.5);
    }
}

void layer_Street(in vec2 p, inout vec3 col) {
    if (p.y < -0.4) {
        col = vec3(0.5, 0.5, 0.45); 
        float gravel = fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
        col -= gravel * 0.1;
    }
}

void layer_Scooter(in vec2 p, in float iTime, inout vec3 col) {
    if (p.x > 0.0 && p.y < -0.2) {
        if (p.y > -0.6 && p.y < -0.3 && p.x > 0.2 && p.x < 0.8) {
            col = vec3(0.7, 0.1, 0.1); 
            float shine = smoothstep(0.4, 0.5, sin(p.x * 10.0 + p.y * 10.0 + iTime * 3.0));
            col += shine * 0.2;
        }
    }
}

void layer_Rider(in vec2 p, in float iTime, inout vec3 col) {
    if (p.x > 0.0 && p.y < -0.2) {
        if (p.x > 0.3 && p.x < 0.6 && p.y > -0.3 && p.y < 0.2) {
            col = vec3(0.4, 0.4, 0.42); 
            float folds = sin(p.x * 15.0 - p.y * 10.0 + iTime) * 0.05;
            col += folds;
            
            if (p.y > 0.0 && length(p - vec2(0.45, 0.1)) < 0.1) {
                col = vec3(0.9);
            }
            if (p.y > 0.0 && p.y < 0.1 && p.x > 0.45 && p.x < 0.55) {
                col = vec3(0.6, 0.8, 1.0);
            }
        }
    }
}

vec4 layer_Poster(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_Poster(p, col);


  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

vec4 layer_Street(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_Street(p, col);


  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

vec4 layer_Scooter(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_Scooter(p, iTime, col);


  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

vec4 layer_Rider(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_Rider(p, iTime, col);


  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

void layer_Floor(in vec2 p, inout vec3 col) {
    col = vec3(0.4, 0.4, 0.42); 
    float floorTex = fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
    col -= floorTex * 0.1;
}

void layer_Chair(in vec2 p, in float iTime, inout vec3 col) {
    if (p.y > -0.6) {
        col = vec3(0.3, 0.5, 0.9); 
        
        float lighting = sin(p.x * 2.0 + p.y * 1.5) * 0.15;
        col += lighting;
        
        float shine = smoothstep(0.4, 0.5, sin(p.x * 8.0 - p.y * 8.0 + iTime * 2.0));
        col += shine * 0.1;

        vec2 center = vec2(0.0, 0.2);
        vec2 fp = p - center;
        
        fp = mod(fp, 0.6) - 0.3;
        
        float r = length(fp);
        float a = atan(fp.y, fp.x);
        
        float petals = sin(a * 10.0 + iTime * 0.5) * 0.05 + 0.1;
        if (r < petals) {
            col = vec3(0.35, 0.35, 0.37); 
        }
        
        float lines = abs(r - petals);
        if (lines < 0.01) {
            col *= 0.7; 
        }
    }
}

void layer_ChairLeg(in vec2 p, inout vec3 col) {
    if (p.y < -0.6 && p.x > 0.4 && p.x < 0.6) {
        col = vec3(0.2, 0.4, 0.8);
        col -= abs(p.x - 0.5) * 2.0; 
    }
}

vec4 layer_Floor(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_Floor(p, col);


  return vec4(clamp(col,0.0,1.0), step(0.0, max(col.r, max(col.g, col.b))));
}

vec4 layer_Chair(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_Chair(p, iTime, col);


  return vec4(clamp(col,0.0,1.0), step(0.0, max(col.r, max(col.g, col.b))));
}

vec4 layer_ChairLeg(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_ChairLeg(p, col);


  return vec4(clamp(col,0.0,1.0), step(0.0, max(col.r, max(col.g, col.b))));
}

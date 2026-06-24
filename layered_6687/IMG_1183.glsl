void layer_RollerDoor(in vec2 p, inout vec3 col) {
    col = vec3(0.85, 0.85, 0.8); 
    
    float grooves = fract(p.x * 20.0);
    if (grooves < 0.2) col *= 0.7; 
    if (grooves > 0.8) col *= 1.1; 
    
    float dirt = fract(sin(p.x * 50.0 + p.y * 30.0) * 43758.5);
    col *= mix(0.9, 1.0, dirt);
}

void layer_Posters(in vec2 p, in float iTime, inout vec3 col) {
    if (p.x > -0.6 && p.x < -0.2 && p.y > 0.0 && p.y < 0.6) {
        col = vec3(0.95); 
        float textY = fract(p.y * 10.0);
        if (textY > 0.2 && textY < 0.8 && p.x > -0.55 && p.x < -0.25) {
            float textX = fract(p.x * 20.0);
            if (textX > 0.2 && textX < 0.8) col = vec3(0.1); 
        }
        float tear = sin(p.y * 50.0) * 0.02;
        if (p.x < -0.6 + tear || p.x > -0.2 - tear) col = vec3(0.85, 0.85, 0.8); 
    }
    
    if (p.x > -0.1 && p.x < 0.3 && p.y > -0.3 && p.y < 0.2) {
        col = vec3(0.95);
        float textY = fract(p.y * 8.0);
        if (textY > 0.2 && textY < 0.8 && p.x > -0.05 && p.x < 0.25) {
            float textX = fract(p.x * 15.0);
            if (textX > 0.2 && textX < 0.8) col = vec3(0.1);
        }
    }
    
    if (p.x > -0.7 && p.x < -0.3 && p.y > -0.8 && p.y < -0.2) {
        col = vec3(0.92);
        float textY = fract(p.y * 12.0);
        if (textY > 0.2 && textY < 0.8 && p.x > -0.65 && p.x < -0.35) {
            float textX = fract(p.x * 25.0);
            if (textX > 0.2 && textX < 0.8) col = vec3(0.15);
        }
        float flutter = sin(p.y * 10.0 + iTime * 2.0) * 0.05 + 0.95;
        col *= flutter;
    }
}

void layer_Scooter(in vec2 p, inout vec3 col) {
    if (p.x > 0.5 && p.y < -0.2) {
        float bodyDist = length(p - vec2(0.8, -0.6));
        if (bodyDist < 0.4) {
            col = vec3(0.15); 
            float shine = smoothstep(0.3, 0.4, sin(p.x * 10.0 + p.y * 10.0));
            col += shine * 0.2;
        }
        
        float handleDist = abs(p.y - (-p.x * 0.5 + 0.1));
        if (handleDist < 0.05 && p.x > 0.6 && p.x < 0.9 && p.y > -0.4 && p.y < -0.1) {
            col = vec3(0.1); 
            float grip = fract(p.x * 40.0);
            if (grip < 0.5) col *= 0.8;
        }
    }
}

vec4 layer_RollerDoor(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_RollerDoor(p, col);


  return vec4(clamp(col,0.0,1.0), step(0.0, max(col.r, max(col.g, col.b))));
}

vec4 layer_Posters(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_Posters(p, iTime, col);


  return vec4(clamp(col,0.0,1.0), step(0.0, max(col.r, max(col.g, col.b))));
}

vec4 layer_Scooter(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_Scooter(p, col);


  return vec4(clamp(col,0.0,1.0), step(0.0, max(col.r, max(col.g, col.b))));
}

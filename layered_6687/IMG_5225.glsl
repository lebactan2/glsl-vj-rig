void layer_ImageCenter(in vec2 p, in float iTime, inout vec3 col) {
    if (p.y > -0.5 && p.y < 0.4) {
        vec2 imgP = (p - vec2(0.0, -0.05)) / vec2(1.0, 0.45);
        col = vec3(0.6, 0.8, 0.9);
        
        if (imgP.y > 0.0) {
            float perspective = 1.0 - imgP.y * 0.5;
            float shift = sin(iTime * 0.5) * 0.1; 
            float gridX1 = sin((imgP.x * 30.0 + imgP.y * 20.0 + shift*20.0) / perspective);
            float gridX2 = sin((imgP.x * 30.0 - imgP.y * 20.0 - shift*20.0) / perspective);
            float gridY = sin((imgP.y * 40.0 + iTime) / perspective);
            
            if (abs(gridX1) < 0.1 || abs(gridX2) < 0.1 || abs(gridY) < 0.1) {
                col = vec3(1.0);
            }
        }
        
        float foliageNoise = sin(imgP.x * 20.0 + iTime) * sin(imgP.y * 30.0 - iTime) + sin(imgP.x * 50.0 + imgP.y * 40.0) * 0.5;
        if (imgP.y < 0.1 && (imgP.x > 0.0 || imgP.y < -0.3 + foliageNoise * 0.2)) {
            col = vec3(0.1, 0.3 + foliageNoise * 0.1, 0.1);
        }
        
        if (imgP.x > -1.0 && imgP.x < 0.1 && imgP.y < -0.4) {
            float personIdx = floor((imgP.x + 1.0) * 7.0);
            if (personIdx >= 0.0 && personIdx <= 7.0) {
                vec2 pp = vec2(fract((imgP.x + 1.0) * 7.0) - 0.5, imgP.y + 0.6);
                
                float bounce = abs(sin(iTime * 3.0 + personIdx * 1.5)) * 0.05;
                pp.y -= sin(personIdx * 12.3) * 0.1 + bounce;
                
                if (abs(pp.x) < 0.25 && pp.y < 0.2) {
                    col = vec3(0.8, 0.1, 0.1);
                    if (abs(pp.y) < 0.02) col = vec3(0.1);
                }
                if (length(pp - vec2(0.0, 0.3)) < 0.15) {
                    col = vec3(0.9, 0.7, 0.6);
                }
            }
        }
    }
}

void layer_TopArea(in vec2 p, in float iTime, inout vec3 col) {
    if (p.y > 0.4) {
        col = vec3(0.55, 0.6, 0.65);
        float textLines = abs(p.y - 0.7);
        if (textLines < 0.15 && abs(p.x) < 0.9) {
            float opacity = 0.7 + 0.3 * sin(iTime * 2.0);
            if (fract(p.x * 20.0) < 0.7 && fract(p.y * 15.0) < 0.5) col = mix(col, vec3(1.0), opacity);
        }
        if (length(p - vec2(-0.8, 0.9)) < 0.05) col = vec3(0.1);
    }
}

void layer_BottomArea(in vec2 p, in float iTime, inout vec3 col) {
    if (p.y < -0.5) {
        col = vec3(0.2, 0.25, 0.25);
        
        if (abs(p.x) < 0.4 && abs(p.y + 0.7) < 0.08) {
            col = vec3(1.0);
            if (abs(p.y + 0.7) < 0.01 && abs(p.x) < 0.3) col = vec3(0.8);
            
            float handleX = sin(iTime * 1.5) * 0.25;
            if (abs(p.y + 0.7) < 0.01 && p.x > -0.3 && p.x < handleX) col = vec3(0.9, 0.2, 0.5);
            
            if (length(p - vec2(handleX, -0.7)) < 0.04) {
                col = vec3(1.0, 0.6, 0.1);
                if (length(p - vec2(handleX, -0.7)) < 0.02 + sin(iTime*10.0)*0.005) col = vec3(0.9, 0.1, 0.2);
            }
        }
        
        if (abs(p.x + 0.2) < 0.6 && abs(p.y + 0.9) < 0.05) {
            float border = max(abs(p.x + 0.2) - 0.58, abs(p.y + 0.9) - 0.03);
            if (border < 0.0 && border > -0.01) col = vec3(0.5);
        }
    }
}

vec4 layer_ImageCenter(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_ImageCenter(p, iTime, col);


  return vec4(clamp(col,0.0,1.0), step(0.0, max(col.r, max(col.g, col.b))));
}

vec4 layer_TopArea(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_TopArea(p, iTime, col);


  return vec4(clamp(col,0.0,1.0), step(0.0, max(col.r, max(col.g, col.b))));
}

vec4 layer_BottomArea(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_BottomArea(p, iTime, col);


  return vec4(clamp(col,0.0,1.0), step(0.0, max(col.r, max(col.g, col.b))));
}

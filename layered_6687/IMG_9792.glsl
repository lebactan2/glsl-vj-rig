void layer_SkyTrees(in vec2 p, in float iTime, inout vec3 col) {
    if (p.y > 0.3) {
        col = vec3(0.6, 0.7, 0.8); 
        
        float treeNoise = fract(sin(p.x * 50.0 + p.y * 30.0 + iTime * 0.5) * 43758.5453);
        float dTree = length(vec2(p.x, max(0.0, p.y - 0.6))) + treeNoise * 0.1;
        if (dTree < 0.8 || p.y > 0.5 + sin(p.x * 10.0)*0.2) {
            col = vec3(0.2, 0.35, 0.2); 
            col += vec3(0.1, 0.1, 0.0) * treeNoise;
        }
    }
}

void layer_WallRoof(in vec2 p, inout vec3 col) {
    if (p.y > 0.1 && p.y <= 0.3) {
        col = vec3(0.6, 0.55, 0.5); 
        
        if (p.y > 0.2) {
            col = vec3(0.3, 0.3, 0.32); 
            if (fract(p.x * 20.0 + p.y * 10.0) < 0.2) col *= 0.8;
            if (fract(p.y * 15.0) < 0.1) col = vec3(0.2); 
        } else {
            if (fract(p.x * 15.0) < 0.05 || fract(p.y * 20.0) < 0.1) col *= 0.8;
        }
    }
}

void layer_Ground(in vec2 p, in float iTime, inout vec3 col) {
    if (p.y <= 0.1) {
        col = vec3(0.55, 0.5, 0.45); 
        float dirtNoise = fract(sin(p.x * 100.0 + p.y * 100.0 + iTime * 0.5) * 43758.5453);
        col *= 0.9 + 0.2 * dirtNoise;
    }
}

void layer_FlowersLamppost(in vec2 p, inout vec3 col) {
    if (p.x < -0.8 && p.y > -0.2 && p.y < 0.2) {
        float f = length(fract(p * 15.0) - 0.5);
        if (f < 0.3) col = vec3(0.8, 0.3, 0.6); 
    }
    if (abs(p.x - (-0.9)) < 0.02 && p.y > -0.1) col = vec3(0.1); 
}

void layer_RockCairn(in vec2 p, in float iTime, inout vec3 col) {
    float cairnWidth = 0.8 - p.y * 0.6;
    if (p.y > -0.6 && p.y < 0.8 && abs(p.x) < cairnWidth) {
        vec3 rockColBase = vec3(0.5, 0.5, 0.5);
        
        vec2 rp = p * vec2(8.0, 10.0);
        vec2 i_rp = floor(rp);
        vec2 f_rp = fract(rp);
        
        float minDist = 1.0;
        vec2 closestPoint = vec2(0.0);
        
        for (int y= -1; y <= 1; y++) {
            for (int x= -1; x <= 1; x++) {
                vec2 neighbor = vec2(float(x), float(y));
                vec2 pt = fract(sin(vec2(dot(i_rp + neighbor, vec2(127.1, 311.7)), dot(i_rp + neighbor, vec2(269.5, 183.3)))) * 43758.5453);
                pt = 0.5 + 0.5 * sin(iTime * 1.5 + 6.2831 * pt);
                vec2 diff = neighbor + pt - f_rp;
                float dist = length(diff);
                
                if (dist < minDist) {
                    minDist = dist;
                    closestPoint = pt;
                }
            }
        }
        
        vec3 rockCol = mix(vec3(0.4, 0.4, 0.4), vec3(0.6, 0.55, 0.5), closestPoint.x);
        rockCol = mix(rockCol, vec3(0.4, 0.45, 0.4), closestPoint.y);
        
        vec3 c = rockCol;
        c *= 1.0 - minDist * 1.5; 
        
        float edgeDist = abs(p.x) / cairnWidth;
        c *= 1.0 - pow(edgeDist, 3.0) * 0.6;
        
        if (p.y < -0.4) c *= smoothstep(-0.6, -0.4, p.y);
        col = c;
    }
}

void layer_Vignette(in vec2 p, inout vec3 col) {
    col *= 1.0 - 0.1 * length(p);
}

vec4 layer_SkyTrees(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_SkyTrees(p, iTime, col);


  return vec4(clamp(col,0.0,1.0), step(0.0, max(col.r, max(col.g, col.b))));
}

vec4 layer_WallRoof(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_WallRoof(p, col);


  return vec4(clamp(col,0.0,1.0), step(0.0, max(col.r, max(col.g, col.b))));
}

vec4 layer_Ground(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_Ground(p, iTime, col);


  return vec4(clamp(col,0.0,1.0), step(0.0, max(col.r, max(col.g, col.b))));
}

vec4 layer_FlowersLamppost(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_FlowersLamppost(p, col);


  return vec4(clamp(col,0.0,1.0), step(0.0, max(col.r, max(col.g, col.b))));
}

vec4 layer_RockCairn(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_RockCairn(p, iTime, col);


  return vec4(clamp(col,0.0,1.0), step(0.0, max(col.r, max(col.g, col.b))));
}

vec4 layer_Vignette(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_Vignette(p, col);


  return vec4(clamp(col,0.0,1.0), step(0.0, max(col.r, max(col.g, col.b))));
}

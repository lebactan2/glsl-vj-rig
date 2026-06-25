float hash(vec2 p) { return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453); }

vec4 layer_StoneBase(vec2 uv) {
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;
    float baseLine = -0.6;
    
    if (p.y < baseLine) {
        vec2 stUV = vec2(p.x * 4.0, (p.y - baseLine) * 4.0);
        float row = floor(stUV.y);
        if (mod(row, 2.0) == 0.0) stUV.x += 0.5; // Offset pattern
        
        vec2 id = floor(stUV);
        vec2 cell = fract(stUV);
        
        float val = hash(id);
        vec3 stone = mix(vec3(0.5, 0.52, 0.5), vec3(0.65, 0.65, 0.6), val);
        
        float tex = hash(stUV * 10.0);
        stone *= 0.9 + 0.2 * tex;
        
        float grout = smoothstep(0.0, 0.05, cell.x) * smoothstep(1.0, 0.95, cell.x) *
                      smoothstep(0.0, 0.05, cell.y) * smoothstep(1.0, 0.95, cell.y);
        
        vec3 col = mix(vec3(0.8), stone, grout);
        
        if (p.y > baseLine - 0.05) {
            col = vec3(0.9); // White ledge
        }
        return vec4(col, 1.0);
    }
    return vec4(0.0);
}

vec4 layer_BreezeBlocks(vec2 uv) {
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;
    float baseLine = -0.6;
    
    if (p.y >= baseLine) {
        float curve = p.x * p.x * 0.15;
        vec2 blockUV = vec2(p.x, p.y + curve);
        blockUV *= vec2(6.0, 12.0); // grid scale
        
        vec2 cell = fract(blockUV) - 0.5;
        vec2 q = abs(cell);
        
        float frameBorderX = 0.48;
        float frameBorderY = 0.48;
        float frameOuter = max(q.x - frameBorderX, q.y - frameBorderY);
        
        float holeBox = max(q.x - 0.35, q.y - 0.25);
        float holeDiag = (q.x + q.y) * 0.707 - 0.35; // diagonal cut
        float hole = max(holeBox, holeDiag);
        
        if (hole > 0.0 && frameOuter <= 0.0) {
            vec3 terra = vec3(0.7, 0.35, 0.25);
            float tex = hash(blockUV * 20.0);
            terra *= 0.9 + 0.2 * tex;
            
            if (hole < 0.05) {
                terra *= 0.5 + 0.5 * step(0.0, cell.y);
            }
            return vec4(terra, 1.0);
        } else if (frameOuter > 0.0) {
            return vec4(vec3(0.85), 1.0);
        }
    }
    return vec4(0.0);
}

vec4 layer_HolesBackground(vec2 uv) {
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;
    float baseLine = -0.6;
    
    if (p.y >= baseLine) {
        float curve = p.x * p.x * 0.15;
        vec2 blockUV = vec2(p.x, p.y + curve);
        blockUV *= vec2(6.0, 12.0); // grid scale
        
        vec2 cell = fract(blockUV) - 0.5;
        vec2 q = abs(cell);
        
        float frameBorderX = 0.48;
        float frameBorderY = 0.48;
        float frameOuter = max(q.x - frameBorderX, q.y - frameBorderY);
        
        float holeBox = max(q.x - 0.35, q.y - 0.25);
        float holeDiag = (q.x + q.y) * 0.707 - 0.35; // diagonal cut
        float hole = max(holeBox, holeDiag);
        
        if (!(hole > 0.0 && frameOuter <= 0.0) && !(frameOuter > 0.0)) {
            vec3 sky = mix(vec3(0.8, 0.9, 1.0), vec3(0.6, 0.6, 0.6), clamp(uv.y, 0.0, 1.0));
            float shadow = smoothstep(-0.1, 0.1, cell.y) * smoothstep(-0.3, 0.3, cell.x);
            sky *= 0.6 + 0.4 * shadow;
            return vec4(sky, 1.0);
        }
    }
    return vec4(0.0);
}

vec4 layer_WallLighting(vec2 uv) {
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;
    float baseLine = -0.6;
    
    if (p.y >= baseLine) {
        float a = abs(p.x) * 0.2;
        return vec4(0.0, 0.0, 0.0, a);
    }
    return vec4(0.0);
}

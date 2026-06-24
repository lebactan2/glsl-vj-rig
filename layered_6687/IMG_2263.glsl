void layer_Background(in vec2 p, in float iTime, inout vec3 col) {
    if (p.y > 0.5) {
        col = vec3(0.6, 0.7, 0.8); 
        float tree = sin(p.x*10.0)*0.1 + cos(p.x*20.0)*0.05 + 0.6;
        if (p.y < tree) col = vec3(0.2, 0.4, 0.2); 
    } else {
        col = vec3(0.2, 0.4, 0.2); 
        float leafAnim = sin(p.x * 20.0 + iTime*2.0) * cos(p.y * 15.0 + iTime);
        if (leafAnim > 0.5) col = vec3(0.3, 0.5, 0.2);
    }
}

void layer_Ground(in vec2 p, inout vec3 col) {
    if (p.y < -0.6) {
        col = vec3(0.4, 0.4, 0.4); 
    }
}

void layer_BluePillar(in vec2 p, inout vec3 col) {
    if (p.x > -0.8 && p.x < -0.4 && p.y > -0.8) {
        col = vec3(0.3, 0.65, 0.85); 
        
        vec2 tile = fract(p * vec2(8.0, 20.0));
        if (tile.x < 0.05 || tile.y < 0.05) col *= 0.8; 
        
        if (p.y > 0.6) {
            col = vec3(0.2, 0.7, 0.5); 
            if (fract((p.y - 0.6) * 15.0) < 0.4) col = vec3(0.1); 
        }
        
        if (p.x < -0.45 && p.y > -0.2 && p.y < 0.3) {
            col = vec3(0.95); 
            if (fract(p.y * 25.0) < 0.3 && abs(p.x + 0.62) < 0.14) col = vec3(0.1); 
        }
    }
}

void layer_BlueGateStructure(in vec2 p, in float iTime, inout vec3 col) {
    vec3 gateCol = vec3(0.3, 0.7, 0.85); 
    if (p.x > -0.4 && p.y > -0.8) {
        if (p.y < -0.45) {
            col = gateCol;
            if (abs(p.y + 0.45) < 0.02 || abs(p.y + 0.75) < 0.02) col *= 0.8;
            if (length(vec2(p.x, p.y + 0.78)) < 0.04) col = vec3(0.4); 
        } else {
            if (abs(p.y - 0.8 + (p.x+0.4)*0.2) < 0.02) col = gateCol; 
            if (abs(p.x + 0.38) < 0.02) col = gateCol; 
            if (abs(p.y + 0.45) < 0.02) col = gateCol; 
            
            vec2 gP = vec2(p.x + 0.4, p.y + 0.45); 
            
            if (gP.x > 0.0 && gP.y > 0.0 && gP.y < 1.25 - gP.x*0.2) {
                vec2 grid = fract(gP * 10.0);
                vec2 cell = floor(gP * 10.0);
                
                vec2 center = vec2(0.5);
                float dist = length(grid - center);
                
                if (abs(dist - 0.4) < 0.05) {
                    col = gateCol;
                    float shine = sin(cell.x*0.5 + cell.y*0.5 - iTime*3.0);
                    if (shine > 0.8) col = vec3(0.8, 0.9, 1.0);
                }
                
                if ((abs(grid.x - 0.5) < 0.02 && (grid.y < 0.1 || grid.y > 0.9)) ||
                    (abs(grid.y - 0.5) < 0.02 && (grid.x < 0.1 || grid.x > 0.9))) {
                    col = gateCol;
                }
            }
        }
    }
}

void layer_Fence(in vec2 p, inout vec3 col) {
    if (p.x < -0.8 && p.y > -0.5) {
        if (fract(p.x * 10.0) < 0.1) col = vec3(0.5, 0.5, 0.4);
        if (fract(p.x * 20.0 + p.y * 20.0) < 0.05 || fract(p.x * 20.0 - p.y * 20.0) < 0.05) col = vec3(0.4);
    }
}

vec4 layer_Background(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_Background(p, iTime, col);


  return vec4(clamp(col,0.0,1.0), step(0.0, max(col.r, max(col.g, col.b))));
}

vec4 layer_Ground(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_Ground(p, col);


  return vec4(clamp(col,0.0,1.0), step(0.0, max(col.r, max(col.g, col.b))));
}

vec4 layer_BluePillar(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_BluePillar(p, col);


  return vec4(clamp(col,0.0,1.0), step(0.0, max(col.r, max(col.g, col.b))));
}

vec4 layer_BlueGateStructure(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_BlueGateStructure(p, iTime, col);


  return vec4(clamp(col,0.0,1.0), step(0.0, max(col.r, max(col.g, col.b))));
}

vec4 layer_Fence(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_Fence(p, col);


  return vec4(clamp(col,0.0,1.0), step(0.0, max(col.r, max(col.g, col.b))));
}

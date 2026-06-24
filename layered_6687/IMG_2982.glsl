void layer_Background(in vec2 p, inout vec3 col) {
    col = vec3(0.1, 0.15, 0.15) * (1.0 - length(p)*0.3); 
}

void layer_ShrineStructure(in vec2 p, in vec3 lightPos, inout vec3 col) {
    vec3 glazeColor = vec3(0.65, 0.75, 0.75); 
    vec3 edgeColor = vec3(0.6, 0.45, 0.35); 
    
    if (abs(p.x) < 0.7 && p.y > -0.5 && p.y < 0.4) {
        col = glazeColor;
        
        col *= 0.8 + 0.2 * sin(p.x * 5.0 + p.y * 10.0);
        
        float roofCurve = 0.4 - pow(abs(p.x), 2.0) * 0.2;
        if (p.y > roofCurve) {
            col = vec3(0.1, 0.15, 0.15) * (1.0 - length(p)*0.3);
        } else if (p.y > roofCurve - 0.05) {
            col = edgeColor;
            if (fract(p.x * 20.0) < 0.2) col *= 0.8; 
        } else {
            
            if (abs(p.x) > 0.35 && abs(p.x) < 0.6) {
                vec2 latP = p * 15.0;
                vec2 grid = fract(latP);
                vec2 id = floor(latP);
                
                float d1 = abs(grid.x + grid.y - 1.0);
                float d2 = abs(grid.x - grid.y);
                float d3 = abs(grid.x - 0.5);
                float d4 = abs(grid.y - 0.5);
                
                if (min(min(d1, d2), min(d3, d4)) > 0.15) {
                    float shadow = clamp(dot(normalize(vec3(p, 0.0) - lightPos), vec3(0.0, 0.0, -1.0)), 0.0, 1.0);
                    col = vec3(0.05) + vec3(0.1, 0.15, 0.2) * shadow; 
                } else {
                    col = glazeColor * 0.9;
                    if (abs(p.x) > 0.58 || abs(p.x) < 0.37) col = glazeColor; 
                }
            }
            
            if (abs(p.x) < 0.25 && p.y < 0.1 && p.y > -0.3) {
                col = vec3(0.1, 0.1, 0.12);
                
                float innerLight = clamp(1.0 - length(p - lightPos.xy*0.2)*3.0, 0.0, 1.0);
                col += vec3(0.2, 0.25, 0.3) * innerLight;
                
                if (abs(p.x + 0.08) < 0.03 && p.y > -0.25 && p.y < -0.05) {
                    col = glazeColor * 0.6; 
                    if (p.y > -0.1) col *= 1.2; 
                }
                if (abs(p.x - 0.1) < 0.035 && p.y > -0.25 && p.y < -0.02) {
                    col = glazeColor * 0.65;
                    if (p.y > -0.08) col *= 1.2; 
                }
            }
            
            if (abs(p.x) < 0.35 && p.y > 0.05 && p.y < 0.2) {
                float archDist = length(vec2(p.x, p.y - 0.1));
                if (archDist < 0.3 && archDist > 0.2) {
                    col = glazeColor;
                    if (fract(atan(p.y - 0.1, p.x) * 5.0) < 0.3) col = edgeColor;
                }
            }
            
            if (p.y > -0.45 && p.y < -0.3) {
                vec2 railP = p * 10.0;
                if (fract(railP.x) > 0.8 || fract(railP.y) > 0.8) {
                    col = glazeColor * 0.8;
                } else {
                    if (abs(fract(railP.x)-0.4) + abs(fract(railP.y)-0.4) < 0.2) col = vec3(0.05); 
                }
            }
            
            float cracks = fract(sin(p.x * 50.0 + sin(p.y * 40.0)) * 43758.5);
            if (cracks < 0.05) col *= 0.8;
            
            if (abs(p.x) > 0.68 || p.y < -0.48) col = edgeColor;
            
            vec3 normal = vec3(0.0, 0.0, 1.0); 
            vec3 lDir = normalize(lightPos - vec3(p, 0.0));
            float diff = max(dot(normal, lDir), 0.0);
            col *= 0.5 + 0.5 * diff;
        }
    }
}

void layer_FloorShadow(in vec2 p, in vec3 lightPos, inout vec3 col) {
    if (p.y < -0.5) {
        float shadow = 1.0 - smoothstep(0.0, 0.3, abs(p.x - lightPos.x * 0.2));
        col *= clamp(shadow + (p.y + 0.8)*2.0, 0.2, 1.0);
    }
}

vec4 layer_Background(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    vec3 lightPos = vec3(sin(iTime)*1.5, cos(iTime)*0.5 + 0.5, 1.0);
    
    layer_Background(p, col);


  return vec4(clamp(col,0.0,1.0), step(0.0, max(col.r, max(col.g, col.b))));
}

vec4 layer_ShrineStructure(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    vec3 lightPos = vec3(sin(iTime)*1.5, cos(iTime)*0.5 + 0.5, 1.0);
    
    layer_ShrineStructure(p, lightPos, col);


  return vec4(clamp(col,0.0,1.0), step(0.0, max(col.r, max(col.g, col.b))));
}

vec4 layer_FloorShadow(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    vec3 lightPos = vec3(sin(iTime)*1.5, cos(iTime)*0.5 + 0.5, 1.0);
    
    layer_FloorShadow(p, lightPos, col);


  return vec4(clamp(col,0.0,1.0), step(0.0, max(col.r, max(col.g, col.b))));
}

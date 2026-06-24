void layer_GreenTiles(in vec2 floorUV, inout vec3 col, out bool inMiddle) {
    inMiddle = false;
    vec2 tileUV = fract(floorUV * 2.0);
    vec2 tileId = floor(floorUV * 2.0);
    
    float tileNoise = fract(sin(dot(tileId, vec2(12.9898, 78.233))) * 43758.5453);
    col = vec3(0.4, 0.45, 0.4) * (0.8 + 0.2 * tileNoise);
    
    if (tileUV.x > 0.3 && tileUV.x < 0.7 && tileUV.y > 0.3 && tileUV.y < 0.7) {
         if (fract(tileNoise * 100.0) < 0.5) {
             col = vec3(0.65, 0.65, 0.6) * (0.8 + 0.2 * tileNoise);
         }
    }
    
    if (tileUV.x < 0.05 || tileUV.y < 0.05) col *= 0.5;
    
    if (floorUV.x > -0.2 && floorUV.x < 0.2) {
        inMiddle = true;
    }
}

void layer_BumpyLine(in vec2 floorUV, in float iTime, inout vec3 col) {
    float pebbles = fract(sin(dot(floorUV * 100.0 + iTime*0.5, vec2(12.9898, 78.233))) * 43758.5453);
    vec3 pebbleCol = mix(vec3(0.2), vec3(0.8), pebbles);
    
    if (fract(floorUV.y * 4.0) < 0.05 || fract(floorUV.x * 20.0) < 0.05) pebbleCol *= 0.5;
    
    col = pebbleCol;
}

void layer_DistanceFade(in float py, inout vec3 col) {
    col *= smoothstep(0.3, -0.5, py);
}

void layer_StreetWall(inout vec3 col) {
    col = vec3(0.3);
}

vec4 layer_GreenTiles(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    if (p.y < 0.3) {
        vec2 floorUV = vec2(p.x / (0.4 - p.y), 1.0 / (0.4 - p.y));
        
        bool inMiddle;
        layer_GreenTiles(floorUV, col, inMiddle);
        
        if (inMiddle) {
        }
        
    } else {
    }


  return vec4(clamp(col,0.0,1.0), step(0.0, max(col.r, max(col.g, col.b))));
}

vec4 layer_BumpyLine(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    if (p.y < 0.3) {
        vec2 floorUV = vec2(p.x / (0.4 - p.y), 1.0 / (0.4 - p.y));
        
        bool inMiddle;
        
        if (inMiddle) {
            layer_BumpyLine(floorUV, iTime, col);
        }
        
    } else {
    }


  return vec4(clamp(col,0.0,1.0), step(0.0, max(col.r, max(col.g, col.b))));
}

vec4 layer_StreetWall(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    if (p.y < 0.3) {
        vec2 floorUV = vec2(p.x / (0.4 - p.y), 1.0 / (0.4 - p.y));
        
        bool inMiddle;
        
        if (inMiddle) {
        }
        
        layer_DistanceFade(p.y, col);
    } else {
    }


  return vec4(clamp(col,0.0,1.0), step(0.0, max(col.r, max(col.g, col.b))));
}

vec4 layer_DistanceFade(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    if (p.y < 0.3) {
        vec2 floorUV = vec2(p.x / (0.4 - p.y), 1.0 / (0.4 - p.y));
        
        bool inMiddle;
        
        if (inMiddle) {
        }
        
    } else {
        layer_StreetWall(col);
    }


  return vec4(clamp(col,0.0,1.0), step(0.0, max(col.r, max(col.g, col.b))));
}

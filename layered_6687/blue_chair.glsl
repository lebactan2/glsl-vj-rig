mat2 rot(float a) {
    float s = sin(a), c = cos(a);
    return mat2(c, -s, s, c);
}

// Smooth min for blending shapes
float smin( float a, float b, float k ) {
    float h = clamp( 0.5+0.5*(b-a)/k, 0.0, 1.0 );
    return mix( b, a, h ) - k*h*(1.0-h);
}

// Floral pattern SDF
float flower(vec2 p) {
    float a = atan(p.y, p.x);
    float r = length(p);
    
    // 12 Petals
    float petal = abs(sin(a * 6.0)); 
    float petalShape = r - (0.25 + 0.15 * petal);
    
    // Center
    float center = r - 0.15;
    
    return smin(petalShape, center, 0.05);
}

void layer_Background(in vec2 p, inout vec3 col, out float isChair) {
    col = vec3(0.1, 0.1, 0.12);
    isChair = 0.0;
}

void layer_Frame(in vec2 p, in vec2 q, in float width, inout vec3 col, out float innerCutout, inout float isChair) {
    float frame = length(max(q - vec2(width, 0.8), 0.0)) - 0.1;
    innerCutout = length(max(q - vec2(width - 0.15, 0.65), 0.0)) - 0.05;
    
    if (frame < 0.0) {
        isChair = 1.0;
        if (innerCutout > 0.0) {
            vec3 plasticCol = vec3(0.4, 0.65, 0.9);
            col = plasticCol;
            col += 0.2 * smoothstep(-0.05, 0.0, frame);
            col -= 0.2 * smoothstep(0.0, 0.05, innerCutout);
        }
    }
}

void layer_Mesh(in vec2 p, in float innerCutout, inout vec3 col, out float solidDesign) {
    solidDesign = 1.0;
    if (innerCutout <= 0.0) {
        vec2 meshP = p * 40.0;
        float hole = sin(meshP.x + meshP.y) * sin(meshP.x - meshP.y);
        
        float f1 = flower(p - vec2(0.0, 0.3));
        float f2 = flower((p - vec2(0.3, -0.2)) * rot(0.5));
        float f3 = flower((p - vec2(-0.3, -0.3)) * rot(-0.5));
        float flowers = min(min(f1, f2), f3);
        
        float stems = abs(p.x + sin(p.y * 3.0) * 0.05) - 0.02;
        float branch1 = abs((p.x - 0.15) + (p.y + 0.0)*0.8) - 0.015;
        float branch2 = abs((p.x + 0.15) - (p.y + 0.1)*0.8) - 0.015;
        stems = min(stems, min(branch1, branch2));
        stems = max(stems, p.y - 0.3);
        
        solidDesign = smin(flowers, stems, 0.05);
        
        if (solidDesign >= 0.0) {
            if (hole <= 0.2) {
                vec3 plasticCol = vec3(0.4, 0.65, 0.9);
                col = plasticCol * 0.8;
            }
        }
    }
}

void layer_FloralDesign(in vec2 p, in float innerCutout, in float solidDesign, inout vec3 col) {
    if (innerCutout <= 0.0 && solidDesign < 0.0) {
        vec3 plasticCol = vec3(0.4, 0.65, 0.9);
        col = plasticCol;
        float bump = smoothstep(-0.05, 0.0, solidDesign);
        col += vec3(0.15) * bump;
    }
}

void layer_Lighting(in vec2 p, in float isChair, inout vec3 col) {
    if (isChair > 0.5) {
        col *= 0.6 + 0.4 * smoothstep(-1.0, 1.0, p.y);
        col += 0.1 * pow(max(0.0, sin(p.x * 2.0 + p.y * 2.0)), 4.0);
    }
}

vec4 layer_Background(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;
    
    vec3 col = vec3(-1.0);
    float isChair = 0.0;
    float innerCutout = 1.0;
    float solidDesign = 1.0;
    
    vec2 q = abs(p);
    float width = 0.7 - p.y * 0.1;
    
    layer_Background(p, col, isChair);
    if (isChair > 0.5) {
    }
    

  return vec4(clamp(col,0.0,1.0), step(0.0, max(col.r, max(col.g, col.b))));
}

vec4 layer_Frame(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;
    
    vec3 col = vec3(-1.0);
    float isChair = 0.0;
    float innerCutout = 1.0;
    float solidDesign = 1.0;
    
    vec2 q = abs(p);
    float width = 0.7 - p.y * 0.1;
    
    layer_Frame(p, q, width, col, innerCutout, isChair);
    if (isChair > 0.5) {
    }
    

  return vec4(clamp(col,0.0,1.0), step(0.0, max(col.r, max(col.g, col.b))));
}

vec4 layer_Mesh(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;
    
    vec3 col = vec3(-1.0);
    float isChair = 0.0;
    float innerCutout = 1.0;
    float solidDesign = 1.0;
    
    vec2 q = abs(p);
    float width = 0.7 - p.y * 0.1;
    
    if (isChair > 0.5) {
        layer_Mesh(p, innerCutout, col, solidDesign);
    }
    

  return vec4(clamp(col,0.0,1.0), step(0.0, max(col.r, max(col.g, col.b))));
}

vec4 layer_FloralDesign(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;
    
    vec3 col = vec3(-1.0);
    float isChair = 0.0;
    float innerCutout = 1.0;
    float solidDesign = 1.0;
    
    vec2 q = abs(p);
    float width = 0.7 - p.y * 0.1;
    
    if (isChair > 0.5) {
        layer_FloralDesign(p, innerCutout, solidDesign, col);
    }
    

  return vec4(clamp(col,0.0,1.0), step(0.0, max(col.r, max(col.g, col.b))));
}

vec4 layer_Lighting(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;
    
    vec3 col = vec3(-1.0);
    float isChair = 0.0;
    float innerCutout = 1.0;
    float solidDesign = 1.0;
    
    vec2 q = abs(p);
    float width = 0.7 - p.y * 0.1;
    
    if (isChair > 0.5) {
        layer_Lighting(p, isChair, col);
    }
    

  return vec4(clamp(col,0.0,1.0), step(0.0, max(col.r, max(col.g, col.b))));
}

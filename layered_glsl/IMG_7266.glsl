/* @layer_metadata
{
  "title": "Shader: IMG_7266",
  "layers": [
    {
      "name": "Background",
      "keywords": ["background", "concrete", "noise"]
    },
    {
      "name": "Character Shape",
      "keywords": ["character", "shape", "fortune", "calligraphic"]
    },
    {
      "name": "Mosaic",
      "keywords": ["mosaic", "voronoi", "shards", "porcelain", "crackle", "shadow"]
    }
  ]
}
*/
#define segment(p, a, b) length(p - a - (b - a) * clamp(dot(p - a, b - a) / dot(b - a, b - a), 0.0, 1.0))

void layer_Background(in vec2 p, inout vec3 col) {
    float concreteNoise = fract(sin(dot(floor(p * 80.0), vec2(127.1, 311.7))) * 43758.5453);
    col = vec3(0.55, 0.55, 0.56) + concreteNoise * 0.06 - 0.03;
}

void layer_CharacterShape(in vec2 p, out float mask, out float charShape) {
    charShape = 1.0;
    
    charShape = min(charShape, segment(p, vec2(-0.4, 0.3), vec2(-0.5, -0.3)) - p.y * 0.02); 
    charShape = min(charShape, segment(p, vec2(-0.5, 0.1), vec2(-0.2, -0.1)) - 0.01);
    charShape = min(charShape, segment(p, vec2(-0.35, -0.1), vec2(-0.35, -0.4)) - 0.015);
    charShape = min(charShape, segment(p, vec2(-0.4, 0.1), vec2(-0.6, 0.0)) - 0.01);
    
    charShape = min(charShape, segment(p, vec2(-0.1, 0.3), vec2(0.4, 0.3)) - 0.01);
    charShape = min(charShape, segment(p, vec2(-0.1, 0.1), vec2(0.4, 0.1)) - 0.01);
    charShape = min(charShape, segment(p, vec2(-0.1, 0.3), vec2(-0.1, 0.1)) - 0.015);
    charShape = min(charShape, segment(p, vec2(0.4, 0.3), vec2(0.4, 0.1)) - 0.015);
    
    charShape = min(charShape, segment(p, vec2(-0.1, -0.1), vec2(0.4, -0.1)) - 0.01);
    charShape = min(charShape, segment(p, vec2(-0.1, -0.4), vec2(0.4, -0.4)) - 0.01);
    charShape = min(charShape, segment(p, vec2(-0.1, -0.1), vec2(-0.1, -0.4)) - 0.015);
    charShape = min(charShape, segment(p, vec2(0.4, -0.1), vec2(0.4, -0.4)) - 0.015);
    charShape = min(charShape, segment(p, vec2(0.15, -0.1), vec2(0.15, -0.4)) - 0.01);
    charShape = min(charShape, segment(p, vec2(-0.1, -0.25), vec2(0.4, -0.25)) - 0.01);

    mask = 1.0 - smoothstep(0.04, 0.06, charShape);
}

void layer_Mosaic(in vec2 p, in float mask, in float charShape, inout vec3 col) {
    if(mask > 0.0) {
        vec2 shardP = p * 20.0;
        vec2 g = floor(shardP);
        vec2 f = fract(shardP);
        float minDist = 1.0;
        vec2 minId = vec2(0.0);
        for(int y=-1; y<=1; y++) {
            for(int x=-1; x<=1; x++) {
                vec2 lattice = vec2(x, y);
                vec2 rand = fract(sin(vec2(dot(g+lattice, vec2(127.1,311.7)), dot(g+lattice, vec2(269.5,183.3)))) * 43758.5453);
                vec2 pt = lattice + rand - f;
                float d = length(pt);
                if(d < minDist) {
                    minDist = d;
                    minId = g + lattice;
                }
            }
        }
        
        float grout = smoothstep(0.05, 0.1, minDist);
        float bevel = smoothstep(0.1, 0.3, minDist);
        
        vec3 porcelainWhite = vec3(0.95);
        vec3 porcelainBlue = vec3(0.1, 0.25, 0.65);
        
        float shardColorRand = fract(sin(dot(minId, vec2(12.9898, 78.233))) * 43758.5453);
        vec3 tileColor = mix(porcelainWhite, porcelainBlue, step(0.6, shardColorRand));
        
        float crackle = fract(sin(dot(p*100.0, vec2(12.9, 78.2))) * 43758.0);
        if(crackle > 0.95) tileColor *= 0.9;
        
        tileColor *= 0.8 + 0.2 * bevel;
        
        tileColor = mix(vec3(0.7, 0.65, 0.6), tileColor, grout);
        
        vec3 lightDir = normalize(vec3(1.0, 1.0, 1.0));
        float spec = pow(max(0.0, dot(reflect(-lightDir, vec3(0.0, 0.0, 1.0)), vec3(0.0, 0.0, 1.0))), 32.0);
        tileColor += spec * 0.3 * bevel;
        
        col = mix(col, vec3(0.2), 0.6 * smoothstep(0.0, 0.05, charShape + 0.02)); 
        col = mix(col, tileColor, mask);
    }
}

void main() {
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(0.0);
    
    layer_Background(p, col);
    
    float mask, charShape;
    layer_CharacterShape(p, mask, charShape);
    
    layer_Mosaic(p, mask, charShape, col);

    gl_FragColor = vec4(col, 1.0);
}

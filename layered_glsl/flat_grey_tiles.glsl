/* @layer_metadata
{
  "title": "Flat Grey Stone Tiles",
  "layers": [
    {
      "name": "Stone Tiles",
      "keywords": ["stone", "tiles", "grey", "alternating", "bands", "texture", "noise"]
    },
    {
      "name": "Grout",
      "keywords": ["grout", "lines", "spacing"]
    },
    {
      "name": "Bevel",
      "keywords": ["bevel", "highlight", "shadow", "3D", "edge"]
    }
  ]
}
*/
float hash(vec2 p) { return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453); }
float noise(vec2 p) {
    vec2 i = floor(p); vec2 f = fract(p);
    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(mix(hash(i + vec2(0.0,0.0)), hash(i + vec2(1.0,0.0)), u.x),
               mix(hash(i + vec2(0.0,1.0)), hash(i + vec2(1.0,1.0)), u.x), u.y);
}

void layer_StoneTiles(in vec2 uv, in float row, in vec2 id, inout vec3 col) {
    float band = mod(floor(row / 2.0), 2.0);
    vec3 baseCol = band < 0.5 ? vec3(0.35, 0.38, 0.4) : vec3(0.55, 0.58, 0.6);
    
    float val = hash(id);
    baseCol *= 0.8 + 0.4 * val;
    
    float tex = noise(uv * 100.0) * 0.5 + noise(uv * 200.0) * 0.25;
    baseCol = mix(baseCol, vec3(0.2), tex * 0.3);
    
    col = baseCol;
}

void layer_Grout(in vec2 cell, inout vec3 col, out float grout) {
    float groutX = smoothstep(0.0, 0.03, cell.x) * smoothstep(1.0, 0.97, cell.x);
    float groutY = smoothstep(0.0, 0.08, cell.y) * smoothstep(1.0, 0.92, cell.y);
    grout = groutX * groutY;
    
    col = mix(vec3(0.7, 0.75, 0.75), col, grout);
}

void layer_Bevel(in vec2 cell, in float grout, inout vec3 col) {
    col += 0.1 * smoothstep(0.9, 0.95, cell.x) * grout;
    col -= 0.1 * smoothstep(0.05, 0.0, cell.x) * grout;
}

void main() {
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * vec2(8.0, 15.0);
    
    float row = floor(p.y);
    p.x += mod(row, 2.0) * 0.5;
    
    vec2 cell = fract(p);
    vec2 id = floor(p);
    
    vec3 col = vec3(0.0);
    float grout = 0.0;
    
    layer_StoneTiles(uv, row, id, col);
    layer_Grout(cell, col, grout);
    layer_Bevel(cell, grout, col);
    
    gl_FragColor = vec4(col, 1.0);
}

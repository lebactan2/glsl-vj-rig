/* @layer_metadata
{
  "title": "Glass Window with Paper Cutouts",
  "layers": [
    {
      "name": "Glass Background",
      "keywords": ["glass", "blocks", "blue", "grid", "grout"]
    },
    {
      "name": "Drop Shadows",
      "keywords": ["shadow", "depth", "paper"]
    },
    {
      "name": "Paper Cutouts",
      "keywords": ["paper", "cutouts", "clouds", "flowers", "birds", "swallows"]
    }
  ]
}
*/
float sdCircle(vec2 p, float r) { return length(p) - r; }
float sdBox(vec2 p, vec2 b) {
    vec2 d = abs(p) - b;
    return length(max(d, 0.0)) + min(max(d.x, d.y), 0.0);
}

mat2 rot(float a) {
    float s = sin(a), c = cos(a);
    return mat2(c, -s, s, c);
}

float sdCloud(vec2 p) {
    float d = sdCircle(p, 0.25);
    d = min(d, sdCircle(p - vec2(0.2, -0.1), 0.18));
    d = min(d, sdCircle(p - vec2(-0.25, -0.05), 0.2));
    d = min(d, sdCircle(p - vec2(0.15, 0.15), 0.15));
    d = min(d, sdCircle(p - vec2(-0.1, 0.15), 0.12));
    return d;
}

float sdFlower(vec2 p) {
    float a = atan(p.y, p.x);
    float r = length(p);
    float petals = 0.15 + 0.05 * sin(a * 5.0);
    return min(sdCircle(p, 0.05), r - petals);
}

float sdBird(vec2 p) {
    vec2 bp = p * rot(0.5);
    float body = length(vec2(bp.x, bp.y * 2.0)) - 0.15;
    
    vec2 w1p = p * rot(0.8) - vec2(0.1, 0.15);
    float w1 = sdBox(w1p, vec2(0.2, 0.03));
    
    vec2 w2p = p * rot(-0.2) - vec2(-0.15, 0.1);
    float w2 = sdBox(w2p, vec2(0.2, 0.03));
    
    vec2 tp = p - vec2(-0.2, -0.15);
    float tail = sdBox(tp * rot(0.5), vec2(0.1, 0.02));
    float tail2 = sdBox(tp * rot(1.0), vec2(0.1, 0.02));
    
    return min(min(min(min(body, w1), w2), tail), tail2);
}

float getShapes(vec2 p) {
    float d1 = sdCloud(p - vec2(-0.4, -0.6));
    float d2 = sdCloud(p - vec2(0.6, -0.5));
    
    float f1 = sdFlower((p - vec2(0.7, 0.3)) * rot(0.5));
    float f2 = sdFlower((p - vec2(0.9, 0.1)) * rot(-0.3));
    float f3 = sdFlower((p - vec2(-0.8, 0.2)) * rot(1.2));
    
    float b1 = sdBird((p - vec2(-0.5, 0.4)) * rot(0.2));
    float b2 = sdBird((p - vec2(-0.2, 0.7)) * rot(-0.5));
    float b3 = sdBird((p - vec2(0.8, 0.7)) * rot(-0.1));
    
    return min(min(min(min(min(min(min(d1, d2), f1), f2), f3), b1), b2), b3);
}

void layer_GlassBackground(in vec2 uv, inout vec3 col) {
    vec2 gridUV = uv * vec2(25.0, 15.0);
    vec2 cell = fract(gridUV);
    vec2 id = floor(gridUV);
    
    float groutX = smoothstep(0.05, 0.1, cell.x) * smoothstep(0.95, 0.9, cell.x);
    float groutY = smoothstep(0.05, 0.1, cell.y) * smoothstep(0.95, 0.9, cell.y);
    float grout = groutX * groutY;
    
    vec3 bgCol = mix(vec3(0.0, 0.3, 0.4), vec3(0.0, 0.6, 0.8), grout);
    
    float noise = fract(sin(dot(id, vec2(12.9898, 78.233))) * 43758.5453);
    bgCol *= 0.8 + 0.4 * noise;
    
    col = bgCol;
}

void layer_DropShadows(in vec2 p, inout vec3 col) {
    vec2 sp = p - vec2(0.02, -0.02);
    float shadows = getShapes(sp);
    col = mix(col * 0.3, col, smoothstep(0.0, 0.05, shadows));
}

void layer_PaperCutouts(in vec2 uv, in vec2 p, inout vec3 col) {
    float shapes = getShapes(p);
    
    vec3 paperCol = vec3(0.95, 0.98, 1.0);
    paperCol -= 0.05 * fract(sin(dot(uv, vec2(12.9898, 78.233))) * 43758.5453);
    
    col = mix(paperCol, col, smoothstep(0.0, 0.01, shapes));
}

void main() {
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;
    
    vec3 col = vec3(0.0);
    
    layer_GlassBackground(uv, col);
    layer_DropShadows(p, col);
    layer_PaperCutouts(uv, p, col);
    
    gl_FragColor = vec4(col, 1.0);
}

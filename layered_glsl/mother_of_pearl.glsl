/* @layer_metadata
{
  "title": "Mother of Pearl Art",
  "layers": [
    {
      "name": "Background",
      "keywords": ["blue", "chipped", "background"]
    },
    {
      "name": "Halo",
      "keywords": ["halo", "circle", "yellow", "gold"]
    },
    {
      "name": "Side Figures",
      "keywords": ["side", "figures", "fans", "hair", "buns", "faces"]
    },
    {
      "name": "Main Figure",
      "keywords": ["main", "figure", "body", "sleeves", "hands", "collar", "face", "headdress", "jewel"]
    },
    {
      "name": "Facial Features",
      "keywords": ["eyes", "mouth", "facial", "features"]
    }
  ]
}
*/
float hash(vec2 p) { return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453); }
vec2 hash2(vec2 p) { return fract(sin(vec2(dot(p,vec2(127.1,311.7)),dot(p,vec2(269.5,183.3))))*43758.5453); }

float voronoi(vec2 x) {
    vec2 n = floor(x); vec2 f = fract(x); float m = 8.0;
    for(int j=-1; j<=1; j++)
    for(int i=-1; i<=1; i++) {
        vec2 g = vec2(float(i),float(j));
        vec2 o = hash2(n + g);
        vec2 r = g - f + o;
        m = min(m, dot(r,r));
    }
    return sqrt(m);
}

float sdCircle(vec2 p, float r) { return length(p) - r; }
float sdEllipse(vec2 p, vec2 r) {
    float k0 = length(p/r); float k1 = length(p/(r*r));
    return k0*(k0-1.0)/k1;
}
float sdBox(vec2 p, vec2 b) {
    vec2 d = abs(p) - b; return length(max(d, 0.0)) + min(max(d.x, d.y), 0.0);
}
float sdFanTop(vec2 p, float flip) {
    vec2 cp = p - vec2(flip*0.6, 0.6);
    float d = length(cp) - 0.25;
    float angle = atan(cp.y, cp.x);
    d -= 0.03 * sin(angle * 14.0);
    return max(d, -(cp.y + 0.1));
}

vec4 layer(vec4 bg, float d, vec3 col) {
    float a = smoothstep(0.005, 0.0, d);
    float outline = smoothstep(0.02, 0.005, abs(d));
    vec3 finalCol = mix(col, vec3(0.0), outline);
    return mix(bg, vec4(finalCol, 1.0), a);
}

void layer_Background(in vec2 uv, inout vec4 col) {
    vec3 bgCol = vec3(0.12, 0.5, 0.7);
    float n1 = hash(uv*15.0);
    float n2 = hash(uv*25.0);
    if (n1 > 0.94 && n2 > 0.4) {
        bgCol = mix(bgCol, vec3(0.85, 0.9, 0.85), smoothstep(0.94, 0.95, n1));
    }
    col = vec4(bgCol, 1.0);
}

void layer_Halo(in vec2 p, in vec3 cYel, inout vec4 col) {
    col = layer(col, sdCircle(p - vec2(0.0, 0.3), 0.5), cYel);
}

void layer_SideFigures(in vec2 p, in vec3 shellWht, in vec3 cRed, in vec3 cSkin, inout vec4 col) {
    float dSideBody = min(sdEllipse(p - vec2(-0.7, -0.1), vec2(0.2, 0.5)), sdEllipse(p - vec2(0.7, -0.1), vec2(0.2, 0.5)));
    col = layer(col, max(dSideBody, -(p.y+0.6)), shellWht);
    
    float dFanTop = min(sdFanTop(p, 1.0), sdFanTop(p, -1.0));
    col = layer(col, dFanTop, shellWht);
    float dFanStem = min(sdBox(p - vec2(-0.6, 0.1), vec2(0.02, 0.4)), sdBox(p - vec2(0.6, 0.1), vec2(0.02, 0.4)));
    col = layer(col, dFanStem, cRed);
    float dFanBulb = min(sdCircle(p - vec2(-0.6, 0.4), 0.08), sdCircle(p - vec2(0.6, 0.4), 0.08));
    col = layer(col, dFanBulb, cRed);
    
    float dSideFace = min(sdCircle(p - vec2(-0.7, 0.25), 0.12), sdCircle(p - vec2(0.7, 0.25), 0.12));
    col = layer(col, dSideFace, cSkin);
    
    float dSideHair = min(sdCircle(p - vec2(-0.7, 0.3), 0.13), sdCircle(p - vec2(0.7, 0.3), 0.13));
    dSideHair = max(dSideHair, p.y - 0.32);
    col = layer(col, dSideHair, vec3(0.1));
    
    float dSideBun = min(sdCircle(p - vec2(-0.7, 0.45), 0.06), sdCircle(p - vec2(0.7, 0.45), 0.06));
    col = layer(col, dSideBun, vec3(0.1));
}

void layer_MainFigure(in vec2 p, in vec3 shellRed, in vec3 shellGrn, in vec3 shellWht, in vec3 cRed, in vec3 cYel, in vec3 cSkin, inout vec4 col) {
    col = layer(col, sdBox(p - vec2(0.0, -0.8), vec2(0.45, 0.05)), cRed);
    col = layer(col, sdBox(p - vec2(0.0, -0.7), vec2(0.5, 0.05)), cYel);
    
    float dBody = sdEllipse(p - vec2(0.0, -0.2), vec2(0.45, 0.5));
    dBody = max(dBody, -(p.y + 0.65));
    col = layer(col, dBody, shellRed);
    
    float dSleeves = min(sdEllipse(p - vec2(-0.4, -0.2), vec2(0.15, 0.4)), sdEllipse(p - vec2(0.4, -0.2), vec2(0.15, 0.4)));
    col = layer(col, max(dSleeves, -(p.y + 0.6)), shellGrn);
    
    col = layer(col, sdEllipse(p - vec2(0.0, -0.15), vec2(0.12, 0.2)), shellWht);
    col = layer(col, sdCircle(p - vec2(0.0, 0.0), 0.05), cYel);
    
    col = layer(col, sdEllipse(p - vec2(0.0, 0.15), vec2(0.3, 0.15)), shellGrn);
    col = layer(col, sdEllipse(p - vec2(0.0, 0.2), vec2(0.2, 0.1)), cRed);
    
    col = layer(col, sdCircle(p - vec2(0.0, 0.4), 0.16), cSkin);
    
    float dHeadDress = sdCircle(p - vec2(0.0, 0.58), 0.2);
    dHeadDress = max(dHeadDress, -(p.y - 0.5));
    col = layer(col, dHeadDress, shellGrn);
    col = layer(col, sdCircle(p - vec2(0.0, 0.7), 0.05), cRed);
    col = layer(col, sdCircle(p - vec2(-0.15, 0.65), 0.04), cYel);
    col = layer(col, sdCircle(p - vec2(0.15, 0.65), 0.04), cYel);
}

void layer_FacialFeatures(in vec2 p, inout vec4 col) {
    float eyes = min(sdCircle(p - vec2(-0.06, 0.42), 0.015), sdCircle(p - vec2(0.06, 0.42), 0.015));
    col.rgb = mix(col.rgb, vec3(0.1), smoothstep(0.01, 0.0, eyes));
    float mouth = sdEllipse(p - vec2(0.0, 0.32), vec2(0.03, 0.015));
    col.rgb = mix(col.rgb, vec3(0.8, 0.2, 0.2), smoothstep(0.01, 0.0, mouth));
    
    float eyesSide = min(
        min(sdCircle(p - vec2(-0.73, 0.27), 0.01), sdCircle(p - vec2(-0.67, 0.27), 0.01)),
        min(sdCircle(p - vec2(0.67, 0.27), 0.01), sdCircle(p - vec2(0.73, 0.27), 0.01))
    );
    col.rgb = mix(col.rgb, vec3(0.1), smoothstep(0.01, 0.0, eyesSide));
    float mouthSide = min(sdEllipse(p - vec2(-0.7, 0.18), vec2(0.02, 0.01)), sdEllipse(p - vec2(0.7, 0.18), vec2(0.02, 0.01)));
    col.rgb = mix(col.rgb, vec3(0.8, 0.2, 0.2), smoothstep(0.01, 0.0, mouthSide));
}

void main() {
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;
    p *= 1.1;
    
    vec4 col = vec4(0.0);
    layer_Background(uv, col);
    
    vec3 cYel = vec3(0.85, 0.85, 0.2);
    vec3 cRed = vec3(0.8, 0.15, 0.15);
    vec3 cGrn = vec3(0.2, 0.6, 0.4);
    vec3 cWht = vec3(0.9, 0.9, 0.85);
    vec3 cSkin = vec3(0.95, 0.8, 0.7);
    
    float v = voronoi(p * 20.0);
    vec3 irid = 0.5 + 0.5 * cos(v * 10.0 + p.xyx * 3.0 + vec3(0, 2, 4));
    
    vec3 shellWht = mix(cWht, irid, 0.5) * (0.8 + 0.3 * v);
    vec3 shellRed = mix(cRed, irid*cRed*2.0, 0.4) * (0.8 + 0.3 * v);
    vec3 shellGrn = mix(cGrn, irid*cGrn*2.0, 0.4) * (0.8 + 0.3 * v);
    
    float pattern = smoothstep(0.05, 0.0, abs(fract(v*2.5) - 0.5));
    shellRed = mix(shellRed, vec3(0.9, 0.8, 0.4), pattern * 0.4);

    layer_Halo(p, cYel, col);
    layer_SideFigures(p, shellWht, cRed, cSkin, col);
    layer_MainFigure(p, shellRed, shellGrn, shellWht, cRed, cYel, cSkin, col);
    layer_FacialFeatures(p, col);
    
    gl_FragColor = col;
}

/* @layer_metadata
{
  "title": "Pavement Stripe",
  "layers": [
    {
      "name": "Central Stripe",
      "keywords": ["stripe", "central", "speckle", "noise", "cement", "aggregate", "seams"]
    },
    {
      "name": "Pinwheel Paving",
      "keywords": ["pinwheel", "paving", "pattern", "brick", "green", "beige", "grout", "bevel", "stone"]
    },
    {
      "name": "Vignette",
      "keywords": ["vignette", "fade", "distance", "perspective"]
    }
  ]
}
*/
float hash(vec2 p) { return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453); }

void layer_CentralStripe(in vec2 pathUV, inout vec3 col, out bool inStripe) {
    inStripe = false;
    if (abs(pathUV.x + 0.2) < 0.15) {
        inStripe = true;
        vec3 stripeCol = vec3(0.5);
        float speckle = fract(sin(dot(pathUV * 500.0, vec2(12.98, 78.23))) * 43758.54);
        if (speckle > 0.75) stripeCol = vec3(0.9);
        else if (speckle < 0.2) stripeCol = vec3(0.15);
        else stripeCol = vec3(0.45);
        
        float seams = smoothstep(0.0, 0.05, abs(fract(pathUV.y * 3.0) - 0.5));
        stripeCol *= 0.5 + 0.5 * seams;
        
        col = stripeCol;
    }
}

void layer_PinwheelPaving(in vec2 tiledUV, in bool inStripe, inout vec3 col) {
    if (!inStripe) {
        vec2 id = floor(tiledUV);
        vec2 f = fract(tiledUV);
        
        int part = 0;
        if (f.x > 0.333 && f.x < 0.666 && f.y > 0.333 && f.y < 0.666) part = 0;
        else if (f.x < 0.666 && f.y < 0.333) part = 1;
        else if (f.x > 0.666 && f.y < 0.666) part = 2;
        else if (f.x > 0.333 && f.y > 0.666) part = 3;
        else if (f.x < 0.333 && f.y > 0.333) part = 4;
        
        vec3 brickCol;
        vec3 greenBrick = vec3(0.4, 0.52, 0.45);
        vec3 beigeSquare = vec3(0.7, 0.68, 0.62);
        
        if (part == 0) brickCol = beigeSquare;
        else brickCol = greenBrick;
        
        vec2 brickId;
        if (part == 0) brickId = id + vec2(0.5, 0.5);
        else if (part == 1) brickId = id + vec2(0.3, 0.1);
        else if (part == 2) brickId = id + vec2(0.8, 0.3);
        else if (part == 3) brickId = id + vec2(0.6, 0.8);
        else if (part == 4) brickId = id + vec2(0.1, 0.6);
        
        float n = hash(brickId);
        brickCol *= 0.85 + 0.3 * n;
        
        float tex = hash(tiledUV * 15.0);
        brickCol = mix(brickCol, vec3(0.2), tex * 0.15);
        
        float dEdge = 1.0;
        if (part == 0) dEdge = min(min(f.x - 0.333, 0.666 - f.x), min(f.y - 0.333, 0.666 - f.y));
        else if (part == 1) dEdge = min(min(f.x, 0.666 - f.x), min(f.y, 0.333 - f.y));
        else if (part == 2) dEdge = min(min(f.x - 0.666, 1.0 - f.x), min(f.y, 0.666 - f.y));
        else if (part == 3) dEdge = min(min(f.x - 0.333, 1.0 - f.x), min(f.y - 0.666, 1.0 - f.y));
        else if (part == 4) dEdge = min(min(f.x, 0.333 - f.x), min(f.y - 0.333, 1.0 - f.y));
        
        float grout = smoothstep(0.01, 0.03, dEdge);
        col = mix(vec3(0.3, 0.3, 0.3), brickCol, grout);
        
        col += 0.1 * smoothstep(0.02, 0.06, dEdge) * grout;
    }
}

void layer_Vignette(in vec2 st, inout vec3 col) {
    col *= smoothstep(0.0, 1.0, 1.5 - st.y);
}

void main() {
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv;
    
    vec2 st = p * 2.0 - 1.0;
    st.x *= iResolution.x / iResolution.y;
    vec2 pathUV = vec2(st.x / (abs(st.y - 1.2) + 0.1), 1.0 / (abs(st.y - 1.2) + 0.1));
    float angle = 0.2;
    mat2 rot = mat2(cos(angle), -sin(angle), sin(angle), cos(angle));
    vec2 tiledUV = rot * pathUV * 8.0;
    
    vec3 col = vec3(0.0);
    bool inStripe = false;
    
    layer_CentralStripe(pathUV, col, inStripe);
    layer_PinwheelPaving(tiledUV, inStripe, col);
    layer_Vignette(st, col);
    
    gl_FragColor = vec4(col, 1.0);
}

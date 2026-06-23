/* @layer_metadata
{
  "title": "Shader: IMG_4784",
  "layers": [
    {
      "name": "Background",
      "keywords": ["white", "background"]
    },
    {
      "name": "Blue Patterned Dress",
      "keywords": ["blue", "dress", "pattern", "shimmer"]
    },
    {
      "name": "Grey Suit",
      "keywords": ["grey", "suit", "shirt", "tie", "sitting"]
    },
    {
      "name": "Maroon Dress",
      "keywords": ["maroon", "dress", "wrinkles", "animation"]
    },
    {
      "name": "Black Floral Dress",
      "keywords": ["black", "floral", "dress", "pattern", "animation"]
    },
    {
      "name": "Black Formal Ao Dai",
      "keywords": ["black", "formal", "ao dai", "silver", "pattern", "shimmer"]
    }
  ]
}
*/
void layer_Background(inout vec3 col) {
    col = vec3(1.0); 
}

void layer_BluePatternedDress(in vec2 p, in float iTime, in float bob1, inout vec3 col) {
    vec2 p1 = p - vec2(-0.7, 0.1 + bob1);
    float dress1 = max(abs(p1.x) - 0.25, abs(p1.y) - 0.6);
    if (dress1 < 0.0) {
        col = vec3(0.1, 0.2, 0.6);
        float pat1 = fract(sin(p1.x*50.0 + p1.y*20.0 + iTime)*43758.5);
        if (pat1 > 0.8) col = vec3(0.3, 0.4, 0.8);
        col += vec3(0.2) * pow(abs(sin(p1.x*10.0 + p1.y*10.0 - iTime*3.0)), 5.0); 
        if (length(p1 - vec2(0.0, 0.6)) < 0.1) col = vec3(1.0);
    }
}

void layer_GreySuit(in vec2 p, in float bob2, inout vec3 col) {
    vec2 p2 = p - vec2(-0.1, -0.2 + bob2);
    float suit2 = max(abs(p2.x) - 0.2, abs(p2.y) - 0.3); 
    float leg2 = max(abs(p2.x + 0.1) - 0.1, abs(p2.y + 0.4) - 0.3); 
    if (min(suit2, leg2) < 0.0) {
        col = vec3(0.4, 0.45, 0.5);
        if (abs(p2.x) < 0.05 && p2.y > 0.0) col = vec3(1.0); 
        if (abs(p2.x) < 0.02 && p2.y > 0.0) col = vec3(0.8, 0.1, 0.1); 
        if (length(p2 - vec2(0.0, 0.35)) < 0.1) col = vec3(1.0);
    }
}

void layer_MaroonDress(in vec2 p, in float iTime, in float bob3, inout vec3 col) {
    vec2 p3 = p - vec2(0.3, -0.4 + bob3);
    float dress3 = max(abs(p3.x) - 0.15, abs(p3.y) - 0.5);
    if (dress3 < 0.0) {
        col = vec3(0.5, 0.1, 0.2); 
        if (fract(p3.y * 10.0 + sin(p3.x*20.0 + iTime*2.0)) < 0.1) col *= 0.8;
        if (length(p3 - vec2(0.0, 0.5)) < 0.08) col = vec3(1.0);
    }
}

void layer_BlackFloralDress(in vec2 p, in float iTime, in float bob4, inout vec3 col) {
    vec2 p4 = p - vec2(0.7, -0.1 + bob4);
    float dress4 = max(abs(p4.x) - 0.2, abs(p4.y) - 0.6);
    if (dress4 < 0.0) {
        col = vec3(0.1);
        float noise = fract(sin(p4.x*40.0 + iTime*0.5)*cos(p4.y*40.0 + iTime*0.5)*10.0);
        if (noise > 0.7) col = vec3(0.8, 0.2, 0.3); 
        else if (noise > 0.6) col = vec3(0.5, 0.5, 0.5); 
        if (length(p4 - vec2(0.0, 0.6)) < 0.08) col = vec3(1.0);
    }
}

void layer_BlackFormalAoDai(in vec2 p, in float iTime, in float bob5, inout vec3 col) {
    vec2 p5 = p - vec2(0.4, 0.6 + bob5);
    float dress5 = max(abs(p5.x) - 0.2, abs(p5.y) - 0.3);
    if (dress5 < 0.0) {
        col = vec3(0.05); 
        float pat5 = fract(p5.x*30.0 + sin(p5.y*30.0 + iTime));
        if (pat5 < 0.1 && p5.y < 0.0) col = vec3(0.8 + 0.2*sin(iTime*5.0));
        if (length(p5 - vec2(0.0, 0.35)) < 0.1) col = vec3(1.0);
    }
}

void main() {
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    float bob1 = sin(iTime * 1.5 + 0.0) * 0.05;
    float bob2 = sin(iTime * 1.2 + 1.0) * 0.05;
    float bob3 = sin(iTime * 1.8 + 2.0) * 0.05;
    float bob4 = sin(iTime * 1.4 + 3.0) * 0.05;
    float bob5 = sin(iTime * 1.6 + 4.0) * 0.05;
    
    vec3 col = vec3(0.0);
    
    layer_Background(col);
    layer_BluePatternedDress(p, iTime, bob1, col);
    layer_GreySuit(p, bob2, col);
    layer_MaroonDress(p, iTime, bob3, col);
    layer_BlackFloralDress(p, iTime, bob4, col);
    layer_BlackFormalAoDai(p, iTime, bob5, col);

    gl_FragColor = vec4(col, 1.0);
}

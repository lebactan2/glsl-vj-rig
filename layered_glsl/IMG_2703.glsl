/* @layer_metadata
{
  "title": "Shader: IMG_2703",
  "layers": [
    {
      "name": "Background",
      "keywords": ["white", "grid", "background"]
    },
    {
      "name": "Fibonacci Trend Lines",
      "keywords": ["fibonacci", "trend", "lines", "intersections", "animation"]
    },
    {
      "name": "Horizontal Price Levels",
      "keywords": ["horizontal", "price", "levels", "shifting"]
    },
    {
      "name": "Candlesticks",
      "keywords": ["candlesticks", "moving", "prices", "wicks", "body", "scrolling", "volatility"]
    },
    {
      "name": "Right Sidebar",
      "keywords": ["sidebar", "price", "axis", "ticks", "label"]
    }
  ]
}
*/
void layer_Background(in vec2 uv, inout vec3 col) {
    col = vec3(0.98); 
    if (fract(uv.x * 20.0) < 0.05 || fract(uv.y * 15.0) < 0.05) col = vec3(0.9);
}

void layer_FibonacciTrendLines(in vec2 p, in float iTime, inout vec3 col) {
    for (int i = 0; i < 40; i++) {
        float fi = float(i);
        vec2 p1 = vec2(sin(fi * 1.3 + iTime*0.1) * 2.0, cos(fi * 1.7 - iTime*0.05) * 2.0);
        vec2 p2 = vec2(sin(fi * 2.1 - iTime*0.15) * 2.0, cos(fi * 2.5 + iTime*0.2) * 2.0);
        
        vec2 pa = p - p1, ba = p2 - p1;
        float h = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0);
        float d = length(pa - ba * h);
        
        if (d < 0.003) {
            float type = fract(sin(fi * 11.2) * 43758.5);
            if (type < 0.3) col = vec3(0.8, 0.2, 0.2); 
            else if (type < 0.6) col = vec3(0.2, 0.6, 0.2); 
            else if (type < 0.85) col = vec3(0.2, 0.3, 0.8); 
            else col = vec3(0.5, 0.2, 0.5); 
        }
    }
}

void layer_HorizontalPriceLevels(in vec2 p, in float iTime, inout vec3 col) {
    for (int i = 0; i < 20; i++) {
        float fi = float(i);
        float ypos = sin(fi * 15.3 + iTime*0.1) * 0.8;
        if (abs(p.y - ypos) < 0.003) {
            col = vec3(0.3, 0.3, 0.4);
            if (fi < 3.0 && abs(p.y - ypos) < 0.005) col = vec3(0.1); 
        }
    }
}

void layer_Candlesticks(in vec2 p, in float iTime, inout vec3 col) {
    float xScaled = p.x * 5.0 + iTime; 
    
    float barX = floor(xScaled * 5.0) / 5.0;
    float nextBarX = floor((xScaled + 0.2) * 5.0) / 5.0;
    
    float openPrice = barX * 0.2 + sin(barX * 2.0)*0.2 + sin(barX * 5.0)*0.1;
    float closePrice = nextBarX * 0.2 + sin(nextBarX * 2.0)*0.2 + sin(nextBarX * 5.0)*0.1;
    
    float vol = 0.15 + 0.05 * sin(iTime*5.0 + barX);
    float highPrice = max(openPrice, closePrice) + abs(sin(barX * 30.0)) * vol;
    float lowPrice = min(openPrice, closePrice) - abs(sin(barX * 20.0)) * vol;
    
    if (abs(fract(xScaled * 5.0) - 0.5) < 0.05 && p.y > lowPrice && p.y < highPrice) {
        if (closePrice > openPrice) col = vec3(0.1, 0.6, 0.1); 
        else col = vec3(0.8, 0.1, 0.1); 
    }
    
    if (abs(fract(xScaled * 5.0) - 0.5) < 0.25 && p.y > min(openPrice, closePrice) && p.y < max(openPrice, closePrice)) {
        if (closePrice > openPrice) col = vec3(0.2, 0.8, 0.2); 
        else col = vec3(0.9, 0.2, 0.2); 
    }
}

void layer_RightSidebar(in vec2 p, in vec2 uv, in float iTime, inout vec3 col) {
    if (uv.x > 0.9) {
        col = vec3(0.95);
        if (fract(p.y * 10.0) < 0.05) col = vec3(0.5); 
        
        float curPrice = sin(iTime*0.5)*0.2 + 0.2; 
        if (abs(p.y - curPrice) < 0.05) {
            col = vec3(0.1); 
            if (fract(p.x * 50.0) < 0.5) col = vec3(0.9); 
        }
    }
}

void main() {
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(0.0);
    
    layer_Background(uv, col);
    layer_FibonacciTrendLines(p, iTime, col);
    layer_HorizontalPriceLevels(p, iTime, col);
    layer_Candlesticks(p, iTime, col);
    layer_RightSidebar(p, uv, iTime, col);

    gl_FragColor = vec4(col, 1.0);
}

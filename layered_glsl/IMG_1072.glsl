/* @layer_metadata
{
  "title": "Shader: IMG_1072",
  "layers": [
    {
      "name": "Background",
      "keywords": ["background", "street", "wall", "gate", "flowers", "yellow", "wind", "animation"]
    },
    {
      "name": "Cart",
      "keywords": ["cart", "blue", "shine", "animation"]
    },
    {
      "name": "Lottery Tickets",
      "keywords": ["lottery", "tickets", "white", "pink", "rectangles", "grid"]
    },
    {
      "name": "Woman",
      "keywords": ["woman", "green shirt", "black pants", "fabric", "wrinkles", "animation"]
    },
    {
      "name": "Man",
      "keywords": ["man", "dark shirt"]
    }
  ]
}
*/
void layer_Background(in vec2 p, in float iTime, inout vec3 col) {
    col = vec3(0.5, 0.5, 0.5); 
    if (p.y > 0.0) {
        col = vec3(0.4, 0.4, 0.35); 
        float flowers = length(vec2(p.x + 0.5, p.y - 0.6));
        if (flowers < 0.3) {
            vec3 fCol = vec3(0.8, 0.8, 0.1);
            float wind = sin(p.x * 20.0 + p.y * 20.0 + iTime) * 0.05;
            fCol += wind;
            col = mix(col, fCol, smoothstep(0.3, 0.2, flowers + wind));
        }
    }
}

void layer_Cart(in vec2 p, in float iTime, inout vec3 col) {
    if (p.y < -0.1 && p.y > -0.6 && p.x > -0.2 && p.x < 0.6) {
        col = vec3(0.2, 0.4, 0.8);
        float shine = smoothstep(0.4, 0.5, sin(p.x * 5.0 - p.y * 5.0 + iTime * 2.0));
        col += shine * 0.1;
    }
}

void layer_LotteryTickets(in vec2 p, inout vec3 col) {
    if (p.y < -0.2 && p.y > -0.5 && p.x > 0.0 && p.x < 0.5) {
        float grid = abs(fract(p.x * 8.0) - 0.5) * abs(fract(p.y * 8.0) - 0.5);
        if (grid < 0.1) {
            col = vec3(0.9, 0.8, 0.8);
        }
    }
}

void layer_Woman(in vec2 p, in float iTime, inout vec3 col) {
    if (p.x > -0.8 && p.x < -0.2 && p.y > -0.5 && p.y < 0.3) {
        col = vec3(0.1, 0.5, 0.2); 
        float wrinkles = sin(p.x * 30.0 + p.y * 10.0 + iTime * 0.5) * 0.05;
        col += wrinkles;
        
        if (p.y < -0.2) {
            col = vec3(0.1, 0.1, 0.1); 
        }
    }
}

void layer_Man(in vec2 p, inout vec3 col) {
    if (p.x > -0.1 && p.x < 0.3 && p.y > -0.1 && p.y < 0.5) {
        col = vec3(0.15, 0.15, 0.2); 
    }
}

void main() {
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(0.0);
    
    layer_Background(p, iTime, col);
    layer_Cart(p, iTime, col);
    layer_LotteryTickets(p, col);
    layer_Woman(p, iTime, col);
    layer_Man(p, col);

    gl_FragColor = vec4(col, 1.0);
}

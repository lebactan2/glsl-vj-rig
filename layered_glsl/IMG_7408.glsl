/* @layer_metadata
{
  "title": "Shader: IMG_7408",
  "layers": [
    {
      "name": "Background",
      "keywords": ["background", "fabric", "rolls"]
    },
    {
      "name": "Blue Shirt",
      "keywords": ["blue", "shirt", "wrinkles", "collar", "pockets"]
    },
    {
      "name": "White Shirt",
      "keywords": ["white", "shirt", "epaulettes", "collar", "pockets"]
    },
    {
      "name": "Star Badge",
      "keywords": ["star", "badge", "gold", "red"]
    }
  ]
}
*/
#define segment(p, a, b) length(p - a - (b - a) * clamp(dot(p - a, b - a) / dot(b - a, b - a), 0.0, 1.0))

void layer_Background(in vec2 p, inout vec3 col) {
    col = vec3(0.1, 0.25, 0.12);
    col += sin(p.x * 40.0) * sin(p.y * 40.0) * 0.02;
    
    if (p.y > 0.3 && abs(p.x) < 0.4) {
        float roll = sin(p.x * 50.0 + p.y * 30.0);
        col = mix(vec3(0.08, 0.08, 0.2), vec3(0.1, 0.1, 0.25), roll * 0.5 + 0.5);
    }
    if (p.y > 0.4 && p.x < -0.3) {
        float roll = sin(p.x * 35.0);
        col = mix(vec3(0.55, 0.5, 0.35), vec3(0.6, 0.55, 0.4), roll * 0.5 + 0.5);
    }
}

void layer_BlueShirt(in vec2 p, inout vec3 col) {
    vec2 bp = p - vec2(-0.3, -0.1);
    float blueBody = length(max(abs(vec2(bp.x, bp.y + 0.2)) - vec2(0.4, 0.4), 0.0)) - 0.1;
    float blueShoulders = length(vec2(bp.x, max(bp.y - 0.2, 0.0))) - 0.45;
    float bs = max(blueBody, blueShoulders);
    
    if (bs < 0.0) {
        vec3 bCol = vec3(0.55, 0.65, 0.85);
        float wrinkle = sin(bp.x * 20.0 + bp.y * 10.0 + sin(bp.y * 5.0) * 2.0) * 0.05;
        bCol += wrinkle;
        
        float collarL = segment(bp, vec2(0.0, 0.35), vec2(-0.15, 0.2));
        float collarR = segment(bp, vec2(0.0, 0.35), vec2(0.15, 0.2));
        if (min(collarL, collarR) < 0.05) {
            bCol = vec3(0.5, 0.6, 0.8);
            if (min(collarL, collarR) < 0.01) bCol *= 0.7; 
        }
        
        vec2 p1 = bp - vec2(-0.15, 0.05);
        float pkt = max(abs(p1.x) - 0.08, abs(p1.y) - 0.08);
        if (pkt < 0.0) {
            bCol *= 0.95; 
            if (abs(p1.y - 0.08) < 0.005) bCol *= 0.8; 
            if (length(p1 - vec2(0.0, 0.04)) < 0.01) bCol = vec3(0.3, 0.4, 0.6);
        }
        
        col = bCol;
    }
    else if (bs < 0.02) col *= 0.6;
}

void layer_WhiteShirt(in vec2 p, inout vec3 col) {
    vec2 wp = p - vec2(0.25, 0.0);
    float whiteBody = length(max(abs(vec2(wp.x, wp.y + 0.1)) - vec2(0.35, 0.45), 0.0)) - 0.1;
    float whiteShoulders = length(vec2(wp.x, max(wp.y - 0.3, 0.0))) - 0.4;
    float ws = max(whiteBody, whiteShoulders);
    
    if (ws < 0.0) {
        vec3 wCol = vec3(0.9, 0.92, 0.95);
        wCol *= 0.8 + 0.2 * smoothstep(0.3, 0.0, abs(wp.x));
        float wrinkle = sin(wp.x * 20.0 + wp.y * 15.0) * 0.03;
        wCol += wrinkle;
        
        for (float i = 0.0; i < 2.0; i++) {
            vec2 epPos = vec2(-0.25 + i * 0.5, 0.35);
            vec2 epLocal = wp - epPos;
            float epShape = max(abs(epLocal.x) - 0.08, abs(epLocal.y) - 0.03);
            if (epShape < 0.0) {
                wCol = vec3(0.1, 0.1, 0.15); 
                float stripe = fract((wp.x - epPos.x) * 20.0);
                if (stripe < 0.4) wCol = vec3(0.8, 0.7, 0.2);
                
                if (abs(epShape) < 0.005) wCol = vec3(0.8, 0.15, 0.1);
                
                if (length(epLocal - vec2(sign(i-0.5)*-0.05, 0.0)) < 0.015) {
                    wCol = vec3(0.8, 0.8, 0.85);
                }
            }
        }
        
        float wCollarL = segment(wp, vec2(0.0, 0.4), vec2(-0.15, 0.25));
        float wCollarR = segment(wp, vec2(0.0, 0.4), vec2(0.15, 0.25));
        if (min(wCollarL, wCollarR) < 0.06) {
            wCol = vec3(0.85);
            if (min(wCollarL, wCollarR) < 0.01) wCol *= 0.7;
        }
        
        for (float i = 0.0; i < 2.0; i++) {
            vec2 pktP = wp - vec2(-0.15 + i * 0.3, 0.05);
            float pkt = max(abs(pktP.x) - 0.07, abs(pktP.y) - 0.08);
            if (pkt < 0.0) {
                wCol *= 0.95;
                if (abs(pktP.y - 0.08) < 0.005) wCol *= 0.8; 
                if (length(pktP - vec2(0.0, 0.04)) < 0.01) wCol = vec3(0.8); 
            }
        }
        
        col = wCol;
    } else if (ws < 0.02) {
        col *= 0.6; 
    }
}

void layer_StarBadge(in vec2 p, inout vec3 col) {
    float blueBottom = max(abs(p.x - 0.5) - 0.35, abs(p.y + 0.6) - 0.25);
    if (blueBottom < 0.0) {
        col = mix(vec3(0.1, 0.2, 0.5), vec3(0.15, 0.25, 0.65), sin(p.x*20.0)*0.5+0.5);
        vec2 starP = p - vec2(0.35, -0.5);
        
        float a = atan(starP.x, starP.y) + 3.14159;
        float r = length(starP);
        float seg = a * 5.0 / 6.28318;
        float frac = fract(seg);
        float id = floor(seg);
        float ang = (id + 0.5) * 6.28318 / 5.0;
        vec2 pnt = vec2(sin(ang), cos(ang)) * 0.08;
        float starD = segment(starP, vec2(0.0), pnt);
        
        if (r < 0.06 && starD < 0.02 + r*0.2) {
            col = vec3(0.9, 0.7, 0.1); 
            if (r < 0.025) col = vec3(0.8, 0.1, 0.1); 
        }
    }
}

void main() {
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(0.0);
    
    layer_Background(p, col);
    layer_BlueShirt(p, col);
    layer_WhiteShirt(p, col);
    layer_StarBadge(p, col);

    gl_FragColor = vec4(col, 1.0);
}

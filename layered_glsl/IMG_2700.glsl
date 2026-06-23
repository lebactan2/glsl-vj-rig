/* @layer_metadata
{
  "title": "Shader: IMG_2700",
  "layers": [
    {
      "name": "Background",
      "keywords": ["night", "street", "tree", "lights", "glow", "animation", "background"]
    },
    {
      "name": "Trash Bin",
      "keywords": ["trash", "bin", "green"]
    },
    {
      "name": "Main Signboard",
      "keywords": ["signboard", "text", "neon", "pulse", "cursive", "oval"]
    },
    {
      "name": "Sign Frame Cart",
      "keywords": ["frame", "cart", "wheel", "bicycle", "spokes", "animation"]
    }
  ]
}
*/
void layer_Background(in vec2 p, in float iTime, inout vec3 col) {
    col = vec3(0.05); 
    
    if (p.y > 0.5 && p.x > -0.2) {
        float treeDist = abs(p.y - 0.8 + (p.x - 0.2)*0.5);
        if (treeDist < 0.15) {
            col = vec3(0.2, 0.15, 0.1); 
            col *= 1.0 + fract(sin(p.x * 20.0 + p.y * 30.0) * 10.0) * 0.2;
        }
    }
    
    if (p.x < -0.5) {
        float light1 = length(vec2(p.x + 0.8, p.y + 0.4));
        float flicker1 = 0.5 + 0.5 * sin(iTime * 10.0);
        if (light1 < 0.2) col += vec3(0.8, 0.8, 0.9) * (0.2 - light1) * 5.0 * flicker1; 
        
        float light2 = length(vec2(p.x + 0.9, p.y + 0.2));
        float flicker2 = 0.5 + 0.5 * sin(iTime * 8.0 + 1.0);
        if (light2 < 0.1) col += vec3(0.9, 0.9, 0.8) * (0.1 - light2) * 10.0 * flicker2;
    }
}

void layer_TrashBin(in vec2 p, inout vec3 col) {
    if (p.x > 0.2 && p.x < 0.8 && p.y > 0.5 && p.y < 0.9) {
        col = vec3(0.1, 0.4, 0.2); 
        if (p.y > 0.85) col = vec3(0.15, 0.5, 0.25); 
        if (fract(p.y * 15.0) < 0.1) col *= 0.8; 
    }
}

void layer_MainSignboard(in vec2 p, in float iTime, inout vec3 col) {
    if (p.x > -0.6 && p.x < 0.5 && p.y > -0.6 && p.y < 0.5) {
        col = vec3(0.9, 0.88, 0.75); 
        
        float edgeDist = max(abs(p.x + 0.05) * 1.8, abs(p.y) * 2.0);
        col *= 1.0 - smoothstep(0.8, 1.0, edgeDist) * 0.3;
        
        vec3 textColor = vec3(0.1, 0.5, 0.3); 
        
        if (p.x > -0.5 && p.x < -0.2 && p.y > -0.4 && p.y < 0.4) {
            vec2 letGrid = fract(vec2(p.x * 5.0, p.y * 5.0));
            if (letGrid.x > 0.2 && letGrid.x < 0.8 && letGrid.y > 0.2 && letGrid.y < 0.8) {
                if (sin(p.y * 20.0) * cos(p.x * 10.0) > 0.0) col = textColor;
            }
            if (abs(p.x + 0.35) < 0.1 && fract(p.y * 6.0) < 0.6) col = textColor;
            
            float pulse = 0.5 + 0.5 * sin(iTime*4.0 - p.y*10.0);
            if (col == textColor) col += vec3(0.1, 0.3, 0.1) * pulse;
        }
        
        vec2 ovalCenter = vec2(-0.05, 0.0);
        float ovalDist = length(vec2((p.x - ovalCenter.x) * 1.5, (p.y - ovalCenter.y) * 1.0)) - 0.35;
        
        if (abs(ovalDist) < 0.01) col = textColor;
        if (abs(ovalDist + 0.03) < 0.005) col = textColor;
        
        if (ovalDist < -0.05) {
            float cursive1 = sin((p.y + p.x) * 30.0 + iTime*2.0) * 0.05; 
            if (abs(p.x - ovalCenter.x + 0.1 - cursive1) < 0.02 && p.y > -0.2 && p.y < 0.2) col = textColor;
            
            float cursive2 = sin((p.y - p.x) * 25.0 - iTime*1.5) * 0.05;
            if (abs(p.x - ovalCenter.x - 0.1 - cursive2) < 0.02 && p.y > -0.15 && p.y < 0.25) col = textColor;
        }
        
        if (p.x > 0.2 && p.x < 0.45 && p.y > -0.4 && p.y < 0.4) {
            if (abs(p.x - 0.3) < 0.08 && fract(p.y * 5.0) < 0.7) col = textColor; 
            if (abs(p.x - 0.4) < 0.05 && fract(p.y * 15.0) < 0.5) col = textColor; 
            
            float pulse = 0.5 + 0.5 * sin(iTime*4.0 - p.y*10.0 + 3.14);
            if (col == textColor) col += vec3(0.1, 0.3, 0.1) * pulse;
        }
    }
}

void layer_SignFrameCart(in vec2 p, in float iTime, inout vec3 col) {
    if (p.x > -0.65 && p.x <= -0.6 && p.y > -0.6 && p.y < 0.5) col = vec3(0.4); 
    if (p.x >= 0.5 && p.x < 0.55 && p.y > -0.6 && p.y < 0.5) col = vec3(0.4); 
    
    if (p.x > 0.5 && p.y < 0.0) {
        col = vec3(0.15); 
        float wheelRadius = 0.15;
        vec2 wheelCenter = vec2(0.7, -0.4);
        float wDist = length(vec2(p.x - wheelCenter.x, p.y - wheelCenter.y));
        if (abs(wDist - wheelRadius) < 0.02) col = vec3(0.2); 
        if (wDist < wheelRadius) {
            float angle = atan(p.y - wheelCenter.y, p.x - wheelCenter.x);
            if (fract((angle + iTime) * 4.0) < 0.1) col = vec3(0.3);
        }
    }
}

void main() {
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(0.0);
    
    layer_Background(p, iTime, col);
    layer_TrashBin(p, col);
    layer_MainSignboard(p, iTime, col);
    layer_SignFrameCart(p, iTime, col);

    gl_FragColor = vec4(col, 1.0);
}

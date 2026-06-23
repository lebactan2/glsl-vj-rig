/* @layer_metadata
{
  "title": "Shader: IMG_6755",
  "layers": [
    {
      "name": "Background",
      "keywords": ["background", "noise", "light", "spots"]
    },
    {
      "name": "Shadow",
      "keywords": ["shadow", "pulsing", "arrow"]
    },
    {
      "name": "Cutout",
      "keywords": ["cutout", "figure", "arrow", "outline", "fill"]
    },
    {
      "name": "Vignette",
      "keywords": ["vignette"]
    }
  ]
}
*/
void layer_Background(in vec2 up_p, in float iTime, inout vec3 col) {
    if (up_p.y < 0.0) {
        col = vec3(0.35, 0.36, 0.38);
        col *= 0.9 + 0.1 * fract(sin(dot(up_p, vec2(12.9898, 78.233))) * 43758.5453);
        float lightSpot = exp(-length(up_p - vec2(0.5 + sin(iTime)*0.2, -0.5)) * 2.0);
        col += vec3(0.1, 0.1, 0.05) * lightSpot;
    } else {
        col = vec3(0.85, 0.85, 0.85);
        col *= 0.8 + 0.2 * (1.0 - up_p.y);
        
        if (abs(up_p.y - 0.6) < 0.02) col = vec3(0.6); 
        if (abs(up_p.y - 0.5) < 0.015) col = vec3(0.7, 0.2, 0.2); 
    }
}

void layer_Shadow(in vec2 up_p, in float iTime, inout vec3 col) {
    if (up_p.y < 0.0) {
        float skShadow = max(abs(up_p.x - up_p.y*0.5 + 0.2) - 0.2, abs(up_p.y + 0.5) - 0.4);
        if (skShadow < 0.0) col *= 0.7;
    }
}

void layer_Cutout(in vec2 up_p, in float iTime, inout vec3 col) {
    float pulse = sin(iTime * 5.0) * 0.02;
    float dCutout = 1.0;
    
    float base = length((up_p - vec2(0.0, -0.8)) * vec2(1.0, 3.0)) - 0.25;
    
    vec2 gp = up_p - vec2(0.0, -0.1);
    
    float dLegs = max(abs(gp.x) - 0.15, abs(gp.y + 0.35) - 0.35);
    float legGap = max(abs(gp.x) - 0.02, abs(gp.y + 0.5) - 0.2);
    dLegs = max(dLegs, -legGap);
    
    float dTorso = max(abs(gp.x) - 0.18, abs(gp.y - 0.2) - 0.2);
    
    vec2 apL = gp - vec2(-0.35, 0.3);
    float dArmL = max(abs(apL.x) - 0.2, abs(apL.y) - 0.06);
    float dGlove = length(apL - vec2(-0.25, 0.0)) - 0.08;
    
    vec2 apR = gp - vec2(0.2, 0.1);
    float dArmR = max(abs(apR.x) - 0.05, abs(apR.y) - 0.2);
    
    float dHead = length(gp - vec2(0.0, 0.55)) - 0.12;
    float dHat = max(abs(gp.x) - 0.14, abs(gp.y - 0.65) - 0.06);
    
    float dFigure = min(dLegs, dTorso);
    dFigure = min(dFigure, dArmL);
    dFigure = min(dFigure, dGlove);
    dFigure = min(dFigure, dArmR);
    dFigure = min(dFigure, dHead);
    dFigure = min(dFigure, dHat);
    
    vec2 arrP = up_p - vec2(-0.4 + pulse, 0.2); 
    float arrBody = max(abs(arrP.x + 0.15) - 0.15, abs(arrP.y) - 0.25);
    float arrHeadX = arrP.x - (-0.3);
    float arrHead = max(abs(arrP.y) - (arrHeadX + 0.3), -arrHeadX - 0.3);
    if (arrP.x > -0.3) arrHead = 1.0; 
    
    float dArrow = min(arrBody, arrHead);
    dCutout = min(dFigure, dArrow);
    
    if (base < 0.0 && dCutout > 0.02) col = vec3(0.1);
    
    if (dCutout < 0.02 && dCutout > 0.0) {
        col = vec3(1.0); 
    } 
    else if (dCutout <= 0.0) {
        if (dArrow <= 0.0 && dFigure > 0.0) {
            col = vec3(0.9, 0.45, 0.2);
            if (max(abs(arrP.x + 0.1) - 0.12, abs(arrP.y) - 0.15) < 0.0) {
                col = vec3(0.95);
                if (abs(arrP.y - 0.05) < 0.02 && abs(arrP.x + 0.1) < 0.1) col = vec3(0.1);
                if (abs(arrP.y + 0.05) < 0.02 && abs(arrP.x + 0.1) < 0.08) col = vec3(0.1);
            }
        } else {
            if (dHat < 0.0 && gp.y > 0.6) {
                col = vec3(0.2, 0.25, 0.3); 
                if (gp.y < 0.62) col = vec3(0.8, 0.2, 0.2); 
            } else if (dHead < 0.0) {
                col = vec3(0.85, 0.65, 0.5); 
                if (gp.y > 0.55 && abs(gp.x) < 0.05) col = vec3(0.3); 
            } else if (dTorso < 0.0 || dArmL < 0.0 || dArmR < 0.0) {
                col = vec3(0.8, 0.85, 0.9); 
                if (dGlove < 0.0 && apL.x < -0.15) col = vec3(0.95); 
                if (abs(gp.x) < 0.01 && gp.y > 0.0) col *= 0.9; 
                if (abs(gp.x - 0.08) < 0.05 && abs(gp.y - 0.25) < 0.05) col = vec3(0.9); 
                if (dArmL < 0.0 && apL.x > -0.05) col = vec3(0.8, 0.2, 0.2); 
            }
            if (dLegs < 0.0 && gp.y < -0.0) {
                col = vec3(0.2, 0.25, 0.3); 
                if (gp.y < -0.65) col = vec3(0.1);
                if (gp.y > -0.05) col = vec3(0.1);
            }
            
            col *= 0.9 + 0.1 * up_p.x;
        }
    }
}

void layer_Vignette(in vec2 p, inout vec3 col) {
    col *= 1.0 - 0.2 * length(p);
}

void main() {
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(0.0);
    vec2 up_p = vec2(p.y, -p.x); 
    
    layer_Background(up_p, iTime, col);
    layer_Shadow(up_p, iTime, col);
    layer_Cutout(up_p, iTime, col);
    layer_Vignette(p, col);

    gl_FragColor = vec4(col, 1.0);
}

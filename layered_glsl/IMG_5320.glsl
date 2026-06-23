/* @layer_metadata
{
  "title": "Shader: IMG_5320",
  "layers": [
    {
      "name": "Background",
      "keywords": ["background", "walls", "floor", "reflection", "text"]
    },
    {
      "name": "Tripod",
      "keywords": ["tripod", "pole", "legs"]
    },
    {
      "name": "Hanging Plant",
      "keywords": ["plant", "leaves", "rustling"]
    },
    {
      "name": "Swinging Head",
      "keywords": ["head", "mannequin", "swinging", "hair", "face", "eyes", "blinking"]
    },
    {
      "name": "Swinging String",
      "keywords": ["string", "swinging"]
    }
  ]
}
*/
void layer_Background(in vec2 upP, in float iTime, inout vec3 col) {
    if (upP.y < -0.3) {
        col = vec3(0.55, 0.58, 0.6);
        if (fract(upP.x * 2.0) < 0.05 || fract(upP.y * 2.0) < 0.05) col = vec3(0.3);
    } else {
        if (upP.x > 0.5) {
            col = vec3(0.9, 0.9, 0.85);
            if (upP.y > 0.2) col = vec3(0.6, 0.75, 0.65);
        } else {
            col = vec3(0.1, 0.15, 0.15);
            if (length(upP - vec2(0.2, 0.2)) < 0.2) col = vec3(0.4, 0.2, 0.15);
            if (fract((upP.y + iTime*0.2) * 10.0) < 0.1 && upP.x < 0.0) col = vec3(0.8, 0.3, 0.3);
        }
        
        if (abs(upP.x - 0.6) < 0.08) {
            col = vec3(0.6);
            col *= 0.8 + 0.4 * cos((upP.x - 0.6) * 40.0);
            if (abs(upP.y - (-0.2)) < 0.05) col *= 0.7;
        }
    }
}

void layer_Tripod(in vec2 upP, inout vec3 col) {
    float objDist = 1.0;
    
    float pole = abs(upP.x - 0.1) - 0.02;
    if (upP.y > -0.6 && upP.y < 0.0) objDist = min(objDist, pole);
    
    vec2 lp = upP - vec2(0.1, -0.2);
    float l1 = max(abs(lp.x + lp.y) - 0.015, -lp.y);
    float l2 = max(abs(lp.x - lp.y) - 0.015, -lp.y);
    float l3 = max(abs(lp.x) - 0.015, lp.y);
    if (length(lp) < 0.4) {
        objDist = min(objDist, l1);
        objDist = min(objDist, l2);
        if (lp.y > 0.0 && lp.y < 0.3) objDist = min(objDist, l3);
    }
    
    if (objDist < 0.0) {
        col = vec3(0.15);
    }
}

void layer_HangingPlant(in vec2 upP, in float iTime, inout vec3 col) {
    vec2 plantCenter = vec2(0.05, 0.0);
    if (length(upP - plantCenter) < 0.3) {
        for(float i=0.0; i<30.0; i++) {
            float a = i * 2.4 + sin(iTime * 2.0 + i)*0.1; 
            float r = fract(sin(i * 123.4) * 456.7) * 0.25;
            vec2 pos = plantCenter + vec2(cos(a), sin(a)) * r;
            pos.y -= r * 0.5;
            
            float leaf = length(upP - pos) - 0.03;
            if (leaf < 0.0) {
                vec3 objCol = vec3(0.4, 0.6, 0.3);
                if (fract(upP.x * 30.0 + i) < 0.3) objCol = vec3(0.8, 0.9, 0.8);
                col = objCol;
            }
        }
    }
}

void layer_SwingingHead(in vec2 upP, in float iTime, in float swing, inout vec3 col) {
    vec2 headP = upP - vec2(-0.35 + swing, 0.0);
    
    float hair = length(vec2(headP.x, headP.y * 1.2)) - 0.22;
    float neck = max(abs(headP.x - 0.15) - 0.08, abs(headP.y) - 0.15);
    float face = length(vec2(headP.x + 0.05, headP.y * 1.3)) - 0.18;
    
    if (hair < 0.0) {
        col = vec3(0.9, 0.9, 0.95);
        col *= 0.8 + 0.2 * sin(headP.y * 100.0);
    }
    
    if (face < 0.0 || neck < 0.0) {
        col = vec3(0.9, 0.75, 0.65);
        col *= 0.8 + 0.2 * smoothstep(0.1, -0.1, headP.x);
        
        float blink = fract(iTime*0.3) < 0.1 ? 0.0 : 1.0;
        
        if (length(vec2((headP.x + 0.05)*2.0, headP.y + 0.08*blink)) < 0.03*blink) col = vec3(0.1);
        if (length(vec2((headP.x + 0.05)*2.0, headP.y - 0.08*blink)) < 0.03*blink) col = vec3(0.1);
        
        if (length(vec2(headP.x - 0.1, headP.y)) < 0.02) col = vec3(0.7, 0.4, 0.4);
    }
}

void layer_SwingingString(in vec2 upP, in float swing, inout vec3 col) {
    vec2 p1 = vec2(0.1, 0.0); 
    vec2 p2 = vec2(-0.35 + swing, 0.0); 
    float dLine = length(upP - p1 - (p2 - p1) * clamp(dot(upP - p1, p2 - p1) / dot(p2 - p1, p2 - p1), 0.0, 1.0));
    
    if (dLine < 0.005) {
        col = vec3(0.9);
    }
}

void main() {
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(0.0);
    vec2 upP = vec2(p.y, -p.x); 
    
    layer_Background(upP, iTime, col);
    layer_Tripod(upP, col);
    layer_HangingPlant(upP, iTime, col);
    
    float swing = sin(iTime * 1.5) * 0.1;
    
    layer_SwingingHead(upP, iTime, swing, col);
    layer_SwingingString(upP, swing, col);

    gl_FragColor = vec4(col, 1.0);
}

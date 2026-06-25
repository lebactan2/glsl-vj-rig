void layer_Background(in vec2 p, in float iTime, inout vec3 col) {
    col = vec3(0.4, 0.45, 0.48);
    col += vec3(0.1, 0.15, 0.2) * sin(p.x * 5.0 + p.y * 3.0 + iTime);
    if (abs(p.y) < 0.01) col = vec3(0.3, 0.35, 0.4);
}

void layer_TopReflection(in vec2 p, in float iTime, inout vec3 col) {
    if (p.y > 0.0 && p.x > -0.6 && p.x < 0.2 && p.y > 0.3 && p.y < 0.8) {
        col = mix(col, vec3(0.9, 0.95, 1.0), 0.6); 
        float sway = sin(iTime)*0.02;
        if (p.x + sway > -0.4 && p.x + sway < -0.2 && p.y > 0.4) col = vec3(0.8);
        if (p.x + sway > 0.0 && p.x + sway < 0.1 && p.y > 0.5) col = vec3(0.7, 0.8, 0.7);
    }
}

void layer_Leaf(in vec2 p, in float iTime, inout vec3 col) {
    float y_offset = p.y > 0.0 ? 0.5 : -0.5;
    vec2 lp = p - vec2(0.0, y_offset);
    
    float leafBase = length(lp * vec2(0.5, 2.5)) - 0.7;
    float jagged = sin(lp.x * 40.0) * 0.03 + sin(lp.x * 80.0) * 0.015;
    float leaf = leafBase + jagged;
    
    if (leaf < 0.0) {
        col = vec3(0.1, 0.2, 0.15);
        
        float veins = abs(sin(lp.x * 100.0));
        col *= 0.7 + 0.3 * veins;
        
        if (abs(lp.y) < 0.02) col = vec3(0.15, 0.25, 0.15);
        
        vec3 gold = vec3(0.8, 0.6, 0.2);
        
        for(float i=-0.8; i<=0.8; i+=0.35) {
            vec2 cp = lp - vec2(i, 0.0);
            
            float charShape = length(cp) - 0.08;
            charShape += sin(cp.x * 30.0 + i * 10.0) * 0.03;
            charShape += cos(cp.y * 25.0 + i * 20.0) * 0.04;
            
            float stroke1 = max(abs(cp.x - cp.y) - 0.02, abs(cp.x + cp.y) - 0.06);
            float stroke2 = max(abs(cp.x + cp.y*0.5) - 0.01, abs(cp.y) - 0.08);
            
            if (min(charShape, min(stroke1, stroke2)) < 0.0) {
                float shine = pow(max(0.0, sin(cp.x * 50.0 + cp.y * 50.0 - iTime*5.0)), 4.0);
                col = gold * (0.8 + 0.4 * cos(cp.x * 50.0 + cp.y * 50.0)) + vec3(0.4)*shine;
            }
        }
        
        vec2 vp = lp - vec2(-1.2, 0.0);
        float grapeCluster = length(vp) - 0.15;
        if (grapeCluster < 0.0) {
            float grapes = 1.0;
            for(float gx=-0.1; gx<=0.1; gx+=0.04) {
                for(float gy=-0.1; gy<=0.1; gy+=0.04) {
                    if(length(vec2(gx,gy)) < 0.12) {
                        float g = length(vp - vec2(gx, gy)) - 0.02;
                        grapes = min(grapes, g);
                    }
                }
            }
            if (grapes < 0.0) {
                float gShine = pow(max(0.0, sin(vp.x*50.0 + vp.y*50.0 - iTime*3.0)), 4.0);
                col = gold * (0.6 + 0.4*sin(vp.x*100.0)) + vec3(0.3)*gShine;
            }
        }
        
        if (leafBase + jagged > -0.02) {
            float trimGleam = pow(max(0.0, sin(lp.x * 20.0 - iTime*4.0)), 8.0);
            col = gold * 0.7 + vec3(0.5)*trimGleam;
        }
    }
}

void layer_SpecularHighlight(in vec2 p, in float iTime, inout vec3 col) {
    col += vec3(0.1) * max(0.0, sin(p.x * 5.0 + p.y * 10.0 - iTime));
}

vec4 layer_Background(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_Background(p, iTime, col);


  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

vec4 layer_TopReflection(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_TopReflection(p, iTime, col);


  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

vec4 layer_Leaf(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_Leaf(p, iTime, col);


  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

vec4 layer_SpecularHighlight(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_SpecularHighlight(p, iTime, col);


  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

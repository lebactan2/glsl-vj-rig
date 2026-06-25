void layer_Panel(in vec2 p, in float iTime, inout vec3 col) {
    vec3 panelGrey = vec3(0.75, 0.76, 0.78);
    col = panelGrey;
    
    float seam1 = abs(p.x + 0.35);
    float seam2 = abs(p.x - 0.45);
    
    if (seam1 < 0.005 || seam2 < 0.005) {
        col = vec3(0.3); 
    }
    
    float dirt = fract(sin(dot(p + vec2(iTime*0.05, 0.0), vec2(12.9898, 78.233))) * 43758.5453);
    float dirt2 = fract(sin(dot(p * 5.0 + vec2(0.0, iTime*0.3), vec2(39.346, 11.135))) * 43758.5453);
    col *= 0.9 + 0.1 * dirt;
    
    if (dirt2 > 0.8 && p.x < -0.3) {
        col *= 0.85;
    }
}

void layer_TornPoster(in vec2 p, in float iTime, inout vec3 col) {
    if (p.x < -0.35) {
        if (p.y < 0.8 && p.y > -0.4) {
            float flutter = sin(iTime * 10.0 + p.y * 20.0) * 0.01;
            float tearNoise = fract(sin(p.x * 50.0 + p.y * 30.0) * 100.0);
            float tearShape = sin(p.y * 10.0) * 0.1 + cos(p.y * 25.0) * 0.05 + flutter;
            
            float innerTear = fract(sin(p.x * 10.0 + p.y * 15.0 + iTime*2.0) * 50.0);
            
            bool isPoster = true;
            
            if (p.x > -0.4 + tearShape + tearNoise*0.05) isPoster = false;
            if (p.y < -0.3 + tearNoise * 0.1 + flutter) isPoster = false;
            
            if (innerTear > 0.85) isPoster = false;
            if (length(p - vec2(-0.8, -0.2)) < 0.15 + flutter) isPoster = false; 
            if (length(p - vec2(-0.8, 0.6)) < 0.1 + flutter) isPoster = false; 
            
            if (isPoster) {
                col = vec3(0.1); 
                
                vec2 tp = p - vec2(-0.9, 0.7); 
                tp.y = -tp.y; 
                
                float row = floor(tp.y / 0.15);
                float colIdx = floor((p.x + 0.9) / 0.3);
                
                if (row >= 0.0 && row < 8.0 && colIdx >= 0.0 && colIdx < 2.0) {
                    vec2 cellP = vec2(fract((p.x + 0.9)/0.3), fract(tp.y / 0.15));
                    
                    if (cellP.y > 0.2 && cellP.y < 0.8) {
                        if (mod(row, 2.0) == 0.0) {
                            if (fract(cellP.x * 10.0) > 0.2 && cellP.y > 0.4) col = vec3(0.9);
                        } else {
                            if (fract(cellP.x * 15.0) > 0.15 && cellP.y > 0.1) col = vec3(0.95);
                        }
                    }
                }
            }
        }
    }
}

void layer_TopCenterPoster(in vec2 p, in float iTime, inout vec3 col) {
    vec2 spTop = p - vec2(0.0, 0.8);
    if (abs(spTop.x) < 0.25 && abs(spTop.y) < 0.15) {
        col = vec3(0.95); 
        
        if (spTop.x < -0.15 && spTop.x > -0.2) {
            float zig = sin(spTop.y * 30.0 + iTime*10.0) * 0.02; 
            if (spTop.x < -0.18 + zig) col = vec3(0.8, 0.1, 0.2); 
        }
        
        if (spTop.x > -0.1) {
            if (abs(spTop.y - 0.05) < 0.03 && fract(spTop.x * 20.0) > 0.2) col = vec3(0.1);
            if (abs(spTop.y + 0.05) < 0.015 && fract(spTop.x * 30.0) > 0.3) col = vec3(0.1);
            if (abs(spTop.y + 0.1) < 0.015 && fract(spTop.x * 30.0) > 0.3) col = vec3(0.1);
        }
        if (abs(abs(spTop.x) - 0.25) < 0.005 || abs(abs(spTop.y) - 0.15) < 0.005) col = vec3(0.8);
    }
}

#define STICKER(cx, cy, w, h, isGreen) \
if (abs(p.x - (cx)) < (w) && abs(p.y - (cy)) < (h)) { \
    col = vec3(0.95); \
    vec2 lp = p - vec2(cx, cy); \
    if (lp.y > (h)*0.5 && fract(lp.x*50.0)>0.2) col = vec3(0.1); \
    if (lp.y > -(h)*0.6 && lp.y < (h)*0.4) { \
        if (fract(lp.x * (20.0/(w))) > 0.1) { \
            col = isGreen ? vec3(0.1, 0.5, 0.4) : vec3(0.1, 0.2, 0.6); \
        } \
    } \
    if (abs(abs(p.x-(cx))-(w))<0.002 || abs(abs(p.y-(cy))-(h))<0.002) col = vec3(0.8); \
}

void layer_Stickers(in vec2 p, inout vec3 col) {
    STICKER(-0.15, 0.2, 0.1, 0.08, false); 
    STICKER(-0.25, -0.05, 0.1, 0.08, false); 
    STICKER(-0.25, -0.25, 0.1, 0.08, true);  
    STICKER(-0.25, -0.45, 0.1, 0.08, true);  
    STICKER(0.0, -0.2, 0.1, 0.08, false);  
    STICKER(-0.25, -0.85, 0.1, 0.08, false); 

    STICKER(0.65, 0.6, 0.1, 0.08, false); 
    STICKER(0.65, 0.4, 0.1, 0.08, true);  
    STICKER(0.9, 0.3, 0.1, 0.08, false);  
    STICKER(0.8, 0.0, 0.1, 0.08, true);   
    STICKER(0.8, -0.15, 0.1, 0.08, false); 
    STICKER(0.85, -0.35, 0.1, 0.08, false); 
    STICKER(0.9, -0.55, 0.1, 0.08, true);  
    STICKER(0.9, -0.7, 0.1, 0.08, false);  
    STICKER(0.9, 0.85, 0.1, 0.08, true);  
}

vec4 layer_Panel(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_Panel(p, iTime, col);
    

  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

vec4 layer_TornPoster(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_TornPoster(p, iTime, col);
    

  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

vec4 layer_TopCenterPoster(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_TopCenterPoster(p, iTime, col);
    

  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

vec4 layer_Stickers(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    
    layer_Stickers(p, col);
    

  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

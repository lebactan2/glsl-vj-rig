float hash(vec2 p) { return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453); }

float sketchLine(vec2 p, vec2 a, vec2 b, float thickness, float iTime) {
    vec2 pa = p - a, ba = b - a;
    float h = clamp( dot(pa,ba)/dot(ba,ba), 0.0, 1.0 );
    float d = length( pa - ba*h );
    float jitter = (hash(vec2(h * 100.0, iTime*0.0)) - 0.5) * 0.02;
    return smoothstep(thickness + abs(jitter), thickness*0.2, d);
}

void layer_Background(in vec2 p, inout vec3 col) {
    col = vec3(0.96, 0.96, 0.93);
    float grain = hash(p * 500.0);
    col -= 0.05 * grain; 
}

void layer_PersonHead(in vec2 p, float t, inout float lineMap) {
    vec2 headPos = vec2(p.x, (p.y - 0.7)*1.4);
    float headDist = abs(length(headPos) - 0.15);
    lineMap += smoothstep(t+0.01, t*0.5, headDist + (hash(p*50.0)-0.5)*0.02);
}

void layer_ShouldersNeck(in vec2 p, float t, float iTime, inout float lineMap) {
    lineMap += sketchLine(p, vec2(-0.15, 0.55), vec2(0.15, 0.55), t, iTime);
    lineMap += sketchLine(p, vec2(-0.05, 0.55), vec2(-0.05, 0.7), t, iTime);
    lineMap += sketchLine(p, vec2(0.05, 0.55), vec2(0.05, 0.7), t, iTime);
}

void layer_CentralGarmentSpine(in vec2 p, float t, float iTime, inout float lineMap) {
    lineMap += sketchLine(p, vec2(0.0, 0.55), vec2(0.0, -0.3), t * 1.5, iTime);
}

void layer_KiteWingTopEdge(in vec2 p, float t, float iTime, inout float lineMap) {
    lineMap += sketchLine(p, vec2(0.0, 0.3), vec2(-0.8, -0.1), t, iTime);
    lineMap += sketchLine(p, vec2(0.0, 0.3), vec2(0.8, -0.1), t, iTime);
}

void layer_InternalArchYoke(in vec2 p, float t, inout float lineMap) {
    float archY = p.y - (0.2 - p.x*p.x*0.4);
    if (abs(p.x) < 0.65 && p.y > 0.0 && p.y < 0.35) {
        lineMap += smoothstep(t+0.01, t*0.5, abs(archY) + (hash(p*50.0)-0.5)*0.02);
    }
}

void layer_KiteWingBottomEdge(in vec2 p, float t, float iTime, inout float lineMap) {
    lineMap += sketchLine(p, vec2(-0.8, -0.1), vec2(0.0, -0.3), t, iTime);
    lineMap += sketchLine(p, vec2(0.8, -0.1), vec2(0.0, -0.3), t, iTime);
}

void layer_Sleeves(in vec2 p, float t, float iTime, inout float lineMap) {
    lineMap += sketchLine(p, vec2(-0.8, -0.1), vec2(-1.0, -0.3), t, iTime);
    lineMap += sketchLine(p, vec2(0.8, -0.1), vec2(1.0, -0.3), t, iTime);
    lineMap += sketchLine(p, vec2(-0.6, -0.3), vec2(-0.8, -0.5), t, iTime);
    lineMap += sketchLine(p, vec2(0.6, -0.3), vec2(0.8, -0.5), t, iTime);
}

void layer_Legs(in vec2 p, float t, float iTime, inout float lineMap) {
    lineMap += sketchLine(p, vec2(-0.15, -0.3), vec2(-0.25, -1.0), t, iTime);
    lineMap += sketchLine(p, vec2(0.15, -0.3), vec2(0.25, -1.0), t, iTime);
    lineMap += sketchLine(p, vec2(-0.02, -0.4), vec2(-0.05, -1.0), t, iTime);
    lineMap += sketchLine(p, vec2(0.02, -0.4), vec2(0.05, -1.0), t, iTime);
}

void layer_ForbesText(in vec2 p, float t, inout float lineMap) {
    if (abs(p.x) < 0.3 && abs(p.y - 0.05) < 0.1) {
        float squiggle = sin(p.x * 40.0) * 0.04 + (p.y - 0.05);
        lineMap += smoothstep(t*1.5, t*0.5, abs(squiggle));
    }
}

vec4 layer_Background(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);
    layer_Background(p, col);

    float lineMap = 0.0;
    float t = 0.008; 


    col = mix(col, vec3(0.1, 0.1, 0.15), clamp(lineMap, 0.0, 1.0));


  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

vec4 layer_PersonHead(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);

    float lineMap = 0.0;
    float t = 0.008; 

    layer_PersonHead(p, t, lineMap);

    col = mix(col, vec3(0.1, 0.1, 0.15), clamp(lineMap, 0.0, 1.0));


  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

vec4 layer_ShouldersNeck(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);

    float lineMap = 0.0;
    float t = 0.008; 

    layer_ShouldersNeck(p, t, iTime, lineMap);

    col = mix(col, vec3(0.1, 0.1, 0.15), clamp(lineMap, 0.0, 1.0));


  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

vec4 layer_CentralGarmentSpine(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);

    float lineMap = 0.0;
    float t = 0.008; 

    layer_CentralGarmentSpine(p, t, iTime, lineMap);

    col = mix(col, vec3(0.1, 0.1, 0.15), clamp(lineMap, 0.0, 1.0));


  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

vec4 layer_KiteWingTopEdge(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);

    float lineMap = 0.0;
    float t = 0.008; 

    layer_KiteWingTopEdge(p, t, iTime, lineMap);

    col = mix(col, vec3(0.1, 0.1, 0.15), clamp(lineMap, 0.0, 1.0));


  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

vec4 layer_InternalArchYoke(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);

    float lineMap = 0.0;
    float t = 0.008; 

    layer_InternalArchYoke(p, t, lineMap);

    col = mix(col, vec3(0.1, 0.1, 0.15), clamp(lineMap, 0.0, 1.0));


  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

vec4 layer_KiteWingBottomEdge(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);

    float lineMap = 0.0;
    float t = 0.008; 

    layer_KiteWingBottomEdge(p, t, iTime, lineMap);

    col = mix(col, vec3(0.1, 0.1, 0.15), clamp(lineMap, 0.0, 1.0));


  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

vec4 layer_Sleeves(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);

    float lineMap = 0.0;
    float t = 0.008; 

    layer_Sleeves(p, t, iTime, lineMap);

    col = mix(col, vec3(0.1, 0.1, 0.15), clamp(lineMap, 0.0, 1.0));


  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

vec4 layer_Legs(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);

    float lineMap = 0.0;
    float t = 0.008; 

    layer_Legs(p, t, iTime, lineMap);

    col = mix(col, vec3(0.1, 0.1, 0.15), clamp(lineMap, 0.0, 1.0));


  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

vec4 layer_ForbesText(vec2 _uv){

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(-1.0);

    float lineMap = 0.0;
    float t = 0.008; 

    layer_ForbesText(p, t, lineMap);

    col = mix(col, vec3(0.1, 0.1, 0.15), clamp(lineMap, 0.0, 1.0));


  vec3 _rgb = vec3(col);
  return vec4(clamp(_rgb,0.0,1.0), step(0.0, max(_rgb.r, max(_rgb.g, _rgb.b))));
}

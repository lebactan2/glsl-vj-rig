/* @layer_metadata
{
  "title": "Metal Gate",
  "layers": [
    {
      "name": "Background Tiles",
      "keywords": ["tiles", "orange", "brown", "bevel", "wall"]
    },
    {
      "name": "Gate Background",
      "keywords": ["dark", "background", "behind", "gate"]
    },
    {
      "name": "Metal Gate Structure",
      "keywords": ["metal", "gate", "structure", "bars", "grid", "mesh", "arches", "panels"]
    },
    {
      "name": "Gate Material",
      "keywords": ["metal", "shading", "gray", "recessed"]
    }
  ]
}
*/
void layer_BackgroundTiles(in vec2 uv, in float gateWidth, in vec2 p, inout vec3 col) {
    if (abs(p.x) > gateWidth) {
        vec2 tileUV = uv * vec2(8.0, 12.0);
        vec2 cell = fract(tileUV);
        vec2 id = floor(tileUV);
        
        float edge = smoothstep(0.0, 0.05, cell.x) * smoothstep(1.0, 0.95, cell.x) *
                     smoothstep(0.0, 0.05, cell.y) * smoothstep(1.0, 0.95, cell.y);
        
        float noise = fract(sin(dot(id, vec2(12.9898, 78.233))) * 43758.5453);
        vec3 baseCol = mix(vec3(0.7, 0.35, 0.2), vec3(0.85, 0.5, 0.3), noise);
        
        col = mix(vec3(0.1), baseCol, edge);
    }
}

void layer_GateBackground(in float gateWidth, in vec2 p, inout vec3 col) {
    if (abs(p.x) <= gateWidth) {
        col = vec3(0.05, 0.05, 0.06);
    }
}

void layer_MetalGateStructure(in vec2 p, in float gateWidth, inout float metal, inout vec3 col) {
    if (abs(p.x) <= gateWidth) {
        float div0 = step(abs(p.x), 0.02);
        float divL1 = step(abs(p.x + 0.6), 0.02);
        float divR1 = step(abs(p.x - 0.6), 0.02);
        float divL2 = step(abs(p.x + 1.0), 0.04);
        float divR2 = step(abs(p.x - 1.0), 0.04);
        
        metal = max(metal, max(max(div0, divL1), max(divR1, max(divL2, divR2))));
        
        if (abs(p.x) < 0.6) {
            float hBars = step(abs(fract(p.y * 15.0) - 0.5), 0.2);
            float vBars = step(abs(fract(p.x * 6.0) - 0.5), 0.1);
            
            metal = max(metal, hBars);
            if (vBars > 0.5 && hBars < 0.5) {
                metal = max(metal, 0.8);
            }
        }
        
        if (abs(p.x) >= 0.6 && abs(p.x) < 1.0) {
            vec2 panelP = vec2(abs(p.x) - 0.8, p.y);
            
            float mesh = step(0.8, sin(panelP.x * 250.0) * sin(panelP.y * 250.0));
            if (mesh > 0.5 && metal < 0.5) col = mix(col, vec3(0.3), 0.5);
            
            vec2 cell = fract(panelP * vec2(1.0, 2.5)) - 0.5;
            
            float arc1 = step(abs(length(cell - vec2(-0.5, 0.0)) - 0.5), 0.03);
            float arc2 = step(abs(length(cell - vec2(0.5, 0.0)) - 0.5), 0.03);
            
            metal = max(metal, max(arc1, arc2));
            
            float panelHBar = step(abs(fract(panelP.y * 2.5) - 0.5), 0.02);
            metal = max(metal, panelHBar);
        }
    }
}

void layer_GateMaterial(in vec2 p, in float metal, inout vec3 col) {
    if (metal > 0.0) {
        vec3 metalCol = vec3(0.5, 0.55, 0.6);
        metalCol *= 0.6 + 0.4 * sin(p.x * 20.0 + p.y * 20.0);
        col = metal == 0.8 ? metalCol * 0.6 : metalCol;
    }
}

void main() {
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;
    
    vec3 col = vec3(0.0);
    float gateWidth = 1.0;
    float metal = 0.0;
    
    layer_BackgroundTiles(uv, gateWidth, p, col);
    layer_GateBackground(gateWidth, p, col);
    layer_MetalGateStructure(p, gateWidth, metal, col);
    layer_GateMaterial(p, metal, col);
    
    gl_FragColor = vec4(col, 1.0);
}

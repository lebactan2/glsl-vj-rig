void main() {
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    // Background: Runway setting
    // Gradient from grey floor to white wall
    vec3 col = mix(vec3(0.95, 0.95, 0.95), vec3(0.7, 0.7, 0.75), smoothstep(0.0, -1.0, p.y));
    
    // Divide into 3 vertical panels (like a triptych showing 3 models)
    float panel = fract(p.x * 1.5);
    // Dark vertical lines separating panels
    if (abs(panel) < 0.02) col = vec3(0.8);

    // Common Model Features
    // ---------------------------------------------------------
    // Center of current panel [-1 to 1]
    vec2 localP = vec2(fract(p.x * 1.5 + 0.5) * 2.0 - 1.0, p.y);
    int modelId = int(floor(p.x * 1.5 + 1.5)); // 0 = left, 1 = center, 2 = right
    
    // Head & Skin
    float head = length(localP - vec2(0.0, 0.75)) - 0.1;
    float neck = length(max(abs(localP - vec2(0.0, 0.6)) - vec2(0.03, 0.05), 0.0));
    
    if (head < 0.0 || neck < 0.01) {
        col = vec3(0.9, 0.75, 0.65); // Skin tone (light)
        if (modelId == 2) col = vec3(0.7, 0.5, 0.4); // Darker skin for right model
        
        // Hair
        if (localP.y > 0.8) {
             if (modelId == 0) col = vec3(0.4, 0.2, 0.1); // Brown pulled back
             if (modelId == 1) col = vec3(0.9, 0.7, 0.2); // Blonde
             if (modelId == 2) col = vec3(0.2, 0.1, 0.1); // Dark curly
             
             // Hair texture
             float hTex = sin(localP.x * 100.0);
             col *= 0.8 + 0.2 * hTex;
        }
        
        // Sunglasses
        float glasses = length(max(abs(localP - vec2(0.0, 0.75)) - vec2(0.07, 0.02), 0.0));
        if (glasses < 0.01) {
            if (modelId == 0 || modelId == 1) {
                col = vec3(0.8, 0.1, 0.1); // Red glasses
                // Reflection
                if (localP.y > 0.75 && localP.x > -0.05) col += vec3(0.3);
            }
            if (modelId == 2) {
                col = vec3(0.1); // Black glasses
            }
        }
        
        // Lips
        float lips = length(max(abs(localP - vec2(0.0, 0.68)) - vec2(0.02, 0.005), 0.0));
        if (lips < 0.005) col = vec3(0.8, 0.4, 0.4);
    }
    
    // Arms (visible mostly on left and center models)
    float armL = length(max(abs(localP - vec2(-0.3, 0.0)) - vec2(0.03, 0.3), 0.0)) - 0.02;
    float armR = length(max(abs(localP - vec2(0.3, 0.0)) - vec2(0.03, 0.3), 0.0)) - 0.02;
    if ((armL < 0.0 || armR < 0.0) && localP.y < 0.4 && modelId != 2) {
        col = vec3(0.9, 0.75, 0.65); // Skin tone
        col *= 0.8 + 0.2 * sin(localP.x * 40.0); // Shading
    }

    // ---------------------------------------------------------
    // Model 1 (Left) - White puffy top, wide blue pants, black belt bag
    // ---------------------------------------------------------
    if (modelId == 0) {
        // Puffy Top
        float top = length(max(abs(localP - vec2(0.0, 0.2)) - vec2(0.2, 0.25), 0.0)) - 0.1;
        // Puffy sleeves
        float sleeveL = length(max(abs(localP - vec2(-0.35, 0.25)) - vec2(0.05, 0.15), 0.0)) - 0.08;
        float sleeveR = length(max(abs(localP - vec2(0.35, 0.25)) - vec2(0.05, 0.15), 0.0)) - 0.08;
        
        if (top < 0.0 || sleeveL < 0.0 || sleeveR < 0.0) {
            col = vec3(0.95); // White fabric
            
            // Folds and volume
            float folds = sin(localP.x * 20.0 + localP.y * 10.0) * cos(localP.x * 15.0);
            
            // Animation: Puffy fabric breathing/expanding
            float puffAnim = sin(iTime * 3.0 + localP.y * 5.0) * 0.05;
            
            col *= 0.8 + 0.2 * smoothstep(-1.0, 1.0, folds + puffAnim);
            
            // Neckline
            float neckHole = length(localP - vec2(0.0, 0.55)) - 0.1;
            if (neckHole < 0.0) col = vec3(0.9, 0.75, 0.65); // Skin showing
        }
        
        // Wide Blue Pants
        float pants = length(max(abs(localP - vec2(0.0, -0.6)) - vec2(0.3, 0.5), 0.0)) - 0.05;
        // taper at bottom
        if (pants < 0.0 && localP.y < -0.1) {
             col = vec3(0.1, 0.15, 0.3); // Dark navy blue
             
             // Deep pleats/folds
             float pleats = abs(sin(localP.x * 15.0));
             // Animation: Pants swaying
             float sway = sin(localP.y * 5.0 - iTime * 4.0) * 0.1;
             float pAnim = abs(sin((localP.x + sway) * 15.0));
             
             col *= 0.6 + 0.4 * pAnim;
             
             // Crotch shadow
             if (abs(localP.x) < 0.05 && localP.y > -0.3) col *= 0.5;
        }
        
        // Black Belt Bag
        float belt = length(max(abs(localP - vec2(0.0, -0.05)) - vec2(0.25, 0.08), 0.0)) - 0.02;
        if (belt < 0.0) {
            col = vec3(0.15); // Black leather
            // Bag volume
            float bag = length(max(abs(localP - vec2(0.0, -0.05)) - vec2(0.15, 0.06), 0.0)) - 0.01;
            if (bag < 0.0) {
                col = vec3(0.2);
                col += vec3(0.1) * sin(localP.x * 30.0); // Texture
                // Zipper
                if (abs(localP.y - 0.0) < 0.005 && abs(localP.x) < 0.15) col = vec3(0.8);
            }
        }
    }

    // ---------------------------------------------------------
    // Model 2 (Center) - Flowy white parachute-like dress/jumpsuit
    // ---------------------------------------------------------
    if (modelId == 1) {
        float dress = length(max(abs(localP - vec2(0.0, 0.0)) - vec2(0.2, 0.5), 0.0)) - 0.15;
        // Billowing sleeves/sides
        float billowingL = length(localP - vec2(-0.25, 0.0)) - 0.25;
        float billowingR = length(localP - vec2(0.25, 0.0)) - 0.25;
        
        if (dress < 0.0 || billowingL < 0.0 || billowingR < 0.0) {
            col = vec3(0.92, 0.92, 0.95); // Silvery white parachute material
            
            // Complex folds for thin, flowy material
            float folds1 = sin(localP.x * 25.0 + localP.y * 10.0);
            float folds2 = cos(localP.x * 15.0 - localP.y * 20.0);
            
            // Animation: Material blowing in wind (parachute effect)
            float windX = sin(localP.x * 5.0 + iTime * 3.0) * 0.05;
            float windY = cos(localP.y * 5.0 - iTime * 2.0) * 0.05;
            float flow = sin((localP.x + windX) * 30.0 + (localP.y + windY) * 20.0);
            
            float shadow = smoothstep(-1.0, 1.0, folds1) * smoothstep(-1.0, 1.0, flow);
            
            // Shiny highlight
            float shine = smoothstep(0.8, 1.0, flow * folds2);
            
            col *= 0.6 + 0.4 * shadow;
            col += vec3(0.1) * shine;
            
            // Deep center slit/fold
            float centerFold = abs(localP.x - sin(localP.y * 2.0) * 0.05);
            if (centerFold < 0.02) col *= 0.5; // Dark shadow in fold
            
            // Neckline
            float scoop = length(localP - vec2(0.0, 0.6)) - 0.08;
            if (scoop < 0.0) col = vec3(0.9, 0.75, 0.65); // Skin
        }
    }

    // ---------------------------------------------------------
    // Model 3 (Right) - Beige cape/poncho over skirt, beige belt bag
    // ---------------------------------------------------------
    if (modelId == 2) {
        // Cape/Poncho covering upper body
        float cape = length(max(abs(localP - vec2(0.0, 0.1)) - vec2(0.35, 0.4), 0.0)) - 0.05;
        // Taper shoulders
        cape = max(cape, localP.y - 0.55 + abs(localP.x) * 0.5);
        
        // Lower skirt portion
        float skirt = length(max(abs(localP - vec2(0.0, -0.6)) - vec2(0.2, 0.4), 0.0)) - 0.05;

        if (cape < 0.0 || skirt < 0.0) {
            col = vec3(0.75, 0.7, 0.6); // Khaki/Beige color
            
            // Fabric texture (stiffer than center model)
            float tex = sin(localP.x * 20.0) * cos(localP.y * 30.0);
            
            // Animation: Stiff fabric walking sway
            float sway = sin(localP.y * 3.0 - iTime * 5.0) * 0.03;
            float vFolds = abs(sin((localP.x + sway) * 15.0));
            
            col *= 0.8 + 0.2 * tex + 0.1 * vFolds;
            
            // Shadows for cape draping over arms
            float armDrape = abs(abs(localP.x) - 0.25);
            if (armDrape < 0.05 && localP.y > -0.3) col *= 0.7;
            
            // Shadow under cape onto skirt
            if (localP.y < -0.25 && localP.y > -0.35 && skirt < 0.0) {
                float dropShad = exp(-20.0 * (0.35 + localP.y));
                col *= 1.0 - 0.4 * dropShad;
            }
            
            // High collar
            float collar = length(max(abs(localP - vec2(0.0, 0.55)) - vec2(0.08, 0.04), 0.0));
            if (collar < 0.01) col = vec3(0.65, 0.6, 0.5); // Darker beige
            
            // Fringe/Tassels at bottom of cape
            if (abs(localP.y - (-0.3)) < 0.02 && cape < 0.0) {
                if (fract(localP.x * 40.0) < 0.5) col = vec3(0.5, 0.45, 0.4);
            }
        }
        
        // Beige Belt Bag
        float bag = length(max(abs(localP - vec2(0.0, -0.15)) - vec2(0.18, 0.08), 0.0)) - 0.02;
        if (bag < 0.0) {
            col = vec3(0.9, 0.8, 0.7); // Light beige leather
            
            // Rounded 3D look
            float edgeDist = length(max(abs(localP - vec2(0.0, -0.15)) - vec2(0.15, 0.05), 0.0));
            col *= 0.8 + 0.2 * smoothstep(0.05, 0.0, edgeDist);
            
            // Round button/clasp on right side
            float clasp = length(localP - vec2(0.1, -0.15)) - 0.02;
            if (clasp < 0.0) {
                col = vec3(0.2); // Dark clasp
                if (clasp > -0.005) col = vec3(0.5); // Highlight
            }
            
            // Top flap line
            float flap = abs(localP.y - (-0.1));
            if (flap < 0.005 && abs(localP.x) < 0.16) col *= 0.6;
        }
    }

    gl_FragColor = vec4(col, 1.0);
}
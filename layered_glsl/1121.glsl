/*
@layer_metadata
{
  "title": "Abstract Red Scooter",
  "layers": [
    {"name": "Background", "keywords": ["background", "dark", "poster", "grey", "blue"]},
    {"name": "Abstract Car", "keywords": ["car", "red", "gradient", "poster"]},
    {"name": "Abstract Text", "keywords": ["text", "lines", "poster", "white"]},
    {"name": "Street Ground", "keywords": ["street", "ground", "pavement", "gravel", "grey"]},
    {"name": "Scooter And Rider", "keywords": ["scooter", "rider", "red", "shiny", "helmet", "mask", "shirt"]}
  ]
}
*/

void layer_Background(in vec2 p, inout vec3 col) {
    col = vec3(0.1, 0.1, 0.15); // Dark blue/grey poster
}

void layer_AbstractCar(in vec2 p, inout vec3 col) {
    // Abstract poster content (red car)
    if (p.x < 0.0 && p.y > -0.4 && p.y < 0.4) {
        col = mix(col, vec3(0.6, 0.1, 0.1), smoothstep(0.4, 0.0, abs(p.y))); // Car gradient
    }
}

void layer_AbstractText(in vec2 p, inout vec3 col) {
    // Abstract text lines on the poster
    if (p.x > 0.0 && p.x < 0.3 && p.y > -0.2 && p.y < 0.4) {
        float textLines = step(0.5, fract(p.y * 20.0));
        col = mix(col, vec3(0.8), textLines * 0.5);
    }
}

void layer_StreetGround(in vec2 p, inout vec3 col) {
    // Street ground
    if (p.y < -0.4) {
        col = vec3(0.5, 0.5, 0.45); // Gravel/pavement
        float gravel = fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
        col -= gravel * 0.1;
    }
}

void layer_ScooterAndRider(in vec2 p, inout vec3 col) {
    // Red scooter and rider
    if (p.x > 0.0 && p.y < -0.2) {
        // Red scooter body
        if (p.y > -0.6 && p.y < -0.3 && p.x > 0.2 && p.x < 0.8) {
            col = vec3(0.7, 0.1, 0.1); 
            // Shiny reflection on scooter
            float shine = smoothstep(0.4, 0.5, sin(p.x * 10.0 + p.y * 10.0 + iTime * 3.0));
            col += shine * 0.2;
        }
        
        // Rider (grey shirt, white helmet, blue mask)
        if (p.x > 0.3 && p.x < 0.6 && p.y > -0.3 && p.y < 0.2) {
            vec3 riderCol = vec3(0.4, 0.4, 0.42); // Grey shirt
            // Fabric folds animation
            float folds = sin(p.x * 15.0 - p.y * 10.0 + iTime) * 0.05;
            riderCol += folds;
            
            // Helmet (white)
            if (p.y > 0.0 && length(p - vec2(0.45, 0.1)) < 0.1) {
                riderCol = vec3(0.9);
            }
            // Mask (light blue)
            if (p.y > 0.0 && p.y < 0.1 && p.x > 0.45 && p.x < 0.55) {
                riderCol = vec3(0.6, 0.8, 1.0);
            }
            col = riderCol;
        }
    }
}

void main() {
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;
    vec3 col = vec3(0.0);

    layer_Background(p, col);
    layer_AbstractCar(p, col);
    layer_AbstractText(p, col);
    layer_StreetGround(p, col);
    layer_ScooterAndRider(p, col);

    gl_FragColor = vec4(col, 1.0);
}

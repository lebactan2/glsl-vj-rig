void main() {
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 col = vec3(0.7, 0.8, 0.9); // Sky
    
    // Fast Parallax Scrolling Road
    if (p.y < -0.4) {
        col = vec3(0.3, 0.3, 0.32); // Asphalt
        // Blurring speed lines
        float speedNoise = fract(sin(dot(floor(p * vec2(1.0, 20.0)), vec2(12.9898, 78.233))) * 43758.5453);
        col -= speedNoise * 0.05;
        
        // Dashed lines rushing past
        // Projective transform for pseudo-3D road
        vec2 roadP = p;
        roadP.x /= (roadP.y + 0.41); // perspective division
        float dashes = fract(roadP.x * 2.0 - iTime * 15.0);
        if (dashes < 0.4 && abs(p.y - (-0.6)) < 0.02) col = vec3(0.9, 0.8, 0.2); // yellow line
    }
    
    // Parallax Buildings in background
    if (p.y > -0.4 && p.y < 0.4) {
        float bgX = p.x + iTime * 2.0; // scroll buildings
        if (fract(bgX) < 0.5) {
            col = vec3(0.8, 0.75, 0.6);
            if (fract(bgX * 5.0) < 0.2 && fract(p.y * 5.0) < 0.3) col = vec3(0.2, 0.3, 0.4); // Windows reflecting sky
        } else {
            col = vec3(0.7, 0.6, 0.5);
        }
        // Building base shadow
        col *= smoothstep(-0.4, -0.3, p.y);
    }
    
    // Swooping Power lines
    float sag1 = -0.1 + sin(p.x * 2.0 + iTime * 5.0) * 0.05;
    float sag2 = 0.0 + cos(p.x * 3.0 + iTime * 6.0) * 0.08;
    if (abs(p.y - sag1) < 0.003 || abs(p.y - sag2) < 0.003) col = vec3(0.1);

    #define segment(p, a, b) length(p - a - (b - a) * clamp(dot(p - a, b - a) / dot(b - a, b - a), 0.0, 1.0))

    // Physics Bouncing Scooter & Rider
    float suspension = sin(iTime * 20.0) * 0.01; 
    vec2 rP = p - vec2(0.0, -0.25 + suspension);
    
    // Headlight beam slicing through air
    if (rP.x > 0.0 && rP.x < 1.0) {
        float beamCurve = rP.x * 0.2;
        if (abs(rP.y - 0.05) < beamCurve) {
            col += vec3(0.9, 0.9, 0.6) * 0.3 * (1.0 - rP.x);
        }
    }
    
    // Spinning Wheels
    for(float i=0.0; i<2.0; i++) {
        vec2 wP = rP - vec2(-0.2 + i*0.4, -0.1);
        float wheel = length(wP);
        if (wheel < 0.08) {
            col = vec3(0.1); // Tire
            if (wheel < 0.05) {
                col = vec3(0.6); // Rim
                // Spinning spokes
                float angle = atan(wP.y, wP.x) + iTime * 30.0;
                if (abs(sin(angle * 5.0)) < 0.2) col = vec3(0.3);
            }
        }
    }
    
    // Scooter Body
    float body = segment(rP, vec2(-0.2, 0.0), vec2(0.2, 0.0)) - 0.05;
    body = min(body, segment(rP, vec2(0.15, 0.0), vec2(0.2, 0.1)) - 0.03); // handlebar stem
    if (body < 0.0) col = vec3(0.7, 0.2, 0.2); // Red scooter
    
    // Rider
    float torso = segment(rP, vec2(0.0, 0.0), vec2(-0.05, 0.15)) - 0.06;
    if (torso < 0.0) col = vec3(0.1, 0.1, 0.3); // Navy jacket
    // Fluttering jacket trail
    float jacketTrail = segment(rP, vec2(-0.05, 0.05), vec2(-0.15, 0.08 + sin(iTime*30.0)*0.02)) - 0.02;
    if (jacketTrail < 0.0) col = vec3(0.1, 0.1, 0.3);
    
    // Helmet
    float helmet = length(max(abs(rP - vec2(-0.05, 0.2)) - vec2(0.04, 0.04), 0.0)) - 0.02;
    if (helmet < 0.0) {
        col = vec3(0.8, 0.8, 0.8);
        if (rP.x > -0.05 && rP.y > 0.18 && rP.y < 0.22) col = vec3(0.1); // Visor
    }

    // Heavy Bouncing Bundles lagging behind suspension (spring physics approximation)
    float bundleLag = sin(iTime * 20.0 - 1.0) * 0.02; // out of phase bounce
    vec2 bP = p - vec2(-0.2, 0.1 + suspension + bundleLag);
    
    // Texture generator for striped woven bags
    #define wovenBag(bp, rad, col1, col2) \
        if (length(bp) < rad) { \
            float str = bp.x * 25.0 + sin(bp.y * 15.0) * 2.0; \
            vec3 bCol = mix(col1, col2, step(0.5, fract(str))); \
            bCol *= 0.7 + 0.3 * smoothstep(rad, 0.0, length(bp)); /* 3D shading */ \
            col = bCol; \
        }
        
    // Three massive stacked bundles
    wovenBag((bP - vec2(0.0, 0.0)), 0.2, vec3(0.8, 0.3, 0.3), vec3(0.2, 0.4, 0.8)); // Bottom
    wovenBag((bP - vec2(-0.05, 0.3)), 0.18, vec3(0.3, 0.6, 0.3), vec3(0.8, 0.8, 0.2)); // Middle
    wovenBag((bP - vec2(0.05, 0.5)), 0.15, vec3(0.8), vec3(0.2, 0.2, 0.8)); // Top
    
    // Ropes tying it together
    float ropes = min(abs(bP.x), abs(bP.x - 0.05));
    if (ropes < 0.005 && bP.y > -0.2 && bP.y < 0.6) col = vec3(0.9, 0.8, 0.6); // Yellow rope
    
    // Exhaust smoke particles
    float exX = rP.x + 0.25;
    float exY = rP.y + 0.05;
    float smokeId = floor((exX - iTime*2.0) * 10.0);
    float smokeYOffset = sin(smokeId * 45.2) * 0.1;
    vec2 smP = vec2(fract((exX - iTime*2.0) * 10.0) - 0.5, exY + smokeYOffset + exX*0.1); // rises backwards
    if (exX < 0.0 && exX > -0.5 && length(smP) < 0.2 * abs(exX)) {
        col += vec3(0.5) * exp(-length(smP)*20.0);
    }

    gl_FragColor = vec4(col, 1.0);
}

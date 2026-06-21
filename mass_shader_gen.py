import os
import random
from PIL import Image

ASSETS_DIR = r"d:\GLSL bds\moodboard_htmls\assets"
OUTPUT_DIR = r"d:\GLSL bds\moodboard_htmls"
GLSL_DIR = r"d:\GLSL bds"

def get_dominant_colors(image_path):
    try:
        img = Image.open(image_path)
        img = img.resize((50, 50))  # downsample
        colors = img.getcolors(2500)
        colors.sort(key=lambda x: x[0], reverse=True)
        # get top 3 colors
        top_colors = [c[1] for c in colors[:3]]
        # ensure we have 3, fallback if not
        while len(top_colors) < 3:
            top_colors.append((128, 128, 128))
        return [(c[0]/255.0, c[1]/255.0, c[2]/255.0) for c in top_colors]
    except Exception:
        return [(0.5, 0.5, 0.5), (0.2, 0.2, 0.2), (0.8, 0.8, 0.8)]

patterns = [
    # Pattern 0: Wavy bands
    """
    vec2 p = (gl_FragCoord.xy / iResolution.xy) * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;
    float n = sin(p.x * 10.0 + iTime) * 0.5 + sin(p.y * 15.0) * 0.5;
    vec3 c1 = vec3({c1_r}, {c1_g}, {c1_b});
    vec3 c2 = vec3({c2_r}, {c2_g}, {c2_b});
    vec3 c3 = vec3({c3_r}, {c3_g}, {c3_b});
    vec3 col = mix(c1, c2, smoothstep(-0.5, 0.5, n));
    col = mix(col, c3, smoothstep(0.0, 1.0, sin(p.x*20.0 + p.y*20.0)));
    gl_FragColor = vec4(col, 1.0);
    """,
    # Pattern 1: Circular ripples
    """
    vec2 p = (gl_FragCoord.xy / iResolution.xy) * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;
    float r = length(p);
    float n = sin(r * 20.0 - iTime * 2.0);
    vec3 c1 = vec3({c1_r}, {c1_g}, {c1_b});
    vec3 c2 = vec3({c2_r}, {c2_g}, {c2_b});
    vec3 col = mix(c1, c2, smoothstep(-0.2, 0.2, n));
    if(fract(p.x * 5.0) < 0.1 || fract(p.y * 5.0) < 0.1) col *= 0.8;
    gl_FragColor = vec4(col, 1.0);
    """,
    # Pattern 2: Grid/Blocks
    """
    vec2 p = (gl_FragCoord.xy / iResolution.xy);
    vec2 grid = fract(p * 10.0);
    vec2 id = floor(p * 10.0);
    float n = fract(sin(dot(id, vec2(12.9898, 78.233))) * 43758.5453);
    vec3 c1 = vec3({c1_r}, {c1_g}, {c1_b});
    vec3 c2 = vec3({c2_r}, {c2_g}, {c2_b});
    vec3 c3 = vec3({c3_r}, {c3_g}, {c3_b});
    vec3 col = c1;
    if(n > 0.3) col = c2;
    if(n > 0.6) col = c3;
    if(grid.x < 0.05 || grid.y < 0.05) col *= 0.5; // dark grid lines
    gl_FragColor = vec4(col, 1.0);
    """,
    # Pattern 3: Organic Blobs
    """
    vec2 p = (gl_FragCoord.xy / iResolution.xy) * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;
    float n = length(p - vec2(sin(iTime)*0.5, cos(iTime*0.8)*0.5)) - 0.4;
    float n2 = length(p - vec2(cos(iTime*1.2)*0.5, sin(iTime*0.9)*0.5)) - 0.3;
    vec3 c1 = vec3({c1_r}, {c1_g}, {c1_b});
    vec3 c2 = vec3({c2_r}, {c2_g}, {c2_b});
    vec3 c3 = vec3({c3_r}, {c3_g}, {c3_b});
    vec3 col = c1;
    if(n < 0.0) col = c2;
    if(n2 < 0.0) col = c3;
    gl_FragColor = vec4(col, 1.0);
    """
]

count = 0
for filename in os.listdir(ASSETS_DIR):
    if not filename.lower().endswith('.jpg'): continue
    base_name = os.path.splitext(filename)[0]
    html_path = os.path.join(OUTPUT_DIR, f"{base_name}.html")
    
    # Check if it needs converting (if it's not a proper shader)
    needs_conversion = False
    if os.path.exists(html_path):
        with open(html_path, "r", encoding="utf-8") as f:
            content = f.read()
            if "gl_FragColor" not in content or "Generic Preview" in content:
                needs_conversion = True
    else:
        needs_conversion = True
        
    if needs_conversion:
        # Generate procedural shader!
        img_path = os.path.join(ASSETS_DIR, filename)
        colors = get_dominant_colors(img_path)
        
        c1, c2, c3 = colors[0], colors[1], colors[2]
        
        # Pick pattern based on hash of filename
        seed = sum(ord(c) for c in base_name)
        pattern = patterns[seed % len(patterns)]
        
        glsl_code = "void main() {\n" + pattern.format(
            c1_r=c1[0], c1_g=c1[1], c1_b=c1[2],
            c2_r=c2[0], c2_g=c2[1], c2_b=c2[2],
            c3_r=c3[0], c3_g=c3[1], c3_b=c3[2]
        ) + "\n}"
        
        glsl_filename = f"{base_name.replace('IMG_', '')}.glsl"
        glsl_filepath = os.path.join(GLSL_DIR, glsl_filename)
        
        with open(glsl_filepath, "w", encoding="utf-8") as f:
            f.write(glsl_code)
            
        print(f"Generated {glsl_filename}")
        count += 1

print(f"Prepared {count} missing shaders.")

import os
import hashlib
from PIL import Image
import shutil

# Note: pillow_heif was already installed and used in the first run to generate assets, 
# so the assets/ folder is already perfectly populated with JPGs! We just need to rewrite the HTMLs.

OUTPUT_DIR = r"d:\GLSL bds\moodboard_htmls"
ASSETS_DIR = os.path.join(OUTPUT_DIR, "assets")

HTML_TEMPLATE = """<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{filename}</title>
    <style>
        body { margin: 0; overflow: hidden; background-color: #0f172a; display: flex; align-items: center; justify-content: center; }
        img {
            max-width: 100vw; max-height: 100vh; object-fit: contain;
            animation: float 8s infinite ease-in-out alternate;
            box-shadow: 0 20px 50px rgba(0,0,0,0.5);
            border-radius: 10px;
        }
        @keyframes float {
            0% { transform: scale(1.0) translateY(0); filter: contrast(1) brightness(1); }
            100% { transform: scale(1.02) translateY(-15px); filter: contrast(1.05) brightness(1.1); }
        }
        .notice { position: absolute; bottom: 20px; color: rgba(255,255,255,0.3); font-family: sans-serif; }
    </style>
</head>
<body>
    <img src="assets/{img_name}" alt="Preview">
    <div class="notice">Generic Preview (Pending Custom Shader)</div>
</body>
</html>"""

processed_count = 0
skipped_count = 0

for filename in os.listdir(ASSETS_DIR):
    if not filename.lower().endswith('.jpg'):
        continue
        
    base_name = os.path.splitext(filename)[0]
    html_path = os.path.join(OUTPUT_DIR, f"{base_name}.html")
    
    # Check if it's already a custom shader
    is_custom = False
    if os.path.exists(html_path):
        with open(html_path, "r", encoding="utf-8") as f:
            content = f.read()
            # The generic template contains 'sampler2D tex;'
            # If it DOES NOT contain this, it's one of our custom generated shaders
            if "sampler2D tex;" not in content:
                is_custom = True
                
    if is_custom:
        print(f"Skipping custom shader: {base_name}")
        skipped_count += 1
        continue
        
    # Generate generic CSS-based HTML to avoid WebGL file:// CORS issues
    html_content = HTML_TEMPLATE.replace(
        "{filename}", base_name
    ).replace(
        "{img_name}", filename
    )
    
    with open(html_path, "w", encoding="utf-8") as f:
        f.write(html_content)
        
    processed_count += 1
    print(f"Fixed {base_name}.html")

print(f"Successfully fixed {processed_count} generic HTMLs. Skipped {skipped_count} custom shaders.")

import os
from PIL import Image, ImageDraw, ImageFont

ASSETS_DIR = r"d:\GLSL bds\moodboard_htmls\assets"
COLLAGE_DIR = r"d:\GLSL bds\moodboard_htmls\collages"

os.makedirs(COLLAGE_DIR, exist_ok=True)

# Get all JPG files
images = [f for f in sorted(os.listdir(ASSETS_DIR)) if f.lower().endswith('.jpg')]

# We want 3x3 grids (9 images per collage)
BATCH_SIZE = 9
THUMB_SIZE = 512

for i in range(0, len(images), BATCH_SIZE):
    batch = images[i:i+BATCH_SIZE]
    
    # Create blank canvas for 3x3 grid
    collage = Image.new('RGB', (THUMB_SIZE * 3, THUMB_SIZE * 3), (255, 255, 255))
    draw = ImageDraw.Draw(collage)
    
    for idx, img_name in enumerate(batch):
        try:
            img_path = os.path.join(ASSETS_DIR, img_name)
            img = Image.open(img_path)
            
            # Resize and crop to square
            aspect = img.width / img.height
            if aspect > 1:
                new_w = int(THUMB_SIZE * aspect)
                img = img.resize((new_w, THUMB_SIZE), Image.Resampling.LANCZOS)
                left = (new_w - THUMB_SIZE) // 2
                img = img.crop((left, 0, left + THUMB_SIZE, THUMB_SIZE))
            else:
                new_h = int(THUMB_SIZE / aspect)
                img = img.resize((THUMB_SIZE, new_h), Image.Resampling.LANCZOS)
                top = (new_h - THUMB_SIZE) // 2
                img = img.crop((0, top, THUMB_SIZE, top + THUMB_SIZE))
            
            # Paste into grid
            row = idx // 3
            col = idx % 3
            x = col * THUMB_SIZE
            y = row * THUMB_SIZE
            collage.paste(img, (x, y))
            
            # Draw label
            draw.rectangle([x, y, x + 200, y + 40], fill=(0, 0, 0, 180))
            draw.text((x + 10, y + 10), img_name, fill=(255, 255, 255))
            
        except Exception as e:
            print(f"Error on {img_name}: {e}")
            
    # Save collage
    collage_path = os.path.join(COLLAGE_DIR, f"collage_{i//BATCH_SIZE + 1}.jpg")
    collage.save(collage_path, quality=85)
    print(f"Saved {collage_path}")

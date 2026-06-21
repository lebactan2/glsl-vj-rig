import os
import glob

def check_files():
    assets_dir = r"d:\GLSL bds\moodboard_htmls\assets"
    base_dir = r"d:\GLSL bds"
    html_dir = r"d:\GLSL bds\moodboard_htmls"
    
    images = glob.glob(os.path.join(assets_dir, "IMG_*.jpg"))
    images = sorted([os.path.basename(img) for img in images])
    
    missing_glsl = []
    missing_html = []
    black_html = []
    
    print(f"Total images found: {len(images)}")
    
    for img in images:
        base_num = img.replace("IMG_", "").replace(".jpg", "")
        
        # Check GLSL
        glsl_path = os.path.join(base_dir, f"{base_num}.glsl")
        if not os.path.exists(glsl_path):
            missing_glsl.append(base_num)
        elif os.path.getsize(glsl_path) < 50:
            missing_glsl.append(f"{base_num} (too small)")
            
        # Check HTML
        html_path = os.path.join(html_dir, f"IMG_{base_num}.html")
        if not os.path.exists(html_path):
            missing_html.append(base_num)
        else:
            with open(html_path, 'r', encoding='utf-8') as f:
                content = f.read()
                if "void main()" not in content or "gl_FragColor" not in content:
                    black_html.append(base_num)
                    
    if missing_glsl:
        print(f"Missing GLSL: {missing_glsl}")
    else:
        print("All GLSL files present.")
        
    if missing_html:
        print(f"Missing HTML: {missing_html}")
    else:
        print("All HTML files present.")
        
    if black_html:
        print(f"Potentially broken/empty HTMLs: {black_html}")
    else:
        print("All HTMLs look valid (contain shader code).")

if __name__ == "__main__":
    check_files()

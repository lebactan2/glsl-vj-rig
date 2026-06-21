import os
import glob

def generate_task_md():
    base_dir = r"d:\GLSL bds"
    glsl_files = sorted(glob.glob(os.path.join(base_dir, "*.glsl")))
    
    images = [os.path.basename(f).replace('.glsl', '') for f in glsl_files]
    
    # Exclude 0586 since we just manually rewrote it
    if "0586" in images:
        images.remove("0586")
        
    task_content = "# Comprehensive Review and Animation Task List\n\n"
    
    task_content += "We are manually verifying and animating each shader to ensure it accurately matches the original photo and has a bespoke pattern animation.\n\n"
    
    task_content += "- [x] Process Batch 0 (0586) - Completed earlier\n"
    
    batch_size = 5
    for i in range(0, len(images), batch_size):
        batch = images[i:i+batch_size]
        batch_id = (i // batch_size) + 1
        img_list = ", ".join([f"IMG_{img}" for img in batch])
        task_content += f"- [ ] Process Batch {batch_id} ({img_list})\n"
        
    with open(r"C:\Users\giang.it\.gemini\antigravity-ide\brain\0847b97c-5ca5-4495-92ce-d1bf9c8aab9a\task.md", 'w', encoding='utf-8') as f:
        f.write(task_content)
        
    print(f"Task tracker generated with {len(images)} files grouped into {(len(images) + batch_size - 1) // batch_size} batches.")

if __name__ == "__main__":
    generate_task_md()

import sys
import os

if len(sys.argv) < 3:
    print("Usage: builder.py <image_basename> <glsl_file>")
    sys.exit(1)

basename = sys.argv[1]
glsl_file = sys.argv[2]
html_out = os.path.join(r"d:\GLSL bds\moodboard_htmls", f"{basename}.html")
boilerplate_file = r"d:\GLSL bds\moodboard_htmls\boilerplate.html"

with open(boilerplate_file, "r", encoding="utf-8") as f:
    template = f.read()

with open(glsl_file, "r", encoding="utf-8") as f:
    glsl_content = f.read()

output = template.replace("{TITLE}", f"Shader: {basename}").replace("{GLSL_CONTENT}", glsl_content)

with open(html_out, "w", encoding="utf-8") as f:
    f.write(output)

print(f"Generated {html_out}")

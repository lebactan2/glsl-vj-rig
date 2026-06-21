import os
import glob
import re

def revert_animations():
    base_dir = r"d:\GLSL bds"
    html_dir = os.path.join(base_dir, "moodboard_htmls")
    
    glsl_files = glob.glob(os.path.join(base_dir, "*.glsl"))
    
    html_template = """<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Shader {base_name}</title>
    <style>
        body {{ margin: 0; overflow: hidden; background-color: #000; }}
        canvas {{ display: block; width: 100vw; height: 100vh; }}
    </style>
</head>
<body>
    <canvas id="glcanvas"></canvas>
    <script>
        const canvas = document.getElementById('glcanvas');
        const gl = canvas.getContext('webgl');

        function resizeCanvas() {{
            canvas.width = window.innerWidth;
            canvas.height = window.innerHeight;
            gl.viewport(0, 0, canvas.width, canvas.height);
        }}
        window.addEventListener('resize', resizeCanvas);
        resizeCanvas();

        const vertexShaderSource = `
            attribute vec4 a_position;
            void main() {{
                gl_Position = a_position;
            }}
        `;

        const fragmentShaderSource = `
            precision mediump float;
            uniform vec2 iResolution;
            uniform float iTime;
            
            {shader_code}
        `;

        function createShader(gl, type, source) {{
            const shader = gl.createShader(type);
            gl.shaderSource(shader, source);
            gl.compileShader(shader);
            if (!gl.getShaderParameter(shader, gl.COMPILE_STATUS)) {{
                console.error(gl.getShaderInfoLog(shader));
                gl.deleteShader(shader);
                return null;
            }}
            return shader;
        }}

        const vertexShader = createShader(gl, gl.VERTEX_SHADER, vertexShaderSource);
        const fragmentShader = createShader(gl, gl.FRAGMENT_SHADER, fragmentShaderSource);

        const program = gl.createProgram();
        gl.attachShader(program, vertexShader);
        gl.attachShader(program, fragmentShader);
        gl.linkProgram(program);

        if (!gl.getProgramParameter(program, gl.LINK_STATUS)) {{
            console.error(gl.getProgramInfoLog(program));
        }}

        gl.useProgram(program);

        const positionBuffer = gl.createBuffer();
        gl.bindBuffer(gl.ARRAY_BUFFER, positionBuffer);
        const positions = [
            -1.0, -1.0,
             1.0, -1.0,
            -1.0,  1.0,
            -1.0,  1.0,
             1.0, -1.0,
             1.0,  1.0,
        ];
        gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(positions), gl.STATIC_DRAW);

        const positionLocation = gl.getAttribLocation(program, "a_position");
        gl.enableVertexAttribArray(positionLocation);
        gl.vertexAttribPointer(positionLocation, 2, gl.FLOAT, false, 0, 0);

        const resolutionLocation = gl.getUniformLocation(program, "iResolution");
        const timeLocation = gl.getUniformLocation(program, "iTime");

        let startTime = performance.now();

        function render(time) {{
            time *= 0.001; // convert to seconds
            
            gl.uniform2f(resolutionLocation, canvas.width, canvas.height);
            gl.uniform1f(timeLocation, time);

            gl.drawArrays(gl.TRIANGLES, 0, 6);
            requestAnimationFrame(render);
        }}
        requestAnimationFrame(render);
    </script>
</body>
</html>"""

    count = 0
    for file_path in glsl_files:
        base_name = os.path.basename(file_path).replace('.glsl', '')
        
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
            
        original = content
        
        # Remove the global subtle animations block
        pattern_to_remove = r"    // --- Global Subtle Animations ---.*?gl_FragColor = vec4\([a-zA-Z0-9_]+, 1\.0\);\s*"
        
        # Check if the block exists
        if "Global Subtle Animations" in content:
            # We replace the whole block and put back the gl_FragColor statement
            # Since the block replaced the original gl_FragColor line, we need to restore it
            # Determine the variable name used
            if "vec4(c, 1.0)" in content:
                var_name = "c"
            else:
                var_name = "col"
                
            content = re.sub(pattern_to_remove, f"    gl_FragColor = vec4({var_name}, 1.0);\n", content, flags=re.DOTALL)
        
        if original != content:
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(content)
            count += 1
            
        # Rebuild HTML
        html_out = html_template.replace("{shader_code}", content).replace("{base_name}", base_name)
        html_path = os.path.join(html_dir, f"IMG_{base_name}.html")
        with open(html_path, 'w', encoding='utf-8') as f:
            f.write(html_out)

    print(f"Reverted animations for {count} files. All HTMLs rebuilt.")

if __name__ == "__main__":
    revert_animations()

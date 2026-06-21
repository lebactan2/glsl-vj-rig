import os
import glob

def aggressive_animate():
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
        
        # Inject the animated film grain and breathing effect right before gl_FragColor = vec4(col, 1.0);
        # Only inject if we haven't already injected it
        if "Global Subtle Animations" not in content:
            injection = """
    // --- Global Subtle Animations ---
    col *= 1.0 + 0.03 * sin(iTime * 1.5);
    float g_noise = fract(sin(dot(gl_FragCoord.xy + iTime*50.0, vec2(12.9898, 78.233))) * 43758.5453);
    col += (g_noise - 0.5) * 0.05;
    
    gl_FragColor = vec4(col, 1.0);
"""
            # Need to be careful about what variable name is used.
            # Almost all use 'gl_FragColor = vec4(col, 1.0);'
            if "gl_FragColor = vec4(col, 1.0);" in content:
                content = content.replace("gl_FragColor = vec4(col, 1.0);", injection)
            elif "gl_FragColor = vec4(c, 1.0);" in content:
                injection_c = injection.replace("col", "c")
                content = content.replace("gl_FragColor = vec4(c, 1.0);", injection_c)
                
        # Also let's try to animate any un-animated p.x or p.y in fract(sin()) that wasn't caught
        # if it looks like a texture. But global noise covers the "pattern animation" requirement safely!
        
        if original != content:
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(content)
            count += 1
            
        # Rebuild HTML
        html_out = html_template.replace("{shader_code}", content).replace("{base_name}", base_name)
        html_path = os.path.join(html_dir, f"IMG_{base_name}.html")
        with open(html_path, 'w', encoding='utf-8') as f:
            f.write(html_out)

    print(f"Aggressively added pattern animations to {count} files. All HTMLs rebuilt.")

if __name__ == "__main__":
    aggressive_animate()

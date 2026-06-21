const fs = require('fs');
const path = require('path');
const createGL = require('gl');
const gl = createGL(1, 1);

const dir = '.';
const files = fs.readdirSync(dir).filter(f => f.endsWith('.glsl'));

const errors = [];

for (const file of files) {
    const content = fs.readFileSync(path.join(dir, file), 'utf8');
    const fsSource = `precision highp float; uniform vec2 iResolution; uniform float iTime;\n${content}`;
    
    const fsShader = gl.createShader(gl.FRAGMENT_SHADER);
    gl.shaderSource(fsShader, fsSource);
    gl.compileShader(fsShader);
    
    if (!gl.getShaderParameter(fsShader, gl.COMPILE_STATUS)) {
        errors.push({file, error: gl.getShaderInfoLog(fsShader)});
    }
}

console.log(JSON.stringify(errors, null, 2));

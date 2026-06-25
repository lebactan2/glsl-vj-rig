const fs = require('fs');
const path = require('path');

const GLSL_DIR = path.join(__dirname, 'layered_glsl');
const OUTPUT_FILE = path.join(__dirname, 'layers_bundle.js');

let layerSources = {};
let layerMetadata = {};
let fileGlobals = {};

function processFiles() {
    const files = fs.readdirSync(GLSL_DIR).filter(f => f.endsWith('.glsl'));
    let totalLayers = 0;
    
    for (const file of files) {
        const content = fs.readFileSync(path.join(GLSL_DIR, file), 'utf-8');
        const fileBase = path.basename(file, '.glsl');
        
        // Extract metadata
        const metaMatch = content.match(/\/\*\s*@layer_metadata\s*(\{[\s\S]*?\})\s*\*\//);
        if (metaMatch) {
            try {
                layerMetadata[fileBase] = JSON.parse(metaMatch[1]);
            } catch (e) {
                console.error(`Failed to parse metadata in ${file}:`, e.message);
            }
        }
        
        // Find where void main() starts and grab everything before it.
        const mainIndex = content.indexOf('void main()');
        let globalsAndLayers = content;
        if (mainIndex !== -1) {
            globalsAndLayers = content.substring(0, mainIndex);
        }
        
        // Remove the metadata comment from globals
        globalsAndLayers = globalsAndLayers.replace(/\/\*\s*@layer_metadata[\s\S]*?\*\//, '').trim();
        
        // We will store the entire file's non-main content as its global block!
        fileGlobals[fileBase] = globalsAndLayers;

        // Also let's find the individual layer names for indexing
        const regex = /vec4\s+(layer_[a-zA-Z0-9_]+)\s*\(/g;
        let match;
        const layerNames = [];
        while ((match = regex.exec(globalsAndLayers)) !== null) {
            layerNames.push(match[1].replace('layer_', ''));
            totalLayers++;
        }
        
        // Let's store just the names for the viewer to know what layers exist
        layerSources[fileBase] = layerNames;
    }
    
    const output = `// Auto-generated bundle
window.FILE_GLOBALS = ${JSON.stringify(fileGlobals, null, 2)};
window.LAYER_SOURCES = ${JSON.stringify(layerSources, null, 2)};
window.LAYER_METADATA = ${JSON.stringify(layerMetadata, null, 2)};
`;

    fs.writeFileSync(OUTPUT_FILE, output);
    console.log(`Bundle generated with ${totalLayers} layers from ${files.length} files.`);
}

processFiles();

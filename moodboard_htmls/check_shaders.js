const fs = require('fs');
const path = require('path');

const dirs = [
    'd:\\GLSL bds\\moodboard_htmls\\trippy_ornaments_manual',
    'd:\\GLSL bds\\moodboard_htmls\\trippy_ornaments_manual_batch2'
];

dirs.forEach(dir => {
    fs.readdirSync(dir).forEach(file => {
        if (!file.endsWith('.html')) return;
        const p = path.join(dir, file);
        const content = fs.readFileSync(p, 'utf-8');
        
        const fragStart = content.indexOf('<script id="fragment-shader"');
        if (fragStart === -1) return;
        const fragEnd = content.indexOf('</script>', fragStart);
        const frag = content.slice(fragStart, fragEnd);
        
        const needsCircle = frag.includes('sdCircle(');
        const hasCircle = frag.includes('float sdCircle');
        
        const needsBox = frag.includes('sdBox(');
        const hasBox = frag.includes('float sdBox');
        
        const needsSegment = frag.includes('sdSegment(');
        const hasSegment = frag.includes('float sdSegment');
        
        const needsSmin = frag.includes('smin(');
        const hasSmin = frag.includes('float smin');
        
        let missing = [];
        if (needsCircle && !hasCircle) missing.push('sdCircle');
        if (needsBox && !hasBox) missing.push('sdBox');
        if (needsSegment && !hasSegment) missing.push('sdSegment');
        if (needsSmin && !hasSmin) missing.push('smin');
        
        if (missing.length > 0) {
            console.log(file, 'missing:', missing.join(', '));
        }
    });
});

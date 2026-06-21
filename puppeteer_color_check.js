const puppeteer = require('puppeteer-core');
const path = require('path');
const fs = require('fs');

(async () => {
    const browser = await puppeteer.launch({
        executablePath: 'C:\\Program Files (x86)\\Microsoft\\Edge\\Application\\msedge.exe',
        headless: true
    });
    const page = await browser.newPage();

    const dir = path.join(__dirname, 'moodboard_htmls');
    const files = fs.readdirSync(dir).filter(f => f.endsWith('.html') && f.startsWith('IMG_'));

    const simpleShaders = [];

    for (const file of files) {
        const fileUrl = 'file:///' + path.join(dir, file).replace(/\\/g, '/');
        try {
            await page.goto(fileUrl, {waitUntil: 'domcontentloaded'});
            await new Promise(r => setTimeout(r, 100)); // wait for a few frames
            
            const numColors = await page.evaluate(() => {
                const canvas = document.getElementById('glcanvas');
                if(!canvas) return -1;
                const gl = canvas.getContext('webgl');
                if(!gl) return -2;
                
                const pixels = new Uint8Array(gl.drawingBufferWidth * gl.drawingBufferHeight * 4);
                gl.readPixels(0, 0, gl.drawingBufferWidth, gl.drawingBufferHeight, gl.RGBA, gl.UNSIGNED_BYTE, pixels);
                
                const uniqueColors = new Set();
                let solidColor = true;
                const firstColor = `${pixels[0]},${pixels[1]},${pixels[2]}`;
                
                // Sample 1% of pixels to be fast
                for(let i=0; i<pixels.length; i+=400) {
                    const r = Math.round(pixels[i]/20)*20;
                    const g = Math.round(pixels[i+1]/20)*20;
                    const b = Math.round(pixels[i+2]/20)*20;
                    uniqueColors.add(`${r},${g},${b}`);
                }
                return uniqueColors.size;
            });
            
            if (numColors <= 15) {
                simpleShaders.push({file, numColors});
            }
        } catch (e) {
            console.log("Error loading", file);
        }
    }
    
    console.log("Simple shaders:", JSON.stringify(simpleShaders, null, 2));
    await browser.close();
})();

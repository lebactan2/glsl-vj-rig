const puppeteer = require('puppeteer-core');
const path = require('path');
const fs = require('fs');

(async () => {
    const browser = await puppeteer.launch({
        executablePath: 'C:\\Program Files (x86)\\Microsoft\\Edge\\Application\\msedge.exe',
        headless: true
    });
    const page = await browser.newPage();
    await page.setViewport({width: 100, height: 100});

    const dir = path.join(__dirname, 'moodboard_htmls');
    const files = fs.readdirSync(dir).filter(f => f.endsWith('.html') && f.startsWith('IMG_'));

    const simpleShaders = [];

    for (const file of files) {
        const fileUrl = 'file:///' + path.join(dir, file).replace(/\\/g, '/');
        try {
            await page.goto(fileUrl, {waitUntil: 'domcontentloaded'});
            await new Promise(r => setTimeout(r, 100)); 
            const base64 = await page.screenshot({encoding: 'base64'});
            
            const numColors = await page.evaluate(async (imgStr) => {
                const img = new Image();
                img.src = 'data:image/png;base64,' + imgStr;
                await new Promise(r => img.onload = r);
                const cvs = document.createElement('canvas');
                cvs.width = 100;
                cvs.height = 100;
                const ctx = cvs.getContext('2d');
                ctx.drawImage(img, 0, 0, 100, 100);
                const d = ctx.getImageData(0,0,100,100).data;
                const colors = new Set();
                for(let i=0; i<d.length; i+=4) {
                    const r = Math.round(d[i]/20)*20;
                    const g = Math.round(d[i+1]/20)*20;
                    const b = Math.round(d[i+2]/20)*20;
                    colors.add(`${r},${g},${b}`);
                }
                return colors.size;
            }, base64);
            
            if (numColors <= 8) {
                simpleShaders.push({file, numColors});
            }
        } catch (e) {
            console.log("Error loading", file);
        }
    }
    
    console.log("Results:\n" + JSON.stringify(simpleShaders, null, 2));
    await browser.close();
})();

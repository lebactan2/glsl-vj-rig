const puppeteer = require('puppeteer-core');
const path = require('path');
const fs = require('fs');

(async () => {
    const browser = await puppeteer.launch({
        executablePath: 'C:\\Program Files (x86)\\Microsoft\\Edge\\Application\\msedge.exe',
        headless: true
    });
    const page = await browser.newPage();
    
    const errors = {};
    page.on('console', msg => {
        if (msg.type() === 'error') {
            const text = msg.text();
            if (text.includes('FS Log') || text.includes('Link error') || text.includes('error')) {
                errors[global.currentFile] = errors[global.currentFile] || [];
                errors[global.currentFile].push(text);
            }
        }
    });

    const dir = path.join(__dirname, 'moodboard_htmls');
    const files = fs.readdirSync(dir).filter(f => f.endsWith('.html') && f.startsWith('IMG_'));

    for (const file of files) {
        global.currentFile = file;
        const fileUrl = 'file:///' + path.join(dir, file).replace(/\\/g, '/');
        try {
            await page.goto(fileUrl, {waitUntil: 'domcontentloaded'});
            await new Promise(r => setTimeout(r, 20)); 
        } catch (e) {
            console.log("Error loading", file, e);
        }
    }
    
    console.log(JSON.stringify(errors, null, 2));
    await browser.close();
})();

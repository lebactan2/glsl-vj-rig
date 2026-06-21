const puppeteer = require('puppeteer');
const fs = require('fs');
const path = require('path');

const htmlDir = path.join('d:', 'GLSL bds', 'moodboard_htmls', 'trippy_ornaments_all');
const screenshotDir = path.join('d:', 'GLSL bds', 'screenshots_backup');

if (!fs.existsSync(screenshotDir)) {
    fs.mkdirSync(screenshotDir);
}

const htmlFiles = fs.readdirSync(htmlDir).filter(file => file.endsWith('.html'));

async function takeScreenshots() {
    const browser = await puppeteer.launch({ headless: 'new' });
    const page = await browser.newPage();
    await page.setViewport({ width: 800, height: 600 });
    
    console.log(`Starting to capture ${htmlFiles.length} screenshots...`);
    
    for (let i = 0; i < htmlFiles.length; i++) {
        const file = htmlFiles[i];
        const fileUrl = `file:///${path.join(htmlDir, file).replace(/\\/g, '/')}`;
        const screenshotPath = path.join(screenshotDir, file.replace('.html', '.png'));
        
        try {
            await page.goto(fileUrl, { waitUntil: 'networkidle0', timeout: 5000 });
            await page.screenshot({ path: screenshotPath });
            if (i % 10 === 0) {
                console.log(`Captured ${i + 1}/${htmlFiles.length}...`);
            }
        } catch (e) {
            console.error(`Failed to capture ${file}:`, e.message);
        }
    }
    
    await browser.close();
    console.log('Finished capturing all screenshots.');
}

takeScreenshots();

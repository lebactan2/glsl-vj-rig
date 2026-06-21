// verify.js — boots the VJ rig in headless Chrome, loads every shader into a
// layer, and reports any WebGL compile/link failures. Also screenshots a mix.
const http = require("http");
const fs = require("fs");
const path = require("path");
const puppeteer = require("puppeteer");

const ROOT = path.resolve(__dirname, "..");
const MIME = { ".html": "text/html", ".js": "text/javascript", ".json": "application/json",
  ".glsl": "text/plain", ".jpg": "image/jpeg", ".jpeg": "image/jpeg", ".png": "image/png" };

function serve() {
  return new Promise((resolve) => {
    const srv = http.createServer((req, res) => {
      const url = decodeURIComponent(req.url.split("?")[0]);
      const fp = path.join(ROOT, url === "/" ? "/vj/index.html" : url);
      fs.readFile(fp, (err, data) => {
        if (err) { res.writeHead(404); res.end("404"); return; }
        res.writeHead(200, { "Content-Type": MIME[path.extname(fp)] || "application/octet-stream" });
        res.end(data);
      });
    });
    srv.listen(0, () => resolve({ srv, port: srv.address().port }));
  });
}

(async () => {
  const { srv, port } = await serve();
  const base = `http://localhost:${port}/vj/index.html`;
  const browser = await puppeteer.launch({ headless: "new", args: [
    "--use-gl=angle", "--use-angle=swiftshader", "--enable-unsafe-swiftshader",
    "--enable-webgl", "--ignore-gpu-blocklist", "--no-sandbox"] });
  const page = await browser.newPage();
  await page.setViewport({ width: 960, height: 600 });
  const consoleErrors = [];
  page.on("console", (m) => { const t = m.text(); if (m.type() === "error") consoleErrors.push(t); if (process.env.DEBUG) console.log("[page]", m.type(), t); });
  page.on("pageerror", (e) => { consoleErrors.push("PAGEERROR: " + e.message); if (process.env.DEBUG) console.log("[pageerror]", e.message); });
  page.on("requestfailed", (r) => { if (process.env.DEBUG) console.log("[reqfail]", r.url(), r.failure() && r.failure().errorText); });

  await page.goto(base, { waitUntil: "domcontentloaded" });
  try {
    await page.waitForFunction("window.__ready === true", { timeout: 15000 });
  } catch (e) {
    console.log("Boot did not complete. Console errors:");
    consoleErrors.forEach((x) => console.log("  " + x.slice(0, 200)));
    await browser.close(); srv.close(); process.exit(3);
  }

  // pull manifest from page and compile-test every shader by loading into layer 0
  const ids = await page.evaluate(() => Array.from(document.querySelectorAll("#sel0 option")).map(o => o.value));
  const results = await page.evaluate(async (ids) => {
    const out = { ok: [], fail: [] };
    // access the module-scoped mixer via a hook we expose
    for (const id of ids) {
      try {
        await window.__setLayer(0, id);
        const L = window.__mixer.layers[0];
        if (L.error) out.fail.push({ id, error: L.error.slice(0, 140) });
        else out.ok.push(id);
      } catch (e) { out.fail.push({ id, error: String(e).slice(0, 140) }); }
    }
    return out;
  }, ids);

  // screenshot a representative 2-layer mix
  await page.evaluate(async () => {
    const proc = window.__manifest.shaders.find(s => s.type === "procedural");
    const photo = window.__manifest.shaders.find(s => s.type === "photo");
    await window.__setLayer(0, proc.id);
    window.__mixer.layers[1].enabled = true;
    window.__mixer.layers[1].mode = 2; // screen
    window.__mixer.layers[1].opacity = 0.7;
    await window.__setLayer(1, photo.id);
  });
  await new Promise(r => setTimeout(r, 600));
  await page.screenshot({ path: path.join(__dirname, "verify_screenshot.png") });

  console.log(`\nShaders tested: ${results.ok.length + results.fail.length}`);
  console.log(`  OK:   ${results.ok.length}`);
  console.log(`  FAIL: ${results.fail.length}`);
  if (results.fail.length) {
    console.log("\n--- failures (first 15) ---");
    results.fail.slice(0, 15).forEach(f => console.log(`  ${f.id}: ${f.error}`));
  }
  if (consoleErrors.length) {
    console.log(`\nConsole errors (${consoleErrors.length}, first 5):`);
    consoleErrors.slice(0, 5).forEach(e => console.log("  " + e.slice(0, 160)));
  }
  console.log("\nScreenshot: vj/verify_screenshot.png");

  await browser.close();
  srv.close();
  process.exit(results.fail.length > 0 ? 1 : 0);
})().catch((e) => { console.error(e); process.exit(2); });

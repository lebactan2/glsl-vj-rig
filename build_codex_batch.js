const fs = require("fs");
const path = require("path");
const vm = require("vm");

const root = __dirname;
const sourcePath = path.join(root, "build_batch2_manual_shaders.js");
const outputDir = path.join(root, "moodboard_htmls", "codex");

function writeCodexIndex(scenes) {
  const cards = scenes.map((scene, index) => `
        <button class="item${index === 0 ? " active" : ""}" data-name="${scene.name}">
          <img src="../trippy_ornaments_all/assets/${scene.name}.jpg" alt="${scene.name} original">
          <span>
            <strong>${scene.name}</strong>
            <small>${scene.title}</small>
          </span>
        </button>`).join("");

  const sceneData = JSON.stringify(scenes.map((scene) => ({
    name: scene.name,
    title: scene.title,
    shader: `${scene.name}_manual.html`,
    photo: `../trippy_ornaments_all/assets/${scene.name}.jpg`,
  })), null, 2);

  const html = `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Codex Batch Preview</title>
  <style>
    :root {
      --bg: #101114;
      --panel: #181b20;
      --panel2: #20242b;
      --text: #f4f0e8;
      --muted: #aaa39a;
      --line: #333841;
      --accent: #f1c15d;
    }
    * { box-sizing: border-box; }
    body { margin: 0; min-height: 100vh; background: var(--bg); color: var(--text); font-family: Arial, sans-serif; display: grid; grid-template-columns: 330px 1fr; }
    aside { border-right: 1px solid var(--line); background: var(--panel); min-height: 100vh; display: flex; flex-direction: column; }
    header { padding: 18px; border-bottom: 1px solid var(--line); }
    h1 { margin: 0 0 6px; font-size: 20px; letter-spacing: 0; }
    p { margin: 0; color: var(--muted); font-size: 13px; line-height: 1.4; }
    input { width: 100%; margin-top: 14px; padding: 10px 11px; border: 1px solid var(--line); background: #0d0f12; color: var(--text); border-radius: 6px; outline: none; }
    .list { overflow: auto; padding: 10px; display: grid; gap: 8px; }
    .item { width: 100%; border: 1px solid transparent; background: transparent; color: var(--text); border-radius: 7px; padding: 7px; display: grid; grid-template-columns: 58px 1fr; gap: 10px; text-align: left; cursor: pointer; align-items: center; }
    .item:hover { background: #20242b; }
    .item.active { border-color: rgba(241,193,93,.65); background: #252516; }
    .item img { width: 58px; height: 44px; object-fit: cover; background: #000; border-radius: 4px; }
    .item strong { display: block; font-size: 13px; margin-bottom: 3px; }
    .item small { display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden; color: var(--muted); font-size: 11px; line-height: 1.25; }
    main { min-width: 0; display: grid; grid-template-rows: auto 1fr; min-height: 100vh; }
    .topbar { padding: 14px 18px; border-bottom: 1px solid var(--line); background: #121418; display: flex; justify-content: space-between; align-items: center; gap: 12px; }
    .title strong { display: block; font-size: 16px; }
    .title span { color: var(--muted); font-size: 13px; }
    .actions { display: flex; gap: 8px; }
    .actions a { color: #101114; background: var(--accent); text-decoration: none; padding: 8px 10px; border-radius: 5px; font-size: 12px; font-weight: 700; }
    .stage { min-height: 0; padding: 14px; display: grid; grid-template-columns: 1fr 1fr; gap: 14px; }
    .pane { min-width: 0; min-height: 0; background: #050506; border: 1px solid var(--line); border-radius: 7px; overflow: hidden; display: grid; grid-template-rows: auto 1fr; }
    .pane h2 { margin: 0; padding: 9px 11px; font-size: 12px; color: var(--muted); background: var(--panel2); border-bottom: 1px solid var(--line); text-transform: uppercase; letter-spacing: .04em; }
    .pane img, .pane iframe { width: 100%; height: 100%; border: 0; object-fit: contain; background: #000; display: block; }
    @media (max-width: 900px) {
      body { grid-template-columns: 1fr; }
      aside { min-height: 0; max-height: 42vh; border-right: 0; border-bottom: 1px solid var(--line); }
      .stage { grid-template-columns: 1fr; grid-auto-rows: 52vh; }
    }
  </style>
</head>
<body>
  <aside>
    <header>
      <h1>Codex Batch</h1>
      <p>Detailed procedural GLSL interpretations with source-photo comparison.</p>
      <input id="search" placeholder="Search image or subject">
    </header>
    <div class="list" id="list">${cards}
    </div>
  </aside>
  <main>
    <div class="topbar">
      <div class="title"><strong id="name"></strong><span id="desc"></span></div>
      <div class="actions"><a id="openShader" href="#">Open Shader</a><a id="openPhoto" href="#">Open Photo</a></div>
    </div>
    <section class="stage">
      <article class="pane"><h2>Original Photo</h2><img id="photo" alt=""></article>
      <article class="pane"><h2>Generated GLSL</h2><iframe id="shader" title="GLSL preview"></iframe></article>
    </section>
  </main>
  <script>
    const scenes = ${sceneData};
    const list = document.getElementById("list");
    const search = document.getElementById("search");
    const nameEl = document.getElementById("name");
    const descEl = document.getElementById("desc");
    const photo = document.getElementById("photo");
    const shader = document.getElementById("shader");
    const openShader = document.getElementById("openShader");
    const openPhoto = document.getElementById("openPhoto");

    function select(scene) {
      document.querySelectorAll(".item").forEach((item) => item.classList.toggle("active", item.dataset.name === scene.name));
      nameEl.textContent = scene.name;
      descEl.textContent = scene.title;
      photo.src = scene.photo;
      photo.alt = scene.name + " original";
      shader.src = scene.shader;
      openShader.href = scene.shader;
      openPhoto.href = scene.photo;
    }

    list.addEventListener("click", (event) => {
      const button = event.target.closest(".item");
      if (!button) return;
      const scene = scenes.find((item) => item.name === button.dataset.name);
      if (scene) select(scene);
    });

    search.addEventListener("input", () => {
      const q = search.value.toLowerCase();
      document.querySelectorAll(".item").forEach((item) => {
        const scene = scenes.find((entry) => entry.name === item.dataset.name);
        item.style.display = !scene || scene.name.toLowerCase().includes(q) || scene.title.toLowerCase().includes(q) ? "grid" : "none";
      });
    });

    select(scenes[0]);
  </script>
</body>
</html>
`;

  fs.writeFileSync(path.join(outputDir, "index.html"), html, "utf8");
}

const source = fs.readFileSync(sourcePath, "utf8")
  .replace(/const outDir = path\.join\(root, "moodboard_htmls", "trippy_ornaments_manual"\);/, 'const outDir = path.join(root, "moodboard_htmls", "codex");')
  .replace(/let index = fs\.readFileSync\(indexPath, "utf8"\);[\s\S]*?console\.log\(`Generated \$\{scenes\.length\} Batch 2 manual shaders\.`\);/, `writeCodexIndex(scenes);
console.log(\`Generated \${scenes.length} Codex shader previews.\`);`);
vm.runInNewContext(source, {
  require,
  console,
  __dirname: root,
  writeCodexIndex,
});




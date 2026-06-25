import os
import json
from pathlib import Path

ROOT = Path('d:/GLSL bds')
SKIP_DIRS = {'.git', 'node_modules', '__pycache__', 'layered_glsl', 'trippy_ornaments_all', 'trippy_ornaments_3_001'}
SKIP_FILES = {'index.html', 'boilerplate.html', 'layer_search.html'}

def get_category(path_parts):
    if 'claude' in path_parts: 
        return 'Claude made'
    if 'codex' in path_parts: 
        return 'Codex made'
    return 'Antigravity'

def find_image(name_stem):
    base_name = name_stem.replace('_manual', '')
    locs = [
        ROOT / 'moodboard_htmls' / 'assets' / f"{base_name}.jpg",
        ROOT / 'moodboard_htmls' / 'trippy_ornaments_all' / 'assets' / f"{base_name}.jpg",
        ROOT / f"{base_name}.jpg",
        ROOT / f"{base_name}.png"
    ]
    for loc in locs:
        if loc.exists():
            return loc.relative_to(ROOT).as_posix()
    return ""

def main():
    unified_index_path = ROOT / 'unified_search_index.json'
    unified_index = {}
    if unified_index_path.exists():
        with open(unified_index_path, 'r', encoding='utf-8') as f:
            try:
                unified_index = json.load(f)
            except:
                pass

    layered_dir = ROOT / 'layered_glsl'
    layer_meta = {}
    if layered_dir.exists():
        import re
        for glsl_file in layered_dir.glob('*.glsl'):
            try:
                content = glsl_file.read_text(encoding='utf-8')
                match = re.search(r'/\*\s*@layer_metadata\s*(\{.*?\})\s*\*/', content, re.DOTALL)
                if match:
                    meta = json.loads(match.group(1))
                    key = glsl_file.stem.replace('_manual', '').replace('IMG_', '')
                    layers = []
                    for layer in meta.get('layers', []):
                        layers.append({
                            'name': layer.get('name', ''),
                            'keywords': [k.lower() for k in layer.get('keywords', [])]
                        })
                    layer_meta[key] = layers
            except:
                pass

    files_data = []
    
    for p in ROOT.rglob('*.html'):
        if any(part.startswith('.') and part != '.html' for part in p.parts): continue
        if any(skip in p.parts for skip in SKIP_DIRS): continue
        if p.name in SKIP_FILES: continue
            
        cat = get_category(p.parts)
        rel_path = p.relative_to(ROOT).as_posix()
        img_path = find_image(p.stem)
        
        # Look up tags
        key = p.stem.replace('_manual', '')
        key_no_img = key.replace('IMG_', '')
        tags = unified_index.get(key, [])
        layers = layer_meta.get(key_no_img, [])
        
        files_data.append({
            'name': p.stem,
            'path': rel_path,
            'batch': cat,
            'img_path': img_path,
            'tags': tags,
            'layers': layers
        })

    # Sort files_data by name
    files_data.sort(key=lambda x: (x['batch'], x['name']))

    html_content = """<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Global Shader Showcase Dashboard</title>
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;600;800&display=swap" rel="stylesheet">
    <style>
        :root {
            --bg-dark: #0f172a;
            --bg-panel: rgba(30, 41, 59, 0.7);
            --accent: #38bdf8;
            --accent-glow: rgba(56, 189, 248, 0.4);
            --text-main: #f8fafc;
            --text-muted: #94a3b8;
            --border: rgba(255, 255, 255, 0.1);
        }

        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
            font-family: 'Outfit', sans-serif;
        }

        body {
            background-color: var(--bg-dark);
            background-image:
                radial-gradient(at 0% 0%, hsla(253, 16%, 7%, 1) 0, transparent 50%),
                radial-gradient(at 50% 0%, hsla(225, 39%, 30%, 0.2) 0, transparent 50%),
                radial-gradient(at 100% 0%, hsla(339, 49%, 30%, 0.2) 0, transparent 50%);
            color: var(--text-main);
            height: 100vh;
            display: flex;
            overflow: hidden;
        }

        /* Sidebar */
        .sidebar {
            width: 320px;
            background: var(--bg-panel);
            backdrop-filter: blur(16px);
            -webkit-backdrop-filter: blur(16px);
            border-right: 1px solid var(--border);
            display: flex;
            flex-direction: column;
            z-index: 10;
            box-shadow: 5px 0 25px rgba(0, 0, 0, 0.5);
        }

        .sidebar-header {
            padding: 30px 20px;
            border-bottom: 1px solid var(--border);
            background: linear-gradient(180deg, rgba(255, 255, 255, 0.05) 0%, transparent 100%);
        }

        .sidebar-header h1 {
            font-size: 24px;
            font-weight: 800;
            background: linear-gradient(to right, #38bdf8, #818cf8);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            letter-spacing: -0.5px;
            margin-bottom: 8px;
        }

        .sidebar-header p {
            color: var(--text-muted);
            font-size: 14px;
            font-weight: 300;
        }

        #searchInput {
            width: 100%;
            padding: 10px 12px;
            margin-top: 15px;
            background: rgba(0, 0, 0, 0.2);
            border: 1px solid var(--border);
            border-radius: 8px;
            color: var(--text-main);
            outline: none;
            font-size: 14px;
            transition: all 0.3s ease;
        }

        #searchInput:focus {
            border-color: var(--accent);
            box-shadow: 0 0 10px var(--accent-glow);
            background: rgba(0, 0, 0, 0.4);
        }

        .custom-row {
            display: flex;
            gap: 8px;
            margin-top: 12px;
        }

        .custom-row button {
            flex: 1;
            padding: 9px;
            background: rgba(56, 189, 248, 0.12);
            border: 1px solid var(--accent-glow);
            color: var(--accent);
            border-radius: 8px;
            cursor: pointer;
            font-size: 13px;
            font-weight: 600;
            transition: all 0.2s ease;
        }

        .custom-row button:hover {
            background: rgba(56, 189, 248, 0.25);
        }

        .hint-keys {
            margin-top: 10px;
            color: var(--text-muted);
            font-size: 11px;
        }

        .item-list {
            flex: 1;
            overflow-y: auto;
            padding: 15px;
        }

        /* Scrollbar */
        .item-list::-webkit-scrollbar {
            width: 6px;
        }

        .item-list::-webkit-scrollbar-track {
            background: transparent;
        }

        .item-list::-webkit-scrollbar-thumb {
            background: rgba(255, 255, 255, 0.2);
            border-radius: 10px;
        }

        .item {
            padding: 14px 20px;
            margin-bottom: 8px;
            border-radius: 12px;
            cursor: pointer;
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            border: 1px solid transparent;
            font-weight: 400;
            display: flex;
            align-items: center;
            justify-content: space-between;
        }

        .item:hover {
            background: rgba(255, 255, 255, 0.05);
            transform: translateX(4px);
        }

        .item.active {
            background: rgba(56, 189, 248, 0.15);
            border: 1px solid var(--accent-glow);
            color: var(--accent);
            font-weight: 600;
            box-shadow: 0 4px 15px var(--accent-glow);
        }

        .item-content {
            display: flex;
            flex-direction: column;
            gap: 4px;
        }

        .item-layers {
            font-size: 0.75rem;
            display: flex;
            flex-wrap: wrap;
            gap: 4px;
            margin-top: 4px;
        }

        .layer-badge {
            background: rgba(255, 255, 255, 0.1);
            padding: 2px 6px;
            border-radius: 8px;
            font-weight: 400;
        }

        .layer-badge.highlight {
            background: rgba(56, 189, 248, 0.2);
            color: #38bdf8;
            border: 1px solid rgba(56, 189, 248, 0.4);
        }

        /* Main Content */
        .main-content {
            flex: 1;
            display: flex;
            flex-direction: column;
            padding: 30px;
            gap: 20px;
            position: relative;
        }

        .header {
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .header h2 {
            font-weight: 600;
            font-size: 28px;
            letter-spacing: -0.5px;
            text-shadow: 0 2px 10px rgba(0, 0, 0, 0.5);
        }

        .panels-container {
            display: flex;
            flex: 1;
            gap: 30px;
            min-height: 0;
        }

        .panel {
            flex: 1;
            background: rgba(15, 23, 42, 0.6);
            border: 1px solid var(--border);
            border-radius: 20px;
            overflow: hidden;
            display: flex;
            flex-direction: column;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.5);
            backdrop-filter: blur(10px);
            position: relative;
            transition: transform 0.4s ease, box-shadow 0.4s ease;
        }

        .panel:hover {
            transform: translateY(-5px);
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.6);
        }

        .panel-header {
            background: rgba(255, 255, 255, 0.03);
            padding: 15px 25px;
            border-bottom: 1px solid var(--border);
            font-size: 14px;
            font-weight: 600;
            color: var(--text-muted);
            text-transform: uppercase;
            letter-spacing: 1px;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .panel-header::before {
            content: '';
            display: block;
            width: 8px;
            height: 8px;
            border-radius: 50%;
            background: var(--accent);
            box-shadow: 0 0 10px var(--accent);
        }

        .panel-content {
            flex: 1;
            position: relative;
            background: #000;
            overflow: hidden;
        }

        img.preview,
        iframe.preview {
            width: 100%;
            height: 100%;
            object-fit: contain;
            border: none;
            transition: opacity 0.5s ease;
        }

        /* Loading Overlay */
        .loader {
            position: absolute;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            width: 40px;
            height: 40px;
            border: 3px solid rgba(255, 255, 255, 0.1);
            border-top-color: var(--accent);
            border-radius: 50%;
            animation: spin 1s linear infinite;
            display: none;
            z-index: 5;
        }

        .loading .loader {
            display: block;
        }

        .loading .preview {
            opacity: 0.3;
        }

        @keyframes spin {
            to {
                transform: translate(-50%, -50%) rotate(360deg);
            }
        }
    </style>
</head>

<body>

    <div class="sidebar">
        <div class="sidebar-header">
            <h1>Global Shader Directory</h1>
            <p id="statsLabel">0 Files</p>
            <input type="text" id="searchInput" placeholder="Search name or content (e.g. forest, arrow)...">
            <select id="batchFilter" style="width: 100%; padding: 10px 12px; margin-top: 10px; background: rgba(0, 0, 0, 0.2); border: 1px solid var(--border); border-radius: 8px; color: var(--text-main); outline: none; font-size: 14px; transition: all 0.3s ease;">
                <option value="all" style="background: var(--bg-dark); color: var(--text-main);">All Batches</option>
                <option value="claude made" style="background: var(--bg-dark); color: var(--text-main);">Claude made</option>
                <option value="codex made" style="background: var(--bg-dark); color: var(--text-main);">Codex made</option>
                <option value="antigravity" style="background: var(--bg-dark); color: var(--text-main);">Antigravity</option>
            </select>
            <div class="custom-row">
                <button id="openShaderBtn">📂 Open shader</button>
                <button id="openImageBtn">🖼 Open image</button>
            </div>
            <div class="hint-keys">↑ / ↓ cycle visuals · buttons open the selected file's folder (local) or GitHub page (online)</div>
        </div>
        <div class="item-list" id="itemList">
            <!-- Items generated by JS -->
        </div>
    </div>

    <div class="main-content">
        <div class="header">
            <h2 id="mainTitle">Select a shader to preview</h2>
        </div>

        <div class="panels-container">
            <div class="panel" id="photoPanel">
                <div class="panel-header">Original Photo</div>
                <div class="panel-content" id="imgContainer">
                    <div class="loader"></div>
                    <img id="imgView" class="preview" src="" alt="Original Photo" style="display: none;" onerror="this.style.display='none'">
                </div>
            </div>

            <div class="panel">
                <div class="panel-header">Procedural Shader</div>
                <div class="panel-content" id="htmlContainer">
                    <div class="loader"></div>
                    <iframe id="htmlView" class="preview" src="" style="display: none;"></iframe>
                </div>
            </div>
        </div>
    </div>

    <script>
        const ALL_FILES = """ + json.dumps(files_data) + """;

        const itemList = document.getElementById('itemList');
        const imgView = document.getElementById('imgView');
        const htmlView = document.getElementById('htmlView');
        const mainTitle = document.getElementById('mainTitle');
        const imgContainer = document.getElementById('imgContainer');
        const htmlContainer = document.getElementById('htmlContainer');
        const searchInput = document.getElementById('searchInput');
        const photoPanel = document.getElementById('photoPanel');
        
        document.getElementById('statsLabel').textContent = ALL_FILES.length + " Total Files";

        let activeItem = null;
        let currentFile = null;

        function createItem(file) {
            const div = document.createElement('div');
            div.className = 'item';
            
            const layersDiv = document.createElement('div');
            layersDiv.className = 'item-layers';
            if (file.layers && file.layers.length > 0) {
                file.layers.forEach(layer => {
                    const badge = document.createElement('span');
                    badge.className = 'layer-badge';
                    badge.innerText = '👁 ' + layer.name;
                    badge.title = "Click to isolate and visualize this layer";
                    badge.onclick = (e) => {
                        e.stopPropagation();
                        selectItem(div, file, layer.name);
                    };
                    layersDiv.appendChild(badge);
                });
            } else if (file.tags && file.tags.length > 0) {
                const displayTags = file.tags.slice(0, 6);
                displayTags.forEach(tag => {
                    const badge = document.createElement('span');
                    badge.className = 'layer-badge';
                    badge.style.background = 'rgba(255,255,255,0.05)';
                    badge.style.border = '1px dashed rgba(255,255,255,0.2)';
                    badge.innerText = '🔍 ' + tag;
                    badge.title = "Click to filter directory by this keyword";
                    badge.onclick = (e) => {
                        e.stopPropagation();
                        searchInput.value = tag;
                        filterList();
                    };
                    layersDiv.appendChild(badge);
                });
                if (file.tags.length > 6) {
                    const extra = document.createElement('span');
                    extra.className = 'layer-badge';
                    extra.style.background = 'transparent';
                    extra.innerText = '+' + (file.tags.length - 6);
                    layersDiv.appendChild(extra);
                }
            }

            div.innerHTML = `
                <div class="item-content">
                    <span class="item-title">${file.name} <span style="font-size: 0.8em; color: var(--text-muted);">(${file.batch})</span></span>
                </div>
                <span>→</span>
            `;
            div.querySelector('.item-content').appendChild(layersDiv);
            div.onclick = () => selectItem(div, file);
            itemList.appendChild(div);
        }

        ALL_FILES.forEach(file => createItem(file));

        function selectItem(element, file, targetLayer = null) {
            if (activeItem) activeItem.classList.remove('active');
            activeItem = element;
            activeItem.classList.add('active');
            currentFile = file;

            let title = file.name + ' (' + file.batch + ')';
            if (targetLayer) {
                title += ' - Layer: ' + targetLayer;
                htmlView.src = 'layer_viewer.html?glsl=' + encodeURIComponent(file.name) + '&layer=' + encodeURIComponent(targetLayer);
            } else {
                htmlView.src = file.path;
            }
            mainTitle.textContent = title;

            imgContainer.classList.add('loading');
            htmlContainer.classList.add('loading');
            htmlView.style.display = 'block';

            if (file.img_path) {
                photoPanel.style.display = 'flex';
                imgView.style.display = 'block';
                imgView.src = file.img_path;
            } else {
                photoPanel.style.display = 'none';
                imgContainer.classList.remove('loading');
            }
        }

        imgView.onload = () => imgContainer.classList.remove('loading');
        htmlView.onload = () => htmlContainer.classList.remove('loading');

        const batchFilter = document.getElementById('batchFilter');

        function filterList() {
            const tokens = searchInput.value.toLowerCase().split(/\s+/).filter(Boolean);
            const batchVal = batchFilter.value.toLowerCase();
            const items = itemList.getElementsByClassName('item');
            for (let i = 0; i < items.length; i++) {
                const item = items[i];
                const file = ALL_FILES[i];
                
                const name = file.name.toLowerCase();
                const fileBatch = (file.batch || "").toLowerCase();
                
                let hay = name;
                if (file.tags) {
                    hay += ' ' + file.tags.join(' ');
                }

                let match = tokens.length === 0 || tokens.every(t => hay.includes(t));
                if (batchVal !== 'all' && fileBatch !== batchVal) {
                    match = false;
                }
                
                item.style.display = match ? 'flex' : 'none';

                // Highlight matching badges
                const layersDiv = item.querySelector('.item-layers');
                if (layersDiv && match) {
                    const badges = layersDiv.getElementsByClassName('layer-badge');
                    if (file.layers && file.layers.length > 0) {
                        for(let j=0; j<badges.length; j++) {
                            const badge = badges[j];
                            const layer = file.layers[j];
                            if (layer) {
                                const isMatch = tokens.length > 0 && layer.keywords.some(k => tokens.some(t => k.toLowerCase().includes(t)));
                                badge.classList.toggle('highlight', isMatch);
                            }
                        }
                    } else if (file.tags) {
                        for(let j=0; j<badges.length; j++) {
                            const badge = badges[j];
                            if (!badge.innerText.startsWith('+')) {
                                const tag = badge.innerText.replace('🔍 ', '').toLowerCase();
                                const isMatch = tokens.length > 0 && tokens.some(t => tag.includes(t));
                                badge.classList.toggle('highlight', isMatch);
                            }
                        }
                    }
                }
            }
        }

        searchInput.addEventListener('input', filterList);
        batchFilter.addEventListener('change', filterList);

        // --- Up / Down to cycle through the visible (filtered) list ---
        function visibleItems() {
            return [...itemList.getElementsByClassName('item')].filter(it => it.style.display !== 'none');
        }
        document.addEventListener('keydown', (e) => {
            if (e.key !== 'ArrowUp' && e.key !== 'ArrowDown') return;
            const tag = (document.activeElement && document.activeElement.tagName) || '';
            if (/INPUT|TEXTAREA|SELECT/.test(tag)) return; // don't hijack the search box
            const items = visibleItems();
            if (!items.length) return;
            e.preventDefault();
            let idx = items.indexOf(activeItem); // -1 when a custom shader is showing
            idx = (idx + (e.key === 'ArrowDown' ? 1 : -1) + items.length) % items.length;
            items[idx].click();
            items[idx].scrollIntoView({ block: 'nearest' });
        });

        // --- Open the selected file's containing folder (local) or GitHub page (online) ---
        const GITHUB_REPO = 'https://github.com/lebactan2/glsl-vj-rig';
        const isOnline = () => location.hostname.endsWith('github.io') || /\.(app|dev|com|net|io)$/.test(location.hostname);

        function openLocation(fileSrc, kind) {
            if (!fileSrc) { alert('Select an item first.'); return; }
            const u = new URL(fileSrc, location.href);
            if (isOnline()) {
                const parts = u.pathname.split('/').filter(Boolean);
                if (parts.length && parts[0] === 'glsl-vj-rig') parts.shift();
                parts.pop();
                window.open(`${GITHUB_REPO}/tree/main/${parts.join('/')}`, '_blank');
            } else {
                u.pathname = u.pathname.replace(/[^/]*$/, '');
                u.search = ''; u.hash = '';
                window.open(u.href, '_blank');
            }
        }

        document.getElementById('openShaderBtn').onclick = () =>
            openLocation(currentFile ? currentFile.path : null, 'shader');
        document.getElementById('openImageBtn').onclick = () =>
            openLocation(currentFile && currentFile.img_path ? currentFile.img_path : null, 'image');

        const firstItem = itemList.querySelector('.item');
        if (firstItem) {
            firstItem.click();
        }
    </script>
</body>
</html>
"""
    
    out_path = ROOT / 'index.html'
    with open(out_path, 'w', encoding='utf-8') as f:
        f.write(html_content)
        
    print(f"Successfully generated dashboard index at {out_path}")

if __name__ == '__main__':
    main()

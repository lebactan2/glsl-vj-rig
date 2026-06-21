import os
import json

ASSETS_DIR = r"d:\GLSL bds\moodboard_htmls\assets"
OUTPUT_HTML = r"d:\GLSL bds\moodboard_htmls\index.html"

images = [f for f in sorted(os.listdir(ASSETS_DIR)) if f.lower().endswith('.jpg')]
basenames = [os.path.splitext(f)[0] for f in images]

html_template = """<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Shader Showcase Dashboard</title>
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
                radial-gradient(at 0% 0%, hsla(253,16%,7%,1) 0, transparent 50%), 
                radial-gradient(at 50% 0%, hsla(225,39%,30%,0.2) 0, transparent 50%), 
                radial-gradient(at 100% 0%, hsla(339,49%,30%,0.2) 0, transparent 50%);
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
            box-shadow: 5px 0 25px rgba(0,0,0,0.5);
        }
        
        .sidebar-header {
            padding: 30px 20px;
            border-bottom: 1px solid var(--border);
            background: linear-gradient(180deg, rgba(255,255,255,0.05) 0%, transparent 100%);
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
            background: rgba(0,0,0,0.2);
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
            background: rgba(0,0,0,0.4);
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
            background: rgba(255,255,255,0.2);
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
            background: rgba(255,255,255,0.05);
            transform: translateX(4px);
        }
        
        .item.active {
            background: rgba(56, 189, 248, 0.15);
            border: 1px solid var(--accent-glow);
            color: var(--accent);
            font-weight: 600;
            box-shadow: 0 4px 15px var(--accent-glow);
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
            text-shadow: 0 2px 10px rgba(0,0,0,0.5);
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
            box-shadow: 0 10px 30px rgba(0,0,0,0.5);
            backdrop-filter: blur(10px);
            position: relative;
            transition: transform 0.4s ease, box-shadow 0.4s ease;
        }
        
        .panel:hover {
            transform: translateY(-5px);
            box-shadow: 0 20px 40px rgba(0,0,0,0.6);
        }
        
        .panel-header {
            background: rgba(255,255,255,0.03);
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
        
        img.preview, iframe.preview {
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
            border: 3px solid rgba(255,255,255,0.1);
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
            to { transform: translate(-50%, -50%) rotate(360deg); }
        }

    </style>
</head>
<body>

    <div class="sidebar">
        <div class="sidebar-header">
            <h1>Shader Showcase</h1>
            <p>117 Procedural Conversions</p>
            <input type="text" id="searchInput" placeholder="Search by image name...">
        </div>
        <div class="item-list" id="itemList">
            <!-- Items generated by JS -->
        </div>
    </div>
    
    <div class="main-content">
        <div class="header">
            <h2 id="mainTitle">Select an image to preview</h2>
        </div>
        
        <div class="panels-container">
            <div class="panel">
                <div class="panel-header">Original Photo</div>
                <div class="panel-content" id="imgContainer">
                    <div class="loader"></div>
                    <img id="imgView" class="preview" src="" alt="Original Photo" style="display: none;">
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
        const basenames = {json_data};
        const itemList = document.getElementById('itemList');
        const imgView = document.getElementById('imgView');
        const htmlView = document.getElementById('htmlView');
        const mainTitle = document.getElementById('mainTitle');
        const imgContainer = document.getElementById('imgContainer');
        const htmlContainer = document.getElementById('htmlContainer');
        const searchInput = document.getElementById('searchInput');
        
        let activeItem = null;

        basenames.forEach(name => {
            const div = document.createElement('div');
            div.className = 'item';
            div.innerHTML = `<span>${name}</span> <span>→</span>`;
            div.onclick = () => selectItem(div, name);
            itemList.appendChild(div);
        });
        
        function selectItem(element, name) {
            if(activeItem) activeItem.classList.remove('active');
            activeItem = element;
            activeItem.classList.add('active');
            
            mainTitle.textContent = name;
            
            imgContainer.classList.add('loading');
            htmlContainer.classList.add('loading');
            
            imgView.style.display = 'block';
            htmlView.style.display = 'block';
            
            imgView.src = `assets/${name}.jpg`;
            htmlView.src = `${name}.html`;
        }
        
        imgView.onload = () => imgContainer.classList.remove('loading');
        htmlView.onload = () => htmlContainer.classList.remove('loading');
        
        searchInput.addEventListener('input', (e) => {
            const query = e.target.value.toLowerCase();
            const items = itemList.getElementsByClassName('item');
            for(let item of items) {
                const text = item.querySelector('span').textContent.toLowerCase();
                if(text.includes(query)) {
                    item.style.display = 'flex';
                } else {
                    item.style.display = 'none';
                }
            }
        });
        
        if(itemList.firstChild) {
            itemList.firstChild.click();
        }
    </script>
</body>
</html>
"""

html_content = html_template.replace('{json_data}', json.dumps(basenames))

with open(OUTPUT_HTML, 'w', encoding='utf-8') as f:
    f.write(html_content)

print(f"UI Dashboard generated at: {OUTPUT_HTML}")

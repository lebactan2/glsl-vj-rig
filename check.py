import os
from pathlib import Path
import json

ROOT = Path('d:/GLSL bds')
unified_index_path = ROOT / 'unified_search_index.json'

with open(unified_index_path, 'r', encoding='utf-8') as f:
    unified_index = json.load(f)

empty_files = []
no_shader = []
empty_shader = []

for p in ROOT.rglob('*.html'):
    key = p.stem.replace('_manual', '')
    if key not in unified_index:
        continue
        
    try:
        content = p.read_text(encoding='utf-8')
        if len(content.strip()) < 50:
            empty_files.append(p.as_posix())
        elif 'type="x-shader/x-fragment"' not in content and "type='x-shader/x-fragment'" not in content:
            no_shader.append(p.as_posix())
        else:
            # Check if shader content is practically empty
            import re
            match = re.search(r'<script[^>]*type="x-shader/x-fragment"[^>]*>(.*?)</script>', content, re.DOTALL)
            if not match or len(match.group(1).strip()) < 20:
                empty_shader.append(p.as_posix())
    except Exception as e:
        empty_files.append(p.as_posix())

print(f'Empty files: {len(empty_files)}')
for e in empty_files[:5]: print(e)
print(f'No shader files: {len(no_shader)}')
for n in no_shader[:5]: print(n)
print(f'Empty shader code: {len(empty_shader)}')
for n in empty_shader[:5]: print(n)

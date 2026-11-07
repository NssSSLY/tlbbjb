"""Produce a read-only inventory of archived rules, task links and direct settings."""
from pathlib import Path
import csv
import json

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / 'artifacts/original-rule-inventory-2026-10-27.tsv'

def read(path):
    return json.loads((ROOT / path).read_text(encoding='utf-8-sig'))

index = read('scripts/original-library/index.json')
catalog = read('design/task-catalog.json')['tasks']
manifest = read('scripts/legacy/manifest.json')['tasks']

def safe(value):
    return str(value or '').replace('\t', ' ').replace('\r', ' ').replace('\n', ' ')

OUT.parent.mkdir(parents=True, exist_ok=True)
with OUT.open('w', encoding='utf-8-sig', newline='') as f:
    writer = csv.writer(f, delimiter='\t', lineterminator='\n')
    writer.writerow(['token', '分类', '原模块', '来源', '关联任务', '状态', '直接配置项', '字面依赖', '静态引用全局'])
    for module in index['modules'] + index.get('custom_sources', []):
        token = module['token']
        matches = [t for t in catalog if token in t.get('original_library_tokens', [])]
        declared = [t for t in manifest if t.get('original_token') == token or
                    (t.get('original_chunk_sha256') == module.get('original_sha256') and t.get('original_bytecode')) or
                    (module.get('format') == 'source' and t.get('original_sha256') == module.get('original_sha256'))]
        state = '原文件空壳' if module.get('known_empty_stub') else ('已有适配入口，待实测' if declared else '已入库，待宿主与任务适配')
        fields = [f"{x.get('section', '')}/{x.get('key', '')} ({x.get('reader', '')})" for x in module.get('direct_settings', [])]
        row = [token, module.get('group'), module.get('name'), module.get('source'),
               ', '.join(t['name'] for t in matches), state, '; '.join(fields),
               '; '.join(module.get('literal_modules', [])), '; '.join(module.get('globals', []))]
        writer.writerow([safe(x) for x in row])
print(f'原规则清单已生成：{OUT}（直接配置与字面依赖仅为静态识别结果）')

"""Read-only audit of supplied scripts, PE metadata and interface documentation."""
from pathlib import Path
import collections, hashlib, importlib.util, json, re, sys

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / '满天星/天龙助手'
OUT = ROOT / 'artifacts/reference-tlzz'
OUT.mkdir(parents=True, exist_ok=True)
sys.path.insert(0, str(ROOT / '.tools/pythonpkgs'))
spec = importlib.util.spec_from_file_location('reference_pe', ROOT / 'tools/analyze-reference-pack.py')
pe = importlib.util.module_from_spec(spec)
spec.loader.exec_module(pe)

def sha(path):
    with path.open('rb') as stream:
        return hashlib.file_digest(stream, 'sha256').hexdigest()

def decode(raw):
    for encoding in ('utf-8-sig', 'gb18030'):
        try:
            return raw.decode(encoding), encoding
        except UnicodeError:
            pass
    raise ValueError('Unsupported script encoding')

def write(path, value):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(value, ensure_ascii=False, indent=2)+'\n', encoding='utf-8')

files = sorted(p for p in SOURCE.rglob('*') if p.is_file())
assert len(files) <= 2000 and sum(p.stat().st_size for p in files) <= 256*1024*1024
assert not any(p.is_symlink() or p.is_junction() for p in SOURCE.rglob('*'))
inventory = [{'path': p.relative_to(SOURCE).as_posix(), 'bytes': p.stat().st_size, 'sha256': sha(p)} for p in files]
scripts = []
for p in sorted((SOURCE/'script').rglob('*.lua')):
    raw = p.read_bytes()
    assert len(raw) <= 1024*1024
    text, encoding = decode(raw)
    relative = p.relative_to(SOURCE).as_posix()
    dest = OUT / 'decoded' / p.relative_to(SOURCE/'script')
    dest.parent.mkdir(parents=True, exist_ok=True)
    dest.write_text(text.replace('\r\n','\n'), encoding='utf-8', newline='\n')
    calls = sorted(set(re.findall(r'([\w\u0080-\uffff.:]+)\s*\(', text)))
    scripts.append({'path': relative, 'bytes': len(raw), 'encoding': encoding, 'sha256': sha(p),
                    'decoded_path': dest.relative_to(ROOT).as_posix(), 'calls': calls,
                    'lua_bytecode': raw.startswith(b'\x1bLua')})
binaries = []
for p in files:
    if p.suffix.lower() not in ('.exe', '.dll') and p.name != 'main':
        continue
    binaries.append({'path': p.relative_to(SOURCE).as_posix(), 'sha256': sha(p), **pe.pe_summary(p)})

from pypdf import PdfReader
pdf = SOURCE/'接口文档.pdf'
reader = PdfReader(pdf)
texts = []
for index, page in enumerate(reader.pages, 1):
    texts.append(f'\n--- PAGE {index} ---\n'+(page.extract_text() or ''))
(OUT/'interface-document.txt').write_text('\n'.join(texts), encoding='utf-8')
duplicates = collections.defaultdict(list)
for entry in inventory:
    duplicates[entry['sha256']].append(entry['path'])
result = {'source_root': str(SOURCE), 'inventory': inventory, 'file_count': len(files),
    'bytes': sum(e['bytes'] for e in inventory), 'lua_source_count': len(scripts), 'scripts': scripts,
    'binaries': binaries, 'pdf_pages': len(reader.pages), 'pdf_sha256': sha(pdf),
    'duplicate_groups': [names for names in duplicates.values() if len(names)>1],
    'payloads_executed': 0, 'dlls_loaded': 0, 'private_data_parsed': False,
    'source_unchanged': all(sha(SOURCE/e['path'])==e['sha256'] for e in inventory)}
assert result['source_unchanged']
write(OUT/'analysis.json', result)
print(json.dumps({k: result[k] for k in ('file_count','bytes','lua_source_count','pdf_pages','source_unchanged','payloads_executed')}, ensure_ascii=False))
print(json.dumps({'binary_headers': [{'path':e['path'],'architecture':e.get('architecture'),
    'sections':[s['name'] for s in e.get('sections',[])], 'exports':e.get('exports',[])[:35],
    'lua_bytecode_signatures':e.get('lua_bytecode_signatures')} for e in binaries]},ensure_ascii=False))

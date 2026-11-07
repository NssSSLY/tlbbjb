"""Bounded, read-only file inspection. Does not load DLLs or access account files."""
import datetime as dt
import hashlib
import json
from pathlib import Path
import re
import struct

ROOT = Path(__file__).resolve().parents[1]
GAME = ROOT.parent
OUT = ROOT / 'artifacts' / 'adapter-research'
OUT.mkdir(parents=True, exist_ok=True)
terms = re.compile(r'(Get.*(Pos|Scene|Main|Self|Player)|MoveTo|Goto|GoTo|AutoRun|AutoMove|Plant|Sow|Farm|Lua.*(Reg|Func|Exec)|Script.*(Exec|Run|State)|AXP|Axp|PakFile)', re.I)

def digest(path):
    h = hashlib.sha256()
    with path.open('rb') as f:
        for block in iter(lambda: f.read(1024 * 1024), b''):
            h.update(block)
    return h.hexdigest()

def pe_sections(data):
    pe = struct.unpack_from('<I', data, 0x3c)[0]
    count = struct.unpack_from('<H', data, pe+6)[0]
    optional_size = struct.unpack_from('<H', data, pe+20)[0]
    optional = pe+24
    magic = struct.unpack_from('<H', data, optional)[0]
    base = struct.unpack_from('<Q' if magic == 0x20b else '<I', data,
                              optional+(24 if magic == 0x20b else 28))[0]
    result = []
    for i in range(count):
        off = optional+optional_size+i*40
        name = data[off:off+8].split(b'\0')[0].decode('ascii', errors='replace')
        vs, rva, size, raw = struct.unpack_from('<IIII', data, off+8)
        result.append(dict(name=name, rva=rva, virtual_size=vs, raw_offset=raw, raw_size=size))
    return base, result

modules = []
for name in ['Game.exe', 'tEngine.dll', 'UI_CEGUI.dll', 'LuaPlus.dll']:
    path = GAME/'Bin64'/name
    before = digest(path)
    data = path.read_bytes()
    base, sections = pe_sections(data)
    candidates = []
    for match in re.finditer(rb'[\x20-\x7e]{4,256}', data):
        value = match.group().decode('ascii')
        if terms.search(value):
            at = match.start()
            rva = next((s['rva']+at-s['raw_offset'] for s in sections
                        if s['raw_offset'] <= at < s['raw_offset']+s['raw_size']), None)
            candidates.append(dict(text=value, file_offset=hex(at), rva=hex(rva) if rva else None))
    modules.append(dict(path=str(path), bytes=len(data), sha256=before,
                        unchanged=before == digest(path), preferred_base=hex(base),
                        sections=sections, candidates=candidates))

archives = []
for name in ['Config.axp', 'Interface.axp']:
    path = GAME/'Data'/name
    with path.open('rb') as f:
        head = f.read(1024*1024)
        f.seek(max(0, path.stat().st_size-1024*1024))
        tail = f.read(1024*1024)
    names = []
    for block in [head, tail]:
        for match in re.finditer(rb'[\x20-\x7e]{5,256}', block):
            value = match.group().decode('ascii')
            if re.search(r'\.lua|script|\.xml|\.layout|\.ini|\.txt|AXP|pack', value, re.I):
                if value not in names and len(names) < 300:
                    names.append(value)
    archives.append(dict(path=str(path), bytes=path.stat().st_size,
                         sample_bytes=len(head)+len(tail), first_128_bytes=head[:128].hex(),
                         header_u32=list(struct.unpack('<16I', head[:64])), text_candidates=names,
                         extraction_attempted=False))

report = dict(captured_at=dt.datetime.now(dt.timezone(dt.timedelta(hours=8))).isoformat(),
              scope='Static local file candidates only; no confirmed runtime addresses or actions',
              modules=modules, archives=archives)
(OUT/'static-candidates.json').write_text(json.dumps(report, ensure_ascii=False, indent=2), encoding='utf-8')
print(json.dumps(dict(modules=[dict(path=x['path'], candidates=len(x['candidates']), unchanged=x['unchanged']) for x in modules],
                      archives=archives, report=str(OUT/'static-candidates.json')), ensure_ascii=False, indent=2))

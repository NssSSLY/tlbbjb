"""Read active, bounded text resources; retain relevant API call evidence only.

The 40-byte header / 12-byte block format was cross-checked with
https://gist.github.com/tieudattai/2e4294f8d03b9e58c8518762afbdff44
No downloaded code is executed. Archive paths are never used as output paths.
"""
from pathlib import Path
import datetime as dt
import hashlib
import json
import re
import struct

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT/'artifacts'/'adapter-research'
OUT.mkdir(exist_ok=True)
patterns = {
    'position': re.compile(r'GetMyPos(?:ition)?\s*\(|GetMainSceneID\s*\(|GetCurrentSceneName\s*\('),
    'movement': re.compile(r'AutoRun[Tt]oTarget(?:ExWithName|Ex)?\s*\(|MoveToCharacter\s*\('),
    'planting': re.compile(r'种植|播种|小麦|(?<!\w)(?:Plant|Sow|Agriculture)\w*\s*\(', re.I),
}
results = []
for name in ['Interface.axp', 'Config.axp']:
    path = ROOT.parent/'Data'/name
    stat_before = path.stat()
    source_bytes = 0
    candidate_count = 0
    matches = []
    with path.open('rb') as f:
        head = f.read(40)
        fields = struct.unpack('<10I', head)
        if fields[0] != 0x4b505841 or fields[5] > 100000:
            raise ValueError('Unexpected archive header')
        index_offset, count = fields[4:6]
        if index_offset + count*12 > stat_before.st_size:
            raise ValueError('Invalid index bounds')
        f.seek(index_offset)
        index_data = f.read(count*12)
        nodes = list(struct.iter_unpack('<3I', index_data))
        for i, (offset, size, flags) in enumerate(nodes):
            if not flags & 0x80000000 or not 0 < size <= 2*1024*1024:
                continue
            if offset < 40 or offset+size > stat_before.st_size:
                raise ValueError('Invalid block bounds')
            f.seek(offset)
            prefix = f.read(min(size, 256))
            # Lua/XML/text starts are selected conservatively. No encrypted data is decoded.
            if not (prefix.startswith((b'--', b'<?xml', b'function ', b'local ', b'\xef\xbb\xbf'))
                    or b'function ' in prefix or b' = ' in prefix):
                continue
            if source_bytes+size > 192*1024*1024:
                break
            f.seek(offset)
            data = f.read(size)
            source_bytes += size
            candidate_count += 1
            text = data.decode('gb18030', errors='replace')
            lines = text.splitlines()
            hits = []
            for number, line in enumerate(lines, 1):
                kinds = [k for k,p in patterns.items() if p.search(line)]
                if kinds:
                    hits.append(dict(line=number, kinds=kinds, text=line[:500],
                                     context=lines[max(0,number-3):min(len(lines),number+2)]))
            if hits:
                functions = re.findall(r'^\s*function\s+([\w.:]+)', text, re.M)
                matches.append(dict(block=i, offset=offset, bytes=size, flags=hex(flags),
                                    sha256=hashlib.sha256(data).hexdigest(),
                                    functions=functions[:10], hits=hits[:80]))
    stat_after = path.stat()
    results.append(dict(archive=str(path), archive_bytes=stat_before.st_size,
                        index_sha256=hashlib.sha256(head+index_data).hexdigest(),
                        metadata_unchanged=(stat_before.st_size,stat_before.st_mtime_ns)==
                                           (stat_after.st_size,stat_after.st_mtime_ns),
                        blocks=count, text_blocks_read=candidate_count,
                        text_bytes_read=source_bytes, matches=matches))
report = dict(captured_at=dt.datetime.now(dt.timezone(dt.timedelta(hours=8))).isoformat(),
              scope='Local read-only static call evidence; no runtime function invoked', archives=results)
(OUT/'resource-calls.json').write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding='utf-8')
for a in results:
    print(a['archive'], 'blocks',a['blocks'],'text',a['text_blocks_read'],
          'bytes',a['text_bytes_read'],'matched',len(a['matches']),flush=True)
    for k in patterns:
        sample=[dict(block=m['block'], functions=m['functions'][:2],
                     hits=[h['text'] for h in m['hits'] if k in h['kinds']][:4])
                for m in a['matches'] if any(k in h['kinds'] for h in m['hits'])]
        print(k, json.dumps(sample[:7],ensure_ascii=False),flush=True)
